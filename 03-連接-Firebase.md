# AntiGravity 懶人包 #03：連接 Firebase

> 版本：v2.0
>
> 更新日期：2026-07-17

## 這份懶人包會做什麼

使用官方 `firebase-tools` 登入 Firebase，並把 Firebase MCP server 加入 AntiGravity。

## 先備條件

- Node.js 與 npm。
- Google／Firebase 帳號。
- 若要操作既有專案，先知道包含 `firebase.json` 的專案資料夾。

## 步驟一：檢查與登入

Windows 使用 `npx.cmd`，避免 PowerShell 執行原則攔截 `.ps1`：

```powershell
npx.cmd -y firebase-tools@latest --version
npx.cmd -y firebase-tools@latest login
npx.cmd -y firebase-tools@latest projects:list
```

登入需要使用者在瀏覽器完成。連線流程不會自動建立 Firebase 專案或部署安全規則。

## 步驟二：確認專案目錄

若已有 Firebase 專案，先確認實際資料夾：

```powershell
Test-Path .\firebase.json
Get-Location
```

沒有 `firebase.json` 時，不要猜測專案 context，也不要自行執行 `firebase init`。

## 步驟三：註冊 MCP

在 `~/.gemini/config/mcp_config.json` 加入：

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

若要固定到特定專案，加入絕對路徑：

```json
{
  "mcpServers": {
    "firebase": {
      "command": "npx.cmd",
      "args": [
        "-y",
        "firebase-tools@latest",
        "mcp",
        "--dir",
        "C:\\path\\to\\firebase-project"
      ]
    }
  }
}
```

## 步驟四：驗收

1. 重啟 AntiGravity。
2. 先測登入狀態與列出 Firebase 專案。
3. 確認 active project 與 project directory 正確。
4. 預設只做唯讀查詢；寫入資料、建立服務或部署前另外確認。

## 安全規則

- Firebase 前端 config 通常可公開，但 Admin SDK／service account 憑證不可公開。
- `.firebaserc` 可能包含專案 ID，公開前先確認。
- 不自動修改或部署 Firestore、Storage、Realtime Database 安全規則。
- 學生正式資料只使用班級代號與座號，不存真名。

## 復原

- 從 `mcp_config.json` 移除 `firebase` server。
- 登出：`npx.cmd -y firebase-tools@latest logout`。
- 移除 MCP 設定不會刪除 Firebase 專案或雲端資料。
