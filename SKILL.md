---
name: antigravity-lazy-packs
description: Antigravity IDE 懶人包安裝入口。列出 Gemini Notebook（原 NotebookLM）、GitHub、Firebase、生圖與 Obsidian 等五個可安裝 Skill，逐項取得同意後安裝。
---

# AntiGravity 懶人包安裝入口

當使用者提供本 repo 並要求安裝時，先讀取 `README.md` 與本檔，再依下列流程執行。

需要一次處理全部項目時，讀取 `00-一次安裝全部.md`；00 是派送說明，不是額外的可安裝 Skill。

## 可用懶人包

| 編號 | 完整 Skill 名稱 | 說明檔 |
|---|---|---|
| 01 | `antigravity-gemini-notebook` | `01-連接-Gemini-Notebook.md` |
| 02 | `antigravity-github` | `02-連接-GitHub.md` |
| 03 | `antigravity-obsidian` | `03-連接-Obsidian.md` |
| 04 | `antigravity-firebase` | `04-連接-Firebase.md` |
| 05 | `antigravity-draw` | `05-用Antigravity生圖.md` |

## 安裝流程

1. 列出上表與目前安裝狀態。
2. 問使用者要安裝哪些；接受「全部」或編號組合。
3. 將編號轉成上表的完整 Skill 名稱。
4. 每一項安裝前逐項確認，不把安裝 Skill 當成執行外部登入或寫入的授權。
5. 在 repo 根目錄使用：

```powershell
.\scripts\install-skills.ps1 -Skill <完整 Skill 名稱>
```

全域安裝目標固定為：

```text
~/.gemini/config/skills/<skill-name>/
```

安裝器預設逐項要求確認，且不覆蓋既有目標；只有使用者確認更新時才加 `-Force`。若偵測到舊版 `antigravity-notebooklm`，先列出舊、新完整路徑；取得同意後才加 `-MigrateLegacy`，安裝新版並移除舊版，避免兩個 Skill 同時觸發。`00-一次安裝全部.md` 與本檔只負責第一次安裝，不會安裝成額外 Skill。只有已在外部流程取得完整授權的自動化情境，才使用 `-Confirm:$false`。如果無法執行 PowerShell 安裝器，才手動複製對應的 `skills/<資料夾>/` 到上述目錄。

## 回報

每項分別回報：已安裝／已存在／跳過／失敗，以及實際安裝路徑。若流程中途停止，明確說明已寫入哪些檔案與如何復原。
