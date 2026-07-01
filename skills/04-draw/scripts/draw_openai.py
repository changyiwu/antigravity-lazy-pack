import argparse
import json
import os
import sys
import urllib.request
import urllib.error

# 預設的 OpenAI API Key (專案層級請保持為空，以免不小心 commit 外流)
DEFAULT_API_KEY = ""

def get_api_key():
    # 優先從環境變數讀取，若無則使用寫入的預設金鑰
    return os.environ.get("OPENAI_API_KEY", DEFAULT_API_KEY)

def draw_image(prompt, output_path, size="1024x1024", model="gpt-image-2", quality="low"):
    api_key = get_api_key()
    if not api_key:
        print("Error: OpenAI API Key is missing.", file=sys.stderr)
        sys.exit(1)

    url = "https://api.openai.com/v1/images/generations"
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key}"
    }
    
    data = {
        "model": model,
        "prompt": prompt,
        "n": 1,
        "size": size,
        "quality": quality
    }
    
    req_data = json.dumps(data).encode("utf-8")
    req = urllib.request.Request(url, data=req_data, headers=headers, method="POST")
    
    print(f"Sending request to OpenAI (Model: {model}, Size: {size}, Quality: {quality})...")
    print(f"Prompt: {prompt}")
    
    try:
        with urllib.request.urlopen(req) as response:
            res_body = response.read().decode("utf-8")
            res_json = json.loads(res_body)
            
            data_item = res_json.get("data", [{}])[0]
            
            if "url" in data_item:
                image_url = data_item["url"]
                print(f"Image generated successfully. Downloading from URL: {image_url}")
                # 確保輸出目錄存在
                output_dir = os.path.dirname(output_path)
                if output_dir and not os.path.exists(output_dir):
                    os.makedirs(output_dir, exist_ok=True)
                urllib.request.urlretrieve(image_url, output_path)
                print(f"Image saved to: {output_path}")
            elif "b64_json" in data_item:
                print("Image generated successfully. Decoding from base64...")
                import base64
                b64_data = data_item["b64_json"]
                image_data = base64.b64decode(b64_data)
                # 確保輸出目錄存在
                output_dir = os.path.dirname(output_path)
                if output_dir and not os.path.exists(output_dir):
                    os.makedirs(output_dir, exist_ok=True)
                with open(output_path, "wb") as f:
                    f.write(image_data)
                print(f"Image saved to: {output_path}")
            else:
                print("Error: No image URL or base64 data found in the response.", file=sys.stderr)
                print("Full API response body:", file=sys.stderr)
                print(res_body, file=sys.stderr)
                sys.exit(1)
            
    except urllib.error.HTTPError as e:
        print(f"HTTP Error {e.code}: {e.reason}", file=sys.stderr)
        try:
            error_details = e.read().decode("utf-8")
            print(f"Details: {error_details}", file=sys.stderr)
        except Exception:
            pass
        sys.exit(1)
    except Exception as e:
        print(f"Error occurred: {e}", file=sys.stderr)
        if 'res_body' in locals():
            print(f"Response body was: {res_body}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate image using OpenAI Image API")
    parser.add_argument("--prompt", required=True, help="The prompt to generate image")
    parser.add_argument("--output", default="output.png", help="The output file path for the image")
    parser.add_argument("--size", default="1024x1024", help="Image size (default: 1024x1024)")
    parser.add_argument("--model", default="gpt-image-2", help="OpenAI image model (default: gpt-image-2, or dall-e-3)")
    parser.add_argument("--quality", default="low", choices=["low", "medium", "high"], help="Image quality (default: low, choices: low, medium, high)")
    args = parser.parse_args()
    
    draw_image(args.prompt, args.output, args.size, args.model, args.quality)
