# 🔧 Configuración de Entornos - Servicios Hogar RD

Esta guía explica cómo configurar y usar los diferentes entornos de la aplicación.

## 📁 Estructura de Archivos

```
lib/config/
├── environment.dart          # Configuración de entornos
├── firebase_config.dart      # Configuración centralizada de Firebase
└── ...

lib/
├── firebase_options_dev.dart     # Configuración Firebase DEV
├── firebase_options_staging.dart # Configuración Firebase STAGING
├── firebase_options_prod.dart    # Configuración Firebase PROD
└── ...

scripts/
├── build_all.sh             # Script de construcción (Linux/Mac)
├── build_all.ps1            # Script de construcción (Windows)
└── ...
```

## 🚀 Comandos Rápidos

### Ejecutar en Desarrollo
```bash
flutter run --flavor dev --dart-define=ENVIRONMENT=development
```

### Ejecutar en Staging
```bash
flutter run --flavor staging --dart-define=ENVIRONMENT=staging
```

### Ejecutar en Producción
```bash
flutter run --flavor prod --dart-define=ENVIRONMENT=production
```

### Construir Todas las Versiones
```bash
# Windows
.\scripts\build_all.ps1

# Linux/Mac
./scripts/build_all.sh
```

## 🔥 Configuración de Firebase

### 1. Proyectos Requeridos
- **Desarrollo:** `servicios-hogar-rd-dev`
- **Staging:** `servicios-hogar-rd-staging`
- **Producción:** `servicios-hogar-rd-prod`

### 2. Aplicaciones Android
- **DEV:** `com.app.hogar.dev`
- **STAGING:** `com.app.hogar.staging`
- **PROD:** `com.app.hogar`

### 3. Aplicaciones iOS
- **DEV:** `com.app.hogar.dev`
- **STAGING:** `com.app.hogar.staging`
- **PROD:** `com.app.hogar`

## 📱 Build Flavors

### Android
Los flavors están configurados en `android/app/build.gradle.kts`:

```kotlin
productFlavors {
    create("dev") {
        dimension = "environment"
        applicationIdSuffix = ".dev"
        versionNameSuffix = "-dev"
        resValue("string", "app_name", "Servicios Hogar RD Dev")
    }
    create("staging") {
        dimension = "environment"
        applicationIdSuffix = ".staging"
        versionNameSuffix = "-staging"
        resValue("string", "app_name", "Servicios Hogar RD Staging")
    }
    create("prod") {
        dimension = "environment"
        resValue("string", "app_name", "Servicios Hogar RD")
    }
}
```

### iOS
Los esquemas están configurados en Xcode:
- **Runner-dev**
- **Runner-staging**
- **Runner-prod**

## 🌐 Variables de Entorno

### URLs de API
- **Desarrollo:** `http://localhost:3000`
- **Staging:** `https://staging-api.servicioshogarrd.com`
- **Producción:** `https://api.servicioshogarrd.com`

### Proyectos Firebase
- **Desarrollo:** `servicios-hogar-rd-dev`
- **Staging:** `servicios-hogar-rd-staging`
- **Producción:** `servicios-hogar-rd-prod`

## 🔧 Configuración de Archivos Nativos

### Android
```
android/app/
├── google-services-dev.json
├── google-services-staging.json
├── google-services-prod.json
└── google-services.json (actual)
```

### iOS
```
ios/Runner/
├── GoogleService-Info-dev.plist
├── GoogleService-Info-staging.plist
├── GoogleService-Info-prod.plist
└── GoogleService-Info.plist (actual)
```

## 🚨 Pasos de Configuración

### 1. Crear Proyectos Firebase
1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Crea los 3 proyectos con los nombres especificados
3. Configura las aplicaciones Android e iOS para cada proyecto

### 2. Descargar Archivos de Configuración
1. Descarga `google-services.json` para cada proyecto Android
2. Descarga `GoogleService-Info.plist` para cada proyecto iOS
3. Colócalos en las ubicaciones especificadas

### 3. Actualizar Claves de Firebase
1. Abre cada archivo `firebase_options_*.dart`
2. Reemplaza las claves de ejemplo con las reales
3. Verifica que los `projectId` coincidan

### 4. Configurar Build Flavors
1. **Android:** Ya configurado en `build.gradle.kts`
2. **iOS:** Configurar esquemas en Xcode
3. **Web:** Usar `--dart-define=ENVIRONMENT=*`

## 🧪 Testing de Configuración

### Verificar Configuración
```dart
// En tu código
FirebaseConfig.printDebugInfo();
```

### Verificar Entorno
```dart
print('Environment: ${Environment.isDevelopment ? "DEV" : 
                     Environment.isStaging ? "STAGING" : "PROD"}');
print('API URL: ${Environment.apiUrl}');
print('Firebase Project: ${Environment.firebaseProjectId}');
```

## 📦 Comandos de Build

### Android APK
```bash
# Desarrollo
flutter build apk --flavor dev --dart-define=ENVIRONMENT=development

# Staging
flutter build apk --flavor staging --dart-define=ENVIRONMENT=staging

# Producción
flutter build apk --flavor prod --dart-define=ENVIRONMENT=production
```

### iOS
```bash
# Desarrollo
flutter build ios --flavor dev --dart-define=ENVIRONMENT=development

# Staging
flutter build ios --flavor staging --dart-define=ENVIRONMENT=staging

# Producción
flutter build ios --flavor prod --dart-define=ENVIRONMENT=production
```

### Web
```bash
# Desarrollo
flutter build web --dart-define=ENVIRONMENT=development

# Staging
flutter build web --dart-define=ENVIRONMENT=staging

# Producción
flutter build web --dart-define=ENVIRONMENT=production
```

## 🔍 Debugging

### Verificar Configuración Actual
```dart
// En main.dart o cualquier widget
@override
void initState() {
  super.initState();
  FirebaseConfig.printDebugInfo();
}
```

### Logs de Entorno
La aplicación mostrará automáticamente:
- Entorno actual
- Proyecto de Firebase
- Estado de validez de la configuración
- Clave API (parcial)

## ⚠️ Notas Importantes

1. **Seguridad:** Nunca subas archivos de configuración a repositorios públicos
2. **Variables:** Usa variables de entorno para claves sensibles en CI/CD
3. **Testing:** Prueba cada entorno antes de hacer deploy
4. **Backup:** Mantén copias de seguridad de tus configuraciones

## 🆘 Solución de Problemas

### Error: "Firebase project not found"
- Verifica que el `projectId` en `firebase_options_*.dart` coincida con el proyecto real
- Asegúrate de que el proyecto existe en Firebase Console

### Error: "Invalid API key"
- Verifica que la `apiKey` en `firebase_options_*.dart` sea correcta
- Descarga nuevamente el archivo de configuración desde Firebase Console

### Error: "App not found"
- Verifica que el `appId` coincida con la aplicación registrada
- Asegúrate de que la aplicación esté registrada en el proyecto correcto

### Error de Build Flavor
- Verifica que el flavor esté definido en `build.gradle.kts`
- Asegúrate de usar `--flavor` en el comando de build

¡Con esta configuración tendrás un entorno completamente separado y profesional! 🎉
