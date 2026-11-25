"""Draws the app's icon and splash images. Run: python tool/make_icons.py

Outputs (all under assets/):
  icon/icon.png             1024x1024 RGB, no alpha (iOS + legacy Android)
  icon/icon_foreground.png  1024x1024 RGBA, glyph inside the adaptive safe zone
  splash/splash.png         768x768  RGBA, white glyph (pre-Android-12 splash)
  splash/android12.png      1152x1152 RGBA, glyph inside the central 768 circle
"""
from pathlib import Path

from PIL import Image, ImageDraw

BRAND = (0, 137, 123)        # #00897B, same as colorSchemeSeed
WHITE = (255, 255, 255, 255)
SOFT = (255, 255, 255, 150)
SS = 4                        # supersampling factor for smooth edges
OUT = Path(__file__).resolve().parent.parent / "assets"


def person(d: ImageDraw.ImageDraw, cx, cy, s, fill):
    """A head and shoulders centred on (cx, cy), roughly s tall."""
    r = s * 0.20
    d.ellipse([cx - r, cy - s * 0.48, cx + r, cy - s * 0.48 + 2 * r], fill=fill)
    w = s * 0.40
    top = cy - s * 0.02
    d.pieslice([cx - w, top, cx + w, top + 2 * w * 0.95], 180, 360, fill=fill)
    d.rectangle([cx - w, top + w * 0.95 - 1, cx + w, top + w * 0.95 + s * 0.06], fill=fill)


def glyph(size, scale):
    """Two people (one behind) on a transparent canvas; scale = glyph/size."""
    big = size * SS
    img = Image.new("RGBA", (big, big), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    s = big * scale
    c = big / 2
    person(d, c - s * 0.26, c - s * 0.02, s * 0.78, SOFT)
    person(d, c + s * 0.12, c + s * 0.08, s, WHITE)
    return img.resize((size, size), Image.LANCZOS)


def main():
    (OUT / "icon").mkdir(parents=True, exist_ok=True)
    (OUT / "splash").mkdir(parents=True, exist_ok=True)

    full = Image.new("RGBA", (1024, 1024), BRAND + (255,))
    full.alpha_composite(glyph(1024, 0.62))
    full.convert("RGB").save(OUT / "icon/icon.png")  # no alpha channel

    # Adaptive icons crop to the inner 66%; keep the glyph well inside it.
    glyph(1024, 0.42).save(OUT / "icon/icon_foreground.png")
    glyph(768, 0.62).save(OUT / "splash/splash.png")
    # Android 12: 1152 canvas, the visible circle is the central 768.
    glyph(1152, 0.40).save(OUT / "splash/android12.png")
    print("written to", OUT)


if __name__ == "__main__":
    main()
