#!/bin/bash

# Script para construir todas las versiones de iOS
# Uso: ./ios/build_scripts/build_all.sh

set -e  # Salir si hay algún error

echo "🍎 Iniciando construcción de todas las versiones iOS..."
echo "====================================================="

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

# Verificar que estemos en macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "Este script solo funciona en macOS"
    exit 1
fi

# Verificar que Flutter esté instalado
if ! command -v flutter &> /dev/null; then
    print_error "Flutter no está instalado o no está en el PATH"
    exit 1
fi

# Verificar que estemos en el directorio correcto
if [ ! -f "pubspec.yaml" ]; then
    print_error "No se encontró pubspec.yaml. Asegúrate de estar en el directorio raíz del proyecto Flutter"
    exit 1
fi

print_status "Verificando dependencias de Flutter..."
flutter pub get

print_status "Ejecutando análisis de código..."
flutter analyze

print_status "Ejecutando tests..."
flutter test

echo ""
echo "🍎 Construyendo aplicaciones iOS..."
echo "=================================="

# iOS - Desarrollo
print_status "Construyendo iOS DEV..."
if flutter build ios --flavor dev --dart-define=ENVIRONMENT=development --no-codesign; then
    print_success "iOS DEV construido exitosamente"
else
    print_warning "Error construyendo iOS DEV (puede requerir configuración adicional)"
fi

# iOS - Staging
print_status "Construyendo iOS STAGING..."
if flutter build ios --flavor staging --dart-define=ENVIRONMENT=staging --no-codesign; then
    print_success "iOS STAGING construido exitosamente"
else
    print_warning "Error construyendo iOS STAGING (puede requerir configuración adicional)"
fi

# iOS - Producción
print_status "Construyendo iOS PROD..."
if flutter build ios --flavor prod --dart-define=ENVIRONMENT=production --no-codesign; then
    print_success "iOS PROD construido exitosamente"
else
    print_warning "Error construyendo iOS PROD (puede requerir configuración adicional)"
fi

echo ""
echo "📊 Resumen de archivos generados:"
echo "================================="

# Mostrar archivos iOS generados
if [ -d "build/ios" ]; then
    print_status "Archivos iOS:"
    find build/ios -name "*.app" -o -name "*.ipa" 2>/dev/null | while read file; do
        echo "  $file" | sed 's|build/ios/||'
    done
fi

echo ""
print_success "🎉 ¡Todas las construcciones iOS completadas!"
print_status "Los archivos están disponibles en:"
print_status "  - iOS: build/ios/"

echo ""
print_status "Para ejecutar en modo desarrollo:"
print_status "  flutter run --flavor dev --dart-define=ENVIRONMENT=development"
print_status ""
print_status "Para ejecutar en modo staging:"
print_status "  flutter run --flavor staging --dart-define=ENVIRONMENT=staging"
print_status ""
print_status "Para ejecutar en modo producción:"
print_status "  flutter run --flavor prod --dart-define=ENVIRONMENT=production"

echo ""
print_warning "Nota: Para builds con firma de código, necesitarás:"
print_warning "1. Configurar certificados de desarrollo en Xcode"
print_warning "2. Configurar provisioning profiles"
print_warning "3. Usar Xcode para archivar y firmar"
