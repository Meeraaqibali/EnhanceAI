import os
import io
import json
import re
import requests
from http.server import BaseHTTPRequestHandler, HTTPServer

AI_ENGINE_KEY = os.getenv("AI_ENGINE_KEY", "")
AI_ENGINE_HOST = "ai-powered-photo-restoration.p.rapidapi.com"
AI_ENGINE_PATH = "/enhance-face"
PORT = 8000


def parse_multipart(body, boundary):
    parts = {}
    delim = b"--" + boundary
    for chunk in body.split(delim):
        if not chunk or chunk in (b"--\r\n", b"--"):
            continue
        chunk = chunk.lstrip(b"\r\n")
        if b"\r\n\r\n" not in chunk:
            continue
        header_blob, data = chunk.split(b"\r\n\r\n", 1)
        if data.endswith(b"\r\n"):
            data = data[:-2]
        m = re.search(rb'name="([^"]+)"', header_blob)
        if m:
            parts[m.group(1).decode()] = data
    return parts


class Handler(BaseHTTPRequestHandler):
    def _cors(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "*")

    def do_OPTIONS(self):
        self.send_response(200)
        self._cors()
        self.end_headers()

    def do_GET(self):
        body = json.dumps({
            "status": "EnhanceAI running",
            "ai_enabled": bool(AI_ENGINE_KEY),
            "host": AI_ENGINE_HOST,
            "path": AI_ENGINE_PATH,
        }).encode()
        self.send_response(200)
        self._cors()
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_POST(self):
        if not self.path.startswith("/enhance"):
            self.send_response(404)
            self.end_headers()
            return
        try:
            ctype = self.headers.get("Content-Type", "")
            if "boundary=" not in ctype:
                raise ValueError("no boundary")
            boundary = ctype.split("boundary=", 1)[1].strip().strip('"').encode()

            length = int(self.headers.get("Content-Length", 0))
            body = self.rfile.read(length)
            fields = parse_multipart(body, boundary)
            image_bytes = fields["file"]
            print(f"[IN ] {len(image_bytes)} bytes")

            if not AI_ENGINE_KEY:
                self._send_image(image_bytes)
                return

            url = f"https://{AI_ENGINE_HOST}{AI_ENGINE_PATH}"
            print(f"[REQ] POST {url}")
            r = requests.post(
                url,
                files={"image": ("input.jpg", image_bytes, "image/jpeg")},
                data={"mode": "single"},
                headers={
                    "x-rapidapi-key": AI_ENGINE_KEY,
                    "x-rapidapi-host": AI_ENGINE_HOST,
                },
                timeout=180,
            )
            print(f"[API] status={r.status_code}")
            print(f"[BODY] {r.text[:400]}")

            if r.status_code != 200:
                self._send_image(image_bytes)
                return

            j = r.json()
            img_url = (
                j.get("image_url")
                or (j.get("data") or {}).get("image_url")
                or (j.get("result") or {}).get("image_url")
                or j.get("url")
            )
            if not img_url:
                print(f"[NO URL] {j}")
                self._send_image(image_bytes)
                return

            enhanced = requests.get(img_url, timeout=60).content
            print(f"[OUT] {len(enhanced)} bytes")
            self._send_image(enhanced)

        except Exception as e:
            print(f"[ERROR] {type(e).__name__}: {e}")
            self.send_response(500)
            self._cors()
            self.end_headers()
            self.wfile.write(str(e).encode())

    def _send_image(self, data):
        self.send_response(200)
        self._cors()
        self.send_header("Content-Type", "image/jpeg")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def log_message(self, fmt, *args):
        pass


if __name__ == "__main__":
    print(f"EnhanceAI backend on http://0.0.0.0:{PORT}")
    print(f"API key set: {bool(AI_ENGINE_KEY)}")
    print(f"Host: {AI_ENGINE_HOST}")
    print(f"Path: {AI_ENGINE_PATH}")
    HTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
