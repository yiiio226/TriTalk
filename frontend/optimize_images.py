#!/usr/bin/env python3
"""
Optimize Flutter asset images by creating 2x and 3x versions.
This reduces memory usage by providing appropriately sized images for different device pixel ratios.
"""

from PIL import Image
import os
import glob

# Configuration
IMAGES_DIR = 'assets/images'

# Automatically find all PNG images over 100KB
def find_large_images():
    """Find all PNG images in the assets directory that are over 100KB."""
    images = []
    for img_path in glob.glob(os.path.join(IMAGES_DIR, '*.png')):
        if os.path.getsize(img_path) > 100000:  # 100KB threshold
            images.append(os.path.basename(img_path))
    return sorted(images)

IMAGES = find_large_images()

# Target sizes (in pixels)
# 1x: 80x80 (base size, we'll keep original for backwards compatibility)
# 2x: 160x160 (for devices with 2.0 pixel ratio)
# 3x: 240x240 (for devices with 3.0 pixel ratio)
SIZES = {
    '2.0x': 160,
    '3.0x': 240,
}

def optimize_image(image_path, output_path, size):
    """Resize and optimize an image."""
    try:
        with Image.open(image_path) as img:
            # Convert RGBA to RGB if saving as JPEG, otherwise keep as PNG
            if img.mode == 'RGBA':
                # Keep PNG format for transparency
                img_resized = img.resize((size, size), Image.Resampling.LANCZOS)
                img_resized.save(output_path, 'PNG', optimize=True)
            else:
                img_resized = img.resize((size, size), Image.Resampling.LANCZOS)
                img_resized.save(output_path, 'PNG', optimize=True)
            
            print(f"✓ Created {output_path} ({size}x{size})")
    except Exception as e:
        print(f"✗ Error processing {image_path}: {e}")

def main():
    print("🎨 Optimizing Flutter asset images...\n")
    
    # Create resolution-specific directories
    for resolution in SIZES.keys():
        dir_path = os.path.join(IMAGES_DIR, resolution)
        os.makedirs(dir_path, exist_ok=True)
        print(f"📁 Created directory: {dir_path}")
    
    print()
    
    # Process each image
    for image_name in IMAGES:
        image_path = os.path.join(IMAGES_DIR, image_name)
        
        if not os.path.exists(image_path):
            print(f"⚠️  Skipping {image_name} (not found)")
            continue
        
        print(f"Processing {image_name}...")
        
        # Get original size
        with Image.open(image_path) as img:
            original_size = img.size
            print(f"  Original size: {original_size[0]}x{original_size[1]}")
        
        # Create optimized versions for each resolution
        for resolution, size in SIZES.items():
            output_dir = os.path.join(IMAGES_DIR, resolution)
            output_path = os.path.join(output_dir, image_name)
            optimize_image(image_path, output_path, size)
        
        print()
    
    print("✅ Optimization complete!")
    print("\n📝 Flutter will automatically use the appropriate resolution based on device pixel ratio.")
    print("   - 2.0x images for devices with 2.0 pixel ratio")
    print("   - 3.0x images for devices with 3.0 pixel ratio")
    print("   - Original images as fallback for 1.0x devices")

if __name__ == '__main__':
    main()
