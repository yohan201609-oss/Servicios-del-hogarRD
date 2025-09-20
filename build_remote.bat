@echo off
echo ========================================
echo    Build Remoto - Servicios Hogar RD
echo ========================================

echo [1/5] Limpiando proyecto...
call flutter clean

echo [2/5] Obteniendo dependencias...
call flutter pub get

echo [3/5] Analizando código...
call flutter analyze

echo [4/5] Compilando APK Debug (sin optimizaciones)...
call flutter build apk --debug --target-platform android-arm64

if %ERRORLEVEL% EQU 0 (
    echo ========================================
    echo    ✅ BUILD EXITOSO
    echo ========================================
    echo APK generado en: build\app\outputs\flutter-apk\
    dir build\app\outputs\flutter-apk\
) else (
    echo ========================================
    echo    ❌ BUILD FALLÓ
    echo ========================================
    echo Revisa los errores arriba
)

pause
