# antigravity-lazy-pack（跨 Agent 專案規則）

> 本檔是 Codex、Claude、Gemini、Antigravity 與其他 Agent 共用的專案規則入口。

## 專案入口

- 專案名稱：`antigravity-lazy-pack`
- 專案用途：Antigravity IDE 2.0 專屬服務連接與生圖懶人包
- 主要工作目錄：`C:\Users\chang\我的雲端硬碟\agents\antigravity-lazy-pack`
- GitHub repo：<https://github.com/changyiwu/antigravity-lazy-pack.git>
- 預設分支：`main`

## Obsidian 對應筆記

- Vault：`C:\Users\chang\我的雲端硬碟\2ndbrain`
- 專案筆記：`antigravity-lazy-pack/專案工作流程.md`

## 通用工作規則

- 所有回應使用繁體中文。
- 涉及檔案操作時，回報完整產出位置。
- Windows 指令優先使用 PowerShell 語法。
- 本專案主要支援 Antigravity IDE 2.0、Windows 10／11 與 PowerShell；不要把 CLI 操作路徑混入 IDE 教學。
- 修改前先檢查 Git 狀態，只處理本次任務相關變更。
- 不把每日流水帳寫進本檔；專案進度記錄於 Obsidian 專案筆記。

## 專案特殊規則

- Antigravity 全域 Skill 安裝到 `~/.gemini/config/skills/<skill-name>/`；Windows 對應為 `C:\Users\<使用者>\.gemini\config\skills\<skill-name>\`。

## 安全與隱私

- 不要 commit API key、token、密碼或 Firebase Admin 憑證。
- 不要 commit NotebookLM 個人匯出清單或筆記本 ID 清單。
- 不要自動納入無關的 Git 變更。
- 不要儲存學生真名；正式資料只使用班級代號與座號。

## 最近進度

- 2026-07-22：移除內建工作流程 Skill、將 Obsidian 懶人包重編為 #05，並把專案規則入口由 `ANTIGRAVITY.md` 遷移為本檔；發布驗證已通過。
