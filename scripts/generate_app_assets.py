#!/usr/bin/env python3
"""
Complete script to generate app icons and launch screens for Photo Points app
Usage: python3 scripts/generate_app_assets.py
Requirements: pip install Pillow
"""

import os
import sys

# Check if required packages are available
try:
    from PIL import Image, ImageDraw, ImageFont
    import math
except ImportError:
    print("Missing required packages. Please install:")
    print("pip install Pillow")
    sys.exit(1)

def create_app_icon(size=1024):
    """Create the Photo Points app icon with camera, location, and environmental elements"""
    # Create a new image with transparency
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Define colors
    bg_color = (76, 175, 80)  # Green
    camera_color = (255, 255, 255)  # White
    lens_color = (25, 118, 210)  # Blue
    pin_color = (244, 67, 54)  # Red
    compass_color = (55, 71, 79)  # Dark gray
    text_color = (255, 255, 255)  # White

    # Background circle
    margin = int(size * 0.05)
    bg_radius = (size - 2 * margin) // 2
    center = size // 2
    draw.ellipse([margin, margin, size - margin, size - margin],
                 fill=bg_color, outline=None)

    # Camera body
    cam_width = int(size * 0.5)
    cam_height = int(size * 0.31)
    cam_x = (size - cam_width) // 2
    cam_y = int(size * 0.29)
    cam_radius = int(size * 0.04)

    # Draw camera body with rounded corners
    draw.rounded_rectangle([cam_x, cam_y, cam_x + cam_width, cam_y + cam_height],
                          radius=cam_radius, fill=camera_color, outline=(189, 189, 189), width=4)

    # Camera lens
    lens_radius = int(size * 0.1)
    lens_center_x = center
    lens_center_y = int(size * 0.45)

    # Outer lens ring
    draw.ellipse([lens_center_x - lens_radius, lens_center_y - lens_radius,
                  lens_center_x + lens_radius, lens_center_y + lens_radius],
                 fill=(66, 66, 66), outline=(117, 117, 117), width=6)

    # Inner lens
    inner_radius = int(size * 0.07)
    draw.ellipse([lens_center_x - inner_radius, lens_center_y - inner_radius,
                  lens_center_x + inner_radius, lens_center_y + inner_radius],
                 fill=lens_color, outline=(13, 71, 161), width=3)

    # Lens center
    center_radius = int(size * 0.04)
    draw.ellipse([lens_center_x - center_radius, lens_center_y - center_radius,
                  lens_center_x + center_radius, lens_center_y + center_radius],
                 fill=(13, 71, 161))

    # Location pin
    pin_x = int(size * 0.69)
    pin_y = int(size * 0.15)
    pin_size = int(size * 0.08)

    # Pin shape (simplified triangle)
    pin_points = [
        (pin_x, pin_y),
        (pin_x - pin_size//2, pin_y - pin_size),
        (pin_x + pin_size//2, pin_y - pin_size)
    ]
    draw.polygon(pin_points, fill=pin_color, outline=(183, 28, 28), width=2)

    # Pin circle
    pin_circle_radius = int(size * 0.02)
    draw.ellipse([pin_x - pin_circle_radius, pin_y - pin_size - pin_circle_radius,
                  pin_x + pin_circle_radius, pin_y - pin_size + pin_circle_radius],
                 fill=text_color)

    # Compass
    compass_x = int(size * 0.39)
    compass_y = int(size * 0.68)
    compass_radius = int(size * 0.06)

    # Compass body
    draw.ellipse([compass_x - compass_radius, compass_y - compass_radius,
                  compass_x + compass_radius, compass_y + compass_radius],
                 fill=compass_color, outline=(38, 50, 56), width=3)

    # Compass needle (simplified)
    needle_length = int(compass_radius * 0.7)
    draw.polygon([
        (compass_x, compass_y - needle_length),
        (compass_x - 5, compass_y),
        (compass_x + 5, compass_y)
    ], fill=pin_color)

    # Time series dots
    dots_y = int(size * 0.68)
    dot_radius = int(size * 0.008)
    for i, alpha in enumerate([0.9, 0.7, 0.5]):
        dot_x = int(size * 0.60) + i * int(size * 0.025)
        dot_color = tuple(int(c * alpha) for c in [76, 175, 80]) + (int(255 * alpha),)
        draw.ellipse([dot_x - dot_radius, dots_y - dot_radius,
                      dot_x + dot_radius, dots_y + dot_radius],
                     fill=dot_color)

    # Add some environmental elements (simplified leaves)
    leaf_points = [
        (int(size * 0.20), int(size * 0.20)),
        (int(size * 0.15), int(size * 0.17)),
        (int(size * 0.12), int(size * 0.20)),
        (int(size * 0.15), int(size * 0.23))
    ]
    draw.polygon(leaf_points, fill=(102, 187, 106))

    leaf_points2 = [
        (int(size * 0.83), int(size * 0.76)),
        (int(size * 0.86), int(size * 0.73)),
        (int(size * 0.89), int(size * 0.76)),
        (int(size * 0.86), int(size * 0.79))
    ]
    draw.polygon(leaf_points2, fill=(102, 187, 106))

    return img

def create_launch_screen(width=1080, height=1920, name="Photo Points"):
    """Create a launch screen image with gradient background and centered logo"""
    # Create a new image
    img = Image.new('RGB', (width, height), (76, 175, 80))  # Green background
    draw = ImageDraw.Draw(img)

    # Define colors
    bg_color = (76, 175, 80)  # Green
    accent_color = (46, 125, 50)  # Darker green
    text_color = (255, 255, 255)  # White

    # Create a subtle gradient effect
    for y in range(height):
        gradient_factor = y / height
        color = (
            int(bg_color[0] + (accent_color[0] - bg_color[0]) * gradient_factor),
            int(bg_color[1] + (accent_color[1] - bg_color[1]) * gradient_factor),
            int(bg_color[2] + (accent_color[2] - bg_color[2]) * gradient_factor)
        )
        draw.line([(0, y), (width, y)], fill=color)

    # Draw a simplified logo in the center
    center_x = width // 2
    center_y = height // 2 - 100  # Offset up a bit for text

    # Camera body (simplified)
    cam_width = int(width * 0.25)
    cam_height = int(cam_width * 0.6)
    cam_x = center_x - cam_width // 2
    cam_y = center_y - cam_height // 2
    cam_radius = int(width * 0.02)

    # Draw camera body
    draw.rounded_rectangle([cam_x, cam_y, cam_x + cam_width, cam_y + cam_height],
                          radius=cam_radius, fill=text_color, outline=(220, 220, 220), width=3)

    # Camera lens
    lens_radius = int(width * 0.06)
    lens_center_y = center_y

    # Outer lens ring
    draw.ellipse([center_x - lens_radius, lens_center_y - lens_radius,
                  center_x + lens_radius, lens_center_y + lens_radius],
                 fill=(66, 66, 66), outline=(117, 117, 117), width=4)

    # Inner lens
    inner_radius = int(width * 0.04)
    draw.ellipse([center_x - inner_radius, lens_center_y - inner_radius,
                  center_x + inner_radius, lens_center_y + inner_radius],
                 fill=(25, 118, 210), outline=(13, 71, 161), width=2)

    # Location pin (small)
    pin_x = center_x + int(width * 0.08)
    pin_y = center_y - int(width * 0.08)
    pin_size = int(width * 0.04)

    # Pin shape
    pin_points = [
        (pin_x, pin_y),
        (pin_x - pin_size//2, pin_y - pin_size),
        (pin_x + pin_size//2, pin_y - pin_size)
    ]
    draw.polygon(pin_points, fill=(244, 67, 54), outline=(183, 28, 28), width=2)

    # Pin circle
    pin_circle_radius = int(width * 0.012)
    draw.ellipse([pin_x - pin_circle_radius, pin_y - pin_size - pin_circle_radius,
                  pin_x + pin_circle_radius, pin_y - pin_size + pin_circle_radius],
                 fill=text_color)

    # Try to use a font, fallback to default if not available
    try:
        # Try to find a good font
        font_size = int(width * 0.08)
        font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", font_size)
        small_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", int(font_size * 0.4))
    except:
        try:
            font_size = int(width * 0.08)
            font = ImageFont.truetype("Arial.ttf", font_size)
            small_font = ImageFont.truetype("Arial.ttf", int(font_size * 0.4))
        except:
            font = ImageFont.load_default()
            small_font = ImageFont.load_default()

    # Draw app name
    text_y = center_y + int(width * 0.12)

    # Get text dimensions for centering
    try:
        bbox = draw.textbbox((0, 0), name, font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]

        # Draw text with shadow
        shadow_offset = 2
        draw.text((center_x - text_width // 2 + shadow_offset, text_y + shadow_offset),
                  name, fill=(0, 0, 0, 128), font=font)
        draw.text((center_x - text_width // 2, text_y), name, fill=text_color, font=font)
    except:
        # Fallback for default font
        draw.text((center_x - len(name) * 10, text_y), name, fill=text_color, font=font)

    # Add subtle tagline
    tagline = "Environmental Monitoring"
    tagline_y = text_y + int(width * 0.06)

    try:
        bbox = draw.textbbox((0, 0), tagline, font=small_font)
        tagline_width = bbox[2] - bbox[0]
        draw.text((center_x - tagline_width // 2, tagline_y),
                  tagline, fill=(255, 255, 255, 200), font=small_font)
    except:
        # Fallback for default font
        draw.text((center_x - len(tagline) * 4, tagline_y),
                  tagline, fill=(255, 255, 255, 200), font=small_font)

    # Add some decorative elements
    # Small dots pattern
    dot_radius = 3
    dot_spacing = 40
    dot_alpha = 50

    for i in range(0, width, dot_spacing):
        for j in range(0, height, dot_spacing):
            if (i + j) % 80 == 0:  # Sparse pattern
                draw.ellipse([i, j, i + dot_radius, j + dot_radius],
                           fill=(255, 255, 255, dot_alpha))

    return img

def main():
    """Main function to generate all app assets"""
    print("Generating Photo Points app assets...")

    # Create necessary directories
    assets_dir = "assets"
    scripts_dir = "scripts"

    for directory in [assets_dir, scripts_dir]:
        if not os.path.exists(directory):
            os.makedirs(directory)
            print(f"Created directory: {directory}")

    print("\n=== Generating App Icons ===")

    # Generate the 1024x1024 icon
    icon = create_app_icon(1024)
    icon_path = os.path.join(assets_dir, "app_icon_1024.png")
    icon.save(icon_path, "PNG")
    print(f"✓ Created: {icon_path}")

    # Generate smaller sizes for testing
    sizes = [512, 256, 128, 64]
    for size in sizes:
        small_icon = icon.resize((size, size), Image.Resampling.LANCZOS)
        small_path = os.path.join(assets_dir, f"app_icon_{size}.png")
        small_icon.save(small_path, "PNG")
        print(f"✓ Created: {small_path}")

    print("\n=== Generating Launch Screens ===")

    # Generate different sizes for different screen densities
    launch_sizes = [
        (1080, 1920, "hdpi"),      # Common Android size
        (1440, 2560, "xhdpi"),     # Higher density Android
        (1125, 2436, "ios"),       # iPhone X/11/12/13 size
        (1242, 2208, "ios_plus"),  # iPhone 6/7/8 Plus size
        (828, 1792, "ios_xr"),     # iPhone XR/11 size
    ]

    for width, height, suffix in launch_sizes:
        launch_screen = create_launch_screen(width, height)
        file_path = os.path.join(assets_dir, f"launch_screen_{suffix}.png")
        launch_screen.save(file_path, "PNG")
        print(f"✓ Created: {file_path}")

    # Also create a simple square version for adaptive use
    square_size = 1024
    square_launch = create_launch_screen(square_size, square_size)
    square_path = os.path.join(assets_dir, "launch_screen_square.png")
    square_launch.save(square_path, "PNG")
    print(f"✓ Created: {square_path}")

    print("\n=== Asset Generation Complete! ===")
    print("\nNext steps:")
    print("1. Run: flutter pub get")
    print("2. Run: flutter pub run flutter_launcher_icons")
    print("3. Run: flutter pub run flutter_native_splash:create")
    print("4. Test: flutter build apk --debug")
    print("\nAll assets have been generated successfully!")

if __name__ == "__main__":
    main()
