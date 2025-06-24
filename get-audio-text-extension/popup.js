// popup.js
document.addEventListener('DOMContentLoaded', async () => {
  const statusDiv = document.getElementById('status');
  const statusText = document.getElementById('status-text');
  
  try {
    // 獲取當前標籤頁
    const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
    
    if (tab && tab.url) {
      const supportedSites = [
        'youtube.com',
        'instagram.com',
        'tiktok.com'
      ];
      
      const isSupported = supportedSites.some(site => tab.url.includes(site));
      
      if (isSupported) {
        statusDiv.className = 'status supported';
        statusText.textContent = '✅ 此網站支援音訊轉錄';
      } else {
        statusDiv.className = 'status not-supported';
        statusText.textContent = '❌ 此網站不支援';
      }
    }
  } catch (error) {
    statusDiv.className = 'status not-supported';
    statusText.textContent = '❌ 無法檢查網站狀態';
  }
});