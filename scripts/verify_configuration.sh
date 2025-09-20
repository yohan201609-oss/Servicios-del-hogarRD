#!/bin/bash

# Script para verificar la configuración de Firebase
# Uso: ./scripts/verify_configuration.sh

set -e  # Salir si hay algún error

echo "🔍 Verificando configuración de Firebase..."
echo "=========================================="

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar mensajes con color
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar que estemos en el directorio correcto
if [ ! -f "pubspec.yaml" ]; then
    print_error "No se encontró pubspec.yaml. Asegúrate de estar en el directorio raíz del proyecto Flutter"
    exit 1
fi

# Verificar que Flutter esté instalado
if ! command -v flutter &> /dev/null; then
    print_error "Flutter no está instalado o no está en el PATH"
    exit 1
fi

print_status "Verificando dependencias de Flutter..."
flutter pub get

print_status "Ejecutando análisis de código..."
flutter analyze

print_status "Ejecutando tests..."
flutter test

echo ""
echo "🧪 Probando configuraciones de Firebase..."
echo "========================================="

# Función para probar un entorno
test_environment() {
    local env=$1
    local flavor=$2
    
    print_status "Probando entorno: $env"
    
    # Crear un archivo temporal para capturar la salida
    local temp_file=$(mktemp)
    
    # Ejecutar con timeout para evitar que se cuelgue
    if timeout 30s flutter run --flavor $flavor --dart-define=ENVIRONMENT=$env --no-sound-null-safety --device-id=flutter-tester 2>&1 | head -20 > "$temp_file" 2>&1; then
        if grep -q "Firebase initialized successfully" "$temp_file"; then
            print_success "✅ $env: Firebase conectado correctamente"
        elif grep -q "Firebase initialization error" "$temp_file"; then
            print_error "❌ $env: Error conectando a Firebase"
            cat "$temp_file" | grep "Firebase initialization error" -A 2
        else
            print_warning "⚠️ $env: No se pudo verificar la conexión (puede ser normal en CI)"
        fi
    else
        print_warning "⚠️ $env: Timeout o error en la ejecución"
    fi
    
    # Limpiar archivo temporal
    rm -f "$temp_file"
}

# Probar cada entorno
test_environment "development" "dev"
test_environment "staging" "staging"
test_environment "production" "prod"

echo ""
echo "📱 Verificando archivos de configuración..."
echo "=========================================="

# Verificar archivos de Android
print_status "Verificando archivos Android..."
if [ -f "android/app/src/dev/google-services.json" ]; then
    print_success "✅ android/app/src/dev/google-services.json existe"
else
    print_error "❌ android/app/src/dev/google-services.json no encontrado"
fi

if [ -f "android/app/src/staging/google-services.json" ]; then
    print_success "✅ android/app/src/staging/google-services.json existe"
else
    print_error "❌ android/app/src/staging/google-services.json no encontrado"
fi

if [ -f "android/app/src/prod/google-services.json" ]; then
    print_success "✅ android/app/src/prod/google-services.json existe"
else
    print_error "❌ android/app/src/prod/google-services.json no encontrado"
fi

# Verificar archivos de iOS
print_status "Verificando archivos iOS..."
if [ -f "ios/Runner/GoogleService-Info-dev.plist" ]; then
    print_success "✅ ios/Runner/GoogleService-Info-dev.plist existe"
else
    print_error "❌ ios/Runner/GoogleService-Info-dev.plist no encontrado"
fi

if [ -f "ios/Runner/GoogleService-Info-staging.plist" ]; then
    print_success "✅ ios/Runner/GoogleService-Info-staging.plist existe"
else
    print_error "❌ ios/Runner/GoogleService-Info-staging.plist no encontrado"
fi

if [ -f "ios/Runner/GoogleService-Info-prod.plist" ]; then
    print_success "✅ ios/Runner/GoogleService-Info-prod.plist existe"
else
    print_error "❌ ios/Runner/GoogleService-Info-prod.plist no encontrado"
fi

# Verificar archivos de configuración Flutter
print_status "Verificando archivos de configuración Flutter..."
if [ -f "lib/firebase_options_dev.dart" ]; then
    print_success "✅ lib/firebase_options_dev.dart existe"
else
    print_error "❌ lib/firebase_options_dev.dart no encontrado"
fi

if [ -f "lib/firebase_options_staging.dart" ]; then
    print_success "✅ lib/firebase_options_staging.dart existe"
else
    print_error "❌ lib/firebase_options_staging.dart no encontrado"
fi

if [ -f "lib/firebase_options_prod.dart" ]; then
    print_success "✅ lib/firebase_options_prod.dart existe"
else
    print_error "❌ lib/firebase_options_prod.dart no encontrado"
fi

echo ""
echo "🔧 Verificando configuración de build flavors..."
echo "=============================================="

# Verificar configuración de Android
print_status "Verificando configuración de Android..."
if grep -q "productFlavors" android/app/build.gradle.kts; then
    print_success "✅ Build flavors configurados en Android"
else
    print_error "❌ Build flavors no configurados en Android"
fi

# Verificar configuración de iOS
print_status "Verificando configuración de iOS..."
if [ -f "ios/Runner.xcworkspace" ]; then
    print_success "✅ Workspace de iOS existe"
else
    print_error "❌ Workspace de iOS no encontrado"
fi

echo ""
echo "📊 Resumen de verificación:"
echo "=========================="

# Contar archivos de configuración
android_configs=$(find android/app/src -name "google-services.json" 2>/dev/null | wc -l)
ios_configs=$(find ios/Runner -name "GoogleService-Info*.plist" 2>/dev/null | wc -l)
flutter_configs=$(find lib -name "firebase_options_*.dart" 2>/dev/null | wc -l)

print_status "Archivos de configuración encontrados:"
print_status "  - Android: $android_configs/3"
print_status "  - iOS: $ios_configs/4 (incluyendo el original)"
print_status "  - Flutter: $flutter_configs/3"

if [ $android_configs -eq 3 ] && [ $ios_configs -eq 4 ] && [ $flutter_configs -eq 3 ]; then
    print_success "🎉 ¡Toda la configuración está completa!"
else
    print_warning "⚠️ Algunos archivos de configuración faltan"
fi

echo ""
print_status "Para probar manualmente:"
print_status "  flutter run --flavor dev --dart-define=ENVIRONMENT=development"
print_status "  flutter run --flavor staging --dart-define=ENVIRONMENT=staging"
print_status "  flutter run --flavor prod --dart-define=ENVIRONMENT=production"

echo ""
print_status "Para construir todas las versiones:"
print_status "  ./scripts/build_all.sh"
print_status "  o en Windows: .\\scripts\\build_all.ps1"
