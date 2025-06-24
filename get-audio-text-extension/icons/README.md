# 圖示檔案說明

## 需要的圖示檔案

Chrome 擴展需要以下三個尺寸的 PNG 圖示：

- `icon-16.png` (16x16 pixels) - 用於擴展列表
- `icon-48.png` (48x48 pixels) - 用於擴展管理頁面  
- `icon-128.png` (128x128 pixels) - 用於 Chrome Web Store

## 如何生成圖示

### 方法 1: 使用線上工具

1. **SVG to PNG 轉換器**：
   - 使用提供的 `icon.svg` 檔案
   - 前往 https://svgtopng.com/ 或類似網站
   - 上傳 `icon.svg`
   - 分別生成 16x16、48x48、128x128 尺寸的 PNG

2. **線上圖示生成器**：
   - 前往 https://favicon.io/favicon-generator/
   - 輸入文字 "GAT" 或上傳 SVG
   - 下載不同尺寸的圖示

### 方法 2: 使用設計軟體

1. **使用 Figma/Sketch/Adobe Illustrator**：
   - 開啟 `icon.svg`
   - 匯出為 PNG，分別設定 16、48、128 像素

2. **使用 GIMP (免費)**：
   - 開啟 `icon.svg`
   - 調整畫布大小
   - 匯出為 PNG

### 方法 3: 使用命令列工具

如果有安裝 ImageMagick：

```bash
# 轉換 SVG 為不同尺寸的 PNG
convert icon.svg -resize 16x16 icon-16.png
convert icon.svg -resize 48x48 icon-48.png  
convert icon.svg -resize 128x128 icon-128.png
```

## 圖示設計說明

提供的 SVG 圖示包含：
- 麥克風圖標（代表音訊錄製）
- 音波圖形（代表聲音處理）
- 文字線條（代表轉錄輸出）
- 漸層背景（現代化外觀）

## 臨時解決方案

如果暫時無法生成 PNG 圖示，可以：

1. 在 `manifest.json` 中暫時移除 icons 部分
2. 或使用任何 16x16、48x48、128x128 的 PNG 圖片作為佔位符

擴展功能不會因為缺少圖示而無法運作，但會影響視覺呈現。