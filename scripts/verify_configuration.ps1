# Script de PowerShell para verificar la configuración de Firebase
# Uso: .\scripts\verify_configuration.ps1

param(
    [switch]$SkipTests
)

# Configurar colores para output
$ErrorActionPreference = "Stop"

function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

Write-Host "🔍 Verificando configuración de Firebase..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# Verificar que estemos en el directorio correcto
if (-not (Test-Path "pubspec.yaml")) {
    Write-Error "No se encontró pubspec.yaml. Asegúrate de estar en el directorio raíz del proyecto Flutter"
    exit 1
}

# Verificar que Flutter esté instalado
try {
    $flutterVersion = flutter --version
    Write-Status "Flutter encontrado: $($flutterVersion.Split("`n")[0])"
} catch {
    Write-Error "Flutter no está instalado o no está en el PATH"
    exit 1
}

Write-Status "Verificando dependencias de Flutter..."
flutter pub get

if (-not $SkipTests) {
    Write-Status "Ejecutando análisis de código..."
    flutter analyze

    Write-Status "Ejecutando tests..."
    flutter test
}

Write-Host ""
Write-Host "📱 Verificando archivos de configuración..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# Verificar archivos de Android
Write-Status "Verificando archivos Android..."
$androidFiles = @(
    "android/app/src/dev/google-services.json",
    "android/app/src/staging/google-services.json",
    "android/app/src/prod/google-services.json"
)

foreach ($file in $androidFiles) {
    if (Test-Path $file) {
        Write-Success "✅ $file existe"
    } else {
        Write-Error "❌ $file no encontrado"
    }
}

# Verificar archivos de iOS
Write-Status "Verificando archivos iOS..."
$iosFiles = @(
    "ios/Runner/GoogleService-Info-dev.plist",
    "ios/Runner/GoogleService-Info-staging.plist",
    "ios/Runner/GoogleService-Info-prod.plist",
    "ios/Runner/GoogleService-Info.plist"
)

foreach ($file in $iosFiles) {
    if (Test-Path $file) {
        Write-Success "✅ $file existe"
    } else {
        Write-Error "❌ $file no encontrado"
    }
}

# Verificar archivos de configuración Flutter
Write-Status "Verificando archivos de configuración Flutter..."
$flutterFiles = @(
    "lib/firebase_options_dev.dart",
    "lib/firebase_options_staging.dart",
    "lib/firebase_options_prod.dart"
)

foreach ($file in $flutterFiles) {
    if (Test-Path $file) {
        Write-Success "✅ $file existe"
    } else {
        Write-Error "❌ $file no encontrado"
    }
}

Write-Host ""
Write-Host "🔧 Verificando configuración de build flavors..." -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan

# Verificar configuración de Android
Write-Status "Verificando configuración de Android..."
if (Test-Path "android/app/build.gradle.kts") {
    $content = Get-Content "android/app/build.gradle.kts" -Raw
    if ($content -match "productFlavors") {
        Write-Success "✅ Build flavors configurados en Android"
    } else {
        Write-Error "❌ Build flavors no configurados en Android"
    }
} else {
    Write-Error "❌ android/app/build.gradle.kts no encontrado"
}

# Verificar configuración de iOS
Write-Status "Verificando configuración de iOS..."
if (Test-Path "ios/Runner.xcworkspace") {
    Write-Success "✅ Workspace de iOS existe"
} else {
    Write-Error "❌ Workspace de iOS no encontrado"
}

Write-Host ""
Write-Host "📊 Resumen de verificación:" -ForegroundColor Cyan
Write-Host "==========================" -ForegroundColor Cyan

# Contar archivos de configuración
$androidConfigs = (Get-ChildItem "android/app/src" -Recurse -Name "google-services.json" -ErrorAction SilentlyContinue).Count
$iosConfigs = (Get-ChildItem "ios/Runner" -Name "GoogleService-Info*.plist" -ErrorAction SilentlyContinue).Count
$flutterConfigs = (Get-ChildItem "lib" -Name "firebase_options_*.dart" -ErrorAction SilentlyContinue).Count

Write-Status "Archivos de configuración encontrados:"
Write-Status "  - Android: $androidConfigs/3"
Write-Status "  - iOS: $iosConfigs/4 (incluyendo el original)"
Write-Status "  - Flutter: $flutterConfigs/3"

if ($androidConfigs -eq 3 -and $iosConfigs -eq 4 -and $flutterConfigs -eq 3) {
    Write-Success "🎉 ¡Toda la configuración está completa!"
} else {
    Write-Warning "⚠️ Algunos archivos de configuración faltan"
}

Write-Host ""
Write-Status "Para probar manualmente:"
Write-Status "  flutter run --flavor dev --dart-define=ENVIRONMENT=development"
Write-Status "  flutter run --flavor staging --dart-define=ENVIRONMENT=staging"
Write-Status "  flutter run --flavor prod --dart-define=ENVIRONMENT=production"

Write-Host ""
Write-Status "Para construir todas las versiones:"
Write-Status "  .\scripts\build_all.ps1"
Write-Status "  o en macOS/Linux: ./scripts/build_all.sh"

Write-Host ""
Write-Status "Opciones del script:"
Write-Status "  -SkipTests     : Saltar análisis y tests"
