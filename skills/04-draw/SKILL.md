---
name: antigravity-draw
description: 使用 AntiGravity 內建能力或 OpenAI Image API 生圖。一般生圖預設走內建工具，只有明確指定 OpenAI 時才執行 API 腳本。
---

# AntiGravity 生圖

## 路線 A：內建生圖

一般「生圖／畫圖」請求預設使用 AntiGravity 當前提供的內建生圖工具，不要求 API Key。先確認用途、比例、內容、風格、文字、限制與輸出位置；完成後回報完整路徑。

## 路線 B：OpenAI Image API

只有使用者明確指定 OpenAI 時才使用：

```powershell
python .\skills\04-draw\scripts\draw_openai.py --prompt "<英文提示詞>" --output "<輸出路徑>" --model gpt-image-2 --quality low
```

API Key 只能從 `OPENAI_API_KEY` 環境變數讀取，禁止寫進腳本、Skill、Markdown 或 Git。支援 quality：`low`、`medium`、`high`。

## 驗收與安全

- 確認圖片存在、可開啟且尺寸符合需求。
- 回報使用路線、模型（若有）、quality 與完整輸出路徑。
- 重要中文文字需人工檢查，必要時後製。
- 不把暫存圖片全部 commit；刪除暫存檔前先詢問。
- API 失敗時不傾印可能含敏感內容的完整回應。
