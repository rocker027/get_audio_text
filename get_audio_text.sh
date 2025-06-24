#!/bin/bash

# 設定目錄
AUDIO_DIR="abs_path_to_audio_dir"

# 建立目錄（如果不存在）
mkdir -p "$AUDIO_DIR"
mkdir -p "$AUDIO_DIR/Transcripts"

# 顏色輸出
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

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
        echo -e "${RED}❌ 缺少必要工具: ${missing_tools[*]}${NC}"
        echo -e "${YELLOW}安裝方法:${NC}"
        echo "brew install yt-dlp ffmpeg"
        echo "pip3 install openai-whisper"
        exit 1
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
        --model medium \
        --output_format txt \
        --output_format srt \
        --output_format vtt \
        --output_dir "$TRANSCRIPT_DIR" \
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
        
        return 0
    else
        echo -e "${RED}❌ 轉錄失敗，保留暫時音訊檔案以便重試${NC}"
        return 1
    fi
}

# 主程式開始
echo -e "${BLUE}🎵 YouTube/Instagram 音訊下載 + 轉錄一條龍服務${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# 檢查工具依賴
check_dependencies

# 檢查參數
if [ $# -eq 0 ]; then
    echo -e "${YELLOW}📋 使用方法:${NC}"
    echo "$0 <video_url> [--no-transcribe] [--keep-audio]"
    echo ""
    echo -e "${BLUE}支援平台:${NC}"
    echo "• YouTube (youtube.com, youtu.be)"
    echo "• Instagram (instagram.com) - 僅公開內容"
    echo "• TikTok"
    echo "• Facebook"
    echo "• 其他 yt-dlp 支援的平台"
    echo ""
    echo -e "${YELLOW}參數說明:${NC}"
    echo "• --no-transcribe: 僅下載音訊，不進行轉錄"
    echo "• --keep-audio: 轉錄完成後保留音訊檔案"
    echo "• --open-folder: 完成後詢問是否開啟資料夾"
    echo ""
    echo -e "${YELLOW}範例:${NC}"
    echo "$0 'https://www.youtube.com/watch?v=...'"
    echo "$0 'https://www.instagram.com/p/...' --no-transcribe"
    echo "$0 'https://www.youtube.com/watch?v=...' --keep-audio"
    echo "$0 'https://www.youtube.com/watch?v=...' --open-folder"
    echo ""
    echo -e "${BLUE}輸出位置:${NC}"
    echo "• 逐字稿: $TRANSCRIPT_DIR"
    echo "• 音訊檔案: 轉錄成功後自動刪除（除非使用 --keep-audio）"
    exit 1
fi

URL="$1"
NO_TRANSCRIBE=false
KEEP_AUDIO=false
OPEN_FOLDER=false

# 檢查參數
for arg in "$@"; do
    case $arg in
        --no-transcribe)
            NO_TRANSCRIBE=true
            ;;
        --keep-audio)
            KEEP_AUDIO=true
            ;;
        --open-folder)
            OPEN_FOLDER=true
            ;;
    esac
done

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

# 下載音訊（使用時間戳檔名）
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
    "$URL"

# 檢查下載結果
if [ $? -eq 0 ]; then
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
    
    if [ -f "$TEMP_AUDIO_FILE" ]; then
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
                CLEAN_NAME=$(echo "$ORIGINAL_NAME" | sed 's/[<>:"/\\|?*]/_/g')
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
        echo -e "${YELLOW}⚠️  找不到下載的檔案: $TEMP_AUDIO_FILE${NC}"
        # 清理資訊檔案
        rm -f "$INFO_FILE"
    fi
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