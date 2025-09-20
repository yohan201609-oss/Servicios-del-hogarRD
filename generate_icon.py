from PIL import Image, ImageDraw, ImageFont
import math

def create_app_icon():
    # Create a 1024x1024 image with transparent background
    size = 1024
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Create gradient background
    center = size // 2
    radius = int(size * 0.45)  # 460px radius
    
    # Draw gradient circle (simplified - using solid color for now)
    # In a real implementation, you'd create a proper gradient
    draw.ellipse([center - radius, center - radius, center + radius, center + radius], 
                 fill=(30, 58, 138, 255))  # Blue color
    
    # Add a lighter blue gradient effect
    inner_radius = int(radius * 0.8)
    draw.ellipse([center - inner_radius, center - inner_radius, center + inner_radius, center + inner_radius], 
                 fill=(6, 182, 212, 200))  # Cyan with transparency
    
    # Draw "RD" text
    try:
        # Try to use a bold font
        font_size = int(size * 0.3)  # 30% of image size
        font = ImageFont.truetype("arial.ttf", font_size)
    except:
        # Fallback to default font
        font = ImageFont.load_default()
    
    # Calculate text position
    text = "RD"
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    
    x = (size - text_width) // 2
    y = (size - text_height) // 2 - 20  # Slightly higher
    
    # Draw white text
    draw.text((x, y), text, fill=(255, 255, 255, 255), font=font)
    
    # Save the image
    img.save('assets/icons/app_icon.png', 'PNG')
    print("Icon generated successfully!")

if __name__ == "__main__":
    create_app_icon()
