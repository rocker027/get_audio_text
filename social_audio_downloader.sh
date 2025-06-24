#!/bin/bash

# 設定目錄
AUDIO_DIR="/Users/rocker/Downloads/CaptureAudio"
TRANSCRIPT_DIR="/Users/rocker/Downloads/CaptureAudio/Transcripts"

# 建立目錄（如果不存在）
mkdir -p "$AUDIO_DIR"
mkdir -p "$TRANSCRIPT_DIR"

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

# 轉錄音訊為文字
transcribe_audio() {
    local audio_file="$1"
    local base_name=$(basename "$audio_file" | sed 's/\.[^.]*$//')
    
    echo -e "${PURPLE}🎤 開始轉錄音訊為文字...${NC}"
    echo -e "${BLUE}📁 輸入檔案: $(basename "$audio_file")${NC}"
    
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
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 轉錄完成！${NC}"
        echo -e "${BLUE}📄 逐字稿檔案:${NC}"
        ls -la "$TRANSCRIPT_DIR/$base_name".{txt,srt,vtt} 2>/dev/null | while read -r line; do
            echo -e "${GREEN}  $(echo "$line" | awk '{print $9}')${NC}"
        done
        
        # 刪除原始音訊檔案
        echo -e "${YELLOW}🗑️  清理音訊檔案...${NC}"
        if rm "$audio_file"; then
            echo -e "${GREEN}✅ 音訊檔案已刪除: $(basename "$audio_file")${NC}"
            echo -e "${BLUE}💾 節省儲存空間，僅保留逐字稿${NC}"
        else
            echo -e "${RED}❌ 無法刪除音訊檔案: $(basename "$audio_file")${NC}"
        fi
        
        return 0
    else
        echo -e "${RED}❌ 轉錄失敗，保留音訊檔案以便重試${NC}"
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
    echo ""
    echo -e "${YELLOW}範例:${NC}"
    echo "$0 'https://www.youtube.com/watch?v=...'"
    echo "$0 'https://www.instagram.com/p/...' --no-transcribe"
    echo "$0 'https://www.youtube.com/watch?v=...' --keep-audio"
    echo ""
    echo -e "${BLUE}輸出位置:${NC}"
    echo "• 逐字稿: $TRANSCRIPT_DIR"
    echo "• 音訊檔案: 轉錄成功後自動刪除（除非使用 --keep-audio）"
    exit 1
fi

URL="$1"
NO_TRANSCRIBE=false
KEEP_AUDIO=false

# 檢查參數
for arg in "$@"; do
    case $arg in
        --no-transcribe)
            NO_TRANSCRIBE=true
            ;;
        --keep-audio)
            KEEP_AUDIO=true
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

# 記錄下載前的檔案
BEFORE_FILES=($(ls "$AUDIO_DIR"/*.mp3 2>/dev/null || true))

# 下載音訊
yt-dlp \
    --extract-audio \
    --audio-format mp3 \
    --audio-quality 0 \
    --output "$AUDIO_DIR/%(uploader)s - %(title)s.%(ext)s" \
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
    
    # 找出最新下載的檔案
    AFTER_FILES=($(ls "$AUDIO_DIR"/*.mp3 2>/dev/null || true))
    NEW_FILE=""
    
    # 比較檔案列表找出新檔案
    for file in "${AFTER_FILES[@]}"; do
        if [[ ! " ${BEFORE_FILES[@]} " =~ " ${file} " ]]; then
            NEW_FILE="$file"
            break
        fi
    done
    
    if [ -z "$NEW_FILE" ]; then
        # 如果找不到新檔案，使用最新的檔案
        NEW_FILE=$(ls -t "$AUDIO_DIR"/*.mp3 2>/dev/null | head -1)
    fi
    
    if [ ! -z "$NEW_FILE" ]; then
        echo -e "${GREEN}🎵 下載檔案: $(basename "$NEW_FILE")${NC}"
        echo -e "${BLUE}📁 暫存位置: $AUDIO_DIR${NC}"
        
        # 檢查是否要進行轉錄
        if [ "$NO_TRANSCRIBE" = false ]; then
            echo ""
            echo -e "${YELLOW}📝 步驟 2/2: 開始轉錄...${NC}"
            
            # 修改轉錄函數以支援保留音訊選項
            if [ "$KEEP_AUDIO" = true ]; then
                # 臨時修改轉錄函數，不刪除音訊
                transcribe_audio_keep() {
                    local audio_file="$1"
                    local base_name=$(basename "$audio_file" | sed 's/\.[^.]*$//')
                    
                    echo -e "${PURPLE}🎤 開始轉錄音訊為文字...${NC}"
                    echo -e "${BLUE}📁 輸入檔案: $(basename "$audio_file")${NC}"
                    
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
                    
                    if [ $? -eq 0 ]; then
                        echo -e "${GREEN}✅ 轉錄完成！${NC}"
                        echo -e "${BLUE}📄 逐字稿檔案:${NC}"
                        ls -la "$TRANSCRIPT_DIR/$base_name".{txt,srt,vtt} 2>/dev/null | while read -r line; do
                            echo -e "${GREEN}  $(echo "$line" | awk '{print $9}')${NC}"
                        done
                        echo -e "${BLUE}💾 保留音訊檔案: $(basename "$audio_file")${NC}"
                        return 0
                    else
                        echo -e "${RED}❌ 轉錄失敗${NC}"
                        return 1
                    fi
                }
                
                if transcribe_audio_keep "$NEW_FILE"; then
                    echo ""
                    echo -e "${GREEN}🎉 一條龍處理完成！${NC}"
                    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                    echo -e "${GREEN}🎵 音訊檔案: $AUDIO_DIR${NC}"
                    echo -e "${GREEN}📄 逐字稿: $TRANSCRIPT_DIR${NC}"
                else
                    echo -e "${YELLOW}⚠️  音訊下載成功，但轉錄失敗${NC}"
                fi
            else
                if transcribe_audio "$NEW_FILE"; then
                    echo ""
                    echo -e "${GREEN}🎉 一條龍處理完成！${NC}"
                    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                    echo -e "${GREEN}📄 逐字稿: $TRANSCRIPT_DIR${NC}"
                    echo -e "${GREEN}💾 已自動清理音訊檔案，節省儲存空間${NC}"
                else
                    echo -e "${YELLOW}⚠️  音訊下載成功，但轉錄失敗${NC}"
                    echo -e "${BLUE}💡 你可以稍後手動轉錄:${NC}"
                    echo "whisper \"$NEW_FILE\" --language Chinese --output_dir \"$TRANSCRIPT_DIR\""
                fi
            fi
            
            # 詢問是否開啟檔案夾
            echo ""
            read -p "要開啟逐字稿資料夾嗎？ (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                open "$TRANSCRIPT_DIR"
            fi
        else
            echo -e "${BLUE}ℹ️  跳過轉錄步驟${NC}"
            # 詢問是否開啟音訊資料夾
            echo ""
            read -p "要開啟音訊資料夾嗎？ (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                open "$AUDIO_DIR"
            fi
        fi
    else
        echo -e "${YELLOW}⚠️  找不到下載的檔案${NC}"
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