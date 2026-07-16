# AntiGravity 懶人包 #02：連接 GitHub

> 版本：v2.0
>
> 更新日期：2026-07-17

## 這份懶人包會做什麼

檢查 Git 與 GitHub CLI、完成瀏覽器登入，設定 Git identity，並驗證目前帳號可以存取 GitHub。

## 先備條件

- 已安裝 Git。
- 已安裝 GitHub CLI `gh`。
- 有 GitHub 帳號。

## 步驟一：檢查與登入

```powershell
git --version
gh --version
gh auth status
```

尚未登入時：

```powershell
gh auth login --web --git-protocol https
gh auth status
```

瀏覽器授權需要使用者本人完成；不要要求使用者把 GitHub token 貼進 Markdown 或對話紀錄。

## 步驟二：設定 Git identity

先讀取現況：

```powershell
git config --global user.name
git config --global user.email
```

只有缺少或使用者要求變更時才設定：

```powershell
git config --global user.name "你的名字"
git config --global user.email "your-email@example.com"
```

不想公開個人信箱時可使用 GitHub no-reply email。

## 步驟三：驗收

```powershell
gh auth status
gh repo list --limit 5
```

驗收只需要確認登入帳號與可讀取 repo，不要在連線流程中自動建立、刪除、公開 repo，或修改預設 branch。

## 安全規則

- GitHub 與 GitHub Copilot 是不同服務；本流程只處理 Git、GitHub CLI 與帳號登入。
- 不把 token、密碼或憑證寫進 repo。
- commit 前先看 `git status` 與 diff。
- 不使用無差別 `git add .`。
- 建立 repo、push、刪除 repo、啟用 Pages 都要另外取得同意。

## 復原

```powershell
gh auth logout
```

Git identity 若需復原，先顯示目前值，再由使用者指定要移除或改回的內容。
