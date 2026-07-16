import argparse
import base64
import binascii
import json
import os
from pathlib import Path
import sys
import tempfile
import urllib.error
import urllib.request


OUTPUT_EXTENSIONS = {
    "png": {".png"},
    "jpeg": {".jpg", ".jpeg"},
    "webp": {".webp"},
}


def get_api_key():
    # API Key 只允許從環境變數讀取，避免寫進腳本或 Git。
    return os.environ.get("OPENAI_API_KEY", "").strip()


def validate_output_path(output_path, output_format):
    path = Path(output_path).expanduser()
    allowed_extensions = OUTPUT_EXTENSIONS[output_format]
    if path.suffix.lower() not in allowed_extensions:
        expected = ", ".join(sorted(allowed_extensions))
        raise ValueError(
            f"Output extension must match --output-format {output_format}: {expected}"
        )
    return path


def atomic_write_bytes(output_path, image_data):
    output_path.parent.mkdir(parents=True, exist_ok=True)
    file_descriptor, temp_name = tempfile.mkstemp(
        prefix=f".{output_path.name}.",
        suffix=".tmp",
        dir=output_path.parent,
    )
    try:
        with os.fdopen(file_descriptor, "wb") as temp_file:
            temp_file.write(image_data)
            temp_file.flush()
            os.fsync(temp_file.fileno())
        os.replace(temp_name, output_path)
    except Exception:
        try:
            os.unlink(temp_name)
        except FileNotFoundError:
            pass
        raise


def download_image(image_url, output_path, timeout):
    request = urllib.request.Request(
        image_url,
        headers={"User-Agent": "antigravity-lazy-pack/2.0"},
    )
    with urllib.request.urlopen(request, timeout=timeout) as response:
        atomic_write_bytes(output_path, response.read())


def draw_image(
    prompt,
    output_path,
    size="1024x1024",
    model="gpt-image-2",
    quality="low",
    output_format="png",
    timeout=120,
):
    api_key = get_api_key()
    if not api_key:
        print("Error: OpenAI API Key is missing.", file=sys.stderr)
        return 1

    url = "https://api.openai.com/v1/images/generations"
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key}",
        "User-Agent": "antigravity-lazy-pack/2.0",
    }
    data = {
        "model": model,
        "prompt": prompt,
        "n": 1,
        "size": size,
        "quality": quality,
        "output_format": output_format,
    }

    request = urllib.request.Request(
        url,
        data=json.dumps(data).encode("utf-8"),
        headers=headers,
        method="POST",
    )

    print(
        f"Sending request to OpenAI (Model: {model}, Size: {size}, "
        f"Quality: {quality}, Format: {output_format})..."
    )
    print("Prompt omitted from terminal output for privacy.")

    try:
        with urllib.request.urlopen(request, timeout=timeout) as response:
            response_json = json.loads(response.read().decode("utf-8"))

        response_data = response_json.get("data")
        if not isinstance(response_data, list) or not response_data:
            raise ValueError("API response did not contain image data.")

        data_item = response_data[0]
        if not isinstance(data_item, dict):
            raise ValueError("API response image item was invalid.")

        if data_item.get("b64_json"):
            image_data = base64.b64decode(data_item["b64_json"], validate=True)
            atomic_write_bytes(output_path, image_data)
        elif data_item.get("url"):
            download_image(data_item["url"], output_path, timeout)
        else:
            raise ValueError("API response did not contain base64 data or an image URL.")

        print(f"Image saved to: {output_path.resolve()}")
        return 0
    except urllib.error.HTTPError as error:
        request_id = error.headers.get("x-request-id") if error.headers else None
        request_id_text = f", Request ID: {request_id}" if request_id else ""
        print(
            f"HTTP Error {error.code}: {error.reason}{request_id_text}",
            file=sys.stderr,
        )
        print("API error body omitted for privacy.", file=sys.stderr)
        return 1
    except urllib.error.URLError as error:
        print(f"Network Error: {error.reason}", file=sys.stderr)
        return 1
    except (ValueError, json.JSONDecodeError, binascii.Error) as error:
        print(f"Response Error: {error}", file=sys.stderr)
        return 1
    except Exception as error:
        print(f"Error occurred: {type(error).__name__}: {error}", file=sys.stderr)
        return 1


def main():
    parser = argparse.ArgumentParser(description="Generate image using OpenAI Image API")
    parser.add_argument("--prompt", required=True, help="The prompt to generate an image")
    parser.add_argument(
        "--output",
        default="output.png",
        help="Output path; extension must match --output-format",
    )
    parser.add_argument(
        "--size",
        default="1024x1024",
        help="Image size (default: 1024x1024)",
    )
    parser.add_argument(
        "--model",
        default="gpt-image-2",
        help="OpenAI image model (default: gpt-image-2)",
    )
    parser.add_argument(
        "--quality",
        default="low",
        choices=["low", "medium", "high"],
        help="Image quality (default: low)",
    )
    parser.add_argument(
        "--output-format",
        default="png",
        choices=sorted(OUTPUT_EXTENSIONS),
        help="Image format (default: png)",
    )
    parser.add_argument(
        "--timeout",
        type=int,
        default=120,
        help="HTTP timeout in seconds (default: 120)",
    )
    args = parser.parse_args()

    if args.timeout <= 0:
        parser.error("--timeout must be greater than zero")

    try:
        output_path = validate_output_path(args.output, args.output_format)
    except ValueError as error:
        parser.error(str(error))

    return draw_image(
        args.prompt,
        output_path,
        args.size,
        args.model,
        args.quality,
        args.output_format,
        args.timeout,
    )


if __name__ == "__main__":
    sys.exit(main())
