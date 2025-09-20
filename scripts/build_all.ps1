# Script de PowerShell para construir todas las versiones de la aplicación
# Uso: .\scripts\build_all.ps1

param(
    [switch]$SkipTests,
    [switch]$SkipAndroid,
    [switch]$SkipiOS,
    [switch]$SkipWeb
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

Write-Host "🚀 Iniciando construcción de todas las versiones..." -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# Verificar que Flutter esté instalado
try {
    $flutterVersion = flutter --version
    Write-Status "Flutter encontrado: $($flutterVersion.Split("`n")[0])"
} catch {
    Write-Error "Flutter no está instalado o no está en el PATH"
    exit 1
}

# Verificar que estemos en el directorio correcto
if (-not (Test-Path "pubspec.yaml")) {
    Write-Error "No se encontró pubspec.yaml. Asegúrate de estar en el directorio raíz del proyecto Flutter"
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
Write-Host "📱 Construyendo aplicaciones Android..." -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

if (-not $SkipAndroid) {
    # Android - Desarrollo
    Write-Status "Construyendo Android DEV..."
    try {
        flutter build apk --flavor dev --dart-define=ENVIRONMENT=development
        Write-Success "Android DEV construido exitosamente"
    } catch {
        Write-Error "Error construyendo Android DEV"
        exit 1
    }

    # Android - Staging
    Write-Status "Construyendo Android STAGING..."
    try {
        flutter build apk --flavor staging --dart-define=ENVIRONMENT=staging
        Write-Success "Android STAGING construido exitosamente"
    } catch {
        Write-Error "Error construyendo Android STAGING"
        exit 1
    }

    # Android - Producción
    Write-Status "Construyendo Android PROD..."
    try {
        flutter build apk --flavor prod --dart-define=ENVIRONMENT=production
        Write-Success "Android PROD construido exitosamente"
    } catch {
        Write-Error "Error construyendo Android PROD"
        exit 1
    }
} else {
    Write-Warning "Saltando construcción de Android"
}

Write-Host ""
Write-Host "🍎 Construyendo aplicaciones iOS..." -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan

if (-not $SkipiOS) {
    # Verificar si estamos en macOS para iOS
    if ($IsMacOS -or $env:OS -eq "Darwin") {
        # iOS - Desarrollo
        Write-Status "Construyendo iOS DEV..."
        try {
            flutter build ios --flavor dev --dart-define=ENVIRONMENT=development --no-codesign
            Write-Success "iOS DEV construido exitosamente"
        } catch {
            Write-Warning "Error construyendo iOS DEV (puede requerir configuración adicional)"
        }

        # iOS - Staging
        Write-Status "Construyendo iOS STAGING..."
        try {
            flutter build ios --flavor staging --dart-define=ENVIRONMENT=staging --no-codesign
            Write-Success "iOS STAGING construido exitosamente"
        } catch {
            Write-Warning "Error construyendo iOS STAGING (puede requerir configuración adicional)"
        }

        # iOS - Producción
        Write-Status "Construyendo iOS PROD..."
        try {
            flutter build ios --flavor prod --dart-define=ENVIRONMENT=production --no-codesign
            Write-Success "iOS PROD construido exitosamente"
        } catch {
            Write-Warning "Error construyendo iOS PROD (puede requerir configuración adicional)"
        }
    } else {
        Write-Warning "Saltando construcción de iOS - solo disponible en macOS"
    }
} else {
    Write-Warning "Saltando construcción de iOS"
}

Write-Host ""
Write-Host "🌐 Construyendo aplicaciones Web..." -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan

if (-not $SkipWeb) {
    # Web - Desarrollo
    Write-Status "Construyendo Web DEV..."
    try {
        flutter build web --dart-define=ENVIRONMENT=development
        Write-Success "Web DEV construida exitosamente"
    } catch {
        Write-Error "Error construyendo Web DEV"
        exit 1
    }

    # Web - Staging
    Write-Status "Construyendo Web STAGING..."
    try {
        flutter build web --dart-define=ENVIRONMENT=staging
        Write-Success "Web STAGING construida exitosamente"
    } catch {
        Write-Error "Error construyendo Web STAGING"
        exit 1
    }

    # Web - Producción
    Write-Status "Construyendo Web PROD..."
    try {
        flutter build web --dart-define=ENVIRONMENT=production
        Write-Success "Web PROD construida exitosamente"
    } catch {
        Write-Error "Error construyendo Web PROD"
        exit 1
    }
} else {
    Write-Warning "Saltando construcción de Web"
}

Write-Host ""
Write-Host "📊 Resumen de archivos generados:" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

# Mostrar archivos APK generados
if (Test-Path "build/app/outputs/flutter-apk") {
    Write-Status "Archivos APK:"
    Get-ChildItem "build/app/outputs/flutter-apk/*.apk" -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Host "  $($_.Name) - $([math]::Round($_.Length / 1MB, 2)) MB" -ForegroundColor Gray
    }
}

# Mostrar archivos Web generados
if (Test-Path "build/web") {
    Write-Status "Archivos Web:"
    Get-ChildItem "build/web" -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Host "  $($_.Name)" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Success "🎉 ¡Todas las construcciones completadas exitosamente!"
Write-Status "Los archivos están disponibles en:"
Write-Status "  - Android APKs: build/app/outputs/flutter-apk/"
Write-Status "  - Web: build/web/"
if ($IsMacOS -or $env:OS -eq "Darwin") {
    Write-Status "  - iOS: build/ios/"
}

Write-Host ""
Write-Status "Para ejecutar en modo desarrollo:"
Write-Status "  flutter run --flavor dev --dart-define=ENVIRONMENT=development"
Write-Status ""
Write-Status "Para ejecutar en modo staging:"
Write-Status "  flutter run --flavor staging --dart-define=ENVIRONMENT=staging"
Write-Status ""
Write-Status "Para ejecutar en modo producción:"
Write-Status "  flutter run --flavor prod --dart-define=ENVIRONMENT=production"

Write-Host ""
Write-Status "Opciones del script:"
Write-Status "  -SkipTests     : Saltar análisis y tests"
Write-Status "  -SkipAndroid   : Saltar construcción de Android"
Write-Status "  -SkipiOS       : Saltar construcción de iOS"
Write-Status "  -SkipWeb       : Saltar construcción de Web"
