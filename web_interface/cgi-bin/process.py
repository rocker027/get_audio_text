#!/usr/bin/python3
# -*- coding: utf-8 -*-

import os
import sys
import subprocess
import json
import tempfile
import shutil
import time
from pathlib import Path
from urllib.parse import parse_qs
from http.cookies import SimpleCookie
import traceback

# 自定義 CGI 錯誤追蹤
def enable_debug():
    def debug_handler(exc_type, exc_value, exc_traceback):
        print("Content-Type: text/html; charset=utf-8\r\n\r\n")
        print("<h1>CGI Script Error</h1>")
        print("<pre>")
        traceback.print_exception(exc_type, exc_value, exc_traceback)
        print("</pre>")
    sys.excepthook = debug_handler

enable_debug()

# 全局翻譯變量
current_translations = {}

def load_translations(lang='en'):
    """載入翻譯檔案"""
    global current_translations
    try:
        script_dir = Path(__file__).parent.parent
        translation_file = script_dir / 'static' / 'translations' / f'{lang}.json'
        
        if translation_file.exists():
            with open(translation_file, 'r', encoding='utf-8') as f:
                current_translations = json.load(f)
        else:
            # 如果翻譯檔案不存在，回退到英文
            if lang != 'en':
                load_translations('en')
    except Exception as e:
        # 如果載入失敗，使用空字典
        current_translations = {}

def t(key, fallback=''):
    """翻譯函數"""
    return current_translations.get(key, fallback)

# 簡單的表單解析類來替代 cgi.FieldStorage
class SimpleFieldStorage:
    def __init__(self):
        self.fields = {}
        self.files = {}
        
        # 獲取請求方法
        method = os.environ.get('REQUEST_METHOD', 'GET')
        
        if method == 'POST':
            # 獲取 Content-Type
            content_type = os.environ.get('CONTENT_TYPE', '')
            content_length = int(os.environ.get('CONTENT_LENGTH', 0))
            
            if content_length > 0:
                if 'multipart/form-data' in content_type:
                    self._parse_multipart(content_type, content_length)
                elif 'application/x-www-form-urlencoded' in content_type:
                    self._parse_urlencoded(content_length)
        elif method == 'GET':
            query_string = os.environ.get('QUERY_STRING', '')
            if query_string:
                self._parse_query_string(query_string)
    
    def _parse_query_string(self, query_string):
        parsed = parse_qs(query_string)
        for key, values in parsed.items():
            self.fields[key] = values[0] if values else ''
    
    def _parse_urlencoded(self, content_length):
        data = sys.stdin.read(content_length)
        self._parse_query_string(data)
    
    def _parse_multipart(self, content_type, content_length):
        # 簡化的 multipart 解析
        import re
        
        # 提取 boundary
        boundary_match = re.search(r'boundary=([^;]+)', content_type)
        if not boundary_match:
            return
        
        boundary = boundary_match.group(1).strip('"')
        data = sys.stdin.buffer.read(content_length)
        
        # 分割各個部分
        parts = data.split(f'--{boundary}'.encode())
        
        for part in parts[1:-1]:  # 跳過第一個和最後一個空部分
            if not part.strip():
                continue
                
            # 分離 headers 和 content
            try:
                header_end = part.find(b'\r\n\r\n')
                if header_end == -1:
                    continue
                    
                headers = part[:header_end].decode('utf-8')
                content = part[header_end + 4:]
                
                # 解析 Content-Disposition
                name_match = re.search(r'name="([^"]+)"', headers)
                if not name_match:
                    continue
                    
                field_name = name_match.group(1)
                
                # 檢查是否為檔案
                filename_match = re.search(r'filename="([^"]*)"', headers)
                if filename_match:
                    filename = filename_match.group(1)
                    if filename:  # 只有當檔名不為空時才算作檔案
                        self.files[field_name] = {
                            'filename': filename,
                            'content': content.rstrip(b'\r\n')
                        }
                    continue
                
                # 一般欄位
                self.fields[field_name] = content.decode('utf-8').rstrip('\r\n')
            except Exception as e:
                continue
    
    def getvalue(self, key, default=None):
        return self.fields.get(key, default)
    
    def __contains__(self, key):
        return key in self.fields or key in self.files
    
    def __getitem__(self, key):
        if key in self.fields:
            return type('Field', (), {'value': self.fields[key]})()
        elif key in self.files:
            file_data = self.files[key]
            field = type('FileField', (), {
                'filename': file_data['filename'],
                'file': type('File', (), {'read': lambda: file_data['content']})()
            })()
            return field
        else:
            raise KeyError(key)

