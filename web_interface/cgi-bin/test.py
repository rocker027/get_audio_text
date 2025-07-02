#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys
import os

# 先嘗試輸出基本調試信息
try:
    import cgi
    import cgitb
    import json
    from pathlib import Path
    
    # 啟用 CGI 錯誤追蹤
    cgitb.enable()
    HAS_MODULES = True
except Exception as e:
    HAS_MODULES = False
    IMPORT_ERROR = str(e)

def main():
    # 設定 HTTP 標頭
    print("Content-Type: application/json; charset=utf-8")
    print("Cache-Control: no-cache")
    print()
    
    if not HAS_MODULES:
        # 如果模組載入失敗，輸出錯誤信息
        error_response = {
            "status": "error",
            "message": f"模組載入失敗: {IMPORT_ERROR}",
            "python_executable": sys.executable,
            "python_version": sys.version
        }
        print(json.dumps(error_response, ensure_ascii=False, indent=2) if 'json' in sys.modules else str(error_response))
        return
    
    try:
        # 解析表單數據
        form = cgi.FieldStorage()
        
        # 收集環境信息
        script_dir = Path(__file__).parent.parent.parent
        get_audio_script = script_dir / "get_audio_text.sh"
        
        response = {
            "status": "success",
            "message": "CGI 測試成功",
            "debug_info": {
                "has_modules": HAS_MODULES,
                "python_version": sys.version,
                "python_executable": sys.executable,
                "current_working_directory": os.getcwd(),
                "script_file_path": str(Path(__file__).absolute()),
                "script_directory": str(script_dir.absolute()),
                "get_audio_script_path": str(get_audio_script.absolute()),
                "get_audio_script_exists": get_audio_script.exists(),
                "environment_variables": {
                    "REQUEST_METHOD": os.environ.get("REQUEST_METHOD", "N/A"),
                    "CONTENT_TYPE": os.environ.get("CONTENT_TYPE", "N/A"),
                    "QUERY_STRING": os.environ.get("QUERY_STRING", "N/A"),
                    "SERVER_SOFTWARE": os.environ.get("SERVER_SOFTWARE", "N/A"),
                    "PATH": os.environ.get("PATH", "N/A")[:200] + "..." if len(os.environ.get("PATH", "")) > 200 else os.environ.get("PATH", "N/A"),
                },
                "form_data": {key: form.getvalue(key) for key in form.keys()} if hasattr(form, 'keys') else "N/A"
            }
        }
        
        print(json.dumps(response, ensure_ascii=False, indent=2))
        
    except Exception as e:
        error_response = {
            "status": "error",
            "message": f"CGI 測試失敗: {str(e)}",
            "error_type": type(e).__name__,
            "python_executable": sys.executable,
            "python_version": sys.version
        }
        print(json.dumps(error_response, ensure_ascii=False, indent=2))

if __name__ == "__main__":
    main()