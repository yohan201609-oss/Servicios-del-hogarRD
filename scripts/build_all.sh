#!/bin/bash

# Script para construir todas las versiones de la aplicación
# Uso: ./scripts/build_all.sh

set -e  # Salir si hay algún error

echo "🚀 Iniciando construcción de todas las versiones..."
echo "=================================================="

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
echo "📱 Construyendo aplicaciones Android..."
echo "======================================"

# Android - Desarrollo
print_status "Construyendo Android DEV..."
if flutter build apk --flavor dev --dart-define=ENVIRONMENT=development; then
    print_success "Android DEV construido exitosamente"
else
    print_error "Error construyendo Android DEV"
    exit 1
fi

# Android - Staging
print_status "Construyendo Android STAGING..."
if flutter build apk --flavor staging --dart-define=ENVIRONMENT=staging; then
    print_success "Android STAGING construido exitosamente"
else
    print_error "Error construyendo Android STAGING"
    exit 1
fi

# Android - Producción
print_status "Construyendo Android PROD..."
if flutter build apk --flavor prod --dart-define=ENVIRONMENT=production; then
    print_success "Android PROD construido exitosamente"
else
    print_error "Error construyendo Android PROD"
    exit 1
fi

echo ""
echo "🍎 Construyendo aplicaciones iOS..."
echo "=================================="

# Verificar si estamos en macOS para iOS
if [[ "$OSTYPE" == "darwin"* ]]; then
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
else
    print_warning "Skipping iOS builds - solo disponible en macOS"
fi

echo ""
echo "🌐 Construyendo aplicaciones Web..."
echo "=================================="

# Web - Desarrollo
print_status "Construyendo Web DEV..."
if flutter build web --dart-define=ENVIRONMENT=development; then
    print_success "Web DEV construida exitosamente"
else
    print_error "Error construyendo Web DEV"
    exit 1
fi

# Web - Staging
print_status "Construyendo Web STAGING..."
if flutter build web --dart-define=ENVIRONMENT=staging; then
    print_success "Web STAGING construida exitosamente"
else
    print_error "Error construyendo Web STAGING"
    exit 1
fi

# Web - Producción
print_status "Construyendo Web PROD..."
if flutter build web --dart-define=ENVIRONMENT=production; then
    print_success "Web PROD construida exitosamente"
else
    print_error "Error construyendo Web PROD"
    exit 1
fi

echo ""
echo "📊 Resumen de archivos generados:"
echo "================================="

# Mostrar archivos APK generados
if [ -d "build/app/outputs/flutter-apk" ]; then
    print_status "Archivos APK:"
    ls -la build/app/outputs/flutter-apk/*.apk 2>/dev/null || print_warning "No se encontraron archivos APK"
fi

# Mostrar archivos Web generados
if [ -d "build/web" ]; then
    print_status "Archivos Web:"
    ls -la build/web/ 2>/dev/null || print_warning "No se encontraron archivos Web"
fi

echo ""
print_success "🎉 ¡Todas las construcciones completadas exitosamente!"
print_status "Los archivos están disponibles en:"
print_status "  - Android APKs: build/app/outputs/flutter-apk/"
print_status "  - Web: build/web/"
if [[ "$OSTYPE" == "darwin"* ]]; then
    print_status "  - iOS: build/ios/"
fi

echo ""
print_status "Para ejecutar en modo desarrollo:"
print_status "  flutter run --flavor dev --dart-define=ENVIRONMENT=development"
print_status ""
print_status "Para ejecutar en modo staging:"
print_status "  flutter run --flavor staging --dart-define=ENVIRONMENT=staging"
print_status ""
print_status "Para ejecutar en modo producción:"
print_status "  flutter run --flavor prod --dart-define=ENVIRONMENT=production"
