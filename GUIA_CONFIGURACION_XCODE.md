# 🍎 Guía de Configuración de Xcode para iOS Flavors

Esta guía te ayudará a configurar Xcode para manejar diferentes entornos (dev, staging, prod) en tu aplicación Flutter.

## 📋 Prerrequisitos

- macOS con Xcode instalado
- Flutter SDK configurado
- Proyectos Firebase creados
- Certificados de desarrollo configurados

## 🛠️ Configuración Paso a Paso

### Paso 1: Abrir el Proyecto en Xcode

```bash
# Desde el directorio raíz del proyecto Flutter
open ios/Runner.xcworkspace
```

**⚠️ Importante:** Siempre abre el archivo `.xcworkspace`, no el `.xcodeproj`

### Paso 2: Crear Configuraciones de Build

#### 2.1 Seleccionar el Proyecto
1. En el navegador de Xcode, selecciona el proyecto **Runner** (el ícono azul)
2. Ve a la pestaña **Info**
3. En la sección **Configurations**, verás las configuraciones actuales:
   - **Debug**
   - **Release**

#### 2.2 Duplicar Configuraciones
1. Haz clic en el botón **+** en la parte inferior
2. Selecciona **Duplicate "Debug" Configuration**
3. Nombra la nueva configuración: **Debug-dev**
4. Repite el proceso para crear:
   - **Debug-staging**
   - **Debug-prod**
   - **Release-dev**
   - **Release-staging**
   - **Release-prod**

### Paso 3: Crear Esquemas de Build

#### 3.1 Abrir Gestor de Esquemas
1. En Xcode: **Product** → **Scheme** → **Manage Schemes**
2. Selecciona el esquema **Runner**
3. Haz clic en **Duplicate**

#### 3.2 Configurar Esquemas
Crear los siguientes esquemas:

**Runner-dev:**
- **Name:** Runner-dev
- **Build Configuration:** Debug-dev
- **Archive Configuration:** Release-dev
- **Run Configuration:** Debug-dev

**Runner-staging:**
- **Name:** Runner-staging
- **Build Configuration:** Debug-staging
- **Archive Configuration:** Release-staging
- **Run Configuration:** Debug-staging

**Runner-prod:**
- **Name:** Runner-prod
- **Build Configuration:** Debug-prod
- **Archive Configuration:** Release-prod
- **Run Configuration:** Debug-prod

### Paso 4: Configurar Build Settings

#### 4.1 Seleccionar Target
1. Selecciona el target **Runner** en el navegador
2. Ve a la pestaña **Build Settings**
3. Asegúrate de que **All** esté seleccionado (no "Basic")

#### 4.2 Configurar Bundle Identifier
Para cada configuración, busca **Product Bundle Identifier**:

**Debug-dev:**
- **Product Bundle Identifier:** `com.app.hogar.dev`

**Debug-staging:**
- **Product Bundle Identifier:** `com.app.hogar.staging`

**Debug-prod:**
- **Product Bundle Identifier:** `com.app.hogar`

**Release-dev:**
- **Product Bundle Identifier:** `com.app.hogar.dev`

**Release-staging:**
- **Product Bundle Identifier:** `com.app.hogar.staging`

**Release-prod:**
- **Product Bundle Identifier:** `com.app.hogar`

#### 4.3 Configurar Display Name
Para cada configuración, busca **Product Name**:

**Debug-dev:**
- **Product Name:** `Servicios Hogar RD Dev`

**Debug-staging:**
- **Product Name:** `Servicios Hogar RD Staging`

**Debug-prod:**
- **Product Name:** `Servicios Hogar RD`

**Release-dev:**
- **Product Name:** `Servicios Hogar RD Dev`

**Release-staging:**
- **Product Name:** `Servicios Hogar RD Staging`

**Release-prod:**
- **Product Name:** `Servicios Hogar RD`

### Paso 5: Configurar Variables de Entorno

#### 5.1 Agregar User-Defined Settings
1. En **Build Settings**, busca **User-Defined Settings**
2. Haz clic en el botón **+** para agregar nuevas variables

**Para Debug-dev:**
- **FIREBASE_ENVIRONMENT:** `dev`
- **API_URL:** `http://localhost:3000`

**Para Debug-staging:**
- **FIREBASE_ENVIRONMENT:** `staging`
- **API_URL:** `https://staging-api.servicioshogarrd.com`

**Para Debug-prod:**
- **FIREBASE_ENVIRONMENT:** `prod`
- **API_URL:** `https://api.servicioshogarrd.com`

**Para Release-dev:**
- **FIREBASE_ENVIRONMENT:** `dev`
- **API_URL:** `http://localhost:3000`

**Para Release-staging:**
- **FIREBASE_ENVIRONMENT:** `staging`
- **API_URL:** `https://staging-api.servicioshogarrd.com`

**Para Release-prod:**
- **FIREBASE_ENVIRONMENT:** `prod`
- **API_URL:** `https://api.servicioshogarrd.com`

### Paso 6: Configurar Script de Selección de Firebase

#### 6.1 Agregar Build Phase
1. Selecciona el target **Runner**
2. Ve a la pestaña **Build Phases**
3. Haz clic en **+** → **New Run Script Phase**
4. Nombra el script: **Select GoogleService-Info.plist**

#### 6.2 Configurar Script
En el campo de script, pega el siguiente código:

