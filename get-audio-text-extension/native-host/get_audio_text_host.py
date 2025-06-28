#!/usr/bin/env python3
"""
Get Audio Text Native Messaging Host

此程序作為 Chrome 擴展與本地 get_audio_text.sh 腳本之間的橋接。
接收來自 Chrome 擴展的請求，調用本地腳本處理音訊轉錄。
"""

import json
import sys
import struct
import subprocess
import os
import tempfile
import threading
import time
from pathlib import Path

# 配置
SCRIPT_PATH = Path(__file__).parent.parent.parent / "get_audio_text.sh"
TIMEOUT = 300  # 5分鐘超時

def read_message():
    """從 Chrome 擴展讀取消息"""
    raw_length = sys.stdin.buffer.read(4)
    if not raw_length:
        return None
    
    message_length = struct.unpack('=I', raw_length)[0]
    message = sys.stdin.buffer.read(message_length).decode('utf-8')
    return json.loads(message)

def send_message(message):
    """發送消息給 Chrome 擴展"""
    encoded_message = json.dumps(message).encode('utf-8')
    encoded_length = struct.pack('=I', len(encoded_message))
    
    sys.stdout.buffer.write(encoded_length)
    sys.stdout.buffer.write(encoded_message)
    sys.stdout.buffer.flush()

def log_error(error_msg):
    """記錄錯誤到日誌檔案"""
    log_file = Path.home() / "get_audio_text_host.log"
    with open(log_file, "a", encoding="utf-8") as f:
        f.write(f"{time.strftime('%Y-%m-%d %H:%M:%S')} - ERROR: {error_msg}\n")

def check_dependencies():
    """檢查必要的依賴"""
    if not SCRIPT_PATH.exists():
        return False, f"找不到腳本：{SCRIPT_PATH}"
    
    if not os.access(SCRIPT_PATH, os.X_OK):
        return False, f"腳本沒有執行權限：{SCRIPT_PATH}"
    
    # 檢查必要工具
    tools = ["yt-dlp", "ffmpeg", "whisper"]
    missing = []
    
    for tool in tools:
        try:
            subprocess.run([tool, "--version"], 
                         capture_output=True, 
                         check=True, 
                         timeout=5)
        except (subprocess.CalledProcessError, FileNotFoundError, subprocess.TimeoutExpired):
            missing.append(tool)
    
    if missing:
        return False, f"缺少必要工具：{', '.join(missing)}"
    
    return True, "依賴檢查通過"

def process_audio_transcription(url, options=None):
    """處理音訊轉錄請求"""
    if options is None:
        options = {}
    
    try:
        # 檢查依賴
        deps_ok, deps_msg = check_dependencies()
        if not deps_ok:
            return {"success": False, "error": deps_msg}
        
        # 建立命令參數
        cmd = [str(SCRIPT_PATH), url]
        
        # 添加選項
        if options.get("no_transcribe"):
            cmd.append("-no-transcribe")
        if options.get("keep_audio"):
            cmd.append("-keep-audio")
        if options.get("open_folder"):
            cmd.append("-open-folder")
        
        # 發送進度更新
        send_message({
            "type": "progress",
            "stage": "starting",
            "message": "開始處理音訊轉錄...",
            "progress": 0
        })
        
        # 執行腳本
        process = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            bufsize=1,
            universal_newlines=True
        )
        
        # 模擬進度更新（因為原腳本沒有進度輸出）
        progress_stages = [
            (10, "downloading", "下載影片資訊..."),
            (30, "extracting", "提取音訊檔案..."),
            (50, "converting", "轉換音訊格式..."),
            (70, "transcribing", "進行語音辨識..."),
            (90, "finalizing", "生成轉錄檔案...")
        ]
        
        def send_progress():
            for progress, stage, message in progress_stages:
                if process.poll() is None:  # 進程仍在運行
                    send_message({
                        "type": "progress",
                        "stage": stage,
                        "message": message,
                        "progress": progress
                    })
                    time.sleep(2)  # 每2秒更新一次
                else:
                    break
        
        # 在背景執行進度更新
        progress_thread = threading.Thread(target=send_progress)
        progress_thread.daemon = True
        progress_thread.start()
        
        # 等待腳本完成
        try:
            stdout, stderr = process.communicate(timeout=TIMEOUT)
        except subprocess.TimeoutExpired:
            process.kill()
            return {"success": False, "error": f"處理超時（{TIMEOUT}秒）"}
        
        if process.returncode == 0:
            # 成功完成
            send_message({
                "type": "progress",
                "stage": "completed",
                "message": "轉錄完成！",
                "progress": 100
            })
            
            # 解析輸出，尋找轉錄檔案路徑
            transcript_file = None
            for line in stdout.split('\n'):
                if '轉錄檔案已保存' in line or 'transcript' in line.lower():
                    # 嘗試提取檔案路徑
                    parts = line.split()
                    for part in parts:
                        if part.endswith('.txt') and os.path.exists(part):
                            transcript_file = part
                            break
            
            result = {
                "success": True,
                "message": "音訊轉錄完成",
                "output": stdout,
                "transcript_file": transcript_file
            }
            
            # 如果找到轉錄檔案，讀取內容
            if transcript_file and os.path.exists(transcript_file):
                try:
                    with open(transcript_file, 'r', encoding='utf-8') as f:
                        result["transcript_content"] = f.read()
                except Exception as e:
                    log_error(f"讀取轉錄檔案失敗：{e}")
            
            return result
        else:
            # 執行失敗
            error_msg = stderr.strip() if stderr.strip() else "腳本執行失敗"
            log_error(f"腳本執行失敗：{error_msg}")
            return {"success": False, "error": error_msg, "output": stdout}
            
    except Exception as e:
        log_error(f"處理轉錄請求時發生異常：{e}")
        return {"success": False, "error": f"處理失敗：{str(e)}"}

def main():
    """主程序循環"""
    try:
        while True:
            message = read_message()
            if message is None:
                break
            
            if message.get("action") == "transcribe":
                url = message.get("url")
                options = message.get("options", {})
                
                if not url:
                    send_message({"success": False, "error": "缺少 URL 參數"})
                    continue

                # 驗證 URL 是否為有效的 URL 或檔案路徑
                if os.path.exists(url):
                    # 處理檔案路徑
                    result = process_audio_transcription(url, options)
                else:
                    # 處理轉錄請求
                    result = process_audio_transcription(url, options)
                send_message(result)
                
            elif message.get("action") == "check_dependencies":
                # 檢查依賴狀態
                deps_ok, deps_msg = check_dependencies()
                send_message({
                    "success": deps_ok,
                    "message": deps_msg,
                    "script_path": str(SCRIPT_PATH)
                })
                
            else:
                send_message({"success": False, "error": "未知的動作"})
                
    except Exception as e:
        log_error(f"主程序異常：{e}")
        send_message({"success": False, "error": f"主程序錯誤：{str(e)}"})

if __name__ == "__main__":
    main()