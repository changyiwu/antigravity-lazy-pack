# antigravity-lazy-pack（專案藍圖）

> 本檔為跨 Agent 通用的專案藍圖（AGENTS.md 開放標準）。任何 Agent 的每個 session 都應先讀本檔＋`handoff.md`。

## 專案簡介

Antigravity IDE 2.0 專屬的服務連接與生圖懶人包。與 `claude-code-lazy-packs/`、`codex-lazy-packs/`、`opencode-lazy-packs/` 平行：同一套教學脈絡，分別給不同 AI 編碼代理使用。目前收斂為五個功能 Skill。

## 關鍵時程

<!-- 目前無固定時程 -->

## 目標與路線圖

- [x] 階段一：五個功能 Skill 成形（一次安裝全部、NotebookLM、GitHub、Firebase、生圖、Obsidian）
- [x] 階段二：移除內建工作流程 Skill，Obsidian 重編為 #05，規則入口由 `ANTIGRAVITY.md` 遷移為 `agents.md`
- [x] 階段三：發布驗證通過，文件／manifest／安裝器／Skill 編號全數同步
- [ ] 階段四：重跑全域 Skill 安裝，確認五個 Antigravity Skills 均為最新版
- [ ] 階段五：新增懶人包時維持文件、manifest、安裝器與驗證器同步

## 資料夾結構

```
antigravity-lazy-pack/
├─ README.md                    # 使用者入口
├─ SKILL.md                     # 懶人包入口 Skill
├─ AntiGravity專屬懶人包.md      # 總覽文件
├─ 00-一次安裝全部.md
├─ 01-連接-NotebookLM.md
├─ 02-連接-GitHub.md
├─ 03-連接-Firebase.md
├─ 04-用Antigravity生圖.md
├─ 05-連接-Obsidian.md
├─ skills/                      # 可安裝的子技能
├─ scripts/                     # 驗證與輔助腳本
├─ agents.md                    # 本檔：專案藍圖
├─ handoff.md                   # 交接檔（每次收工必更新）
├─ .agents/  .github/  .gitattributes  .gitignore
└─ LICENSE
```

## 同步層級（本專案初始化至第 3 層級）

| 層級 | 平台 | 位置 | 讀取時機 |
|------|------|------|---------|
| L1 | 本地（GDrive） | `agents.md`＋`handoff.md` | 每個 session |
| L2 | GitHub | https://github.com/changyiwu/antigravity-lazy-pack （公開） | 指定時 |
| L3 | Obsidian | `antigravity-lazy-pack/專案工作流程.md` | 有需要時 |

## 工作約定

- 任何 Agent、任何電腦：**開工先讀 `handoff.md`，收工必更新 `handoff.md`**
- 修改共用檔案前先讀最新內容，避免覆蓋其他 Agent 的變更
- 所有回應與文件使用繁體中文；涉及檔案操作時回報完整產出位置
- Windows 指令優先使用 PowerShell 語法
- 本專案主要支援 Antigravity IDE 2.0、Windows 10／11 與 PowerShell；**不要把 CLI 操作路徑混入 IDE 教學**
- 修改前先檢查 Git 狀態，只處理本次任務相關變更
- 不把每日流水帳寫進本檔；詳細脈絡寫 Obsidian 專案筆記
- 專案規則入口已是本檔，**不要重新建立 `ANTIGRAVITY.md`**

## 專案特殊規則

- Antigravity 全域 Skill 安裝到 `~/.gemini/config/skills/<skill-name>/`；Windows 對應為 `C:\Users\<使用者>\.gemini\config\skills\<skill-name>\`

## 安全與隱私

- 不要 commit API key、token、密碼或 Firebase Admin 憑證
- 不要 commit NotebookLM 個人匯出清單或筆記本 ID 清單
- 不要提交真實 Vault 路徑或私人筆記內容
- 不要自動納入無關的 Git 變更
- 不要儲存學生真名；正式資料只使用班級代號與座號

## 最近進度

- 2026-07-22：移除內建工作流程 Skill、將 Obsidian 懶人包重編為 #05，並把專案規則入口由 `ANTIGRAVITY.md` 遷移為本檔；發布驗證已通過。
- 2026-07-24：專案藍圖改用標準範本格式（補上路線圖 checklist、資料夾結構與同步層級表）。
