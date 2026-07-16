---
name: antigravity-obsidian
description: 在 AntiGravity 透過 MCPVault 連接 Obsidian。使用者說「連接 Obsidian」「設定 Obsidian」時載入。
---

# 連接 Obsidian

1. 找到真正使用的 vault，確認資料夾存在且包含 `.obsidian`；寫入前由使用者確認實體路徑。
2. 全域安裝 MCPVault 前先取得同意：

```powershell
npm.cmd install -g @bitbonsai/mcpvault
Get-Command mcpvault
```

3. 在 `~/.gemini/config/mcp_config.json` 加入：

```json
{
  "mcpServers": {
    "obsidian": {
      "command": "C:\\Users\\<使用者>\\AppData\\Roaming\\npm\\mcpvault.cmd",
      "args": ["C:\\Users\\<使用者>\\Documents\\<vault>"]
    }
  }
}
```

4. 重啟 AntiGravity，先唯讀列出 vault 根目錄。
5. 建立測試筆記前先取得同意；讀回驗證後，再詢問保留或刪除。

安全規則：只授權必要 vault；不讀取無關私人筆記；不提交真實 vault 路徑或筆記內容；批次搬移、覆蓋或刪除前先顯示範圍並取得同意。回報 MCP 狀態、vault 驗證與測試筆記處理結果。
