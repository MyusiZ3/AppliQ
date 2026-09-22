import os
from PIL import Image

def generate_icons():
    src_path = r"c:\Users\muham\Documents\Github\AppliQ\assets\images\appliq_logo.png"
    if not os.path.exists(src_path):
        print(f"Error: {src_path} not found")
        return

    src_img = Image.open(src_path).convert("RGBA")

    # Android legacy icon sizes (Square with white background and safe padding)
    legacy_sizes = {
        r"c:\Users\muham\Documents\Github\AppliQ\android\app\src\main\res\mipmap-mdpi": 48,
        r"c:\Users\muham\Documents\Github\AppliQ\android\app\src\main\res\mipmap-hdpi": 72,
        r"c:\Users\muham\Documents\Github\AppliQ\android\app\src\main\res\mipmap-xhdpi": 96,
        r"c:\Users\muham\Documents\Github\AppliQ\android\app\src\main\res\mipmap-xxhdpi": 144,
        r"c:\Users\muham\Documents\Github\AppliQ\android\app\src\main\res\mipmap-xxxhdpi": 192,
    }

    for dir_path, size in legacy_sizes.items():
        os.makedirs(dir_path, exist_ok=True)
        # Create solid white canvas
        canvas = Image.new("RGBA", (size, size), (255, 255, 255, 255))
        # Resize logo to 100% full canvas
        inner_size = size
        resized_logo = src_img.resize((inner_size, inner_size), Image.Resampling.LANCZOS)
        offset = ((size - inner_size) // 2, (size - inner_size) // 2)
        canvas.paste(resized_logo, offset, resized_logo)
        out_file = os.path.join(dir_path, "ic_launcher.png")
        canvas.save(out_file, "PNG")
        print(f"Saved: {out_file} ({size}x{size})")

    # Android Adaptive Foreground sizes (100% full canvas)
    foreground_sizes = {
        r"c:\Users\muham\Documents\Github\AppliQ\android\app\src\main\res\mipmap-mdpi": 108,
        r"c:\Users\muham\Documents\Github\AppliQ\android\app\src\main\res\mipmap-hdpi": 162,
        r"c:\Users\muham\Documents\Github\AppliQ\android\app\src\main\res\mipmap-xhdpi": 216,
        r"c:\Users\muham\Documents\Github\AppliQ\android\app\src\main\res\mipmap-xxhdpi": 324,
        r"c:\Users\muham\Documents\Github\AppliQ\android\app\src\main\res\mipmap-xxxhdpi": 432,
    }

    for dir_path, size in foreground_sizes.items():
        os.makedirs(dir_path, exist_ok=True)
        canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        # Resize logo to 100% full
        inner_size = size
        resized_logo = src_img.resize((inner_size, inner_size), Image.Resampling.LANCZOS)
        offset = ((size - inner_size) // 2, (size - inner_size) // 2)
        canvas.paste(resized_logo, offset, resized_logo)
        out_file = os.path.join(dir_path, "ic_launcher_foreground.png")
        canvas.save(out_file, "PNG")
        print(f"Saved: {out_file} ({size}x{size})")

    # Create Adaptive Icon XML in mipmap-anydpi-v26
    anydpi_dir = r"c:\Users\muham\Documents\Github\AppliQ\android\app\src\main\res\mipmap-anydpi-v26"
    os.makedirs(anydpi_dir, exist_ok=True)
    xml_content = """<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
"""
    with open(os.path.join(anydpi_dir, "ic_launcher.xml"), "w") as f:
        f.write(xml_content)
    print("Saved ic_launcher.xml in mipmap-anydpi-v26")

    # Add background color value in values/colors.xml or values/ic_launcher_background.xml
    values_dir = r"c:\Users\muham\Documents\Github\AppliQ\android\app\src\main\res\values"
    os.makedirs(values_dir, exist_ok=True)
    bg_xml = """<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">#FFFFFF</color>
</resources>
"""
    with open(os.path.join(values_dir, "ic_launcher_background.xml"), "w") as f:
        f.write(bg_xml)
    print("Saved ic_launcher_background.xml in values/")

    # Web icons
    web_icons = {
        r"c:\Users\muham\Documents\Github\AppliQ\web\favicon.png": 32,
        r"c:\Users\muham\Documents\Github\AppliQ\web\icons\Icon-192.png": 192,
        r"c:\Users\muham\Documents\Github\AppliQ\web\icons\Icon-512.png": 512,
        r"c:\Users\muham\Documents\Github\AppliQ\web\icons\Icon-maskable-192.png": 192,
        r"c:\Users\muham\Documents\Github\AppliQ\web\icons\Icon-maskable-512.png": 512,
    }
    for out_file, size in web_icons.items():
        os.makedirs(os.path.dirname(out_file), exist_ok=True)
        canvas = Image.new("RGBA", (size, size), (255, 255, 255, 255))
        inner_size = size
        resized_logo = src_img.resize((inner_size, inner_size), Image.Resampling.LANCZOS)
        offset = ((size - inner_size) // 2, (size - inner_size) // 2)
        canvas.paste(resized_logo, offset, resized_logo)
        canvas.save(out_file, "PNG")
        print(f"Saved: {out_file} ({size}x{size})")

if __name__ == "__main__":
    generate_icons()
