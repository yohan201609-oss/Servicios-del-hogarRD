# 🔥 Guía de Configuración de Firebase Multi-Entorno

Esta guía te ayudará a configurar proyectos separados de Firebase para desarrollo, staging y producción.

## 📋 Tabla de Contenidos

1. [Crear Proyectos en Firebase Console](#1-crear-proyectos-en-firebase-console)
2. [Configurar Aplicaciones Android](#2-configurar-aplicaciones-android)
3. [Configurar Aplicaciones iOS](#3-configurar-aplicaciones-ios)
4. [Configurar Build Flavors para Android](#4-configurar-build-flavors-para-android)
5. [Configurar Build Flavors para iOS](#5-configurar-build-flavors-para-ios)
6. [Actualizar Configuraciones de Código](#6-actualizar-configuraciones-de-código)
7. [Comandos de Build](#7-comandos-de-build)

---

## 1. Crear Proyectos en Firebase Console

### Paso 1: Acceder a Firebase Console
1. Ve a [https://console.firebase.google.com/](https://console.firebase.google.com/)
2. Inicia sesión con tu cuenta de Google

### Paso 2: Crear Proyecto de Desarrollo
1. Haz clic en **"Crear un proyecto"**
2. **Nombre del proyecto:** `servicios-hogar-rd-dev`
3. **ID del proyecto:** `servicios-hogar-rd-dev`
4. **Región:** Selecciona la más cercana (ej: us-central1)
5. **Google Analytics:** ✅ Habilitado
6. **Cuenta de Analytics:** Selecciona o crea una nueva
7. Haz clic en **"Crear proyecto"**

### Paso 3: Crear Proyecto de Staging
1. Repite el proceso anterior con:
   - **Nombre:** `servicios-hogar-rd-staging`
   - **ID:** `servicios-hogar-rd-staging`

### Paso 4: Crear Proyecto de Producción
1. Repite el proceso anterior con:
   - **Nombre:** `servicios-hogar-rd-prod`
   - **ID:** `servicios-hogar-rd-prod`

---

## 2. Configurar Aplicaciones Android

### Paso 1: Agregar App Android al Proyecto DEV
1. En el proyecto `servicios-hogar-rd-dev`:
   - Haz clic en **"Agregar app"** → **Android**
   - **Nombre del paquete Android:** `com.app.hogar.dev`
   - **Apodo de la app:** `Servicios Hogar RD Dev`
   - **Certificado de firma SHA-1:** (opcional por ahora)
   - Haz clic en **"Registrar app"**
   - Descarga `google-services.json`

### Paso 2: Agregar App Android al Proyecto STAGING
1. En el proyecto `servicios-hogar-rd-staging`:
   - **Nombre del paquete:** `com.app.hogar.staging`
   - **Apodo:** `Servicios Hogar RD Staging`
   - Descarga `google-services.json`

### Paso 3: Agregar App Android al Proyecto PROD
1. En el proyecto `servicios-hogar-rd-prod`:
   - **Nombre del paquete:** `com.app.hogar`
   - **Apodo:** `Servicios Hogar RD`
   - Descarga `google-services.json`

### Paso 4: Organizar Archivos de Configuración
```
android/app/
├── google-services-dev.json
├── google-services-staging.json
├── google-services-prod.json
└── google-services.json (actual - para desarrollo)
```

---

## 3. Configurar Aplicaciones iOS

### Paso 1: Agregar App iOS al Proyecto DEV
1. En el proyecto `servicios-hogar-rd-dev`:
   - Haz clic en **"Agregar app"** → **iOS**
   - **ID del paquete iOS:** `com.app.hogar.dev`
   - **Apodo de la app:** `Servicios Hogar RD Dev`
   - **ID de la app:** `com.app.hogar.dev`
   - Haz clic en **"Registrar app"**
   - Descarga `GoogleService-Info.plist`

### Paso 2: Agregar App iOS al Proyecto STAGING
1. En el proyecto `servicios-hogar-rd-staging`:
   - **ID del paquete:** `com.app.hogar.staging`
   - **Apodo:** `Servicios Hogar RD Staging`
   - Descarga `GoogleService-Info.plist`

### Paso 3: Agregar App iOS al Proyecto PROD
1. En el proyecto `servicios-hogar-rd-prod`:
   - **ID del paquete:** `com.app.hogar`
   - **Apodo:** `Servicios Hogar RD`
   - Descarga `GoogleService-Info.plist`

### Paso 4: Organizar Archivos de Configuración
```
ios/Runner/
├── GoogleService-Info-dev.plist
├── GoogleService-Info-staging.plist
├── GoogleService-Info-prod.plist
└── GoogleService-Info.plist (actual - para desarrollo)
```

---

## 4. Configurar Build Flavors para Android

### Paso 1: Crear Estructura de Directorios
```
android/app/src/
├── dev/
│   └── google-services.json
├── staging/
│   └── google-services.json
└── prod/
    └── google-services.json
```

### Paso 2: Actualizar `android/app/build.gradle.kts`

```kotlin
android {
    compileSdk 34

    defaultConfig {
        applicationId "com.app.hogar"
        minSdk 21
        targetSdk 34
        versionCode 1
        versionName "1.0"
    }

    flavorDimensions "environment"
    productFlavors {
        dev {
            dimension "environment"
            applicationIdSuffix ".dev"
            versionNameSuffix "-dev"
            resValue "string", "app_name", "Servicios Hogar RD Dev"
        }
        staging {
            dimension "environment"
            applicationIdSuffix ".staging"
            versionNameSuffix "-staging"
            resValue "string", "app_name", "Servicios Hogar RD Staging"
        }
        prod {
            dimension "environment"
            resValue "string", "app_name", "Servicios Hogar RD"
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}

dependencies {
    // Firebase
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-analytics'
    implementation 'com.google.firebase:firebase-auth'
    implementation 'com.google.firebase:firebase-firestore'
    
    // Google Services
    implementation 'com.google.gms:google-services:4.4.0'
}
```

### Paso 3: Actualizar `android/build.gradle.kts`

```kotlin
plugins {
    id("com.android.application") version "8.1.4" apply false
    id("org.jetbrains.kotlin.android") version "1.8.10" apply false
    id("com.google.gms.google-services") version "4.4.0" apply false
}
```

### Paso 4: Crear Script de Build
```bash
# android/build_scripts/build_dev.sh
#!/bin/bash
flutter build apk --flavor dev --dart-define=ENVIRONMENT=development
```

---

## 5. Configurar Build Flavors para iOS

### Paso 1: Crear Configuraciones en Xcode
1. Abre `ios/Runner.xcworkspace` en Xcode
2. Selecciona el proyecto **Runner**
3. Ve a **Info** → **Configurations**
4. Duplica **Debug** y **Release** para cada flavor:
   - **Debug-dev**
   - **Debug-staging**
   - **Debug-prod**
   - **Release-dev**
   - **Release-staging**
   - **Release-prod**

### Paso 2: Crear Esquemas de Build
1. En Xcode: **Product** → **Scheme** → **Manage Schemes**
2. Duplica el esquema **Runner** para cada flavor:
   - **Runner-dev**
   - **Runner-staging**
   - **Runner-prod**

### Paso 3: Configurar Build Settings
Para cada esquema, configura:
- **Bundle Identifier:** `com.app.hogar.dev` (dev), `com.app.hogar.staging` (staging), `com.app.hogar` (prod)
- **Display Name:** `Servicios Hogar RD Dev` (dev), `Servicios Hogar RD Staging` (staging), `Servicios Hogar RD` (prod)

### Paso 4: Script de Build para iOS
```bash
# ios/build_scripts/build_dev.sh
#!/bin/bash
flutter build ios --flavor dev --dart-define=ENVIRONMENT=development
```

---

## 6. Actualizar Configuraciones de Código

### Paso 1: Actualizar `lib/firebase_options_dev.dart`
Reemplaza las claves de ejemplo con las reales del proyecto DEV:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'TU_API_KEY_DEV_AQUI',
  appId: '1:TU_PROJECT_NUMBER:android:com.app.hogar.dev',
  messagingSenderId: 'TU_MESSAGING_SENDER_ID',
  projectId: 'servicios-hogar-rd-dev',
  storageBucket: 'servicios-hogar-rd-dev.firebasestorage.app',
);
```

### Paso 2: Actualizar `lib/firebase_options_staging.dart`
Reemplaza con las claves del proyecto STAGING.

### Paso 3: Actualizar `lib/firebase_options_prod.dart`
Reemplaza con las claves del proyecto PROD.

---

## 7. Comandos de Build

### Android
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

---

## 🔧 Scripts de Automatización

### `scripts/build_all.sh`
```bash
#!/bin/bash

echo "🔨 Building all environments..."

# Android
echo "📱 Building Android..."
flutter build apk --flavor dev --dart-define=ENVIRONMENT=development
flutter build apk --flavor staging --dart-define=ENVIRONMENT=staging
flutter build apk --flavor prod --dart-define=ENVIRONMENT=production

# iOS
echo "🍎 Building iOS..."
flutter build ios --flavor dev --dart-define=ENVIRONMENT=development
flutter build ios --flavor staging --dart-define=ENVIRONMENT=staging
flutter build ios --flavor prod --dart-define=ENVIRONMENT=production

# Web
echo "🌐 Building Web..."
flutter build web --dart-define=ENVIRONMENT=development
flutter build web --dart-define=ENVIRONMENT=staging
flutter build web --dart-define=ENVIRONMENT=production

echo "✅ All builds completed!"
```

---

## ⚠️ Notas Importantes

1. **Seguridad:** Nunca subas archivos `google-services.json` o `GoogleService-Info.plist` a repositorios públicos
2. **Variables de Entorno:** Usa variables de entorno para claves sensibles en CI/CD
3. **Testing:** Prueba cada entorno antes de hacer deploy a producción
4. **Backup:** Mantén copias de seguridad de tus configuraciones

---

## 🚀 Próximos Pasos

1. Crear los proyectos en Firebase Console
2. Configurar las aplicaciones Android e iOS
3. Actualizar las claves en los archivos de configuración
4. Configurar los build flavors
5. Probar los builds de cada entorno
6. Configurar CI/CD para automatizar los deploys

¡Con esta configuración tendrás un entorno completamente separado para desarrollo, staging y producción! 🎉