# 設定路徑 - 改善路徑檢測邏輯
def get_script_paths():
    """智能檢測腳本路徑"""
    # CGI 腳本的絕對路徑
    cgi_script_path = Path(__file__).absolute()
    
    # 可能的腳本位置
    possible_locations = [
        # 從 web_interface/cgi-bin/ 上兩級到專案根目錄
        cgi_script_path.parent.parent.parent / "get_audio_text.sh",
        # 如果在不同的結構中
        cgi_script_path.parent.parent / "get_audio_text.sh",
        # 絕對路徑（如果環境變數有設定）
        Path(os.environ.get('GET_AUDIO_TEXT_SCRIPT', ''))
    ]
    
    for location in possible_locations:
        if location.exists() and location.is_file():
            return location, cgi_script_path.parent.parent / "uploads"
    
    # 如果都找不到，回傳預設路徑
    return cgi_script_path.parent.parent.parent / "get_audio_text.sh", cgi_script_path.parent.parent / "uploads"

GET_AUDIO_TEXT_SCRIPT, UPLOAD_DIR = get_script_paths()
UPLOAD_DIR.mkdir(exist_ok=True)

def send_status(message, progress=0):
    """發送狀態更新"""
    status = {
        "status": "processing",
        "message": message,
        "progress": progress
    }
    print(json.dumps(status, ensure_ascii=False))
    sys.stdout.flush()

def send_error(message):
    """發送錯誤訊息"""
    error = {
        "status": "error",
        "message": message
    }
    print(json.dumps(error, ensure_ascii=False))
    sys.stdout.flush()

def send_success(message, result_content=""):
    """發送成功訊息"""
    success = {
        "status": "success",
        "message": message,
        "result": result_content
    }
    print(json.dumps(success, ensure_ascii=False))
    sys.stdout.flush()

def get_transcript_summary(original_name, script_dir):
    """尋找並讀取總結檔案"""
    # 清理檔名 - 保持與腳本一致的清理邏輯
    clean_name = original_name
    for char in '<>:"/\\|?*':
        clean_name = clean_name.replace(char, '_')
    
    # 嘗試多種檔名格式
    possible_names = [
        clean_name,  # 完整檔名（包含副檔名）
        os.path.splitext(clean_name)[0],  # 去除副檔名
    ]
    
    # 實際的總結檔案儲存位置
    transcript_dirs = [
        Path("/Users/rocker/Downloads/AudioCapture/Transcripts"),  # 實際位置
        script_dir / "Transcripts",  # 相對位置
        script_dir,  # 腳本根目錄
    ]
    
    # 支援的副檔名
    extensions = [".md", ".txt"]
    
    # 嘗試所有可能的組合
    for base_name in possible_names:
        for transcript_dir in transcript_dirs:
            if not transcript_dir.exists():
                continue
                
            for ext in extensions:
                # 嘗試不同的檔名模式
                possible_files = [
                    transcript_dir / f"{base_name}_summary{ext}",
                    transcript_dir / f"{base_name}_summary.txt",  # 腳本生成的格式
                    transcript_dir / f"{base_name}_summary.md",   # 期望的格式
                ]
                
                for file_path in possible_files:
                    if file_path.exists():
                        try:
                            with open(file_path, 'r', encoding='utf-8') as f:
                                content = f.read().strip()
                                if content:  # 確保檔案不是空的
                                    return content
                        except Exception as e:
                            continue
    
    return ""

