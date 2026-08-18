# 阿茲塔瑞記憶遊戲助手

這是一個語音錄製網頁：玩家說「開始」後錄入光柱順序，停頓 3.5 秒便自動播放剛才的內容。

## 本機使用

雙擊 `启动本地页面.cmd`，再在瀏覽器開啟 `http://localhost:8080/`。首次使用請允許麥克風權限。

## 部署到 Vercel

1. 將此 Git 倉庫推送到 GitHub、GitLab 或 Bitbucket。
2. 在 Vercel 選擇 **Add New → Project**，匯入該倉庫。
3. Framework Preset 選擇 **Other**，不需設定 Build Command 或 Output Directory。
4. 點擊 Deploy。

Vercel 會提供 HTTPS 網址，瀏覽器便能正確要求麥克風權限。語音辨識使用 Chrome／Edge 的 Web Speech API。

## 使用統計

部署環境會透過 `api/counter.js` 記錄頁面瀏覽與「開始監聽」點擊次數。Redis 憑證需僅存在於 Vercel Environment Variables，並使用 `WDSS_REDIS_KV_REST_API_URL` 與 `WDSS_REDIS_KV_REST_API_TOKEN`；不要將任何憑證提交到 Git。
