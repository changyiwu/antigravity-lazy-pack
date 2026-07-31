---
name: antigravity-gemini-notebook
description: 在 AntiGravity 連接第三方 Gemini Notebook MCP。使用者說「連接 Gemini Notebook」「設定 Gemini Notebook」，或使用舊稱「連接 NotebookLM」「設定 NotebookLM」時載入。
---

# 連接 Gemini Notebook

> 上游 Repo 已改名為 `gemini-notebook-mcp-cli`，但 PyPI 套件 `notebooklm-mcp-cli`、CLI `nlm` 與 MCP 執行檔 `notebooklm-mcp` 仍沿用舊技術名稱。這是非 Google 官方工具，使用 Gemini Notebook 內部介面，並在本機保存登入 profile 與瀏覽器認證資料。不要提交憑證、筆記本 ID 清單或個人匯出檔。

1. 檢查 `uv --version`。
2. 取得同意後，未安裝時執行 `uv tool install notebooklm-mcp-cli`；已安裝則用 `uv tool upgrade notebooklm-mcp-cli`。
3. 驗證 `nlm --version` 與 `Get-Command nlm, notebooklm-mcp -All`；若出現失效的 uv trampoline，取得同意後用 `uv tool install --force notebooklm-mcp-cli` 修復。
4. 說明本機認證影響並取得同意後，執行 `nlm login`，再用 `nlm login --check` 與 `nlm doctor` 驗證。
5. 先執行唯讀的 `nlm setup list` 檢查上游工具認定的 AntiGravity 設定位置。AntiGravity IDE 2.0 只接受 `~/.gemini/config/mcp_config.json`；截至 `notebooklm-mcp-cli 0.9.4`，工具顯示的是不相容的 `~/.gemini/antigravity/mcp_config.json`，因此不要執行 `nlm setup add antigravity`。未來版本也只有明確顯示正確路徑時，才能在取得同意後使用自動設定。不要另外執行 `nlm skill install antigravity`，避免重複安裝上游 Skill。
6. 說明會修改使用者 MCP 設定並取得同意後，先解析並備份 `~/.gemini/config/mcp_config.json`，只合併 `.mcpServers.gemini-notebook`，保留其他 server；若舊的 `.mcpServers.notebooklm` 或 `.mcpServers.notebooklm-mcp` 存在，顯示差異並取得同意後移除舊 key，避免兩個 server 同時暴露重複工具；寫入後再解析驗證：

```json
{
  "mcpServers": {
    "gemini-notebook": {
      "command": "notebooklm-mcp",
      "args": []
    }
  }
}
```

7. 重啟 AntiGravity，確認 `gemini-notebook` MCP 已連線（執行命令仍是 `notebooklm-mcp`），並驗證能列出筆記本。
8. 若要建立測試筆記本，建立前先確認，完成後再問是否刪除。

不可使用 `nlm mcp`。回報工具版本、登入狀態、MCP 狀態與測試資料處理結果。
