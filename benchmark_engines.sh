#!/bin/bash

# Whisper 引擎效能基準測試腳本
# 比較 faster-whisper 與 OpenAI whisper 的速度和準確性

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m'

# 測試設定
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$HOME/.get_audio_text_config"

# 載入設定
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo -e "${RED}❌ 未找到設定檔: $CONFIG_FILE${NC}"
    echo -e "${YELLOW}請先執行 get_audio_text.sh 進行初始設定${NC}"
    exit 1
fi

# 函數：格式化時間
format_time() {
    local seconds=$1
    local minutes=$((seconds / 60))
    local remaining_seconds=$((seconds % 60))
    printf "%02d:%02d" $minutes $remaining_seconds
}

# 函數：測試 faster-whisper
test_faster_whisper() {
    local audio_file="$1"
    local output_prefix="$2"
    
    echo -e "${PURPLE}🚀 測試 faster-whisper...${NC}"
    
    if [ ! -d "$FASTER_WHISPER_VENV" ]; then
        echo -e "${RED}❌ faster-whisper 虛擬環境不存在${NC}"
        return 1
    fi
    
    local start_time=$(date +%s)
    
    # 創建臨時測試腳本
    local test_script="/tmp/benchmark_faster_whisper_$$.py"
    cat > "$test_script" << 'EOF'
import sys
import time
import os
from faster_whisper import WhisperModel

def benchmark_transcribe(audio_path, model_size, compute_type, device, output_prefix):
    try:
        start_time = time.time()
        
        print(f"載入模型: {model_size}")
        model = WhisperModel(model_size, 
                           device=device, 
                           compute_type=compute_type,
                           download_root=os.environ.get('WHISPER_MODEL_DIR'))
        
        load_time = time.time()
        print(f"模型載入時間: {load_time - start_time:.2f}s")
        
        print(f"開始轉錄...")
        transcribe_start = time.time()
        segments, info = model.transcribe(
            audio_path,
            language="zh",
            vad_filter=True,
            vad_parameters=dict(min_silence_duration_ms=500)
        )
        
        # 生成輸出檔案
        txt_path = f"{output_prefix}_faster.txt"
        segment_count = 0
        with open(txt_path, 'w', encoding='utf-8') as f:
            for segment in segments:
                f.write(f"{segment.text.strip()}\n")
                segment_count += 1
        
        transcribe_end = time.time()
        
        print(f"語言偵測: {info.language} (信心度: {info.language_probability:.2f})")
        print(f"片段數量: {segment_count}")
        print(f"轉錄時間: {transcribe_end - transcribe_start:.2f}s")
        print(f"總時間: {transcribe_end - start_time:.2f}s")
        
        return transcribe_end - start_time
        
    except Exception as e:
        print(f"錯誤: {str(e)}")
        return -1

if __name__ == "__main__":
    if len(sys.argv) != 6:
        print("使用方法: python script.py <audio_path> <model_size> <compute_type> <device> <output_prefix>")
        sys.exit(1)
    
    audio_path, model_size, compute_type, device, output_prefix = sys.argv[1:6]
    total_time = benchmark_transcribe(audio_path, model_size, compute_type, device, output_prefix)
    
    if total_time > 0:
        print(f"RESULT:faster:{total_time:.2f}")
    else:
        print("RESULT:faster:FAILED")
EOF
    
    # 執行測試
    local result=$(source "$FASTER_WHISPER_VENV/bin/activate" && \
                   WHISPER_MODEL_DIR="$WHISPER_MODEL_DIR" python3 "$test_script" \
                   "$audio_file" "small" "float16" "auto" "$output_prefix" 2>/dev/null | tail -1)
    
    rm -f "$test_script"
    
    local end_time=$(date +%s)
    local total_time=$((end_time - start_time))
    
    if [[ "$result" == RESULT:faster:* ]]; then
        local transcribe_time=${result#RESULT:faster:}
        if [[ "$transcribe_time" != "FAILED" ]]; then
            echo -e "${GREEN}✅ faster-whisper 完成${NC}"
            echo -e "${BLUE}轉錄時間: ${transcribe_time}s${NC}"
            echo -e "${BLUE}總時間: ${total_time}s${NC}"
            echo "$transcribe_time"
            return 0
        fi
    fi
    
    echo -e "${RED}❌ faster-whisper 測試失敗${NC}"
    echo "-1"
    return 1
}

# 函數：測試 OpenAI whisper
test_openai_whisper() {
    local audio_file="$1"
    local output_prefix="$2"
    
    echo -e "${BLUE}🎵 測試 OpenAI whisper...${NC}"
    
    # 決定使用哪個 whisper 指令
    local WHISPER_CMD="whisper"
    if ! command -v whisper &> /dev/null; then
        if [ -f "/Users/rocker/Library/Python/3.9/bin/whisper" ]; then
            WHISPER_CMD="/Users/rocker/Library/Python/3.9/bin/whisper"
        else
            echo -e "${RED}❌ OpenAI whisper 不可用${NC}"
            echo "-1"
            return 1
        fi
    fi
    
    local start_time=$(date +%s)
    
    # 執行轉錄到臨時目錄
    local temp_dir="/tmp/whisper_benchmark_$$"
    mkdir -p "$temp_dir"
    
    "$WHISPER_CMD" "$audio_file" \
        --language Chinese \
        --model small \
        --output_format txt \
        --output_dir "$temp_dir" \
        --model_dir "$WHISPER_MODEL_DIR" \
        --verbose False > /dev/null 2>&1
    
    local whisper_result=$?
    local end_time=$(date +%s)
    local total_time=$((end_time - start_time))
    
    if [ $whisper_result -eq 0 ]; then
        # 找到輸出檔案並複製
        local base_name=$(basename "$audio_file" | sed 's/\.[^.]*$//')
        if [ -f "$temp_dir/${base_name}.txt" ]; then
            cp "$temp_dir/${base_name}.txt" "${output_prefix}_openai.txt"
            echo -e "${GREEN}✅ OpenAI whisper 完成${NC}"
            echo -e "${BLUE}總時間: ${total_time}s${NC}"
            echo "$total_time"
        else
            echo -e "${RED}❌ 未找到輸出檔案${NC}"
            echo "-1"
            total_time=-1
        fi
    else
        echo -e "${RED}❌ OpenAI whisper 測試失敗${NC}"
        echo "-1"
        total_time=-1
    fi
    
    # 清理臨時目錄
    rm -rf "$temp_dir"
    
    return $((whisper_result == 0 ? 0 : 1))
}

# 函數：分析輸出檔案
analyze_output() {
    local faster_file="$1"
    local openai_file="$2"
    
    echo -e "${YELLOW}📊 分析輸出結果...${NC}"
    
    if [ -f "$faster_file" ] && [ -f "$openai_file" ]; then
        local faster_words=$(wc -w < "$faster_file" 2>/dev/null || echo "0")
        local openai_words=$(wc -w < "$openai_file" 2>/dev/null || echo "0")
        local faster_lines=$(wc -l < "$faster_file" 2>/dev/null || echo "0")
        local openai_lines=$(wc -l < "$openai_file" 2>/dev/null || echo "0")
        
        echo -e "${BLUE}faster-whisper: ${faster_words} 字詞, ${faster_lines} 行${NC}"
        echo -e "${BLUE}OpenAI whisper: ${openai_words} 字詞, ${openai_lines} 行${NC}"
        
        local word_diff=$((faster_words - openai_words))
        local line_diff=$((faster_lines - openai_lines))
        
        if [ $word_diff -ne 0 ]; then
            echo -e "${YELLOW}字詞差異: $word_diff${NC}"
        fi
        if [ $line_diff -ne 0 ]; then
            echo -e "${YELLOW}行數差異: $line_diff${NC}"
        fi
        
        # 檢查相似度（簡單比較）
        if command -v diff >/dev/null; then
            local diff_lines=$(diff -u "$faster_file" "$openai_file" | wc -l 2>/dev/null || echo "0")
            echo -e "${BLUE}差異行數: $diff_lines${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  無法分析輸出檔案（檔案不存在）${NC}"
    fi
}

# 主程式
main() {
    echo -e "${BLUE}🏁 Whisper 引擎效能基準測試${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
    
    # 檢查參數
    if [ $# -ne 1 ]; then
        echo -e "${YELLOW}使用方法: $0 <audio_file>${NC}"
        echo -e "${YELLOW}範例: $0 /path/to/audio.mp3${NC}"
        exit 1
    fi
    
    local audio_file="$1"
    
    # 檢查音訊檔案是否存在
    if [ ! -f "$audio_file" ]; then
        echo -e "${RED}❌ 音訊檔案不存在: $audio_file${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}測試音訊: $(basename "$audio_file")${NC}"
    echo -e "${BLUE}檔案大小: $(du -h "$audio_file" | cut -f1)${NC}"
    echo ""
    
    # 準備輸出前綴
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local output_prefix="/tmp/benchmark_${timestamp}"
    
    # 測試 faster-whisper
    echo -e "${PURPLE}測試 1/2: faster-whisper${NC}"
    local faster_time=$(test_faster_whisper "$audio_file" "$output_prefix")
    echo ""
    
    # 測試 OpenAI whisper
    echo -e "${PURPLE}測試 2/2: OpenAI whisper${NC}"
    local openai_time=$(test_openai_whisper "$audio_file" "$output_prefix")
    echo ""
    
    # 輸出結果比較
    echo -e "${GREEN}📊 基準測試結果${NC}"
    echo -e "${GREEN}==================${NC}"
    
    if [[ "$faster_time" != "-1" ]] && [[ "$openai_time" != "-1" ]]; then
        echo -e "${BLUE}faster-whisper: ${faster_time}s${NC}"
        echo -e "${BLUE}OpenAI whisper:  ${openai_time}s${NC}"
        
        # 計算速度提升
        local speedup=$(echo "scale=2; $openai_time / $faster_time" | bc 2>/dev/null || echo "無法計算")
        if [[ "$speedup" != "無法計算" ]]; then
            echo -e "${GREEN}速度提升: ${speedup}x${NC}"
            
            if (( $(echo "$speedup > 1" | bc -l) )); then
                echo -e "${GREEN}🎉 faster-whisper 更快！${NC}"
            elif (( $(echo "$speedup < 1" | bc -l) )); then
                echo -e "${YELLOW}😐 OpenAI whisper 更快${NC}"
            else
                echo -e "${BLUE}⚖️  兩者速度相當${NC}"
            fi
        fi
    else
        echo -e "${RED}❌ 測試失敗，無法進行比較${NC}"
        if [[ "$faster_time" == "-1" ]]; then
            echo -e "${RED}- faster-whisper 測試失敗${NC}"
        fi
        if [[ "$openai_time" == "-1" ]]; then
            echo -e "${RED}- OpenAI whisper 測試失敗${NC}"
        fi
    fi
    
    echo ""
    
    # 分析輸出檔案
    analyze_output "${output_prefix}_faster.txt" "${output_prefix}_openai.txt"
    
    echo ""
    echo -e "${YELLOW}測試檔案保存在:${NC}"
    echo -e "${BLUE}faster-whisper: ${output_prefix}_faster.txt${NC}"
    echo -e "${BLUE}OpenAI whisper: ${output_prefix}_openai.txt${NC}"
    echo ""
    echo -e "${GREEN}✅ 基準測試完成${NC}"
}

# 檢查依賴
if ! command -v bc >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  建議安裝 bc 以進行數值計算: brew install bc${NC}"
fi

# 執行主程式
main "$@"