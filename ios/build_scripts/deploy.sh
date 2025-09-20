#!/bin/bash

# Script de deploy para iOS
# Uso: ./ios/build_scripts/deploy.sh <flavor> <environment>

set -e  # Salir si hay algún error

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

# Verificar parámetros
FLAVOR=$1
ENVIRONMENT=$2

if [ -z "$FLAVOR" ] || [ -z "$ENVIRONMENT" ]; then
    print_error "Uso: ./ios/build_scripts/deploy.sh <flavor> <environment>"
    print_error "Ejemplo: ./ios/build_scripts/deploy.sh dev development"
    print_error ""
    print_error "Flavors disponibles:"
    print_error "  - dev"
    print_error "  - staging"
    print_error "  - prod"
    print_error ""
    print_error "Environments disponibles:"
    print_error "  - development"
    print_error "  - staging"
    print_error "  - production"
    exit 1
fi

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

print_status "🚀 Iniciando deploy de $FLAVOR para $ENVIRONMENT..."
print_status "=================================================="

# Verificar que el flavor sea válido
case $FLAVOR in
    dev|staging|prod)
        print_status "Flavor válido: $FLAVOR"
        ;;
    *)
        print_error "Flavor inválido: $FLAVOR"
        print_error "Flavors válidos: dev, staging, prod"
        exit 1
        ;;
esac

# Verificar que el environment sea válido
case $ENVIRONMENT in
    development|staging|production)
        print_status "Environment válido: $ENVIRONMENT"
        ;;
    *)
        print_error "Environment inválido: $ENVIRONMENT"
        print_error "Environments válidos: development, staging, production"
        exit 1
        ;;
esac

# Verificar dependencias
print_status "Verificando dependencias de Flutter..."
flutter pub get

# Ejecutar análisis
print_status "Ejecutando análisis de código..."
flutter analyze

# Ejecutar tests
print_status "Ejecutando tests..."
flutter test

# Build
print_status "Construyendo iOS $FLAVOR para $ENVIRONMENT..."
if flutter build ios --flavor $FLAVOR --dart-define=ENVIRONMENT=$ENVIRONMENT --no-codesign; then
    print_success "Build completado exitosamente"
else
    print_error "Error en el build"
    exit 1
fi

# Verificar si Xcode está disponible para archivar
if command -v xcodebuild &> /dev/null; then
    print_status "Xcode encontrado. ¿Deseas crear un archivo IPA?"
    read -p "Crear IPA? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Creando archivo IPA..."
        
        # Crear directorio de salida
        mkdir -p "build/ios/ipa"
        
        # Archivar
        xcodebuild -workspace ios/Runner.xcworkspace \
                   -scheme Runner-$FLAVOR \
                   -configuration Release-$FLAVOR \
                   -archivePath "build/ios/ipa/Runner-$FLAVOR.xcarchive" \
                   archive
        
        # Exportar IPA
        xcodebuild -exportArchive \
                   -archivePath "build/ios/ipa/Runner-$FLAVOR.xcarchive" \
                   -exportPath "build/ios/ipa" \
                   -exportOptionsPlist "ios/ExportOptions.plist"
        
        print_success "Archivo IPA creado en build/ios/ipa/"
    fi
else
    print_warning "Xcode no encontrado. No se puede crear archivo IPA"
    print_warning "Para crear IPA, instala Xcode y ejecuta este script nuevamente"
fi

print_success "🎉 Deploy de $FLAVOR para $ENVIRONMENT completado!"
print_status "Archivos disponibles en:"
print_status "  - iOS: build/ios/"

echo ""
print_status "Para ejecutar en simulador:"
print_status "  flutter run --flavor $FLAVOR --dart-define=ENVIRONMENT=$ENVIRONMENT"

echo ""
print_status "Para ejecutar en dispositivo:"
print_status "  flutter run --flavor $FLAVOR --dart-define=ENVIRONMENT=$ENVIRONMENT -d <device_id>"
