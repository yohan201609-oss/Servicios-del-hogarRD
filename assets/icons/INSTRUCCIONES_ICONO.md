# Instrucciones para el Icono de la App

## Pasos para configurar el icono:

1. **Coloca tu archivo de imagen** (el logo con "RD" en círculo con gradiente azul-cyan) en esta carpeta
2. **Renómbralo** como `app_icon.png`
3. **Asegúrate** de que sea una imagen PNG de alta calidad (mínimo 1024x1024 píxeles)
4. **El fondo debe ser transparente** para que se vea bien en todos los dispositivos

## Especificaciones del icono:
- **Formato**: PNG
- **Tamaño mínimo**: 1024x1024 píxeles
- **Fondo**: Transparente
- **Contenido**: Logo circular con "RD" y gradiente azul-cyan

## Una vez que hayas colocado el archivo:
Ejecuta estos comandos en la terminal:
```bash
flutter pub get
flutter pub run flutter_launcher_icons:main
flutter clean
flutter build apk --debug
flutter install --debug
```

¡Esto generará automáticamente todos los tamaños de icono necesarios para Android, iOS, Web, Windows y macOS!
