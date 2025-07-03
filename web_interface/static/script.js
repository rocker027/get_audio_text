(() => {
    // 全局翻譯對象
    let currentTranslations = {};

    // 多語系功能
    async function fetchTranslations(lang) {
        try {
            const response = await fetch(`static/translations/${lang}.json`);
            if (!response.ok) {
                throw new Error(`Failed to load translations for ${lang}`);
            }
            return await response.json();
        } catch (error) {
            console.error(`Error loading translations for ${lang}:`, error);
            // Fallback to English if translation fails
            if (lang !== 'en') {
                return await fetchTranslations('en');
            }
            return {};
        }
    }

    function updateTranslations(translations) {
        document
            .querySelectorAll('[data-i18n]')
            .forEach((element) => {
                const key = element.getAttribute('data-i18n');
                if (translations[key]) {
                    element.textContent = translations[key];
                }
            });
    }

    async function setLanguage(lang) {
        try {
            const translations = await fetchTranslations(lang);
            currentTranslations = translations;
            updateTranslations(translations);
            document.querySelector('html').setAttribute('lang', lang);
            
            // Store language preference
            localStorage.setItem('preferred-language', lang);
            
            // Update dynamic content if elements exist
            const dropZone = document.getElementById('dropZone');
            if (dropZone && !dropZone.classList.contains('has-file')) {
                const dropContent = dropZone.querySelector('.drop-content');
                if (dropContent) {
                    dropContent.innerHTML = `
                        <div class="drop-icon">📄</div>
                        <p>${t('dropZoneText', '將檔案拖拉到此處')}</p>
                        <small>${t('dropZoneHint', '支援影片、音頻、逐字稿檔案')}</small>
                    `;
                }
            }
        } catch (error) {
            console.error('Error setting language:', error);
        }
    }

    // 翻譯函數
    function t(key, fallback = '') {
        return currentTranslations[key] || fallback;
    }

    // 主要功能
    document.addEventListener('DOMContentLoaded', function() {
        // 多語系初始化
        const languageSelect = document.getElementById('languageSelect');
        
        if (languageSelect) {
            languageSelect.addEventListener('change', function () {
                console.log("Selected language: " + this.value);
                const lang = this.value;
                setLanguage(lang);
            });
        }
        
        // Load saved language preference or default to English
        const savedLang = localStorage.getItem('preferred-language') || 'en';
        if (languageSelect) {
            languageSelect.value = savedLang;
        }
        setLanguage(savedLang);

        // DOM 元素
        const form = document.getElementById('transcriptionForm');
        const urlInput = document.getElementById('urlInput');
        const fileInput = document.getElementById('fileInput');
        const browseBtn = document.getElementById('browseBtn');
        const dropZone = document.getElementById('dropZone');
        const submitBtn = document.getElementById('submitBtn');
        const btnText = document.querySelector('.btn-text');
        const btnSpinner = document.querySelector('.btn-spinner');
        
        // 狀態區域
        const statusSection = document.getElementById('statusSection');
        const progressFill = document.getElementById('progressFill');
        const progressText = document.getElementById('progressText');
        const logOutput = document.getElementById('logOutput');
        
        // 結果區域
        const resultSection = document.getElementById('resultSection');
        const markdownPreview = document.getElementById('markdownPreview');
        const copyBtn = document.getElementById('copyBtn');
        
        let isProcessing = false;
        let currentResult = '';

        // 瀏覽檔案按鈕
        browseBtn.addEventListener('click', function(e) {
            e.preventDefault();
            fileInput.click();
        });

        // 檔案選擇變化
        fileInput.addEventListener('change', function() {
            if (this.files.length > 0) {
                updateDropZone(this.files[0]);
                urlInput.value = ''; // 清空 URL 輸入
            }
        });

        // 拖拉上傳功能
        ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
            dropZone.addEventListener(eventName, preventDefaults);
        });

        function preventDefaults(e) {
            e.preventDefault();
            e.stopPropagation();
        }

        ['dragenter', 'dragover'].forEach(eventName => {
            dropZone.addEventListener(eventName, highlight);
        });

        ['dragleave', 'drop'].forEach(eventName => {
            dropZone.addEventListener(eventName, unhighlight);
        });

        function highlight() {
            dropZone.classList.add('drag-over');
        }

        function unhighlight() {
            dropZone.classList.remove('drag-over');
        }

        dropZone.addEventListener('drop', handleDrop);

        function handleDrop(e) {
            const files = e.dataTransfer.files;
            if (files.length > 0) {
                fileInput.files = files;
                updateDropZone(files[0]);
                urlInput.value = ''; // 清空 URL 輸入
            }
        }

        function updateDropZone(file) {
            const dropContent = dropZone.querySelector('.drop-content');
            dropContent.innerHTML = `
                <div class="drop-icon">📁</div>
                <p><strong>${file.name}</strong></p>
                <small>${t('fileSizeLabel', '檔案大小:')} ${formatFileSize(file.size)}</small>
            `;
            dropZone.classList.add('has-file');
        }

        function formatFileSize(bytes) {
            if (bytes === 0) return '0 Bytes';
            const k = 1024;
            const sizes = ['Bytes', 'KB', 'MB', 'GB'];
            const i = Math.floor(Math.log(bytes) / Math.log(k));
            return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
        }

        // URL 輸入變化時清空檔案選擇
        urlInput.addEventListener('input', function() {
            if (this.value.trim()) {
                fileInput.value = '';
                resetDropZone();
            }
        });

        function resetDropZone() {
            const dropContent = dropZone.querySelector('.drop-content');
            dropContent.innerHTML = `
                <div class="drop-icon">📄</div>
                <p>${t('dropZoneText', '將檔案拖拉到此處')}</p>
                <small>${t('dropZoneHint', '支援影片、音頻、逐字稿檔案')}</small>
            `;
            dropZone.classList.remove('has-file');
        }

        // 表單提交
        form.addEventListener('submit', async function(e) {
            e.preventDefault();
            
            if (isProcessing) {
                return;
            }

            // 驗證輸入
            const hasUrl = urlInput.value.trim();
            const hasFile = fileInput.files.length > 0;
            
            if (!hasUrl && !hasFile) {
                alert(t('errorInputRequired', '請輸入 URL 或選擇檔案'));
                return;
            }

            isProcessing = true;
            updateUIState(true);
            
            try {
                await processForm();
            } catch (error) {
                console.error(t('errorProcessing', '處理錯誤:'), error);
                showError(t('errorProcessingOccurred', '處理過程中發生錯誤: ') + error.message);
            } finally {
                isProcessing = false;
                updateUIState(false);
            }
        });

        function updateUIState(processing) {
            if (processing) {
                btnText.style.display = 'none';
                btnSpinner.style.display = 'inline-block';
                submitBtn.disabled = true;
                statusSection.style.display = 'block';
                resultSection.style.display = 'none';
                logOutput.textContent = '';
            } else {
                btnText.style.display = 'inline';
                btnSpinner.style.display = 'none';
                submitBtn.disabled = false;
            }
        }

        async function processForm() {
            const formData = new FormData(form);
            
            // 加入當前語系資訊
            const currentLang = localStorage.getItem('preferred-language') || 'en';
            formData.append('language', currentLang);
            
            try {
                const response = await fetch('cgi-bin/process.py', {
                    method: 'POST',
                    body: formData,
                    headers: {
                        'Accept': 'application/json'
                    }
                });

                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }

                // 總是使用串流處理，因為我們的 CGI 腳本發送多行 JSON
                const reader = response.body.getReader();
                const decoder = new TextDecoder();
                let buffer = '';

                while (true) {
                    const { done, value } = await reader.read();
                    if (done) break;

                    // 將新數據添加到緩衝區
                    buffer += decoder.decode(value, { stream: true });
                    
                    // 按行分割處理
                    const lines = buffer.split('\n');
                    
                    // 保留最後一行未完成的數據
                    buffer = lines.pop() || '';
                    
                    for (const line of lines) {
                        const cleanLine = line.trim();
                        if (cleanLine) {
                            try {
                                // 移除 ANSI 顏色代碼
                                const cleanedLine = cleanLine.replace(/\u001b\[[0-9;]*m/g, '');
                                
                                // 嘗試解析為 JSON
                                const data = JSON.parse(cleanedLine);
                                handleStatusUpdate(data);
                            } catch (e) {
                                // 如果不是 JSON，檢查是否是有用的日誌信息
                                const logLine = cleanLine.replace(/\u001b\[[0-9;]*m/g, '');
                                if (logLine && !logLine.includes('Content-Type') && !logLine.includes('Cache-Control')) {
                                    appendLog(logLine);
                                }
                            }
                        }
                    }
                }
                
                // 處理最後剩餘的數據
                if (buffer.trim()) {
                    try {
                        const cleanedBuffer = buffer.trim().replace(/\u001b\[[0-9;]*m/g, '');
                        const data = JSON.parse(cleanedBuffer);
                        handleStatusUpdate(data);
                    } catch (e) {
                        // 最後的數據不是 JSON，作為日誌處理
                        const logLine = buffer.trim().replace(/\u001b\[[0-9;]*m/g, '');
                        if (logLine && !logLine.includes('Content-Type') && !logLine.includes('Cache-Control')) {
                            appendLog(logLine);
                        }
                    }
                }
            } catch (error) {
                console.error('請求錯誤:', error);
                showError('無法連接到服務器: ' + error.message);
            }
        }

        function handleStatusUpdate(data) {
            switch (data.status) {
                case 'processing':
                    updateProgress(data.progress || 0, data.message);
                    appendLog(data.message);
                    break;
                case 'success':
                    updateProgress(100, data.message);
                    appendLog(data.message);
                    showResult(data.result);
                    break;
                case 'error':
                    showError(data.message);
                    break;
            }
        }

        function updateProgress(progress, message) {
            progressFill.style.width = `${progress}%`;
            progressText.textContent = message;
        }

        function appendLog(message) {
            if (message) {
                logOutput.textContent += message + '\n';
                logOutput.scrollTop = logOutput.scrollHeight;
            }
        }

        function showError(message) {
            updateProgress(0, t('statusProcessingFailed', '處理失敗'));
            appendLog(`${t('errorPrefix', '錯誤: ')}${message}`);
            progressFill.style.backgroundColor = '#e74c3c';
        }

        function showResult(content) {
            if (content) {
                currentResult = content;
                resultSection.style.display = 'block';
                
                // 渲染 Markdown
                if (typeof marked !== 'undefined') {
                    markdownPreview.innerHTML = marked.parse(content);
                } else {
                    // 如果 marked.js 未載入，則顯示純文字
                    markdownPreview.innerHTML = `<pre>${content}</pre>`;
                }
                
                resultSection.scrollIntoView({ behavior: 'smooth' });
            } else {
                appendLog(t('statusCompleteNoSummary', '處理完成，但未產生總結內容'));
            }
        }

        // 複製功能
        copyBtn.addEventListener('click', async function() {
            if (!currentResult) {
                alert(t('errorNoContentToCopy', '沒有內容可複製'));
                return;
            }

            try {
                if (navigator.clipboard && window.isSecureContext) {
                    await navigator.clipboard.writeText(currentResult);
                    showCopySuccess();
                } else {
                    // 降級方案
                    fallbackCopyTextToClipboard(currentResult);
                }
            } catch (err) {
                console.error(t('errorCopyFailed', '複製失敗:'), err);
                alert(t('errorCopyFailedManual', '複製失敗，請手動選擇文字複製'));
            }
        });

        function fallbackCopyTextToClipboard(text) {
            const textArea = document.createElement('textarea');
            textArea.value = text;
            textArea.style.position = 'fixed';
            textArea.style.left = '-999999px';
            textArea.style.top = '-999999px';
            document.body.appendChild(textArea);
            textArea.focus();
            textArea.select();
            
            try {
                document.execCommand('copy');
                showCopySuccess();
            } catch (err) {
                console.error(t('errorCopyFallbackFailed', '降級複製失敗:'), err);
                alert(t('errorCopyFailedManual', '複製失敗，請手動選擇文字複製'));
            }
            
            document.body.removeChild(textArea);
        }

        function showCopySuccess() {
            const originalText = copyBtn.textContent;
            copyBtn.textContent = t('statusCopySuccess', '✅ 已複製');
            copyBtn.style.backgroundColor = '#27ae60';
            
            setTimeout(() => {
                copyBtn.textContent = originalText;
                copyBtn.style.backgroundColor = '';
            }, 2000);
        }
    });
})();