def execute_script(input_source, options, original_name=""):
    """執行音頻轉錄腳本"""
    try:
        # 建構命令
        cmd = [str(GET_AUDIO_TEXT_SCRIPT), input_source]
        
        # 添加選項
        if options.get('model'):
            cmd.extend(['--model', options['model']])
        if options.get('keep_audio'):
            cmd.append('--keep-audio')
        if options.get('no_transcribe'):
            cmd.append('--no-transcribe')
        if options.get('no_summary'):
            cmd.append('--no-summary')
        
        send_status(t('statusExecutingCommand', '執行命令: ') + ' '.join(cmd), 10)
        
        # 執行腳本
        process = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            universal_newlines=True,
            bufsize=1
        )
        
        progress = 20
        output_lines = []
        
        # 實時讀取輸出並清理 ANSI 顏色代碼
        import re
        ansi_escape = re.compile(r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])')
        
        for line in process.stdout:
            line = line.strip()
            if line:
                # 移除 ANSI 顏色代碼
                clean_line = ansi_escape.sub('', line)
                output_lines.append(clean_line)
                send_status(clean_line, min(progress, 90))
                progress += 2
        
        # 等待程序完成
        return_code = process.wait()
        
        if return_code == 0:
            send_status(t('statusScriptComplete', '腳本執行完成，正在讀取結果...'), 95)
            
            # 嘗試讀取總結檔案
            script_root_dir = GET_AUDIO_TEXT_SCRIPT.parent
            summary_content = get_transcript_summary(original_name or input_source, script_root_dir)
            
            if summary_content:
                send_success(t('statusProcessingComplete', '處理完成！'), summary_content)
            else:
                send_success(t('statusProcessingCompleteNoSummary', '處理完成！但未找到總結檔案。'), "")
        else:
            send_error(t('errorScriptExecutionFailed', '腳本執行失敗，返回碼: ') + str(return_code))
            
    except Exception as e:
        send_error(t('errorExecutionError', '執行錯誤: ') + str(e))

def main():
    # 設定 HTTP 標頭 - 使用 application/json 而不是 text/plain
    print("Content-Type: application/json; charset=utf-8")
    print("Cache-Control: no-cache")
    print("Access-Control-Allow-Origin: *")
    print("Access-Control-Allow-Methods: POST, GET, OPTIONS")
    print("Access-Control-Allow-Headers: Content-Type")
    print()
    
    try:
        # 解析表單數據
        form = SimpleFieldStorage()
        
        # 載入翻譯
        language = form.getvalue('language', 'en')
        load_translations(language)
        
        # 立即發送初始狀態
        send_status(t('statusStartProcessing', '開始處理請求...'), 0)
        send_status(t('statusParsingForm', '解析表單數據...'), 5)
        
        # 檢查腳本是否存在
        if not GET_AUDIO_TEXT_SCRIPT.exists():
            send_error(t('errorScriptNotFound', '找不到轉錄腳本: ') + str(GET_AUDIO_TEXT_SCRIPT))
            return
        
        # 確保腳本有執行權限
        os.chmod(GET_AUDIO_TEXT_SCRIPT, 0o755)
        send_status(t('statusScriptPermissionCheck', '腳本權限檢查完成'), 8)
        
        # 處理 URL 輸入
        if 'url' in form and form['url'].value.strip():
            url = form['url'].value.strip()
            send_status(t('statusProcessingURL', '處理 URL: ') + url, 5)
            
            options = {
                'model': form.getvalue('model', 'small'),
                'keep_audio': 'keep_audio' in form,
                'no_transcribe': 'no_transcribe' in form,
                'no_summary': 'no_summary' in form
            }
            
            execute_script(url, options, url)
            
        # 處理檔案上傳
        elif 'file' in form and form.files.get('file', {}).get('filename'):
            file_data = form.files['file']
            original_filename = file_data['filename']
            
            send_status(t('statusUploadingFile', '上傳檔案: ') + original_filename, 5)
            
            # 儲存上傳的檔案
            upload_path = UPLOAD_DIR / original_filename
            try:
                with open(upload_path, 'wb') as f:
                    f.write(file_data['content'])
                
                send_status(t('statusFileUploadComplete', '檔案上傳完成'), 10)
                
                options = {
                    'model': form.getvalue('model', 'small'),
                    'keep_audio': 'keep_audio' in form,
                    'no_transcribe': 'no_transcribe' in form,
                    'no_summary': 'no_summary' in form
                }
                
                execute_script(str(upload_path), options, original_filename)
                
            except Exception as e:
                send_error(t('errorFileUploadFailed', '檔案上傳失敗: ') + str(e))
            finally:
                # 清理上傳的檔案
                if upload_path.exists():
                    try:
                        upload_path.unlink()
                    except:
                        pass
        else:
            send_error(t('errorNoInputProvided', '請提供 URL 或上傳檔案'))
            
    except Exception as e:
        send_error(t('errorSystemError', '系統錯誤: ') + str(e))

if __name__ == "__main__":
    main()