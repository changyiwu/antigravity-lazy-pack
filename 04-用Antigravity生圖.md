# AntiGravity 懶人包 #04：用 AntiGravity 生圖

> 版本：v2.0
>
> 更新日期：2026-07-17

## 這份懶人包會做什麼

提供兩條生圖路線：若目前 Antigravity IDE 版本確實提供可用的內建生圖工具，優先使用該工具；只有使用者明確指定 OpenAI API 時，才執行專案附帶的 Python 腳本。

## 路線 A：AntiGravity 內建生圖

只有目前介面能實際找到並呼叫內建生圖工具時才使用。若找不到，不要假裝已具備該能力，應回報現況並詢問是否改走 OpenAI Image API。

適合一般「幫我生圖／畫圖」請求：

1. 確認用途、比例、主題、風格、文字與輸出位置。
2. 使用 AntiGravity 當前提供的生圖能力。
3. 將成品存到使用者指定的專案 `assets/`，或暫存目錄。
4. 回報實際完整路徑。

不需要 OpenAI API Key，也不要因為專案內有腳本就自動改走 API。

## 路線 B：OpenAI Image API

只有使用者明確說「用 OpenAI 生圖」時使用。

### 設定 API Key

API Key 只從環境變數讀取，禁止寫進腳本、Markdown 或 Git：

```powershell
$env:OPENAI_API_KEY = '你的 API Key'
```

### 執行

```powershell
python .\skills\04-draw\scripts\draw_openai.py `
  --prompt "English image prompt" `
  --output ".\assets\output.png" `
  --model gpt-image-2 `
  --output-format png `
  --quality low
```

可用 quality：`low`、`medium`、`high`。可用輸出格式：`png`、`jpeg`、`webp`，檔名副檔名必須一致。目前腳本以 `gpt-image-2` 為預設，不再把已淘汰的 DALL-E 模型列為建議選項。

## 建議提示格式

```text
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

## 驗收

- 圖片檔存在且可以開啟。
- 尺寸與格式符合需求。
- 回報使用路線、模型（若有）、quality 與完整輸出路徑。
- 中文文字需人工檢查；重要文字建議後製。

## 安全與清理

- 不印出或回報 API Key。
- 不在終端輸出完整 prompt 或原始 API 錯誤本文。
- 不把臨時圖片全部提交到懶人包 repo。
- 暫存圖片若要刪除，先詢問使用者。
- API 失敗時只回報狀態碼、原因與 request ID（若有），不傾印可能含敏感內容的完整回應。
