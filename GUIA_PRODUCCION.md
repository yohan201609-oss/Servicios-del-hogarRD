# 🚀 Guía Completa para Llevar el Proyecto a Producción

## Servicios Hogar RD - Configuración de Producción

### 📋 Índice
1. [Configuraciones de Seguridad](#configuraciones-de-seguridad)
2. [Configuraciones de Firebase](#configuraciones-de-firebase)
3. [Configuraciones de Android](#configuraciones-de-android)
4. [Configuraciones de iOS](#configuraciones-de-ios)
5. [Configuraciones de Web](#configuraciones-de-web)
6. [Configuraciones de Performance](#configuraciones-de-performance)
7. [Configuraciones de Monitoreo](#configuraciones-de-monitoreo)
8. [Configuraciones de Despliegue](#configuraciones-de-despliegue)
9. [Checklist Final](#checklist-final)

---

## 🔒 Configuraciones de Seguridad

### 1. **Configuración de Firebase Security Rules**

**Archivo:** `firestore.rules`
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Reglas para usuarios
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Reglas para perfiles de cliente
    match /perfiles_cliente/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Reglas para perfiles de proveedor
    match /perfiles_proveedor/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Reglas para servicios (solo lectura pública)
    match /servicios/{serviceId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

**Archivo:** `storage.rules`
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /providers/{providerId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

### 2. **Configuración de Variables de Entorno**

**Archivo:** `lib/config/environment.dart`
```dart
class Environment {
  static const String _environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
  
  static bool get isDevelopment => _environment == 'development';
  static bool get isStaging => _environment == 'staging';
  static bool get isProduction => _environment == 'production';
  
  // URLs de API
  static String get apiUrl {
    switch (_environment) {
      case 'production':
        return 'https://api.servicioshogarrd.com';
      case 'staging':
        return 'https://staging-api.servicioshogarrd.com';
      default:
        return 'http://localhost:3000';
    }
  }
  
  // Configuraciones de Firebase
  static String get firebaseProjectId {
    switch (_environment) {
      case 'production':
        return 'servicios-hogar-rd-prod';
      case 'staging':
        return 'servicios-hogar-rd-staging';
      default:
        return 'servicios-hogar-rd-dev';
    }
  }
}
```

### 3. **Configuración de Certificados y Firma**

**Archivo:** `android/app/upload-keystore.properties`
```properties
storePassword=tu_password_seguro
keyPassword=tu_password_seguro
keyAlias=upload
storeFile=../upload-keystore.jks
```

---

## 🔥 Configuraciones de Firebase

### 1. **Configuración de Proyectos Separados**

**Desarrollo:**
- Proyecto: `servicios-hogar-rd-dev`
- Configuración: `lib/firebase_options_dev.dart`

**Staging:**
- Proyecto: `servicios-hogar-rd-staging`
- Configuración: `lib/firebase_options_staging.dart`

**Producción:**
- Proyecto: `servicios-hogar-rd-prod`
- Configuración: `lib/firebase_options_prod.dart`

### 2. **Configuración de Analytics**

**Archivo:** `lib/services/firebase_analytics_service.dart`
```dart
import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseAnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  static Future<void> logEvent(String name, Map<String, dynamic> parameters) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }
  
  static Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }
}
```

### 3. **Configuración de Crashlytics**

**Archivo:** `lib/services/crashlytics_service.dart`
```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class CrashlyticsService {
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  
  static Future<void> recordError(dynamic exception, StackTrace? stackTrace) async {
    await _crashlytics.recordError(exception, stackTrace);
  }
  
  static Future<void> setUserId(String userId) async {
    await _crashlytics.setUserId(userId);
  }
}
```

---

## 🤖 Configuraciones de Android

### 1. **Configuración de Firma de Producción**

**Archivo:** `android/app/build.gradle.kts`
```kotlin
android {
    signingConfigs {
        create("release") {
            keyAlias = "upload"
            keyPassword = "tu_password_seguro"
            storeFile = file("../upload-keystore.jks")
            storePassword = "tu_password_seguro"
        }
    }
    
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            minifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}
```

### 2. **Configuración de ProGuard**

**Archivo:** `android/app/proguard-rules.pro`
```proguard
# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Gson
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.** { *; }
```

### 3. **Configuración de Permisos**

**Archivo:** `android/app/src/main/AndroidManifest.xml`
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Permisos de Internet -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    
    <!-- Permisos de Ubicación -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    
    <!-- Permisos de Notificaciones -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    
    <!-- Permisos de Cámara -->
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    
    <application
        android:label="@string/app_name"
        android:name="${applicationName}"
        android:icon="@mipmap/launcher_icon"
        android:allowBackup="false"
        android:usesCleartextTraffic="false">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        
        <!-- Firebase Messaging Service -->
        <service
            android:name=".MyFirebaseMessagingService"
            android:exported="false">
            <intent-filter>
                <action android:name="com.google.firebase.MESSAGING_EVENT" />
            </intent-filter>
        </service>
        
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

---

## 🍎 Configuraciones de iOS

### 1. **Configuración de Info.plist**

**Archivo:** `ios/Runner/Info.plist`
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDisplayName</key>
    <string>Servicios Hogar RD</string>
    <key>CFBundleIdentifier</key>
    <string>com.servicioshogarrd.app</string>
    <key>CFBundleVersion</key>
    <string>$(FLUTTER_BUILD_NUMBER)</string>
    <key>CFBundleShortVersionString</key>
    <string>$(FLUTTER_BUILD_NAME)</string>
    
    <!-- Permisos de Ubicación -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>Esta app necesita acceso a tu ubicación para encontrar proveedores cercanos.</string>
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>Esta app necesita acceso a tu ubicación para encontrar proveedores cercanos.</string>
    
    <!-- Permisos de Cámara -->
    <key>NSCameraUsageDescription</key>
    <string>Esta app necesita acceso a la cámara para tomar fotos de servicios.</string>
    
    <!-- Permisos de Fotos -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>Esta app necesita acceso a tus fotos para seleccionar imágenes de servicios.</string>
    
    <!-- Configuración de Red -->
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <false/>
        <key>NSExceptionDomains</key>
        <dict>
            <key>servicioshogarrd.com</key>
            <dict>
                <key>NSExceptionAllowsInsecureHTTPLoads</key>
                <false/>
                <key>NSExceptionMinimumTLSVersion</key>
                <string>TLSv1.2</string>
            </dict>
        </dict>
    </dict>
</dict>
</plist>
```

### 2. **Configuración de App Store Connect**

- **Bundle ID:** `com.servicioshogarrd.app`
- **Versión:** 1.0.0
- **Categoría:** Utilities
- **Clasificación:** 4+

---

## 🌐 Configuraciones de Web

### 1. **Configuración de PWA**

**Archivo:** `web/manifest.json`
```json
{
    "name": "Servicios Hogar RD",
    "short_name": "Servicios RD",
    "start_url": "/",
    "display": "standalone",
    "background_color": "#1a237e",
    "theme_color": "#3f51b5",
    "description": "Encuentra servicios para tu hogar en República Dominicana",
    "orientation": "portrait-primary",
    "prefer_related_applications": false,
    "scope": "/",
    "lang": "es",
    "dir": "ltr",
    "icons": [
        {
            "src": "icons/Icon-192.png",
            "sizes": "192x192",
            "type": "image/png",
            "purpose": "any"
        },
        {
            "src": "icons/Icon-512.png",
            "sizes": "512x512",
            "type": "image/png",
            "purpose": "any"
        },
        {
            "src": "icons/Icon-maskable-192.png",
            "sizes": "192x192",
            "type": "image/png",
            "purpose": "maskable"
        },
        {
            "src": "icons/Icon-maskable-512.png",
            "sizes": "512x512",
            "type": "image/png",
            "purpose": "maskable"
        }
    ]
}
```

### 2. **Configuración de Service Worker**

**Archivo:** `web/sw.js`
```javascript
const CACHE_NAME = 'servicios-hogar-rd-v1';
const urlsToCache = [
  '/',
  '/main.dart.js',
  '/flutter.js',
  '/favicon.png'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => cache.addAll(urlsToCache))
  );
});

self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request)
      .then((response) => {
        if (response) {
          return response;
        }
        return fetch(event.request);
      }
    )
  );
});
```

---

## ⚡ Configuraciones de Performance

### 1. **Configuración de Build Optimizado**

**Archivo:** `lib/main_production.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options_prod.dart';
import 'services/app_service.dart';
import 'screens/simple_login_screen.dart';
import 'screens/simple_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configuración de performance
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Inicializar Firebase para producción
  await Firebase.initializeApp(
    options: DefaultFirebaseOptionsProd.currentPlatform,
  );
  
  // Inicializar servicios
  await AppService.instance.initialize();
  
  runApp(const MyApp());
}
```

### 2. **Configuración de Lazy Loading**

**Archivo:** `lib/utils/lazy_loading.dart`
```dart
class LazyLoading {
  static Widget buildLazyWidget(Widget child) {
    return FutureBuilder(
      future: Future.delayed(const Duration(milliseconds: 100)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return child;
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
```

---

## 📊 Configuraciones de Monitoreo

### 1. **Configuración de Sentry**

**Archivo:** `lib/services/sentry_service.dart`
```dart
import 'package:sentry_flutter/sentry_flutter.dart';

class SentryService {
  static Future<void> init() async {
    await SentryFlutter.init(
      (options) {
        options.dsn = 'TU_DSN_DE_SENTRY';
        options.tracesSampleRate = 1.0;
        options.debug = false;
      },
      appRunner: () => runApp(const MyApp()),
    );
  }
}
```

### 2. **Configuración de Logging**

**Archivo:** `lib/utils/logger_config.dart`
```dart
import 'package:logger/logger.dart';

class LoggerConfig {
  static Logger get logger {
    return Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
    );
  }
}
```

---

## 🚀 Configuraciones de Despliegue

### 1. **Script de Build para Producción**

**Archivo:** `scripts/build_production.sh`
```bash
#!/bin/bash

# Limpiar proyecto
flutter clean
flutter pub get

# Build para Android
flutter build apk --release --target-platform android-arm64
flutter build appbundle --release

# Build para iOS
flutter build ios --release

# Build para Web
flutter build web --release --web-renderer html

# Build para Windows
flutter build windows --release

# Build para macOS
flutter build macos --release

echo "Builds completados para producción"
```

### 2. **Configuración de CI/CD**

**Archivo:** `.github/workflows/production.yml`
```yaml
name: Production Build

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.9.2'
        
    - name: Install dependencies
      run: flutter pub get
      
    - name: Run tests
      run: flutter test
      
    - name: Build APK
      run: flutter build apk --release
      
    - name: Build App Bundle
      run: flutter build appbundle --release
      
    - name: Upload artifacts
      uses: actions/upload-artifact@v2
      with:
        name: release-files
        path: build/app/outputs/
```

---

## ✅ Checklist Final

### **Configuraciones de Seguridad**
- [ ] Firebase Security Rules configuradas
- [ ] Variables de entorno separadas por ambiente
- [ ] Certificados de firma configurados
- [ ] Permisos de Android configurados
- [ ] Permisos de iOS configurados

### **Configuraciones de Firebase**
- [ ] Proyectos separados (dev/staging/prod)
- [ ] Analytics configurado
- [ ] Crashlytics configurado
- [ ] Performance Monitoring configurado
- [ ] Remote Config configurado

### **Configuraciones de Build**
- [ ] ProGuard configurado para Android
- [ ] Build optimizado para producción
- [ ] Lazy loading implementado
- [ ] Caching configurado
- [ ] Service Worker configurado

### **Configuraciones de Monitoreo**
- [ ] Sentry configurado
- [ ] Logging configurado
- [ ] Métricas de performance
- [ ] Alertas configuradas

### **Configuraciones de Despliegue**
- [ ] Scripts de build automatizados
- [ ] CI/CD configurado
- [ ] Artifacts configurados
- [ ] Testing automatizado

### **Configuraciones de App Stores**
- [ ] Google Play Console configurado
- [ ] App Store Connect configurado
- [ ] Metadatos completos
- [ ] Screenshots y descripciones
- [ ] Políticas de privacidad

### **Configuraciones de Dominio y Hosting**
- [ ] Dominio configurado
- [ ] SSL/TLS configurado
- [ ] CDN configurado
- [ ] Backup configurado

---

## 🎯 Próximos Pasos

1. **Implementar todas las configuraciones** listadas en esta guía
2. **Probar en ambiente de staging** antes de producción
3. **Configurar monitoreo** y alertas
4. **Preparar documentación** para el equipo
5. **Capacitar al equipo** en las nuevas configuraciones

---

**Nota:** Esta guía debe ser actualizada regularmente según las mejores prácticas y cambios en las tecnologías utilizadas.
