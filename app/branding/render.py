"""Render the HomeSync logo into the Android and web icon files.

Usage (from app/):  python branding/render.py
Needs Chrome (or Edge) and Pillow. Chrome renders logo.svg at 1024 px;
Pillow scales it down. The Android adaptive icon is a vector drawable
(res/drawable/ic_launcher_foreground.xml) and is not generated here.
"""

import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

from PIL import Image

APP = Path(__file__).resolve().parent.parent
SVG = (APP / "branding" / "logo.svg").read_text(encoding="utf-8")
CAPIZ = "#E9EEE7"

BROWSERS = [
    r"C:\Program Files\Google\Chrome\Application\chrome.exe",
    r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
    "/usr/bin/google-chrome",
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
]


def inner(svg: str) -> str:
    """The logo without its rounded tile."""
    body = re.sub(r"<svg[^>]*>|</svg>", "", svg)
    return re.sub(r"<rect width=\"100\" height=\"100\"[^>]*/>", "", body)


def variants() -> dict[str, str]:
    content = inner(SVG)
    # Maskable / full-bleed: square background, content shrunk into the
    # 80% safe circle around the middle.
    maskable = (
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">'
        f'<rect width="100" height="100" fill="{CAPIZ}"/>'
        f'<g transform="translate(50 50) scale(0.78) translate(-50 -55)">{content}</g>'
        "</svg>"
    )
    return {"tile": SVG, "maskable": maskable}


def render(svg: str, out: Path, browser: str) -> None:
    html = (
        "<html><body style='margin:0;background:transparent'>"
        + svg.replace("<svg ", "<svg width='1024' height='1024' ", 1)
        + "</body></html>"
    )
    with tempfile.TemporaryDirectory() as tmp:
        page = Path(tmp) / "logo.html"
        page.write_text(html, encoding="utf-8")
        subprocess.run(
            [
                browser,
                "--headless=new",
                "--disable-gpu",
                "--hide-scrollbars",
                "--default-background-color=00000000",
                "--window-size=1024,1024",
                f"--screenshot={out}",
                page.as_uri(),
            ],
            check=True,
            capture_output=True,
        )


def save(img: Image.Image, size: int, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    img.resize((size, size), Image.LANCZOS).save(path, optimize=True)
    print(f"{path.relative_to(APP)}  {size}px")


def main() -> None:
    browser = next((b for b in BROWSERS if os.path.exists(b)), None)
    if not browser:
        sys.exit("Chrome or Edge not found")
    with tempfile.TemporaryDirectory() as tmp:
        imgs = {}
        for name, svg in variants().items():
            out = Path(tmp) / f"{name}.png"
            render(svg, out, browser)
            imgs[name] = Image.open(out).convert("RGBA").crop((0, 0, 1024, 1024))
        tile, maskable = imgs["tile"], imgs["maskable"]

        web = APP / "web"
        save(tile, 32, web / "favicon.png")
        save(tile, 192, web / "icons" / "Icon-192.png")
        save(tile, 512, web / "icons" / "Icon-512.png")
        save(maskable, 192, web / "icons" / "Icon-maskable-192.png")
        save(maskable, 512, web / "icons" / "Icon-maskable-512.png")
        save(maskable, 180, web / "icons" / "apple-touch-icon.png")

        # Legacy launcher icons (Android 7 and older; newer use the adaptive icon).
        res = APP / "android" / "app" / "src" / "main" / "res"
        for folder, size in {
            "mdpi": 48,
            "hdpi": 72,
            "xhdpi": 96,
            "xxhdpi": 144,
            "xxxhdpi": 192,
        }.items():
            save(tile, size, res / f"mipmap-{folder}" / "ic_launcher.png")

        save(tile, 512, APP / "branding" / "logo-512.png")


if __name__ == "__main__":
    main()
