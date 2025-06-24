// content.js
(function() {
  'use strict';

  // 檢查是否已經初始化
  if (window.gatExtensionLoaded) {
    return;
  }
  window.gatExtensionLoaded = true;

  // 配置
  const CONFIG = {
    buttonText: '🎵 轉錄',
    buttonId: 'gat-transcribe-btn',
    notificationId: 'gat-notification',
    progressId: 'gat-progress',
    buttonStyle: `
      position: fixed;
      top: 20px;
      right: 20px;
      z-index: 10000;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      border: none;
      padding: 12px 20px;
      border-radius: 25px;
      cursor: pointer;
      font-size: 14px;
      font-weight: 500;
      box-shadow: 0 4px 15px rgba(0,0,0,0.2);
      transition: all 0.3s ease;
      display: flex;
      align-items: center;
      gap: 8px;
    `,
    notificationStyle: `
      position: fixed;
      top: 80px;
      right: 20px;
      z-index: 10001;
      background: rgba(0,0,0,0.8);
      color: white;
      padding: 15px 20px;
      border-radius: 8px;
      font-size: 14px;
      max-width: 300px;
      box-shadow: 0 4px 20px rgba(0,0,0,0.3);
    `
  };

  // 建立轉錄按鈕
  function createTranscribeButton() {
    const button = document.createElement('button');
    button.id = CONFIG.buttonId;
    button.innerHTML = CONFIG.buttonText;
    button.style.cssText = CONFIG.buttonStyle;
    
    button.addEventListener('mouseenter', () => {
      button.style.transform = 'scale(1.05)';
      button.style.boxShadow = '0 6px 20px rgba(0,0,0,0.3)';
    });
    
    button.addEventListener('mouseleave', () => {
      button.style.transform = 'scale(1)';
      button.style.boxShadow = '0 4px 15px rgba(0,0,0,0.2)';
    });
    
    button.addEventListener('click', handleTranscribe);
    
    return button;
  }

  // 建立通知元素
  function createNotification(message, type = 'info') {
    const notification = document.createElement('div');
    notification.id = CONFIG.notificationId;
    notification.style.cssText = CONFIG.notificationStyle;
    
    if (type === 'error') {
      notification.style.background = 'rgba(244, 67, 54, 0.9)';
    } else if (type === 'success') {
      notification.style.background = 'rgba(76, 175, 80, 0.9)';
    }
    
    notification.innerHTML = message;
    
    return notification;
  }

  // 建立進度條
  function createProgressBar() {
    const progressContainer = document.createElement('div');
    progressContainer.id = CONFIG.progressId;
    progressContainer.style.cssText = `
      position: fixed;
      top: 140px;
      right: 20px;
      z-index: 10002;
      background: rgba(0,0,0,0.8);
      padding: 20px;
      border-radius: 8px;
      color: white;
      min-width: 250px;
    `;
    
    progressContainer.innerHTML = `
      <div style="display: flex; align-items: center; gap: 15px;">
        <div class="spinner"></div>
        <div>
          <div id="progress-text">處理中...</div>
          <div id="progress-bar">
            <div id="progress-fill" style="width: 0%"></div>
          </div>
        </div>
      </div>
    `;
    
    return progressContainer;
  }

  // 顯示通知
  function showNotification(message, type = 'info', duration = 3000) {
    // 移除現有通知
    const existingNotification = document.getElementById(CONFIG.notificationId);
    if (existingNotification) {
      existingNotification.remove();
    }
    
    const notification = createNotification(message, type);
    document.body.appendChild(notification);
    
    // 動畫效果
    notification.style.animation = 'slideIn 0.3s ease';
    
    setTimeout(() => {
      if (notification.parentNode) {
        notification.style.animation = 'slideOut 0.3s ease';
        setTimeout(() => {
          if (notification.parentNode) {
            notification.remove();
          }
        }, 300);
      }
    }, duration);
  }

  // 更新進度
  function updateProgress(text, percentage) {
    const progressContainer = document.getElementById(CONFIG.progressId);
    if (progressContainer) {
      const progressText = document.getElementById('progress-text');
      const progressFill = document.getElementById('progress-fill');
      
      if (progressText) progressText.textContent = text;
      if (progressFill) progressFill.style.width = percentage + '%';
    }
  }

  // 移除進度條
  function removeProgress() {
    const progressContainer = document.getElementById(CONFIG.progressId);
    if (progressContainer) {
      progressContainer.remove();
    }
  }

  // 獲取當前頁面的影片URL
  function getCurrentVideoUrl() {
    const url = window.location.href;
    
    // YouTube
    if (url.includes('youtube.com/watch')) {
      return url;
    }
    
    // Instagram
    if (url.includes('instagram.com/p/') || url.includes('instagram.com/reel/')) {
      return url;
    }
    
    // TikTok
    if (url.includes('tiktok.com/@') && url.includes('/video/')) {
      return url;
    }
    
    return null;
  }

  // 獲取影片標題
  function getVideoTitle() {
    let title = '';
    
    // YouTube
    if (window.location.href.includes('youtube.com')) {
      const titleElement = document.querySelector('h1.title yt-formatted-string') || 
                          document.querySelector('#title h1') ||
                          document.querySelector('h1[class*="title"]');
      if (titleElement) {
        title = titleElement.textContent.trim();
      }
    }
    
    // Instagram
    if (window.location.href.includes('instagram.com')) {
      const titleElement = document.querySelector('article h1') ||
                          document.querySelector('[data-testid="post-title"]');
      if (titleElement) {
        title = titleElement.textContent.trim();
      }
    }
    
    // TikTok
    if (window.location.href.includes('tiktok.com')) {
      const titleElement = document.querySelector('[data-e2e="browse-video-desc"]') ||
                          document.querySelector('.video-meta-caption');
      if (titleElement) {
        title = titleElement.textContent.trim();
      }
    }
    
    // 如果沒有找到標題，使用URL作為標題
    if (!title) {
      title = window.location.href.split('/').pop() || 'video';
    }
    
    // 清理標題，移除不合法的檔名字符
    title = title.replace(/[<>:"/\\|?*]/g, '').substring(0, 100);
    
    return title || 'untitled';
  }

  // 模擬音訊提取和轉錄過程
  async function simulateTranscription(videoUrl, videoTitle) {
    const progressContainer = createProgressBar();
    document.body.appendChild(progressContainer);
    
    try {
      // 步驟1: 分析影片
      updateProgress('分析影片資訊...', 10);
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      // 步驟2: 提取音訊
      updateProgress('提取音訊檔案...', 30);
      await new Promise(resolve => setTimeout(resolve, 2000));
      
      // 步驟3: 音訊轉換
      updateProgress('轉換音訊格式...', 50);
      await new Promise(resolve => setTimeout(resolve, 1500));
      
      // 步驟4: 語音轉錄
      updateProgress('進行語音辨識...', 70);
      await new Promise(resolve => setTimeout(resolve, 3000));
      
      // 步驟5: 生成文字檔
      updateProgress('生成轉錄文字...', 90);
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      // 步驟6: 完成
      updateProgress('處理完成！', 100);
      await new Promise(resolve => setTimeout(resolve, 500));
      
      // 生成模擬的轉錄內容
      const transcriptContent = generateMockTranscript(videoTitle, videoUrl);
      
      // 下載轉錄檔案
      downloadTranscript(transcriptContent, videoTitle);
      
      removeProgress();
      showNotification('✅ 轉錄完成！檔案已下載', 'success', 4000);
      
    } catch (error) {
      removeProgress();
      showNotification('❌ 轉錄失敗：' + error.message, 'error', 5000);
      console.error('Transcription error:', error);
    }
  }

  // 生成模擬轉錄內容
  function generateMockTranscript(title, url) {
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    
    // 根據不同平台生成不同的示範內容
    let sampleContent = '';
    
    if (url.includes('youtube.com')) {
      sampleContent = `大家好，歡迎來到今天的頻道。今天我們要來討論一個非常有趣的話題。

首先，我想跟大家分享一些重要的觀點。在現代社會中，科技的發展讓我們的生活變得更加便利。

特別是在音訊處理和語音辨識方面，我們看到了許多令人驚艷的進步。從最初的簡單語音命令，到現在能夠準確轉錄複雜對話的系統。

這項技術的應用範圍非常廣泛，包括：
- 會議記錄和筆記整理
- 多媒體內容的無障礙存取
- 語言學習和教育應用
- 客服和商業流程自動化

當然，我們也要考慮到隱私和資料安全的問題。在使用這些服務時，確保個人資訊的保護是非常重要的。

總結來說，語音轉錄技術為我們帶來了許多可能性，但同時也需要謹慎使用。

感謝大家的收看，如果喜歡這個內容，請記得按讚和訂閱。我們下次見！`;
    } else if (url.includes('instagram.com')) {
      sampleContent = `嗨大家！今天想跟你們分享一個超棒的發現。

最近我在研究音訊轉錄技術，發現這個領域真的進步得非常快。以前需要人工逐字輸入的工作，現在都可以透過AI來完成。

這對創作者來說真的是一大福音。想像一下，你錄製了一段精彩的影片，但要手動製作字幕會花費大量時間。現在有了自動轉錄，這個過程變得輕鬆多了。

而且不只是中文，現在的系統還支援多種語言，準確度也越來越高。

對於有聽力障礙的朋友們來說，這項技術讓他們能夠更好地享受多媒體內容。這真的是科技改善生活的最佳例子。

希望這個分享對你們有幫助！記得追蹤我獲得更多科技資訊喔！`;
    } else {
      sampleContent = `Hi everyone! 今天要跟大家分享一個很酷的技術話題。

語音轉錄技術現在真的太厲害了！不管是開會、上課，還是創作內容，都可以用到這個功能。

特別是對於內容創作者來說，能夠快速把影片音訊轉成文字，對於製作字幕和整理重點都超級有用的。

而且現在的AI技術越來越聰明，不只能辨識語音，還能理解上下文，甚至自動加標點符號。

對學生來說也很實用，可以把錄音的課程內容轉成筆記，復習的時候就方便多了。

科技真的讓我們的生活變得更有效率！大家有用過類似的工具嗎？歓迎在留言區分享你們的經驗！`;
    }
    
    return `音訊轉錄結果
========================

影片標題: ${title}
來源網址: ${url}
轉錄時間: ${new Date().toLocaleString('zh-TW')}
處理方式: Get Audio Text Chrome Extension

轉錄內容:
------------------------

${sampleContent}

------------------------
轉錄統計資訊:
- 總字數: ${sampleContent.length} 字
- 估計播放時間: ${Math.ceil(sampleContent.length / 300)} 分鐘
- 語言: 繁體中文 (檢測)
- 置信度: 95.2%

技術資訊:
------------------------
[示範版本說明]
此為 Get Audio Text Chrome Extension 的示範輸出。
實際使用時會整合真實的音訊提取和語音辨識 API，
提供準確的影片音訊轉錄結果。

支援功能:
✓ 多平台音訊提取 (YouTube, Instagram, TikTok)
✓ 高準確度語音辨識
✓ 自動標點符號
✓ 多語言支援
✓ 時間戳記標註
✓ 格式化輸出

========================
Generated by Get Audio Text Extension v1.0.0
處理完成時間: ${new Date().toLocaleString('zh-TW')}
`;
  }
  }

  // 下載轉錄文件
  function downloadTranscript(content, filename) {
    const blob = new Blob([content], { type: 'text/plain;charset=utf-8' });
    const url = URL.createObjectURL(blob);
    
    const a = document.createElement('a');
    a.href = url;
    a.download = `${filename}_transcript_${new Date().toISOString().slice(0, 10)}.txt`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
  }

  // 處理轉錄請求
  async function handleTranscribe() {
    const videoUrl = getCurrentVideoUrl();
    
    if (!videoUrl) {
      showNotification('❌ 無法識別當前頁面的影片', 'error');
      return;
    }
    
    const videoTitle = getVideoTitle();
    
    // 禁用按鈕避免重複點擊
    const button = document.getElementById(CONFIG.buttonId);
    if (button) {
      button.disabled = true;
      button.style.opacity = '0.6';
      button.innerHTML = '🔄 處理中...';
    }
    
    showNotification('🚀 開始音訊轉錄處理...', 'info');
    
    try {
      await simulateTranscription(videoUrl, videoTitle);
    } finally {
      // 重新啟用按鈕
      if (button) {
        button.disabled = false;
        button.style.opacity = '1';
        button.innerHTML = CONFIG.buttonText;
      }
    }
  }

  // 檢查是否為支援的網站
  function isSupportedSite() {
    const url = window.location.href;
    return url.includes('youtube.com') || 
           url.includes('instagram.com') || 
           url.includes('tiktok.com');
  }

  // 初始化擴展
  function initExtension() {
    if (!isSupportedSite()) {
      return;
    }
    
    // 等待頁面載入完成
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', initExtension);
      return;
    }
    
    // 移除現有按鈕（如果存在）
    const existingButton = document.getElementById(CONFIG.buttonId);
    if (existingButton) {
      existingButton.remove();
    }
    
    // 建立並添加轉錄按鈕
    const button = createTranscribeButton();
    document.body.appendChild(button);
    
    console.log('Get Audio Text Extension loaded on', window.location.hostname);
  }

  // 監聽URL變化（針對SPA網站）
  let currentUrl = window.location.href;
  const urlCheckInterval = setInterval(() => {
    if (window.location.href !== currentUrl) {
      currentUrl = window.location.href;
      setTimeout(initExtension, 1000); // 延遲1秒等待頁面更新
    }
  }, 1000);

  // 初始化
  initExtension();

  // 清理函數
  window.addEventListener('beforeunload', () => {
    clearInterval(urlCheckInterval);
  });

})();