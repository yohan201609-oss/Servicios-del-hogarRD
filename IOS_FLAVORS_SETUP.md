# 🍎 Configuración de Build Flavors para iOS

Esta guía explica cómo configurar build flavors para iOS con diferentes entornos y configuraciones de Firebase.

## 📋 Prerrequisitos

- macOS con Xcode instalado
- Flutter SDK configurado
- Proyectos Firebase creados
- Certificados de desarrollo configurados

## 🛠️ Configuración Paso a Paso

### Paso 1: Crear Configuraciones en Xcode

#### 1.1 Abrir el Proyecto
```bash
open ios/Runner.xcworkspace
```

#### 1.2 Crear Configuraciones
1. Selecciona el proyecto **Runner** en el navegador
2. Ve a la pestaña **Info**
3. En la sección **Configurations**, haz clic en el botón **+**
4. Duplica las configuraciones existentes:

**Configuraciones a crear:**
- **Debug-dev** (duplicar de Debug)
- **Debug-staging** (duplicar de Debug)
- **Debug-prod** (duplicar de Debug)
- **Release-dev** (duplicar de Release)
- **Release-staging** (duplicar de Release)
- **Release-prod** (duplicar de Release)

### Paso 2: Crear Esquemas de Build

#### 2.1 Abrir Gestor de Esquemas
1. En Xcode: **Product** → **Scheme** → **Manage Schemes**
2. Haz clic en **Duplicate** en el esquema **Runner**

#### 2.2 Crear Esquemas
Crear los siguientes esquemas:

**Runner-dev:**
- **Name:** Runner-dev
- **Build Configuration:** Debug-dev
- **Archive Configuration:** Release-dev

**Runner-staging:**
- **Name:** Runner-staging
- **Build Configuration:** Debug-staging
- **Archive Configuration:** Release-staging

**Runner-prod:**
- **Name:** Runner-prod
- **Build Configuration:** Debug-prod
- **Archive Configuration:** Release-prod

### Paso 3: Configurar Build Settings

#### 3.1 Configurar Bundle Identifiers
Para cada esquema, ve a **Build Settings** y configura:

**Runner-dev:**
- **Product Bundle Identifier:** `com.app.hogar.dev`
- **Display Name:** `Servicios Hogar RD Dev`

**Runner-staging:**
- **Product Bundle Identifier:** `com.app.hogar.staging`
- **Display Name:** `Servicios Hogar RD Staging`

**Runner-prod:**
- **Product Bundle Identifier:** `com.app.hogar`
- **Display Name:** `Servicios Hogar RD`

#### 3.2 Configurar User-Defined Settings
Agregar variables personalizadas:

**Para todos los esquemas:**
- **FIREBASE_ENVIRONMENT:** dev/staging/prod
- **API_URL:** URL correspondiente al entorno

### Paso 4: Configurar Archivos de Firebase

#### 4.1 Estructura de Archivos
```
ios/Runner/
├── GoogleService-Info-dev.plist
├── GoogleService-Info-staging.plist
├── GoogleService-Info-prod.plist
└── GoogleService-Info.plist (actual)
```

#### 4.2 Script de Selección de Archivo
Crear un script de build phase para seleccionar el archivo correcto:

**Script:**
```bash
# Script: Select GoogleService-Info.plist
if [ "${FIREBASE_ENVIRONMENT}" = "dev" ]; then
    cp "${SRCROOT}/Runner/GoogleService-Info-dev.plist" "${SRCROOT}/Runner/GoogleService-Info.plist"
elif [ "${FIREBASE_ENVIRONMENT}" = "staging" ]; then
    cp "${SRCROOT}/Runner/GoogleService-Info-staging.plist" "${SRCROOT}/Runner/GoogleService-Info.plist"
elif [ "${FIREBASE_ENVIRONMENT}" = "prod" ]; then
    cp "${SRCROOT}/Runner/GoogleService-Info-prod.plist" "${SRCROOT}/Runner/GoogleService-Info.plist"
fi
```

### Paso 5: Configurar Info.plist

#### 5.1 Agregar Configuraciones por Entorno
En `ios/Runner/Info.plist`, agregar:

```xml
<key>CFBundleDisplayName</key>
<string>$(DISPLAY_NAME)</string>
<key>CFBundleIdentifier</key>
<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
<key>FirebaseEnvironment</key>
<string>$(FIREBASE_ENVIRONMENT)</string>
<key>APIURL</key>
<string>$(API_URL)</string>
```

## 🚀 Comandos de Build

### Build para Desarrollo
```bash
flutter build ios --flavor dev --dart-define=ENVIRONMENT=development
```

### Build para Staging
```bash
flutter build ios --flavor staging --dart-define=ENVIRONMENT=staging
```

### Build para Producción
```bash
flutter build ios --flavor prod --dart-define=ENVIRONMENT=production
```

### Build con Configuración Específica
```bash
# Debug
flutter build ios --flavor dev --dart-define=ENVIRONMENT=development --debug

# Release
flutter build ios --flavor prod --dart-define=ENVIRONMENT=production --release
```

