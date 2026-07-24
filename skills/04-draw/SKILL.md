---
name: antigravity-draw
description: 使用 Antigravity IDE 當前實際可用的內建工具或 OpenAI Image API 生圖。只有確認內建工具存在時才走內建路線；明確指定 OpenAI 時執行 API 腳本。
---

# AntiGravity 生圖

## 路線 A：內建生圖

先確認目前介面確實存在可呼叫的內建生圖工具；存在時才使用，不要求 API Key。若找不到，回報現況並詢問是否改走 OpenAI。先確認用途、比例、內容、風格、文字、限制與輸出位置；完成後回報完整路徑。

## 路線 B：OpenAI Image API

只有使用者明確指定 OpenAI 時才使用：

```powershell
python "$HOME/.gemini/config/skills/antigravity-draw/scripts/draw_openai.py" --prompt "<英文提示詞>" --output "<輸出路徑.png>" --model gpt-image-2 --output-format png --quality low
```

API Key 只能從 `OPENAI_API_KEY` 環境變數讀取，禁止寫進腳本、Skill、Markdown 或 Git。支援 quality：`low`、`medium`、`high`；支援格式：`png`、`jpeg`、`webp`，副檔名必須一致。

## 驗收與安全

- 確認圖片存在、可開啟且尺寸符合需求。
- 回報使用路線、模型（若有）、quality 與完整輸出路徑。
- 重要中文文字需人工檢查，必要時後製。
- 不把暫存圖片全部 commit；刪除暫存檔前先詢問。
- API 失敗時不傾印可能含敏感內容的完整回應。
- 不在終端輸出完整 prompt；只回報安全的狀態碼、原因與 request ID。
