---
name: antigravity-draw
description: AntiGravity 生圖指引。說「生圖」「畫圖」「產生圖片」或特別提到「用 OpenAI 生圖/畫圖/說圖」時載入。
---

# 生圖（AntiGravity 版）

## 生圖路線

| 路線 | 說明 | 觸發條件 | 執行方式 |
|------|------|------|------|
| A：內建生圖 | 直接使用 AntiGravity 內建的 generate_image 工具產圖，不需 API Key | 預設生圖請求（如「幫我生一張貓的圖」） | 呼叫 `generate_image` 工具 |
| B：OpenAI 生圖 | 使用內建的 Python 腳本呼叫 OpenAI 生圖 API | 當明確要求「用 OpenAI 生圖」、「使用 OpenAI 說圖」、「用 OpenAI 畫圖」時 | 執行 `python skills/04-draw/scripts/draw_openai.py --prompt "..." --output "..."` |

## OpenAI 生圖使用指南

若使用者要求**使用 OpenAI**（或指定用 DALL-E 3）進行生圖：
1. 提取使用者的提示詞（Prompt），並轉換為適合生圖模型的英文描述以獲得最佳效果。
2. 決定輸出路徑（例如專案中的 `assets/` 資料夾，或是暫存目錄 `scratch/` ）。
3. 使用 `run_command` 工具執行以下指令：
   ```bash
   python "skills/04-draw/scripts/draw_openai.py" --prompt "<英文提示詞>" --output "<輸出路徑>"
   ```
4. 預設的 API Key 已寫入於 `draw_openai.py` 中。如需使用其他 Key，可透過設定環境變數 `OPENAI_API_KEY` 來覆蓋。
5. 腳本預設採用 `gpt-image-2` 模型生圖，並兼容 `base64` 與 `url` 兩種 API 回傳格式。若需使用其他模型，可加帶 `--model dall-e-3` 參數。

## 建議提示格式

```
生成一張圖片：
用途：
尺寸比例：
主題：
畫面內容：
風格：
色彩：
文字：
限制：
輸出位置：
```

## 注意
- 重要中文文字建議後製（生圖模型可能出錯）
- 專案圖片放 `assets/` 資料夾

