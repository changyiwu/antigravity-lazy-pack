# Antigravity IDE 2.0 懶人包

這個 repo 收錄 Google Antigravity IDE 2.0 使用者可公開套用的服務連接與生圖教學。每個功能都有一份完整說明檔，以及一個對應的 Agent Skill。

目前主要支援 Windows 10／11 與 PowerShell，不適用於 Antigravity CLI。IDE 與 CLI 的全域 Skill 目錄不同，本專案只使用下方固定的 IDE 路徑。

本 repo 不放個人 NotebookLM 清單、研究產物、生成圖片、測試專案、API Key、token 或帳號憑證。

## 固定規則

- 專案規則的主要入口是 `agents.md`。
- 全域 Skill 統一安裝到 `~/.gemini/config/skills/<skill-name>/`。
- Windows 對應為 `C:\Users\<使用者>\.gemini\config\skills\<skill-name>\`。

## 使用方式

### 方式一：請 AI 列出並安裝

把這段交給你的 AI agent：

```text
這是 Antigravity IDE 懶人包：https://github.com/changyiwu/antigravity-lazy-pack
請讀取 README.md 與 SKILL.md，列出所有可用的懶人包，逐項問我要安裝哪些；不要未經確認就執行登入、建立專案或外部寫入。
```

下載或 clone 本 repo 後，可以直接安裝單一 Skill：

```powershell
.\scripts\install-skills.ps1 -Skill antigravity-notebooklm
```

安裝全部五個功能 Skill：

```powershell
.\scripts\install-skills.ps1 -All
```

安裝器會逐項要求確認；若目標已存在，預設不覆蓋，確認要更新時才加 `-Force`。只有已在外部流程取得完整授權的自動化情境，才使用 `-Confirm:$false`。安裝完成後，Skill 會位於 `~/.gemini/config/skills/`。

### 方式二：直接使用說明檔

1. 開啟下表對應的 Markdown 說明檔。
2. 把內容交給 AntiGravity 或其他 AI 編碼助理。
3. 遇到登入、全域安裝、建立測試資料或外部寫入時，由使用者確認後再繼續。

## 懶人包清單

| 編號 | 完整說明 | 對應 Skill | 說明 |
|---|---|---|---|
| 00 | [一次安裝全部](00-一次安裝全部.md) | 安裝派送入口，不另行安裝 | 逐項安裝與回報五個功能 Skill |
| 01 | [連接 NotebookLM](01-連接-NotebookLM.md) | `antigravity-notebooklm` | 第三方 NotebookLM CLI／MCP |
| 02 | [連接 GitHub](02-連接-GitHub.md) | `antigravity-github` | Git、GitHub CLI 與登入驗證 |
| 03 | [連接 Firebase](03-連接-Firebase.md) | `antigravity-firebase` | Firebase CLI、專案 context 與 MCP |
| 04 | [用 AntiGravity 生圖](04-用Antigravity生圖.md) | `antigravity-draw` | 內建生圖與 OpenAI API 進階路線 |
| 05 | [連接 Obsidian](05-連接-Obsidian.md) | `antigravity-obsidian` | Vault 與 MCPVault |

舊的單一大文件已改為[相容索引](AntiGravity專屬懶人包.md)，不再重複維護完整教學。

## 安全原則

- NotebookLM 整合是非 Google 官方工具，會在本機使用與保存瀏覽器認證資料。
- 不把 API Key、GitHub token、Firebase Admin 憑證或 NotebookLM 個人清單寫進 repo。
- 安裝 Skill 不代表授權立即登入、建立專案、建立測試資料或執行部署。
- 測試物件建立前先確認，完成後再詢問要保留或刪除。
- commit 前先檢查 diff，只提交本次相關檔案，不使用無差別 `git add .`。

## 專案結構

```text
README.md                 使用者入口與索引
agents.md                 跨 Agent 專案主要規則入口
SKILL.md                  AI 安裝派送入口
編號說明檔                一份安裝入口與五份功能教學
skills/*/SKILL.md         五個精簡可執行 Skill
scripts/                  Skill 安裝器與發布前驗證
```

## 發布前檢查

修改說明檔、Skill 或腳本後執行。先備條件是 Windows PowerShell 5.1 以上，以及 PATH 中可執行的 `python` 或 `py -3`：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\validate-lazy-pack.ps1
```

檢查內容包括章號、五個 Skill 與 manifest 一對一、安裝器模擬、Markdown 連結、JSON 範例、frontmatter、固定規則入口、全域 Skill 路徑、舊指令、敏感資料樣式、UTF-8、PowerShell／Python 語法，以及發布必備檔案。

## 授權

本專案的文件與程式碼採 [MIT License](LICENSE)。

## 相關系列

- Codex 懶人包：https://github.com/mathruffian-dot/codex-lazy-packs
- Claude Code 懶人包：https://github.com/mathruffian-dot/claude-code-lazy-packs
- OpenCode 懶人包：https://github.com/mathruffian-dot/opencode-lazy-packs
