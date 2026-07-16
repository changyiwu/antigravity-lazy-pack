---
name: antigravity-install-all
description: 逐項安裝並設定全部 AntiGravity 懶人包。使用者說「全部安裝」「安裝所有 AntiGravity 懶人包」時載入。
---

# 一次安裝全部 AntiGravity 懶人包

全域 Skill 目標固定為 `~/.gemini/config/skills/<skill-name>/`。

依序處理：

1. `antigravity-notebooklm`
2. `antigravity-github`
3. `antigravity-firebase`
4. `antigravity-draw`
5. `antigravity-workflow`
6. `antigravity-obsidian`

## 執行規則

- 先檢查六項目前狀態。
- 每一項安裝或執行前都先取得使用者同意。
- 已安裝項目只驗證，不直接覆蓋。
- 安裝 Skill 不代表可以立即登入、建立專案、建立測試資料、生圖或修改外部服務。
- 使用完整 frontmatter 名稱，不使用 `01-notebooklm` 之類資料夾名當作 `--skill` 值。

在 repo 根目錄執行單項安裝：

```powershell
.\scripts\install-skills.ps1 -Skill <完整 Skill 名稱>
```

安裝器預設不覆蓋既有目標；只有使用者確認更新時才加 `-Force`。每完成一項回報：已安裝／已存在／跳過／失敗與實際路徑；最後列六項總表。中途停止時，說明已寫入內容與復原方式。
