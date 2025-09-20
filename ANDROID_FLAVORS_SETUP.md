# 🤖 Configuración de Build Flavors para Android

Esta guía explica cómo configurar y usar los build flavors de Android para diferentes entornos.

## 📁 Estructura de Archivos Creada

```
android/app/src/
├── dev/
│   └── google-services.json          # Configuración Firebase DEV
├── staging/
│   └── google-services.json          # Configuración Firebase STAGING
└── prod/
    └── google-services.json          # Configuración Firebase PROD
```

## 🔧 Configuración Implementada

### 1. **`android/app/build.gradle.kts`** ✅

```kotlin
android {
    namespace = "com.app.hogar"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.app.hogar"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    flavorDimensions += "environment"
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

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    // Firebase
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-storage")
    
    // Google Services
    implementation("com.google.gms:google-services:4.4.0")
}
```

### 2. **`android/build.gradle.kts`** ✅

```kotlin
plugins {
    id("com.android.application") version "8.1.4" apply false
    id("org.jetbrains.kotlin.android") version "1.8.10" apply false
    id("com.google.gms.google-services") version "4.4.0" apply false
}
```

## 🚀 Comandos de Build

### **Desarrollo**
```bash
flutter build apk --flavor dev --dart-define=ENVIRONMENT=development
```
- **Package ID:** `com.app.hogar.dev`
- **App Name:** "Servicios Hogar RD Dev"
- **Version:** "1.0-dev"
- **Firebase Project:** `servicios-hogar-rd-dev`

### **Staging**
```bash
flutter build apk --flavor staging --dart-define=ENVIRONMENT=staging
```
- **Package ID:** `com.app.hogar.staging`
- **App Name:** "Servicios Hogar RD Staging"
- **Version:** "1.0-staging"
- **Firebase Project:** `servicios-hogar-rd-staging`

### **Producción**
```bash
flutter build apk --flavor prod --dart-define=ENVIRONMENT=production
```
- **Package ID:** `com.app.hogar`
- **App Name:** "Servicios Hogar RD"
- **Version:** "1.0"
- **Firebase Project:** `servicios-hogar-rd-prod`

## 🧪 Comandos de Testing

### **Ejecutar en Dispositivo/Emulador**
```bash
# Desarrollo
flutter run --flavor dev --dart-define=ENVIRONMENT=development

# Staging
flutter run --flavor staging --dart-define=ENVIRONMENT=staging

# Producción
flutter run --flavor prod --dart-define=ENVIRONMENT=production
```

### **Verificar Configuración**
```bash
# Ver flavors disponibles
flutter build apk --help | grep flavor

# Ver configuración actual
flutter doctor -v
```

## 📱 Configuración de Firebase

### **Archivos de Configuración**
Cada flavor tiene su propio archivo `google-services.json`:

1. **`android/app/src/dev/google-services.json`**
   - Proyecto: `servicios-hogar-rd-dev`
   - Package: `com.app.hogar.dev`

2. **`android/app/src/staging/google-services.json`**
   - Proyecto: `servicios-hogar-rd-staging`
   - Package: `com.app.hogar.staging`

3. **`android/app/src/prod/google-services.json`**
   - Proyecto: `servicios-hogar-rd-prod`
   - Package: `com.app.hogar`

### **Actualizar Configuraciones**
1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Crea los 3 proyectos con los nombres especificados
3. Registra las aplicaciones Android con los package names correctos
4. Descarga los archivos `google-services.json` reales
5. Reemplaza los archivos de ejemplo con los reales

## 🔍 Verificación de Configuración

### **Verificar Build Flavors**
```bash
# Listar flavors disponibles
./gradlew tasks --all | grep "assemble"

# Deberías ver:
# assembleDev
# assembleStaging
# assembleProd
# assembleDevDebug
# assembleDevRelease
# assembleStagingDebug
# assembleStagingRelease
# assembleProdDebug
# assembleProdRelease
```

### **Verificar Configuración de Firebase**
```bash
# Verificar que los archivos estén en su lugar
ls -la android/app/src/*/google-services.json

# Deberías ver:
# android/app/src/dev/google-services.json
# android/app/src/staging/google-services.json
# android/app/src/prod/google-services.json
```

## 🚨 Solución de Problemas

### **Error: "Flavor not found"**
```bash
# Verificar que el flavor esté definido
./gradlew tasks --all | grep "assembleDev"
```

### **Error: "Google Services not found"**
- Verifica que el archivo `google-services.json` esté en la carpeta correcta
- Verifica que el `package_name` en el archivo coincida con el `applicationId` del flavor

### **Error: "Firebase project not found"**
- Verifica que el `project_id` en `google-services.json` sea correcto
- Asegúrate de que el proyecto exista en Firebase Console

### **Error de Build**
```bash
# Limpiar y reconstruir
flutter clean
flutter pub get
flutter build apk --flavor dev --dart-define=ENVIRONMENT=development
```

## 📊 Estructura de APKs Generados

```
build/app/outputs/flutter-apk/
├── app-dev-debug.apk          # Desarrollo Debug
├── app-dev-release.apk        # Desarrollo Release
├── app-staging-debug.apk      # Staging Debug
├── app-staging-release.apk    # Staging Release
├── app-prod-debug.apk         # Producción Debug
└── app-prod-release.apk       # Producción Release
```

## 🎯 Próximos Pasos

1. **Crear Proyectos Firebase:**
   - `servicios-hogar-rd-dev`
   - `servicios-hogar-rd-staging`
   - `servicios-hogar-rd-prod`

2. **Registrar Aplicaciones Android:**
   - `com.app.hogar.dev`
   - `com.app.hogar.staging`
   - `com.app.hogar`

3. **Descargar Configuraciones Reales:**
   - Reemplazar archivos `google-services.json` de ejemplo
   - Actualizar claves en `firebase_options_*.dart`

4. **Probar Builds:**
   - Ejecutar cada flavor en dispositivo/emulador
   - Verificar que se conecte al proyecto Firebase correcto

## ✅ Checklist de Configuración

- [x] Estructura de directorios creada
- [x] `build.gradle.kts` configurado con flavors
- [x] Plugins de Firebase configurados
- [x] Archivos `google-services.json` de ejemplo creados
- [ ] Proyectos Firebase creados en consola
- [ ] Aplicaciones Android registradas
- [ ] Configuraciones reales descargadas
- [ ] Builds probados en dispositivos

¡Con esta configuración tendrás builds completamente separados para cada entorno! 🎉
