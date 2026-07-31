# AntiGravity 懶人包 #01：連接 Gemini Notebook

> 版本：v2.1
>
> 更新日期：2026-08-01

## 這份懶人包會做什麼

安裝第三方 [`gemini-notebook-mcp-cli`](https://github.com/jacob-bd/gemini-notebook-mcp-cli) 專案發布的 PyPI 套件 `notebooklm-mcp-cli`，完成瀏覽器登入，並讓 AntiGravity 透過 `notebooklm-mcp` 連接 Gemini Notebook。

> [Google 已於 2026-07-16 將 NotebookLM 改名為 Gemini Notebook](https://workspaceupdates.googleblog.com/2026/07/notebooklm-now-gemini-notebook.html)，但 PyPI 套件 `notebooklm-mcp-cli`、CLI `nlm` 與 MCP 執行檔 `notebooklm-mcp` 目前仍沿用舊技術名稱，不要自行改成不存在的套件或指令。

> 這不是 Google 官方 Gemini Notebook API。工具會使用 Gemini Notebook 的內部介面，並在本機保存登入 profile 與瀏覽器認證資料；Google 更新介面後可能暫時失效。不要把認證資料、筆記本 ID 清單或個人匯出檔提交到 GitHub。

## 先備條件

- AntiGravity 可正常使用。
- Python 3.11 以上或 `uv`。
- 可登入 Gemini Notebook 的 Google 帳號。

## 步驟一：安裝或更新

安裝或更新會修改使用者層級的 `uv` tool，執行前先取得同意。

```powershell
uv --version
uv tool install notebooklm-mcp-cli
```

已安裝時改用：

```powershell
uv tool upgrade notebooklm-mcp-cli
```

若 `nlm` 顯示 `uv trampoline failed to canonicalize script path`，先用 `Get-Command nlm -All` 確認命中的舊 shim；取得重新安裝同意後執行：

```powershell
uv tool install --force notebooklm-mcp-cli
```

驗證兩個執行檔：

```powershell
nlm --version
Get-Command nlm, notebooklm-mcp -All
```

## 步驟二：登入

登入會開啟瀏覽器並在本機保存認證資料，執行前先取得同意。

```powershell
nlm login
nlm login --check
nlm doctor
```

`nlm login` 會開啟瀏覽器並自動擷取登入認證；這不是要求使用者手動貼 cookie，但工具仍會在本機使用與保存認證資料。

若 Windows 終端顯示編碼錯誤，可在同一個 PowerShell 視窗執行：

```powershell
$env:PYTHONIOENCODING = 'utf-8'
nlm doctor
```

## 步驟三：註冊 MCP

先用唯讀命令確認上游工具目前認定的 AntiGravity 設定位置：

```powershell
nlm setup list
```

本專案支援的 **AntiGravity IDE 2.0** 實際讀取：

```text
~/.gemini/config/mcp_config.json
```

截至 `notebooklm-mcp-cli 0.9.4`，`nlm setup list` 顯示的 AntiGravity 路徑是 `~/.gemini/antigravity/mcp_config.json`，與 IDE 2.0 的實際路徑不同。因此不要執行 `nlm setup add antigravity`；請使用下方合併流程修改正確檔案。未來版本若修正路徑，也必須先確認它明確顯示 `~/.gemini/config/mcp_config.json`，才能在取得同意後使用自動設定。

使用本懶人包時不需要另外執行 `nlm skill install antigravity`，避免再安裝一份上游 Skill。

在 AntiGravity 的 MCP 管理介面新增 server，或編輯全域設定：

```text
~/.gemini/config/mcp_config.json
```

修改設定時必須使用合併流程：

1. 若檔案已存在，先用 `Get-Content -Raw` 讀取，並以 `ConvertFrom-Json` 確認目前 JSON 合法。
2. 寫入前建立帶時間戳的備份，例如 `mcp_config.json.bak-20260801-120000`。
3. 只新增或更新 `.mcpServers.gemini-notebook`，保留其他 server；下方範例不可拿來覆蓋整份既有設定。
4. 若舊的 `.mcpServers.notebooklm` 或 `.mcpServers.notebooklm-mcp` 已存在，先顯示舊、新設定差異；取得同意後移除舊 key，不要讓兩個 server 同時暴露重複工具。
5. 若同名 server 已存在，先顯示差異並取得更新同意。
6. 寫入後再次使用 `Get-Content -Raw | ConvertFrom-Json` 驗證。

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

不要使用已失效的 `nlm mcp`。

## 步驟四：驗收

1. 完全重啟 AntiGravity。
2. 確認 `gemini-notebook` MCP 顯示已連線，執行命令仍是 `notebooklm-mcp`。
3. 請 Agent 列出筆記本；只回報數量或連線結果，不把完整清單寫進 repo。
4. 若要建立測試筆記本，建立前先確認，測試完成後再詢問是否刪除。

## 復原

- 從 `~/.gemini/config/mcp_config.json` 移除 `gemini-notebook` server，保留其他 server，寫入後再次解析驗證。
- 只有先前曾確認自動設定使用的就是這個檔案時，才可在取得同意後執行 `nlm setup remove antigravity`。
- 若仍有舊的 `notebooklm` server，先確認不是其他工具使用後再移除。
- 登出：`nlm logout`。
- 移除工具：`uv tool uninstall notebooklm-mcp-cli`。
- 刪除本機 profile 前先列出影響並取得使用者同意。
