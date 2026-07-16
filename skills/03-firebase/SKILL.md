---
name: antigravity-firebase
description: 在 AntiGravity 連接 Firebase MCP。使用者說「連接 Firebase」「設定 Firebase」時載入。
---

# 連接 Firebase

1. 檢查 `node --version` 與 `npm.cmd --version`。
2. 執行 `npx.cmd -y firebase-tools@latest --version`。
3. 尚未登入時先取得同意，再執行 `npx.cmd -y firebase-tools@latest login`。
4. 用 `npx.cmd -y firebase-tools@latest projects:list` 唯讀驗證。
5. 若已有專案，確認包含 `firebase.json` 的實際目錄；不要猜測或自行 `firebase init`。
6. 在 `~/.gemini/config/mcp_config.json` 加入：

```json
{
  "mcpServers": {
    "firebase": {
      "command": "npx.cmd",
      "args": ["-y", "firebase-tools@latest", "mcp"]
    }
  }
}
```

需要固定專案 context 時，在 args 後加入 `"--dir", "<含 firebase.json 的絕對路徑>"`。

安全規則：不公開 Admin SDK／service account 憑證；不自動建立專案、部署或修改安全規則；正式學生資料只用班級代號與座號。回報登入狀態、專案目錄、active project 與 MCP 狀態。
