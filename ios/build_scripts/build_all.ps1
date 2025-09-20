# Script de PowerShell para construir todas las versiones de iOS
# Uso: .\ios\build_scripts\build_all.ps1

param(
    [switch]$SkipTests,
    [switch]$SkipiOS
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

Write-Host "🍎 Iniciando construcción de todas las versiones iOS..." -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan

# Verificar que estemos en macOS
if (-not ($IsMacOS -or $env:OS -eq "Darwin")) {
    Write-Error "Este script solo funciona en macOS"
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
Write-Host "🍎 Construyendo aplicaciones iOS..." -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan

if (-not $SkipiOS) {
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
    Write-Warning "Saltando construcción de iOS"
}

Write-Host ""
Write-Host "📊 Resumen de archivos generados:" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

# Mostrar archivos iOS generados
if (Test-Path "build/ios") {
    Write-Status "Archivos iOS:"
    Get-ChildItem "build/ios" -Recurse -Include "*.app", "*.ipa" -ErrorAction SilentlyContinue | ForEach-Object {
        $relativePath = $_.FullName.Replace((Get-Location).Path + "\", "").Replace("\", "/")
        Write-Host "  $relativePath" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Success "🎉 ¡Todas las construcciones iOS completadas!"
Write-Status "Los archivos están disponibles en:"
Write-Status "  - iOS: build/ios/"

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
Write-Warning "Nota: Para builds con firma de código, necesitarás:"
Write-Warning "1. Configurar certificados de desarrollo en Xcode"
Write-Warning "2. Configurar provisioning profiles"
Write-Warning "3. Usar Xcode para archivar y firmar"

Write-Host ""
Write-Status "Opciones del script:"
Write-Status "  -SkipTests     : Saltar análisis y tests"
Write-Status "  -SkipiOS       : Saltar construcción de iOS"
