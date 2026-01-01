from PIL import Image
import sys
import os

def remove_white_bg(image_path):
    try:
        img = Image.open(image_path)
        img = img.convert("RGBA")
        datas = img.getdata()

        newData = []
        for item in datas:
            # Change all white (and near white) pixels to transparent
            if item[0] > 240 and item[1] > 240 and item[2] > 240:
                newData.append((255, 255, 255, 0))
            else:
                newData.append(item)

        img.putdata(newData)
        img.save(image_path, "PNG")
        print(f"Successfully processed: {image_path}")
    except Exception as e:
        print(f"Error processing {image_path}: {e}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        # Process all files passed as arguments
        for file_path in sys.argv[1:]:
            if os.path.exists(file_path):
                remove_white_bg(file_path)
            else:
                print(f"File not found: {file_path}")
    else:
        print("Usage: python3 remove_bg.py <image_path1> [image_path2 ...]")