```bash
# Script: Select GoogleService-Info.plist
if [ "${FIREBASE_ENVIRONMENT}" = "dev" ]; then
    cp "${SRCROOT}/Runner/GoogleService-Info-dev.plist" "${SRCROOT}/Runner/GoogleService-Info.plist"
    echo "Using GoogleService-Info-dev.plist"
elif [ "${FIREBASE_ENVIRONMENT}" = "staging" ]; then
    cp "${SRCROOT}/Runner/GoogleService-Info-staging.plist" "${SRCROOT}/Runner/GoogleService-Info.plist"
    echo "Using GoogleService-Info-staging.plist"
elif [ "${FIREBASE_ENVIRONMENT}" = "prod" ]; then
    cp "${SRCROOT}/Runner/GoogleService-Info-prod.plist" "${SRCROOT}/Runner/GoogleService-Info.plist"
    echo "Using GoogleService-Info-prod.plist"
else
    echo "Warning: FIREBASE_ENVIRONMENT not set, using default GoogleService-Info.plist"
fi
```

#### 6.3 Configurar Orden de Ejecución
1. Arrastra el script **Select GoogleService-Info.plist** para que se ejecute **ANTES** de **Copy Bundle Resources**
2. El orden debe ser:
   - **Select GoogleService-Info.plist**
   - **Copy Bundle Resources**
   - **Other build phases...**

### Paso 7: Configurar Info.plist

#### 7.1 Agregar Configuraciones Dinámicas
En `ios/Runner/Info.plist`, reemplaza las configuraciones estáticas con variables:

```xml
<key>CFBundleDisplayName</key>
<string>$(PRODUCT_NAME)</string>
<key>CFBundleIdentifier</key>
<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
<key>FirebaseEnvironment</key>
<string>$(FIREBASE_ENVIRONMENT)</string>
<key>APIURL</key>
<string>$(API_URL)</string>
```

### Paso 8: Configurar Certificados y Provisioning Profiles

#### 8.1 Configurar Signing & Capabilities
Para cada esquema:

1. Selecciona el target **Runner**
2. Ve a la pestaña **Signing & Capabilities**
3. Configura para cada configuración:

**Debug-dev:**
- **Team:** Tu equipo de desarrollo
- **Bundle Identifier:** `com.app.hogar.dev`
- **Provisioning Profile:** Automático

**Debug-staging:**
- **Team:** Tu equipo de desarrollo
- **Bundle Identifier:** `com.app.hogar.staging`
- **Provisioning Profile:** Automático

**Debug-prod:**
- **Team:** Tu equipo de desarrollo
- **Bundle Identifier:** `com.app.hogar`
- **Provisioning Profile:** Automático

#### 8.2 Configurar Release (Producción)
Para las configuraciones Release, configura:

**Release-prod:**
- **Team:** Tu equipo de producción
- **Bundle Identifier:** `com.app.hogar`
- **Provisioning Profile:** Perfil de distribución

## 🧪 Verificación de Configuración

### Verificar Esquemas
1. En Xcode, selecciona el esquema en la barra de herramientas
2. Deberías ver:
   - **Runner-dev**
   - **Runner-staging**
   - **Runner-prod**

### Verificar Configuraciones
1. Selecciona **Product** → **Scheme** → **Edit Scheme**
2. Verifica que cada esquema tenga la configuración correcta

### Verificar Build Settings
1. En **Build Settings**, verifica que cada configuración tenga:
   - Bundle Identifier correcto
   - Product Name correcto
   - Variables de entorno configuradas

## 🚀 Comandos de Build

### Desde Xcode
1. Selecciona el esquema deseado
2. Presiona **Cmd + B** para build
3. Presiona **Cmd + R** para run

### Desde Terminal
```bash
# Desarrollo
flutter run --flavor dev --dart-define=ENVIRONMENT=development

# Staging
flutter run --flavor staging --dart-define=ENVIRONMENT=staging

# Producción
flutter run --flavor prod --dart-define=ENVIRONMENT=production
```

## 🚨 Solución de Problemas

### Error: "Bundle identifier not found"
- Verifica que el Bundle ID esté configurado en Firebase Console
- Verifica que el Bundle ID coincida en Xcode y Firebase

### Error: "GoogleService-Info.plist not found"
- Verifica que el archivo esté en la ubicación correcta
- Verifica que el script de selección esté funcionando
- Verifica que el script se ejecute antes de "Copy Bundle Resources"

### Error: "Code signing error"
- Verifica que los certificados estén configurados
- Verifica que los provisioning profiles estén correctos
- Verifica que el Team esté seleccionado

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

## ✅ Checklist de Configuración

- [ ] Proyecto abierto en Xcode
- [ ] Configuraciones creadas (Debug-dev, Debug-staging, etc.)
- [ ] Esquemas creados (Runner-dev, Runner-staging, Runner-prod)
- [ ] Bundle identifiers configurados
- [ ] Display names configurados
- [ ] Variables de entorno configuradas
- [ ] Script de selección de Firebase configurado
- [ ] Info.plist actualizado
- [ ] Certificados configurados
- [ ] Builds probados en simulador
- [ ] Builds probados en dispositivo físico

## 🎯 Próximos Pasos

1. **Configurar Firebase:**
   - Crear proyectos iOS en Firebase Console
   - Descargar archivos GoogleService-Info.plist reales

2. **Probar Configuración:**
   - Ejecutar builds de prueba
   - Verificar conexión a Firebase

3. **Configurar CI/CD:**
   - Scripts de automatización
   - Deploy automático por entornos

¡Con esta configuración tendrás builds completamente separados para iOS! 🎉
