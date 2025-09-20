from PIL import Image, ImageDraw, ImageFont
import os

def create_simple_icon():
    # Create a 512x512 image
    size = 512
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Create gradient background
    center = size // 2
    radius = 240
    
    # Draw circular background with gradient effect
    for i in range(radius, 0, -1):
        ratio = (radius - i) / radius
        r = int(33 + (0 - 33) * ratio)
        g = int(150 + (188 - 150) * ratio)
        b = int(243 + (212 - 243) * ratio)
        
        draw.ellipse([center - i, center - i, center + i, center + i], 
                    fill=(r, g, b, 255))
    
    # Draw "RD" text
    try:
        # Try to use a bold font
        font = ImageFont.truetype("arial.ttf", 200)
    except:
        # Fallback to default font
        font = ImageFont.load_default()
    
    # Draw RD text in white
    text = "RD"
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    
    x = (size - text_width) // 2
    y = (size - text_height) // 2
    
    draw.text((x, y), text, fill=(255, 255, 255, 255), font=font)
    
    # Save the image
    output_path = 'assets/icons/app_icon.png'
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    img.save(output_path, 'PNG')
    print(f"Icono creado en: {output_path}")

if __name__ == "__main__":
    create_simple_icon()