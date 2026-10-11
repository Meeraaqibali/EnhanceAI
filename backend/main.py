from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.responses import StreamingResponse
from fastapi.middleware.cors import CORSMiddleware
import io
import os
from PIL import Image, ImageEnhance, ImageFilter
from gradio_client import Client, handle_file

app = FastAPI(title="EnhanceAI Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Config ---
HF_TOKEN = os.getenv("HF_TOKEN", "")  # set this in your env
FACE_SPACE = "leonelhs/faceshine"     # free GFPGAN + CodeFormer Space
MAX_DIM = 2000

# --- Cache the client so we don't reconnect every request ---
_client = None

def get_client():
    global _client
    if _client is None:
        _client = Client(FACE_SPACE, hf_token=HF_TOKEN if HF_TOKEN else None)
    return _client


# ---------- AI face restoration ----------
def ai_face_restore(img: Image.Image) -> Image.Image:
    """Send image to HF Space for GFPGAN/CodeFormer face restoration."""
    try:
        client = get_client()
        # Save input to a temp file because gradio_client needs a path
        tmp_in = "/tmp/enhance_in.png"
        tmp_out = "/tmp/enhance_out.png"
        img.save(tmp_in, format="PNG")

        result = client.predict(
            image=handle_file(tmp_in),
            version="v1.4",          # GFPGAN model version
            scale=2,                 # upscale factor
            api_name="/gfpgan_face",
        )

        # result is usually a filepath string or tuple
        if isinstance(result, (list, tuple)):
            result = result[0]

        out = Image.open(result).convert("RGB")
        return out
    except Exception as e:
        print(f"[AI restore failed] {e}")
        return None  # fall back to filters


# ---------- Fallback PIL enhancer ----------
def _resize_if_needed(img: Image.Image) -> Image.Image:
    if max(img.size) > MAX_DIM:
        ratio = MAX_DIM / max(img.size)
        img = img.resize((int(img.width * ratio), int(img.height * ratio)), Image.LANCZOS)
    return img


def pil_enhance(img: Image.Image, mode: str) -> Image.Image:
    img = _resize_if_needed(img)
    if mode == "portrait":
        img = img.resize((img.width * 2, img.height * 2), Image.LANCZOS)
        img = img.filter(ImageFilter.UnsharpMask(radius=3, percent=180, threshold=3))
        img = ImageEnhance.Color(img).enhance(1.15)
        img = ImageEnhance.Contrast(img).enhance(1.1)
        img = ImageEnhance.Brightness(img).enhance(1.05)
    elif mode == "landscape":
        img = img.resize((img.width * 2, img.height * 2), Image.LANCZOS)
        img = img.filter(ImageFilter.UnsharpMask(radius=2, percent=140, threshold=3))
        img = ImageEnhance.Color(img).enhance(1.35)
        img = ImageEnhance.Contrast(img).enhance(1.2)
    elif mode == "old":
        img = img.resize((img.width * 2, img.height * 2), Image.LANCZOS)
        img = ImageEnhance.Contrast(img).enhance(1.4)
        img = ImageEnhance.Sharpness(img).enhance(2.0)
        img = img.filter(ImageFilter.UnsharpMask(radius=2, percent=200, threshold=2))
    return img


# ---------- Routes ----------
@app.get("/")
def root():
    return {
        "status": "EnhanceAI backend running",
        "ai_face_restore": bool(HF_TOKEN),
        "modes": ["portrait", "landscape", "old"],
    }


@app.post("/enhance/{mode}")
async def enhance(mode: str, file: UploadFile = File(...)):
    data = await file.read()
    try:
        img = Image.open(io.BytesIO(data)).convert("RGB")
    except Exception:
        raise HTTPException(400, "Invalid image")

    # For portrait, try AI face restore first
    if mode == "portrait" and HF_TOKEN:
        ai_result = ai_face_restore(img)
        if ai_result is not None:
            buf = io.BytesIO()
            ai_result.save(buf, format="PNG", optimize=True)
            buf.seek(0)
            return StreamingResponse(buf, media_type="image/png")

    # Otherwise fall back to PIL filters
    enhanced = pil_enhance(img, mode)
    buf = io.BytesIO()
    enhanced.save(buf, format="PNG", optimize=True)
    buf.seek(0)
    return StreamingResponse(buf, media_type="image/png")
