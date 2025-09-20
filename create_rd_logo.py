from PIL import Image, ImageDraw
import os

def create_rd_logo():
    # Create a 512x512 image with transparent background
    size = 512
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Create gradient background (simplified version)
    center = size // 2
    radius = 240
    
    # Draw the circular background with gradient effect
    for i in range(radius, 0, -1):
        # Calculate gradient color from blue to cyan
        ratio = (radius - i) / radius
        r = int(33 + (0 - 33) * ratio)  # 33 to 0
        g = int(150 + (188 - 150) * ratio)  # 150 to 188
        b = int(243 + (212 - 243) * ratio)  # 243 to 212
        
        draw.ellipse([center - i, center - i, center + i, center + i], 
                    fill=(r, g, b, 255), outline=None)
    
    # Draw the R and D letters in white
    # Letter R (simplified)
    # Vertical line
    draw.rectangle([120, 120, 140, 380], fill=(255, 255, 255, 255))
    # Top horizontal line
    draw.rectangle([120, 120, 200, 140], fill=(255, 255, 255, 255))
    # Middle horizontal line
    draw.rectangle([120, 200, 200, 220], fill=(255, 255, 255, 255))
    # Diagonal line
    for i in range(60):
        y = 220 + i
        x = 200 - i
        draw.rectangle([x, y, x+2, y+2], fill=(255, 255, 255, 255))
    
    # Letter D (simplified)
    # Vertical line
    draw.rectangle([320, 120, 340, 380], fill=(255, 255, 255, 255))
    # Curved part (simplified as rectangles)
    draw.rectangle([340, 120, 420, 140], fill=(255, 255, 255, 255))  # Top
    draw.rectangle([340, 200, 420, 220], fill=(255, 255, 255, 255))  # Middle
    draw.rectangle([340, 280, 420, 300], fill=(255, 255, 255, 255))  # Lower middle
    draw.rectangle([340, 360, 420, 380], fill=(255, 255, 255, 255))  # Bottom
    
    # Save the image
    output_path = 'assets/icons/app_icon_rd.png'
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    img.save(output_path, 'PNG')
    print(f"Logo creado en: {output_path}")

if __name__ == "__main__":
    create_rd_logo()
