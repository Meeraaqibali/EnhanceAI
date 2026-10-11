from fastapi import FastAPI, File, UploadFile
from fastapi.responses import StreamingResponse
import io
from PIL import Image, ImageEnhance, ImageFilter

app = FastAPI(title="EnhanceAI Backend")


def enhance_image(pil_img: Image.Image) -> Image.Image:
    """Basic enhancement: upscale 2x, sharpen, boost color & contrast."""
    # Upscale 2x with high-quality resampling
    new_size = (pil_img.width * 2, pil_img.height * 2)
    img = pil_img.resize(new_size, Image.LANCZOS)

    # Sharpen
    img = img.filter(ImageFilter.UnsharpMask(radius=2, percent=150, threshold=3))

    # Boost color and contrast
    img = ImageEnhance.Color(img).enhance(1.2)
    img = ImageEnhance.Contrast(img).enhance(1.1)
    img = ImageEnhance.Sharpness(img).enhance(1.5)

    return img


@app.get("/")
def root():
    return {"status": "EnhanceAI backend running"}


@app.post("/enhance/")
async def enhance_endpoint(file: UploadFile = File(...)):
    image_data = await file.read()
    pil_img = Image.open(io.BytesIO(image_data)).convert("RGB")

    enhanced = enhance_image(pil_img)

    buf = io.BytesIO()
    enhanced.save(buf, format="PNG")
    buf.seek(0)

    return StreamingResponse(buf, media_type="image/png")
