// background.js
chrome.runtime.onInstalled.addListener(() => {
  console.log('Get Audio Text 擴充套件已安裝');
});

// 監聽來自 content script 的消息
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.action === 'downloadFile') {
    chrome.downloads.download({
      url: request.url,
      filename: request.filename,
      saveAs: true
    }).then(() => {
      sendResponse({ success: true });
    }).catch((error) => {
      sendResponse({ success: false, error: error.message });
    });
    return true; // 保持消息通道開放
  }

  if (request.type === 'downloadModel') {
    fetch(request.url)
      .then(resp => resp.arrayBuffer())
      .then(buf => {
        sendResponse({ success: true, buffer: buf });
      })
      .catch(e => {
        sendResponse({ success: false, error: e.message });
      });
    return true; // async response
  }
});