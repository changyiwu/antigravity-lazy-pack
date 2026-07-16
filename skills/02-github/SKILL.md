---
name: antigravity-github
description: 在 AntiGravity 設定 Git 與 GitHub CLI。使用者說「連接 GitHub」「設定 GitHub」時載入。
---

# 連接 GitHub

1. 執行 `git --version`、`gh --version`、`gh auth status`。
2. 尚未登入時，先取得同意，再執行 `gh auth login --web --git-protocol https`。
3. 讀取 `git config --global user.name` 與 `user.email`；只有缺少或使用者要求時才修改。
4. 用 `gh auth status` 與 `gh repo list --limit 5` 做唯讀驗收。

安全規則：

- 不要求使用者把 token 貼進 Markdown 或 repo。
- 不在連線流程中自動建立／刪除 repo、push、啟用 Pages 或修改預設 branch。
- commit 前檢查 `git status` 與 diff，不使用無差別 `git add .`。
- 外部寫入與刪除都要另外取得授權。

回報 Git、GitHub CLI 版本、登入帳號、Git identity 與仍待處理事項。
