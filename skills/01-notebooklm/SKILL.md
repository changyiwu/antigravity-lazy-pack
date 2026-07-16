---
name: antigravity-notebooklm
description: 在 AntiGravity 連接第三方 NotebookLM MCP。使用者說「連接 NotebookLM」「設定 NotebookLM」時載入。
---

# 連接 NotebookLM

> `notebooklm-mcp-cli` 是非 Google 官方工具，使用 NotebookLM 內部介面，並在本機保存登入 profile 與瀏覽器認證資料。不要提交憑證、筆記本 ID 清單或個人匯出檔。

1. 檢查 `uv --version`。
2. 未安裝時執行 `uv tool install notebooklm-mcp-cli`；已安裝則用 `uv tool upgrade notebooklm-mcp-cli`。
3. 驗證 `nlm --version` 與 `Get-Command nlm, notebooklm-mcp`。
4. 執行 `nlm login`，再用 `nlm login --check` 與 `nlm doctor` 驗證。
5. 在 `~/.gemini/config/mcp_config.json` 加入：

```json
{
  "mcpServers": {
    "notebooklm": {
      "command": "notebooklm-mcp",
      "args": []
    }
  }
}
```

6. 重啟 AntiGravity，驗證能列出筆記本。
7. 若要建立測試筆記本，建立前先確認，完成後再問是否刪除。

不可使用 `nlm mcp`。回報工具版本、登入狀態、MCP 狀態與測試資料處理結果。
