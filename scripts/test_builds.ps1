# Script de PowerShell para probar builds de todos los entornos
# Uso: .\scripts\test_builds.ps1

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

Write-Host "🧪 Probando builds de todos los entornos..." -ForegroundColor Cyan
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

# Función para probar un build
function Test-Build {
    param(
        [string]$Platform,
        [string]$Flavor,
        [string]$Environment
    )
    
    Write-Status "Probando $Platform $Flavor para $Environment..."
    
    $cmd = "flutter build $Platform"
    if ($Platform -eq "apk") {
        $cmd += " --flavor $Flavor"
    }
    $cmd += " --dart-define=ENVIRONMENT=$Environment"
    
    if ($Platform -eq "ios") {
        $cmd += " --no-codesign"
    }
    
    try {
        Invoke-Expression $cmd
        Write-Success "✅ $Platform $Flavor $Environment: Build exitoso"
    } catch {
        Write-Error "❌ $Platform $Flavor $Environment: Error en build"
        return $false
    }
    return $true
}

Write-Host ""
Write-Host "📱 Probando builds de Android..." -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan

if (-not $SkipAndroid) {
    Test-Build "apk" "dev" "development"
    Test-Build "apk" "staging" "staging"
    Test-Build "apk" "prod" "production"
} else {
    Write-Warning "Saltando builds de Android"
}

Write-Host ""
Write-Host "🍎 Probando builds de iOS..." -ForegroundColor Cyan
Write-Host "============================" -ForegroundColor Cyan

if (-not $SkipiOS) {
    # Verificar si estamos en macOS para iOS
    if ($IsMacOS -or $env:OS -eq "Darwin") {
        Test-Build "ios" "dev" "development"
        Test-Build "ios" "staging" "staging"
        Test-Build "ios" "prod" "production"
    } else {
        Write-Warning "Saltando builds de iOS - solo disponible en macOS"
    }
} else {
    Write-Warning "Saltando builds de iOS"
}

Write-Host ""
Write-Host "🌐 Probando builds de Web..." -ForegroundColor Cyan
Write-Host "============================" -ForegroundColor Cyan

if (-not $SkipWeb) {
    Test-Build "web" "" "development"
    Test-Build "web" "" "staging"
    Test-Build "web" "" "production"
} else {
    Write-Warning "Saltando builds de Web"
}

Write-Host ""
Write-Host "📊 Resumen de builds:" -ForegroundColor Cyan
Write-Host "====================" -ForegroundColor Cyan

# Mostrar archivos generados
Write-Status "Archivos APK generados:"
if (Test-Path "build/app/outputs/flutter-apk") {
    Get-ChildItem "build/app/outputs/flutter-apk/*.apk" -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Host "  $($_.Name) - $([math]::Round($_.Length / 1MB, 2)) MB" -ForegroundColor Gray
    }
}

Write-Status "Archivos Web generados:"
if (Test-Path "build/web") {
    Get-ChildItem "build/web" -ErrorAction SilentlyContinue | Select-Object -First 5 | ForEach-Object {
        Write-Host "  $($_.Name)" -ForegroundColor Gray
    }
}

if ($IsMacOS -or $env:OS -eq "Darwin") {
    Write-Status "Archivos iOS generados:"
    if (Test-Path "build/ios") {
        Get-ChildItem "build/ios" -Recurse -Include "*.app", "*.ipa" -ErrorAction SilentlyContinue | ForEach-Object {
            $relativePath = $_.FullName.Replace((Get-Location).Path + "\", "").Replace("\", "/")
            Write-Host "  $relativePath" -ForegroundColor Gray
        }
    }
}

Write-Success "🎉 ¡Todos los builds probados exitosamente!"
Write-Status "Los archivos están disponibles en:"
Write-Status "  - Android APKs: build/app/outputs/flutter-apk/"
Write-Status "  - Web: build/web/"
if ($IsMacOS -or $env:OS -eq "Darwin") {
    Write-Status "  - iOS: build/ios/"
}

Write-Host ""
Write-Status "Para ejecutar en dispositivos:"
Write-Status "  flutter run --flavor dev --dart-define=ENVIRONMENT=development"
Write-Status "  flutter run --flavor staging --dart-define=ENVIRONMENT=staging"
Write-Status "  flutter run --flavor prod --dart-define=ENVIRONMENT=production"

Write-Host ""
Write-Status "Opciones del script:"
Write-Status "  -SkipTests     : Saltar análisis y tests"
Write-Status "  -SkipAndroid   : Saltar builds de Android"
Write-Status "  -SkipiOS       : Saltar builds de iOS"
Write-Status "  -SkipWeb       : Saltar builds de Web"
