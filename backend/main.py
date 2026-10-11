from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.responses import StreamingResponse
from fastapi.middleware.cors import CORSMiddleware
import io
from PIL import Image, ImageEnhance, ImageFilter

app = FastAPI(title="EnhanceAI Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

MAX_DIM = 3000  # guard against OOM


def _resize_if_needed(img: Image.Image) -> Image.Image:
    if max(img.size) > MAX_DIM:
        ratio = MAX_DIM / max(img.size)
        img = img.resize((int(img.width * ratio), int(img.height * ratio)), Image.LANCZOS)
    return img


def enhance_portrait(img: Image.Image) -> Image.Image:
    img = _resize_if_needed(img)
    img = img.resize((img.width * 2, img.height * 2), Image.LANCZOS)
    img = img.filter(ImageFilter.UnsharpMask(radius=3, percent=180, threshold=3))
    img = ImageEnhance.Color(img).enhance(1.15)
    img = ImageEnhance.Contrast(img).enhance(1.1)
    img = ImageEnhance.Brightness(img).enhance(1.05)
    return img


def enhance_landscape(img: Image.Image) -> Image.Image:
    img = _resize_if_needed(img)
    img = img.resize((img.width * 2, img.height * 2), Image.LANCZOS)
    img = img.filter(ImageFilter.UnsharpMask(radius=2, percent=140, threshold=3))
    img = ImageEnhance.Color(img).enhance(1.35)  # punchy colors
    img = ImageEnhance.Contrast(img).enhance(1.2)
    return img


def enhance_old(img: Image.Image) -> Image.Image:
    img = _resize_if_needed(img).convert("L")  # grayscale base
    img = img.resize((img.width * 2, img.height * 2), Image.LANCZOS)
    # Auto-contrast for faded photos
    img = ImageEnhance.Contrast(img).enhance(1.4)
    img = ImageEnhance.Sharpness(img).enhance(2.0)
    img = img.filter(ImageFilter.UnsharpMask(radius=2, percent=200, threshold=2))
    # Warm sepia tone
    sepia = Image.new("RGB", img.size)
    pixels = img.load()
    out = sepia.load()
    for y in range(img.height):
        for x in range(img.width):
            g = pixels[x, y]
            out[x, y] = (min(255, int(g * 1.1)),
                         min(255, int(g * 1.0)),
                         min(255, int(g * 0.85)))
    return sepia


HANDLERS = {
    "portrait": enhance_portrait,
    "landscape": enhance_landscape,
    "old": enhance_old,
}


@app.get("/")
def root():
    return {"status": "EnhanceAI backend running", "modes": list(HANDLERS.keys())}


async def _run(file: UploadFile, mode: str):
    if mode not in HANDLERS:
        raise HTTPException(400, f"Unknown mode: {mode}")
    data = await file.read()
    try:
        img = Image.open(io.BytesIO(data)).convert("RGB")
    except Exception:
        raise HTTPException(400, "Invalid image")

    enhanced = HANDLERS[mode](img)
    buf = io.BytesIO()
    enhanced.save(buf, format="PNG", optimize=True)
    buf.seek(0)
    return StreamingResponse(buf, media_type="image/png")


@app.post("/enhance/{mode}")
async def enhance_router(mode: str, file: UploadFile = File(...)):
    return await _run(file, mode)
