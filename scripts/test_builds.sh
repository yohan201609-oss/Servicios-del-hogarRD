#!/bin/bash

# Script para probar builds de todos los entornos
# Uso: ./scripts/test_builds.sh

set -e  # Salir si hay algún error

echo "🧪 Probando builds de todos los entornos..."
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

echo ""
echo "📱 Probando builds de Android..."
echo "==============================="

# Función para probar un build
test_build() {
    local platform=$1
    local flavor=$2
    local environment=$3
    
    print_status "Probando $platform $flavor para $environment..."
    
    local cmd="flutter build $platform"
    if [ "$platform" = "apk" ]; then
        cmd="$cmd --flavor $flavor"
    fi
    cmd="$cmd --dart-define=ENVIRONMENT=$environment"
    
    if [ "$platform" = "ios" ]; then
        cmd="$cmd --no-codesign"
    fi
    
    if eval $cmd; then
        print_success "✅ $platform $flavor $environment: Build exitoso"
    else
        print_error "❌ $platform $flavor $environment: Error en build"
        return 1
    fi
}

# Probar builds de Android
test_build "apk" "dev" "development"
test_build "apk" "staging" "staging"
test_build "apk" "prod" "production"

echo ""
echo "🍎 Probando builds de iOS..."
echo "============================"

# Verificar si estamos en macOS para iOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    test_build "ios" "dev" "development"
    test_build "ios" "staging" "staging"
    test_build "ios" "prod" "production"
else
    print_warning "Saltando builds de iOS - solo disponible en macOS"
fi

echo ""
echo "🌐 Probando builds de Web..."
echo "============================"

test_build "web" "" "development"
test_build "web" "" "staging"
test_build "web" "" "production"

echo ""
echo "📊 Resumen de builds:"
echo "===================="

# Mostrar archivos generados
print_status "Archivos APK generados:"
if [ -d "build/app/outputs/flutter-apk" ]; then
    ls -la build/app/outputs/flutter-apk/*.apk 2>/dev/null | while read file; do
        echo "  $file" | sed 's|build/app/outputs/flutter-apk/||'
    done
fi

print_status "Archivos Web generados:"
if [ -d "build/web" ]; then
    ls -la build/web/ 2>/dev/null | head -5
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
    print_status "Archivos iOS generados:"
    if [ -d "build/ios" ]; then
        find build/ios -name "*.app" -o -name "*.ipa" 2>/dev/null | while read file; do
            echo "  $file" | sed 's|build/ios/||'
        done
    fi
fi

print_success "🎉 ¡Todos los builds probados exitosamente!"
print_status "Los archivos están disponibles en:"
print_status "  - Android APKs: build/app/outputs/flutter-apk/"
print_status "  - Web: build/web/"
if [[ "$OSTYPE" == "darwin"* ]]; then
    print_status "  - iOS: build/ios/"
fi

echo ""
print_status "Para ejecutar en dispositivos:"
print_status "  flutter run --flavor dev --dart-define=ENVIRONMENT=development"
print_status "  flutter run --flavor staging --dart-define=ENVIRONMENT=staging"
print_status "  flutter run --flavor prod --dart-define=ENVIRONMENT=production"
