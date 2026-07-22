# AntiGravity 懶人包 #05：連接 Obsidian

> 版本：v2.0
>
> 更新日期：2026-07-17

## 這份懶人包會做什麼

確認真正使用的 Obsidian vault，安裝 MCPVault，並讓 AntiGravity 可以在授權範圍內讀寫 Markdown 筆記。

## 步驟一：確認 vault

常見位置：

```text
C:\Users\<使用者>\OneDrive\文件\<vault>
C:\Users\<使用者>\Documents\<vault>
G:\我的雲端硬碟\<vault>
```

確認條件：

- 資料夾存在。
- 內含 `.obsidian`。
- 是使用者日常真正使用的 vault。
- 寫入前由使用者確認實體路徑。

## 步驟二：安裝 MCPVault

全域 npm 安裝會修改使用者環境，執行前先確認：

```powershell
npm.cmd install -g @bitbonsai/mcpvault
Get-Command mcpvault
```

Windows 常見執行檔：

```text
C:\Users\<使用者>\AppData\Roaming\npm\mcpvault.cmd
```

## 步驟三：註冊 MCP

在 `~/.gemini/config/mcp_config.json` 加入：

修改設定時必須使用合併流程：

1. 若檔案已存在，先用 `Get-Content -Raw | ConvertFrom-Json` 確認 JSON 合法。
2. 寫入前建立帶時間戳的備份。
3. 只新增或更新 `.mcpServers.obsidian`，保留其他 server；下方範例不可覆蓋整份既有設定。
4. 若同名 server 已存在，先顯示差異並取得更新同意。
5. 寫入後再次解析 JSON 驗證。

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

實際 vault 路徑屬於本機設定，不要複製回公開教學檔或 commit 到公開 repo。

## 步驟四：驗收

1. 完全重啟 AntiGravity。
2. 測試列出 vault 根目錄。
3. 建立測試筆記前先取得同意。
4. 建立後讀回內容，確認編碼與路徑正確。
5. 再詢問要保留或刪除測試筆記。

## 安全規則

- 只授權必要的 vault，不把整個使用者家目錄交給 MCP。
- 不讀取或回傳與任務無關的私人筆記。
- 批次搬移、覆蓋或刪除筆記前必須先顯示範圍並取得同意。
- 不把 vault 實體路徑、私人筆記或附件提交到公開 repo。

## 復原

- 從 `mcp_config.json` 移除 `obsidian` server。
- 卸載：`npm.cmd uninstall -g @bitbonsai/mcpvault`。
- 移除 MCP 不會刪除 vault；任何測試筆記仍需另外確認後處理。
