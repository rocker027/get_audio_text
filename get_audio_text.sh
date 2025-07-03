#!/bin/bash

# 載入多語言支援
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lang/i18n.sh"

# 初始化多語言支援
if ! init_i18n; then
    echo "錯誤: 無法初始化多語言支援" >&2
    exit 1
fi

# 顏色輸出
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# 設定檔路徑
CONFIG_FILE="$HOME/.get_audio_text_config"

# 載入設定檔
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
        echo -e "${GREEN}$(t MSG_STATUS_SUCCESS) $(t MSG_CONFIG_LOAD): $AUDIO_DIR${NC}"
        return 0
    else
        return 1
    fi
}

# 驗證目錄是否有效
validate_directory() {
    local dir_path="$1"
    
    # 展開波浪號
    dir_path="${dir_path/#\~/$HOME}"
    
    # 檢查是否為絕對路徑
    if [[ ! "$dir_path" = /* ]]; then
        echo -e "${RED}$(t MSG_STATUS_ERROR) $(t MSG_ABSOLUTE_PATH_REQUIRED)${NC}"
        return 1
    fi
    
    # 檢查父目錄是否存在
    local parent_dir=$(dirname "$dir_path")
    if [ ! -d "$parent_dir" ]; then
        echo -e "${RED}$(t MSG_STATUS_ERROR) $(t MSG_PARENT_DIR_NOT_EXIST): $parent_dir${NC}"
        return 1
    fi
    
    # 檢查是否可寫入
    if [ -d "$dir_path" ]; then
        if [ ! -w "$dir_path" ]; then
            echo -e "${RED}$(t MSG_STATUS_ERROR) $(t MSG_NO_WRITE_PERMISSION): $dir_path${NC}"
            return 1
        fi
    else
        # 目錄不存在，檢查是否可在父目錄建立
        if [ ! -w "$parent_dir" ]; then
            echo -e "${RED}$(t MSG_STATUS_ERROR) $(t MSG_CANNOT_CREATE_DIR): $parent_dir${NC}"
            return 1
        fi
    fi
    
    return 0
}

# 初次設定引導
initial_setup() {
    # 設定預設路徑
    local DEFAULT_PATH="$HOME/Downloads/AudioCapture"
    
    echo -e "${BLUE}🎵 $(t MSG_WELCOME)${NC}"
    echo -e "${BLUE}$(t MSG_SEPARATOR)${NC}"
    echo -e "${YELLOW}📁 $(t MSG_FIRST_SETUP)${NC}"
    echo ""
    echo -e "${GREEN}🎯 建議使用預設路徑: $DEFAULT_PATH${NC}"
    echo -e "${BLUE}💡 或選擇其他路徑範例:${NC}"
    echo "• $HOME/Documents/AudioTranscripts"
    echo "• $HOME/Desktop/Audio"
    echo ""
    
    while true; do
        echo -e "${YELLOW}請輸入音訊檔案下載目錄的完整路徑${NC}"
        echo -e "${BLUE}(直接按 Enter 使用預設路徑: $DEFAULT_PATH)${NC}"
        read -p "📁 路徑: " user_audio_dir
        
        # 檢查輸入是否為空，如果為空則使用預設路徑
        if [ -z "$user_audio_dir" ]; then
            user_audio_dir="$DEFAULT_PATH"
            echo -e "${GREEN}$(t MSG_STATUS_SUCCESS) $(t MSG_USE_DEFAULT_PATH): $user_audio_dir${NC}"
        fi
        
        # 驗證目錄
        if validate_directory "$user_audio_dir"; then
            # 展開波浪號
            user_audio_dir="${user_audio_dir/#\~/$HOME}"
            
            # 如果目錄不存在，詢問是否建立
            if [ ! -d "$user_audio_dir" ]; then
                echo ""
                echo -e "${YELLOW}$(t MSG_STATUS_WARNING)  $(t MSG_DIRECTORY_NOT_EXIST): $user_audio_dir${NC}"
                read -p "$(t MSG_CREATE_DIRECTORY) " -n 1 -r
                echo ""
                
                if [[ $REPLY =~ ^[Nn]$ ]]; then
                    echo -e "${BLUE}請重新輸入路徑${NC}"
                    echo ""
                    continue
                fi
                
                # 建立目錄
                if mkdir -p "$user_audio_dir"; then
                    echo -e "${GREEN}$(t MSG_STATUS_SUCCESS) $(t MSG_DIRECTORY_CREATED)${NC}"
                else
                    echo -e "${RED}$(t MSG_STATUS_ERROR) $(t MSG_DIRECTORY_CREATE_FAILED)${NC}"
                    echo ""
                    continue
                fi
            fi
            
            # 設定相關目錄
            AUDIO_DIR="$user_audio_dir"
            TRANSCRIPT_DIR="$AUDIO_DIR/Transcripts"
            WHISPER_MODEL_DIR="$AUDIO_DIR/WhisperModel"
            
            # 建立子目錄
            mkdir -p "$TRANSCRIPT_DIR"
            mkdir -p "$WHISPER_MODEL_DIR"
            
            # 儲存設定檔
            cat > "$CONFIG_FILE" << EOF
# get_audio_text 設定檔
AUDIO_DIR="$AUDIO_DIR"
TRANSCRIPT_DIR="$AUDIO_DIR/Transcripts"
WHISPER_MODEL_DIR="$AUDIO_DIR/WhisperModel"
EOF
            
            echo ""
            echo -e "${GREEN}🎉 $(t MSG_SETUP_COMPLETE)${NC}"
            echo -e "${BLUE}📁 $(t MSG_AUDIO_DIR): $AUDIO_DIR${NC}"
            echo -e "${BLUE}📄 $(t MSG_TRANSCRIPT_DIR): $TRANSCRIPT_DIR${NC}"
            echo -e "${BLUE}🤖 $(t MSG_WHISPER_MODEL_DIR): $WHISPER_MODEL_DIR${NC}"
            echo -e "${GREEN}💾 $(t MSG_CONFIG_SAVED): $CONFIG_FILE${NC}"
            echo ""
            break
        else
            echo ""
            echo -e "${BLUE}請重新輸入正確的路徑${NC}"
            echo ""
        fi
    done
}

# 預設值（如果設定檔載入失敗時使用）
AUDIO_DIR=""
TRANSCRIPT_DIR=""
WHISPER_MODEL_DIR=""
WHISPER_MODEL_NAME="small" # 預設模型，可被 --model 參數覆寫

# 檢查必要工具
check_dependencies() {
    local missing_tools=()

    if ! command -v yt-dlp &> /dev/null; then
        missing_tools+=("yt-dlp")
    fi

    if ! command -v ffmpeg &> /dev/null; then
        missing_tools+=("ffmpeg")
    fi

    # 檢查 whisper（支援多種安裝路徑）
    if ! command -v whisper &> /dev/null && [ ! -f "/Users/rocker/Library/Python/3.9/bin/whisper" ]; then
        missing_tools+=("whisper")
    fi

    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo -e "${RED}$(t MSG_STATUS_ERROR) $(t MSG_MISSING_TOOLS): ${missing_tools[*]}${NC}"
        echo -e "${YELLOW}$(t MSG_INSTALL_METHODS)${NC}"
        echo "brew install yt-dlp ffmpeg"
        echo "pip3 install openai-whisper"
        exit 1
    fi
}

# 檢查 Gemini CLI 是否可用
check_gemini_cli() {
    # 檢查常見的 gemini 命令
    if command -v gemini &> /dev/null; then
        echo -e "${GREEN}$(t MSG_STATUS_SUCCESS) $(t MSG_GEMINI_DETECTED)${NC}"
        return 0
    elif command -v google-generativeai &> /dev/null; then
        echo -e "${GREEN}$(t MSG_STATUS_SUCCESS) $(t MSG_GEMINI_DETECTED)${NC}"
        return 0
    else
        echo -e "${BLUE}$(t MSG_STATUS_INFO)  $(t MSG_GEMINI_NOT_DETECTED)${NC}"
        return 1
    fi
}


# 從字幕檔案（VTT/SRT）提取純文字內容
extract_text_from_subtitle() {
    local subtitle_file="$1"
    local output_file="$2"
    
    if [ ! -f "$subtitle_file" ]; then
        echo -e "${RED}❌ 字幕檔案不存在: $subtitle_file${NC}"
        return 1
    fi
    
    # 根據副檔名決定處理方式
    local ext="${subtitle_file##*.}"
    
    if [ "$ext" = "vtt" ]; then
        # 處理 VTT 格式
        grep -v "^WEBVTT$" "$subtitle_file" | \
        grep -v "^$" | \
        grep -v "^NOTE" | \
        grep -v " --> " | \
        sed 's/<[^>]*>//g' | \
        grep -v "^[0-9]*$" > "$output_file"
    elif [ "$ext" = "srt" ]; then
        # 處理 SRT 格式
        grep -v "^[0-9]*$" "$subtitle_file" | \
        grep -v " --> " | \
        grep -v "^$" | \
        sed 's/<[^>]*>//g' > "$output_file"
    else
        echo -e "${RED}❌ 不支援的字幕格式: $ext${NC}"
        return 1
    fi
    
    # 檢查提取結果
    if [ -s "$output_file" ]; then
        echo -e "${GREEN}✅ 文字內容提取完成${NC}"
        return 0
    else
        echo -e "${RED}❌ 文字內容提取失敗${NC}"
        rm -f "$output_file"
        return 1
    fi
}

# 檢測檔案類型
detect_file_type() {
    local file="$1"
    
    # 詳細的檔案存在性檢查
    if [ ! -f "$file" ]; then
        echo -e "${RED}❌ 檔案不存在: $file${NC}" >&2
        echo "nonexistent"
        return 1
    fi
    
    # 獲取副檔名並轉換為小寫
    local ext="${file##*.}"
    local ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
    
    echo -e "${BLUE}📋 檔案: $(basename "$file")${NC}" >&2
    echo -e "${BLUE}📋 副檔名: $ext_lower${NC}" >&2
    
    case "$ext_lower" in
        # 影片格式
        mp4|avi|mkv|mov|wmv|flv|webm|m4v|3gp|ogv)
            echo "video"
            ;;
        # 音訊格式  
        mp3|wav|flac|aac|ogg|m4a|wma|opus)
            echo "audio"
            ;;
        # 逐字稿格式
        txt|vtt|srt)
            echo "transcript"
            ;;
        # 未知格式
        *)
            echo -e "${YELLOW}⚠️  未知的檔案格式: $ext_lower${NC}" >&2
            echo "unknown"
            ;;
    esac
}

# 從影片檔案提取音訊
extract_audio_from_video() {
    local video_file="$1"
    local output_audio="$2"
    
    echo -e "${PURPLE}🎬 從影片檔案提取音訊...${NC}"
    echo -e "${BLUE}📹 影片檔案: $(basename "$video_file")${NC}"
    echo -e "${BLUE}🎵 輸出音訊: $(basename "$output_audio")${NC}"
    
    # 檢查 ffmpeg 是否可用
    if ! command -v ffmpeg &> /dev/null; then
        echo -e "${RED}❌ 需要 ffmpeg 來提取影片音訊${NC}"
        echo -e "${YELLOW}安裝方法: brew install ffmpeg${NC}"
        return 1
    fi
    
    # 使用 ffmpeg 提取音訊
    ffmpeg -i "$video_file" \
           -vn \
           -acodec mp3 \
           -ab 192k \
           -ar 44100 \
           -y \
           "$output_audio" 2>/dev/null
    
    local ffmpeg_result=$?
    
    if [ $ffmpeg_result -eq 0 ] && [ -f "$output_audio" ]; then
        echo -e "${GREEN}✅ 音訊提取完成！${NC}"
        return 0
    else
        echo -e "${RED}❌ 音訊提取失敗${NC}"
        rm -f "$output_audio"
        return 1
    fi
}

# 處理逐字稿檔案（直接進行 AI 分析）
process_transcript_file() {
    local input_file="$1"
    local original_name="$2"
    
    echo -e "${PURPLE}📄 處理逐字稿檔案...${NC}"
    echo -e "${BLUE}📝 檔案: $(basename "$input_file")${NC}"
    
    # 清理檔名中的特殊字元（移除副檔名）
    local name_without_ext=$(basename "$original_name" | sed 's/\.[^.]*$//')
    local clean_name=$(echo "$name_without_ext" | sed 's/[<>:"/\\|?*]/_/g')
    
    # 獲取副檔名
    local ext="${input_file##*.}"
    local target_file="$TRANSCRIPT_DIR/${clean_name}.${ext}"
    
    # 複製檔案到 Transcripts 目錄（如果不是同一個檔案）
    if [ "$input_file" != "$target_file" ]; then
        cp "$input_file" "$target_file"
        echo -e "${GREEN}✅ 逐字稿已複製到: $(basename "$target_file")${NC}"
    else
        echo -e "${BLUE}ℹ️  逐字稿已在目標目錄中${NC}"
    fi
    
    # 直接進行 AI 分析
    echo -e "${BLUE}🤖 開始 AI 分析...${NC}"
    
    # AI 分析功能 - 支援多種格式
    local transcript_file=""
    local use_temp_file=false
    
    # 按優先級檢查檔案格式
    if [ -f "$TRANSCRIPT_DIR/${clean_name}.txt" ]; then
        transcript_file="$TRANSCRIPT_DIR/${clean_name}.txt"
        echo -e "${BLUE}📄 使用 TXT 格式逐字稿進行 AI 分析${NC}"
    elif [ -f "$TRANSCRIPT_DIR/${clean_name}.vtt" ]; then
        local temp_txt="/tmp/${clean_name}_extracted.txt"
        if extract_text_from_subtitle "$TRANSCRIPT_DIR/${clean_name}.vtt" "$temp_txt"; then
            transcript_file="$temp_txt"
            use_temp_file=true
            echo -e "${BLUE}📄 從 VTT 格式提取文字進行 AI 分析${NC}"
        fi
    elif [ -f "$TRANSCRIPT_DIR/${clean_name}.srt" ]; then
        local temp_txt="/tmp/${clean_name}_extracted.txt"
        if extract_text_from_subtitle "$TRANSCRIPT_DIR/${clean_name}.srt" "$temp_txt"; then
            transcript_file="$temp_txt"
            use_temp_file=true
            echo -e "${BLUE}📄 從 SRT 格式提取文字進行 AI 分析${NC}"
        fi
    fi
    
    if [ -n "$transcript_file" ] && [ -f "$transcript_file" ]; then
        # 執行 Gemini 總結（如果未被跳過）
        if [ "$NO_SUMMARY" = false ] && check_gemini_cli; then
            echo ""
            generate_summary_with_gemini "$transcript_file" "$original_name"
        fi
        
        # 清理臨時檔案
        if [ "$use_temp_file" = true ] && [ -f "$transcript_file" ]; then
            rm -f "$transcript_file"
        fi
        
        echo ""
        echo -e "${GREEN}🎉 逐字稿檔案處理完成！${NC}"
        echo -e "${BLUE}📁 檔案位置: $TRANSCRIPT_DIR${NC}"
        return 0
    else
        echo -e "${RED}❌ 無法處理逐字稿檔案${NC}"
        return 1
    fi
}

# 使用 Gemini 生成逐字稿總結
generate_summary_with_gemini() {
    local transcript_file="$1"
    local original_name="$2"
    
    # 檢查逐字稿檔案是否存在
    if [ ! -f "$transcript_file" ]; then
        echo -e "${RED}❌ 逐字稿檔案不存在: $transcript_file${NC}"
        return 1
    fi
    
    # 準備輸出檔案路徑
    local clean_name=$(echo "$original_name" | sed 's/[<>:"/\\|?*]/_/g')
    local summary_file="$TRANSCRIPT_DIR/${clean_name}_summary.md"
    
    echo -e "${PURPLE}🤖 開始使用 Gemini 生成總結...${NC}"
    echo -e "${BLUE}📄 分析檔案: $(basename "$transcript_file")${NC}"
    
    # 決定使用哪個 gemini 命令
    local GEMINI_CMD="gemini"
    if ! command -v gemini &> /dev/null; then
        if command -v google-generativeai &> /dev/null; then
            GEMINI_CMD="google-generativeai"
        else
            echo -e "${RED}❌ 無法找到可用的 Gemini CLI${NC}"
            return 1
        fi
    fi
    
    # 準備提示詞
    local prompt="請為以下逐字稿內容生成一個詳細的總結，包含：

## 📋 總結格式
1. **主要內容摘要**：用 3-5 個重點概括核心內容
2. **關鍵資訊與要點**：列出重要的事實、數據或觀點
3. **學習/討論要點**：
   - 如果是教學內容：整理學習要點和技巧
   - 如果是訪談討論：歸納主要觀點和結論
4. **行動建議**：如果適用，提供實用的建議或下一步

請使用清楚的標題和條列式格式，讓總結易於閱讀和理解。"
    
    # 執行 Gemini 總結（使用 -p 參數傳遞提示詞，用 stdin 傳遞逐字稿內容）
    cat "$transcript_file" | $GEMINI_CMD -p "$prompt" > "$summary_file" 2>/dev/null
    
    local gemini_result=$?
    
    if [ $gemini_result -eq 0 ] && [ -s "$summary_file" ]; then
        echo -e "${GREEN}✅ 總結生成完成！${NC}"
        echo -e "${GREEN}📄 總結檔案: ${clean_name}_summary.txt${NC}"
        echo -e "${BLUE}📁 儲存位置: $TRANSCRIPT_DIR${NC}"
        return 0
    else
        echo -e "${RED}❌ Gemini 總結生成失敗${NC}"
        # 清理空的或失敗的總結檔案
        [ -f "$summary_file" ] && rm -f "$summary_file"
        return 1
    fi
}


# 轉錄音訊為文字並重新命名逐字稿
transcribe_audio_with_rename() {
    local audio_file="$1"
    local original_name="$2"
    local keep_audio="$3"

    # 使用時間戳作為暫時的逐字稿檔名
    local temp_base_name=$(basename "$audio_file" .mp3)

    echo -e "${PURPLE}🎤 開始轉錄音訊為文字...${NC}"

    # 根據動態的模型名稱定義模型路徑
    local model_path="$WHISPER_MODEL_DIR/${WHISPER_MODEL_NAME}.pt"

    # 檢查模型檔案，並提供提示
    if [ ! -f "$model_path" ]; then
        echo -e "${YELLOW}⚠️  Whisper 模型 '$WHISPER_MODEL_NAME' 不存在。${NC}"
        echo -e "${YELLOW}首次執行將自動下載，請耐心等候...${NC}"
    else
        echo -e "${GREEN}✅ 偵測到本地 Whisper 模型 '$WHISPER_MODEL_NAME'，將直接載入。${NC}"
    fi

    echo -e "${BLUE}📁 暫時檔案: $(basename "$audio_file")${NC}"
    echo -e "${BLUE}🏷️  目標名稱: $original_name${NC}"

    # 檢查檔案是否存在
    if [ ! -f "$audio_file" ]; then
        echo -e "${RED}❌ 音訊檔案不存在: $audio_file${NC}"
        return 1
    fi

    # 決定使用哪個 whisper 指令
    WHISPER_CMD="whisper"
    if ! command -v whisper &> /dev/null; then
        if [ -f "/Users/rocker/Library/Python/3.9/bin/whisper" ]; then
            WHISPER_CMD="/Users/rocker/Library/Python/3.9/bin/whisper"
        fi
    fi

    # 使用 Whisper 進行轉錄
    "$WHISPER_CMD" "$audio_file" \
        --language Chinese \
        --model "$WHISPER_MODEL_NAME" \
        --output_format txt \
        --output_format srt \
        --output_format vtt \
        --output_dir "$TRANSCRIPT_DIR" \
        --model_dir "$WHISPER_MODEL_DIR" \
       --verbose False

    local transcribe_result=$?

    if [ $transcribe_result -eq 0 ]; then
        echo -e "${GREEN}✅ 轉錄完成！${NC}"

        # 清理原始名稱中的特殊字元
        local clean_name=$(echo "$original_name" | sed 's/[<>:"/\\|?*]/_/g')

        # 重新命名逐字稿檔案
        for ext in txt srt vtt; do
            if [ -f "$TRANSCRIPT_DIR/$temp_base_name.$ext" ]; then
                local new_transcript_file="$TRANSCRIPT_DIR/${clean_name}.$ext"
                mv "$TRANSCRIPT_DIR/$temp_base_name.$ext" "$new_transcript_file"
                echo -e "${GREEN}📄 $clean_name.$ext${NC}"
            fi
        done

        # 處理音訊檔案
        if [ "$keep_audio" = true ]; then
            # 保留音訊檔案，重新命名為原始名稱
            local final_audio_file="$AUDIO_DIR/${clean_name}.mp3"
            mv "$audio_file" "$final_audio_file"
            echo -e "${BLUE}💾 音訊檔案重新命名為: $(basename "$final_audio_file")${NC}"
        else
            # 刪除音訊檔案
            echo -e "${YELLOW}🗑️  清理暫時音訊檔案...${NC}"
            if rm "$audio_file"; then
                echo -e "${GREEN}✅ 暫時音訊檔案已刪除${NC}"
                echo -e "${BLUE}💾 節省儲存空間，僅保留逐字稿${NC}"
            else
                echo -e "${RED}❌ 無法刪除音訊檔案: $(basename "$audio_file")${NC}"
            fi
        fi

        # AI 分析功能 - 支援多種格式
        local transcript_file=""
        local use_temp_file=false
        
        # 按優先級檢查檔案格式
        if [ -f "$TRANSCRIPT_DIR/${clean_name}.txt" ]; then
            transcript_file="$TRANSCRIPT_DIR/${clean_name}.txt"
            echo -e "${BLUE}📄 使用 TXT 格式逐字稿進行 AI 分析${NC}"
        elif [ -f "$TRANSCRIPT_DIR/${clean_name}.vtt" ]; then
            local temp_txt="/tmp/${clean_name}_extracted.txt"
            if extract_text_from_subtitle "$TRANSCRIPT_DIR/${clean_name}.vtt" "$temp_txt"; then
                transcript_file="$temp_txt"
                use_temp_file=true
                echo -e "${BLUE}📄 從 VTT 格式提取文字進行 AI 分析${NC}"
            fi
        elif [ -f "$TRANSCRIPT_DIR/${clean_name}.srt" ]; then
            local temp_txt="/tmp/${clean_name}_extracted.txt"
            if extract_text_from_subtitle "$TRANSCRIPT_DIR/${clean_name}.srt" "$temp_txt"; then
                transcript_file="$temp_txt"
                use_temp_file=true
                echo -e "${BLUE}📄 從 SRT 格式提取文字進行 AI 分析${NC}"
            fi
        fi
        
        if [ -n "$transcript_file" ] && [ -f "$transcript_file" ]; then
            # 執行 Gemini 總結（如果未被跳過）
            if [ "$NO_SUMMARY" = false ] && check_gemini_cli; then
                echo ""
                generate_summary_with_gemini "$transcript_file" "$original_name"
            fi
            
            # 清理臨時檔案
            if [ "$use_temp_file" = true ] && [ -f "$transcript_file" ]; then
                rm -f "$transcript_file"
            fi
        else
            echo -e "${YELLOW}⚠️  找不到可用的逐字稿檔案，跳過 AI 分析${NC}"
            echo -e "${BLUE}ℹ️  支援格式: .txt, .vtt, .srt${NC}"
        fi

        return 0
    else
        echo -e "${RED}❌ 轉錄失敗，保留暫時音訊檔案以便重試${NC}"
        return 1
    fi
}

# 主程式開始
echo -e "${BLUE}🎵 $(t MSG_APP_TITLE)${NC}"
echo -e "${BLUE}$(t MSG_SEPARATOR)${NC}"

# 載入或建立設定
if ! load_config; then
    echo -e "${YELLOW}$(t MSG_STATUS_WARNING)  $(t MSG_CONFIG_NOT_FOUND)${NC}"
    echo ""
    initial_setup
fi

# 確保目錄存在（如果設定檔損壞或目錄被刪除）
if [ ! -d "$AUDIO_DIR" ]; then
    echo -e "${YELLOW}⚠️  音訊目錄不存在，重新建立...${NC}"
    mkdir -p "$AUDIO_DIR"
    mkdir -p "$TRANSCRIPT_DIR"
    mkdir -p "$WHISPER_MODEL_DIR"
fi

# 檢查工具依賴
check_dependencies

URL=""
NO_TRANSCRIBE=false
KEEP_AUDIO=false
OPEN_FOLDER=false
NO_SUMMARY=false

# 手動解析第一個非選項參數作為 URL
for arg in "$@"; do
  case $arg in
    -*) # 這是一個選項，忽略
      ;;
    *)  # 這不是一個選項，將其視為 URL
      URL="$arg"
      break # 找到第一個就停止
      ;;
  esac
done

# 使用迴圈解析所有參數
while [[ $# -gt 0 ]]; do
    case $1 in
        --model)
            WHISPER_MODEL_NAME="$2"
            shift 2
            ;;
        --no-transcribe)
            NO_TRANSCRIBE=true
            shift
            ;;
        --keep-audio)
            KEEP_AUDIO=true
            shift
            ;;
        --open-folder)
            OPEN_FOLDER=true
            shift
            ;;
        --no-summary)
            NO_SUMMARY=true
            shift
            ;;
        -*)
            # 忽略未知選項，因為它可能是檔名的一部分
            shift
            ;;
        *)
            # 忽略非選項參數，因為我們已經手動處理了 URL
            shift
            ;;
    esac
done

# 檢查參數（改進空參數檢查）
if [ -z "$URL" ]; then
    echo -e "${YELLOW}📋 使用方法:${NC}"
    echo "$0 <url_or_file_path> [options]"
    echo ""
    echo -e "${BLUE}支援來源:${NC}"
    echo "• YouTube (youtube.com, youtu.be)"
    echo "• Instagram (instagram.com) - 僅公開內容"
    echo "• TikTok"
    echo "• Facebook"
    echo "• 其他 yt-dlp 支援的平台"
    echo ""
    echo -e "${GREEN}支援檔案類型:${NC}"
    echo "• 影片檔案: MP4, AVI, MKV, MOV, WMV, FLV, WEBM, M4V 等"
    echo "• 音訊檔案: MP3, WAV, FLAC, AAC, OGG, M4A, WMA 等"  
    echo "• 逐字稿檔案: TXT, VTT, SRT"
    echo ""
    echo -e "${PURPLE}處理流程:${NC}"
    echo "• 影片檔案 → 音訊提取 → Whisper 轉錄 → AI 分析"
    echo "• 音訊檔案 → Whisper 轉錄 → AI 分析"
    echo "• 逐字稿檔案 → 直接 AI 分析"
    echo ""
    echo -e "${YELLOW}參數說明:${NC}"
    echo "• --model [model_name]: 指定 Whisper 模型 (tiny, base, small, medium, large)，預設: small"
    echo "• --no-transcribe:      僅下載音訊，不進行轉錄"
    echo "• --keep-audio:         轉錄完成後保留音訊檔案"
    echo "• --open-folder:        完成後詢問是否開啟資料夾"
    echo ""
    echo -e "${YELLOW}AI 分析選項:${NC}"
    echo "• --no-summary:         跳過 Gemini AI 總結生成"
    echo ""
    echo -e "${YELLOW}範例:${NC}"
    echo -e "${BLUE}# 線上影片${NC}"
    echo "$0 'https://www.youtube.com/watch?v=...'"
    echo "$0 'https://www.instagram.com/p/...' --no-transcribe"
    echo ""
    echo -e "${BLUE}# 本地影片檔案${NC}"
    echo "$0 '/path/to/video.mp4'"
    echo "$0 '/path/to/video.mov' --keep-audio"
    echo ""
    echo -e "${BLUE}# 本地音訊檔案${NC}"
    echo "$0 '/path/to/audio.mp3'"
    echo "$0 '/path/to/audio.wav' --model base"
    echo ""
    echo -e "${BLUE}# 本地逐字稿檔案${NC}"
    echo "$0 '/path/to/transcript.txt'"
    echo "$0 '/path/to/subtitle.vtt' --no-summary"
    echo ""
    echo -e "${BLUE}輸出位置:${NC}"
    echo "• 逐字稿: $TRANSCRIPT_DIR"
    echo "• 音訊檔案: 轉錄成功後自動刪除（除非使用 --keep-audio）"
    exit 1
fi

# URL 已在前面的迴圈中解析，這裡進行最終檢查
if [ -z "$URL" ]; then
    echo -e "${RED}❌ 未提供 URL 或檔案路徑${NC}"
    exit 1
fi

echo -e "${BLUE}🔍 解析的路徑: $URL${NC}"


# 檢查是否為檔案路徑（處理包含空格和特殊字符的路徑）
# 首先判斷是否為 URL（包含協議）
if [[ "$URL" =~ ^https?:// ]] || [[ "$URL" =~ ^ftp:// ]]; then
    IS_FILE=false
elif [ -f "$URL" ]; then
    IS_FILE=true
    echo -e "${GREEN}✅ 檔案存在性檢查通過${NC}"
else
    # 檔案不存在，但也不是 URL，提供更好的錯誤訊息
    echo -e "${RED}❌ 檔案不存在: $URL${NC}"
    echo -e "${YELLOW}💡 請確認檔案路徑正確，或提供有效的 URL${NC}"
    exit 1
fi

# 處理檔案類型
if [ "$IS_FILE" = true ]; then
    
    # 檢測檔案類型
    FILE_TYPE=$(detect_file_type "$URL")
    ORIGINAL_NAME=$(basename "$URL")
    
    case "$FILE_TYPE" in
        "video")
            PLATFORM="本地影片檔案"
            EMOJI="📹"
            echo -e "${BLUE}$EMOJI 偵測到影片檔案: $URL${NC}"
            echo -e "${BLUE}📋 處理流程: 影片 → 音訊提取 → Whisper 轉錄 → AI 分析${NC}"
            
            # 生成臨時音訊檔案名稱
            TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
            TEMP_AUDIO_FILE="$AUDIO_DIR/temp_audio_${TIMESTAMP}.mp3"
            
            # 提取音訊
            if extract_audio_from_video "$URL" "$TEMP_AUDIO_FILE"; then
                echo -e "${GREEN}✅ 音訊提取成功，準備進行轉錄${NC}"
            else
                echo -e "${RED}❌ 音訊提取失敗${NC}"
                exit 1
            fi
            ;;
            
        "audio")
            PLATFORM="本地音訊檔案"
            EMOJI="🎵"
            echo -e "${BLUE}$EMOJI 偵測到音訊檔案: $URL${NC}"
            echo -e "${BLUE}📋 處理流程: 音訊 → Whisper 轉錄 → AI 分析${NC}"
            TEMP_AUDIO_FILE="$URL"
            ;;
            
        "transcript")
            PLATFORM="本地逐字稿檔案"
            EMOJI="📄"
            echo -e "${BLUE}$EMOJI 偵測到逐字稿檔案: $URL${NC}"
            echo -e "${BLUE}📋 處理流程: 逐字稿 → AI 分析${NC}"
            
            # 直接處理逐字稿檔案
            if process_transcript_file "$URL" "$ORIGINAL_NAME"; then
                echo -e "${GREEN}🎉 逐字稿檔案處理完成！${NC}"
                exit 0
            else
                echo -e "${RED}❌ 逐字稿檔案處理失敗${NC}"
                exit 1
            fi
            ;;
            
        "unknown")
            echo -e "${RED}❌ 不支援的檔案格式: $(echo "${URL##*.}" | tr '[:lower:]' '[:upper:]')${NC}"
            echo -e "${YELLOW}💡 支援的格式:${NC}"
            echo "• 影片: MP4, AVI, MKV, MOV, WMV, FLV, WEBM, M4V 等"
            echo "• 音訊: MP3, WAV, FLAC, AAC, OGG, M4A, WMA 等"
            echo "• 逐字稿: TXT, VTT, SRT"
            exit 1
            ;;
            
        "nonexistent")
            echo -e "${RED}❌ 本地檔案不存在: $URL${NC}"
            exit 1
            ;;
    esac
elif [ "$IS_FILE" = false ]; then
    # 處理 URL 下載
    DOWNLOAD_SUCCESS=false
    # 平台偵測
    if [[ "$URL" == *"instagram.com"* ]]; then
        PLATFORM="Instagram"
        EMOJI="📸"
    elif [[ "$URL" == *"youtube.com"* ]] || [[ "$URL" == *"youtu.be"* ]]; then
        PLATFORM="YouTube"
        EMOJI="🎥"
    elif [[ "$URL" == *"tiktok.com"* ]]; then
        PLATFORM="TikTok"
        EMOJI="🎵"
    else
        PLATFORM="其他平台"
        EMOJI="🌐"
    fi

    echo -e "${BLUE}$EMOJI 偵測到 $PLATFORM URL${NC}"
    echo -e "${YELLOW}📥 步驟 1/2: 下載音訊...${NC}"

    # 生成時間戳檔名
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    TEMP_FILENAME="temp_audio_${TIMESTAMP}"

    # 記錄下載前的檔案
    BEFORE_FILES=($(ls "$AUDIO_DIR"/*.mp3 2>/dev/null || true))

    # 先獲取影片資訊
    echo -e "${BLUE}🔍 獲取影片資訊...${NC}"
    VIDEO_INFO=$(yt-dlp --print "%(uploader)s - %(title)s" "$URL" 2>/dev/null)
    if [ $? -eq 0 ] && [ ! -z "$VIDEO_INFO" ]; then
        echo -e "${GREEN}🏷️  原始標題: $VIDEO_INFO${NC}"
        echo "$VIDEO_INFO" > "$AUDIO_DIR/${TEMP_FILENAME}_info.txt"
    else
        echo -e "${YELLOW}⚠️  無法獲取影片資訊，使用時間戳作為標題${NC}"
        echo "Unknown_${TIMESTAMP}" > "$AUDIO_DIR/${TEMP_FILENAME}_info.txt"
    fi

    # 下載音訊
    yt-dlp \
        --extract-audio \
        --audio-format mp3 \
        --audio-quality 0 \
        --output "$AUDIO_DIR/${TEMP_FILENAME}.%(ext)s" \
        --embed-metadata \
        --add-metadata \
        --ignore-errors \
        --no-playlist \
        --sleep-interval 1 \
        --max-sleep-interval 3 \
        --user-agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
        "${URL}"

    # 檢查下載結果
    YT_DLP_EXIT_CODE=$?
    if [ $YT_DLP_EXIT_CODE -eq 0 ]; then
        DOWNLOAD_SUCCESS=true
        echo -e "${GREEN}✅ 音訊下載完成！${NC}"

        # 檢查時間戳檔案是否存在
        TEMP_AUDIO_FILE="$AUDIO_DIR/${TEMP_FILENAME}.mp3"
        INFO_FILE="$AUDIO_DIR/${TEMP_FILENAME}_info.txt"

        # 如果時間戳檔案不存在，查找最新下載的檔案
        if [ ! -f "$TEMP_AUDIO_FILE" ]; then
            echo -e "${YELLOW}⚠️  時間戳檔案不存在，查找實際下載的檔案...${NC}"

            # 找出新增的檔案
            AFTER_FILES=($(ls "$AUDIO_DIR"/*.mp3 2>/dev/null || true))
            ACTUAL_FILE=""

            for file in "${AFTER_FILES[@]}"; do
                if [[ ! " ${BEFORE_FILES[@]} " =~ " ${file} " ]]; then
                    ACTUAL_FILE="$file"
                    break
                fi
            done

            if [ ! -z "$ACTUAL_FILE" ]; then
                echo -e "${BLUE}📁 實際下載檔案: $(basename "$ACTUAL_FILE")${NC}"
                # 將實際檔案重新命名為時間戳檔案
                mv "$ACTUAL_FILE" "$TEMP_AUDIO_FILE"
                echo -e "${GREEN}📝 已重新命名為: $(basename "$TEMP_AUDIO_FILE")${NC}"
            else
                echo -e "${RED}❌ 找不到下載的檔案${NC}"
                rm -f "$INFO_FILE"
                exit 1
            fi
        fi

        # 讀取原始檔案資訊
        if [ -f "$INFO_FILE" ]; then
            ORIGINAL_NAME=$(cat "$INFO_FILE" | head -1)
            if [ -z "$ORIGINAL_NAME" ]; then
                ORIGINAL_NAME="Unknown_${TIMESTAMP}"
            fi
        else
            ORIGINAL_NAME="Unknown_${TIMESTAMP}"
        fi

        echo -e "${GREEN}🏷️  原始標題: $ORIGINAL_NAME${NC}"
        echo -e "${BLUE}📁 暫時檔案: $(basename "$TEMP_AUDIO_FILE")${NC}"
        echo -e "${BLUE}📁 暫存位置: $AUDIO_DIR${NC}"
    else
        echo -e "${RED}❌ 音訊下載失敗${NC}"
        echo -e "${YELLOW}💡 可能原因:${NC}"
        echo "• URL 格式錯誤"
        echo "• 網路連線問題"
        echo "• 影片為私人內容"
        echo "• 影片已被刪除"
        echo ""
        echo -e "${YELLOW}🔧 建議:${NC}"
        echo "• 確認 URL 完整且正確"
        echo "• 確認內容為公開可存取"
        echo "• 檢查網路連線"
       exit 1
    fi
fi

# 檢查檔案是否存在或下載結果
if [ "$IS_FILE" = true ] || [ "$DOWNLOAD_SUCCESS" = true ]; then

    if [ "$IS_FILE" = true ]; then
        echo -e "${GREEN}✅ 使用本地檔案: $URL${NC}"
        TEMP_AUDIO_FILE="$URL"
        ORIGINAL_NAME=$(basename "$URL")
    else
        echo -e "${GREEN}✅ 音訊下載完成！${NC}"
        # 檢查時間戳檔案是否存在
        TEMP_AUDIO_FILE="$AUDIO_DIR/${TEMP_FILENAME}.mp3"
        INFO_FILE="$AUDIO_DIR/${TEMP_FILENAME}_info.txt"
    fi

    if [ ! -f "$TEMP_AUDIO_FILE" ]; then
        echo -e "${YELLOW}⚠️  暫時檔案不存在，請檢查${NC}"
        exit 1
    fi

    # 讀取原始檔案資訊
    if [ -f "$INFO_FILE" ]; then
        ORIGINAL_NAME=$(cat "$INFO_FILE" | head -1)
        if [ -z "$ORIGINAL_NAME" ]; then
            ORIGINAL_NAME="Unknown_${TIMESTAMP}"
        fi
    else
        ORIGINAL_NAME=$(basename "$TEMP_AUDIO_FILE")
    fi

    echo -e "${GREEN}🏷️  原始標題: $ORIGINAL_NAME${NC}"
    echo -e "${BLUE}📁 暫時檔案: $(basename "$TEMP_AUDIO_FILE")${NC}"
    echo -e "${BLUE}📁 暫存位置: $AUDIO_DIR${NC}"

    # 檢查是否要進行轉錄
    if [ "$NO_TRANSCRIBE" = false ]; then
        echo ""
        echo -e "${YELLOW}📝 步驟 2/2: 開始轉錄...${NC}"

        if [ "$KEEP_AUDIO" = true ]; then
            # 轉錄但保留音訊
            if transcribe_audio_with_rename "$TEMP_AUDIO_FILE" "$ORIGINAL_NAME" true; then
                echo ""
                echo -e "${GREEN}🎉 一條龍處理完成！${NC}"
                echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                echo -e "${GREEN}🎵 音訊檔案: $AUDIO_DIR${NC}"
                echo -e "${GREEN}📄 逐字稿: $TRANSCRIPT_DIR${NC}"
            else
                echo -e "${YELLOW}⚠️  音訊下載成功，但轉錄失敗${NC}"
            fi
        else
            # 轉錄並刪除音訊
            if transcribe_audio_with_rename "$TEMP_AUDIO_FILE" "$ORIGINAL_NAME" false; then
                echo ""
                echo -e "${GREEN}🎉 一條龍處理完成！${NC}"
                echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                echo -e "${GREEN}📄 逐字稿: $TRANSCRIPT_DIR${NC}"
                echo -e "${GREEN}💾 已自動清理音訊檔案，節省儲存空間${NC}"
            else
                echo -e "${YELLOW}⚠️  音訊下載成功，但轉錄失敗${NC}"
                echo -e "${BLUE}💡 你可以稍後手動轉錄:${NC}"
                echo "whisper \"$TEMP_AUDIO_FILE\" --language Chinese --output_dir \"$TRANSCRIPT_DIR\""
            fi
        fi

        # 清理資訊檔案
        rm -f "$INFO_FILE"

        # 只有使用 --open-folder 參數時才詢問
        if [ "$OPEN_FOLDER" = true ]; then
            echo ""
            read -p "要開啟逐字稿資料夾嗎？ (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                open "$TRANSCRIPT_DIR"
            fi
        fi
    else
        echo -e "${BLUE}ℹ️  跳過轉錄步驟${NC}"

        # 如果不轉錄，將暫時檔案重新命名為原始名稱
        if [ "$ORIGINAL_NAME" != "Unknown_${TIMESTAMP}" ]; then
            # 清理檔名中的特殊字元
            CLEAN_NAME=$(echo "$original_name" | sed 's/[<>:"/\\|?*]/_/g')
            FINAL_AUDIO_FILE="$AUDIO_DIR/${CLEAN_NAME}.mp3"
            mv "$TEMP_AUDIO_FILE" "$FINAL_AUDIO_FILE"
            echo -e "${GREEN}📁 檔案已重新命名為: $(basename "$FINAL_AUDIO_FILE")${NC}"
        fi

        # 清理資訊檔案
        rm -f "$INFO_FILE"

        # 只有使用 --open-folder 參數時才詢問
        if [ "$OPEN_FOLDER" = true ]; then
            echo ""
            read -p "要開啟音訊資料夾嗎？ (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                open "$AUDIO_DIR"
            fi
        fi
    fi
else
    if [ "$IS_FILE" = true ]; then
        echo -e "${RED}❌ 本地檔案不存在: $URL${NC}"
    else
        echo -e "${RED}❌ 音訊下載失敗${NC}"
        echo -e "${YELLOW}💡 可能原因:${NC}"
        echo "• URL 格式錯誤"
        echo "• 網路連線問題"
        echo "• 影片為私人內容"
        echo "• 影片已被刪除"
        echo ""
        echo -e "${YELLOW}🔧 建議:${NC}"
        echo "• 確認 URL 完整且正確"
        echo "• 確認內容為公開可存取"
        echo "• 檢查網路連線"
    fi
fi