---
name: antigravity-workflow
description: 使用 ANTIGRAVITY.md 執行 AntiGravity 開工、收工與新專案初始化流程。使用者說「開工」「收工」「初始化專案」時載入。
---

# 開工／收工／新專案初始化

固定規則：

- 專案主要規則入口是根目錄 `ANTIGRAVITY.md`，不要改用其他規則檔取代。
- 全域 Skill 安裝到 `~/.gemini/config/skills/<skill-name>/`。

## 開工

1. 讀取 `ANTIGRAVITY.md`。
2. 依其中設定讀取 Obsidian 專案駕駛艙。
3. 執行 `git status --short --branch` 與最近 commit 檢查。
4. 回報狀態、風險與建議下一步。
5. 不自動 pull、commit 或 push。

## 收工

1. 檢查 diff、敏感資料與無關變更。
2. 執行適合的專案驗證。
3. 更新 Obsidian 駕駛艙；只有固定規則改變時才更新 `ANTIGRAVITY.md`。
4. 只 stage 本次相關檔案，不使用無差別 `git add .`。
5. commit／push 前確認 remote、branch 與授權。
6. 回報本機、Obsidian 與 GitHub 狀態。

## 新專案初始化

先確認名稱、用途、資料夾、GitHub repo／公開性、部署需求與 Obsidian 位置。盤點後只補缺少的 `ANTIGRAVITY.md`、README、`.gitignore`、Git、GitHub repo 與專案駕駛艙；不可覆蓋既有檔案或未經同意建立外部資源。