## 🧪 Testing y Verificación

### Ejecutar en Simulador
```bash
# Desarrollo
flutter run --flavor dev --dart-define=ENVIRONMENT=development

# Staging
flutter run --flavor staging --dart-define=ENVIRONMENT=staging

# Producción
flutter run --flavor prod --dart-define=ENVIRONMENT=production
```

### Verificar Configuración
```bash
# Verificar que los flavors estén configurados
flutter build ios --help | grep flavor

# Verificar configuración de Firebase
flutter run --flavor dev --dart-define=ENVIRONMENT=development --verbose
```

## 📱 Configuración de Firebase

### Proyectos Requeridos
- **Desarrollo:** `servicios-hogar-rd-dev`
- **Staging:** `servicios-hogar-rd-staging`
- **Producción:** `servicios-hogar-rd-prod`

### Aplicaciones iOS
- **DEV:** `com.app.hogar.dev`
- **STAGING:** `com.app.hogar.staging`
- **PROD:** `com.app.hogar`

### Archivos de Configuración
Cada entorno necesita su propio `GoogleService-Info.plist`:

1. **GoogleService-Info-dev.plist**
   - Proyecto: `servicios-hogar-rd-dev`
   - Bundle ID: `com.app.hogar.dev`

2. **GoogleService-Info-staging.plist**
   - Proyecto: `servicios-hogar-rd-staging`
   - Bundle ID: `com.app.hogar.staging`

3. **GoogleService-Info-prod.plist**
   - Proyecto: `servicios-hogar-rd-prod`
   - Bundle ID: `com.app.hogar`

## 🔧 Scripts de Automatización

### Script de Build Completo
```bash
#!/bin/bash
# ios/build_scripts/build_all.sh

echo "🍎 Building all iOS flavors..."

# Desarrollo
echo "Building DEV..."
flutter build ios --flavor dev --dart-define=ENVIRONMENT=development

# Staging
echo "Building STAGING..."
flutter build ios --flavor staging --dart-define=ENVIRONMENT=staging

# Producción
echo "Building PROD..."
flutter build ios --flavor prod --dart-define=ENVIRONMENT=production

echo "✅ All iOS builds completed!"
```

### Script de Deploy
```bash
#!/bin/bash
# ios/build_scripts/deploy.sh

FLAVOR=$1
ENVIRONMENT=$2

if [ -z "$FLAVOR" ] || [ -z "$ENVIRONMENT" ]; then
    echo "Usage: ./deploy.sh <flavor> <environment>"
    echo "Example: ./deploy.sh dev development"
    exit 1
fi

echo "🚀 Deploying $FLAVOR for $ENVIRONMENT..."

# Build
flutter build ios --flavor $FLAVOR --dart-define=ENVIRONMENT=$ENVIRONMENT

# Archive (si es necesario)
# xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner-$FLAVOR archive

echo "✅ Deploy completed!"
```

## 🚨 Solución de Problemas

### Error: "Flavor not found"
```bash
# Verificar que el flavor esté definido en Xcode
# Verificar que el esquema esté creado correctamente
```

### Error: "Bundle identifier not found"
- Verificar que el Bundle ID esté configurado en Firebase Console
- Verificar que el Bundle ID coincida en Xcode y Firebase

### Error: "GoogleService-Info.plist not found"
- Verificar que el archivo esté en la ubicación correcta
- Verificar que el script de selección esté funcionando

### Error de Build
```bash
# Limpiar y reconstruir
flutter clean
cd ios
rm -rf Pods Podfile.lock
cd ..
flutter pub get
cd ios
pod install
cd ..
flutter build ios --flavor dev --dart-define=ENVIRONMENT=development
```

## 📊 Estructura de Builds Generados

```
build/ios/
├── Debug-dev/
├── Debug-staging/
├── Debug-prod/
├── Release-dev/
├── Release-staging/
└── Release-prod/
```

## ✅ Checklist de Configuración

- [ ] Configuraciones creadas en Xcode
- [ ] Esquemas de build creados
- [ ] Bundle identifiers configurados
- [ ] Display names configurados
- [ ] Archivos GoogleService-Info.plist creados
- [ ] Script de selección de archivo configurado
- [ ] Info.plist actualizado
- [ ] Builds probados en simulador
- [ ] Builds probados en dispositivo físico

## 🎯 Próximos Pasos

1. **Configurar Xcode:**
   - Crear configuraciones y esquemas
   - Configurar Bundle IDs y Display Names

2. **Configurar Firebase:**
   - Crear proyectos iOS en Firebase Console
   - Descargar archivos GoogleService-Info.plist

3. **Probar Configuración:**
   - Ejecutar builds de prueba
   - Verificar conexión a Firebase

4. **Automatizar:**
   - Crear scripts de build
   - Configurar CI/CD

¡Con esta configuración tendrás builds completamente separados para iOS! 🎉
