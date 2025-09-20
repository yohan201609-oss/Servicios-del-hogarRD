# 🚀 Guía de Build Remoto - Servicios Hogar RD

## 📋 Resumen
Este proyecto está configurado para compilar automáticamente en GitHub Actions, solucionando los problemas de espacio en disco y caché corrupta local.

## 🔧 Workflows Disponibles

### 1. **Build Automático** (`flutter_build.yml`)
- ✅ Se ejecuta automáticamente en cada push a `main` o `develop`
- ✅ Analiza el código, ejecuta tests y compila APK
- ✅ Genera APK de debug y release (solo en main)

### 2. **Build por Entorno** (`flutter_environments.yml`)
- 🎯 Permite compilar para entornos específicos (dev, staging, prod)
- 🚀 Ejecución manual desde GitHub Actions
- 📱 Genera APK optimizado para cada entorno

### 3. **Release & Distribución** (`release.yml`)
- 🏷️ Se ejecuta al crear tags (v1.0.0, v1.1.0, etc.)
- 📦 Genera APK y App Bundle para Google Play
- 🎉 Crea release automático en GitHub

## 🚀 Cómo Usar

### **Opción 1: Push Automático**
```bash
git add .
git commit -m "feat: nueva funcionalidad"
git push origin main
```
✅ El build se ejecutará automáticamente

### **Opción 2: Build Manual**
1. Ve a GitHub → Actions
2. Selecciona "Flutter Multi-Environment Build"
3. Haz clic en "Run workflow"
4. Elige el entorno (dev/staging/prod)
5. Ejecuta

### **Opción 3: Crear Release**
```bash
git tag v1.0.0
git push origin v1.0.0
```
✅ Se creará un release automático

## 📱 Descargar APK

1. Ve a GitHub → Actions
2. Selecciona el workflow ejecutado
3. Haz clic en "Artifacts"
4. Descarga el APK generado

## 🔍 Monitoreo

- **Status:** Ve el estado en GitHub Actions
- **Logs:** Revisa los logs si hay errores
- **Artifacts:** Descarga los APK generados

## ⚡ Ventajas del Build Remoto

- ✅ **Sin problemas de espacio en disco**
- ✅ **Sin caché corrupta de Gradle**
- ✅ **Entorno limpio cada vez**
- ✅ **Múltiples plataformas automáticamente**
- ✅ **Integración continua**
- ✅ **Distribución automática**

## 🛠️ Configuración Adicional

### **Para Firebase App Distribution:**
1. Ve a GitHub → Settings → Secrets
2. Agrega `FIREBASE_TOKEN` y `FIREBASE_APP_ID`
3. Los APK se distribuirán automáticamente

### **Para Google Play:**
1. Configura Google Play Console
2. Agrega secrets de autenticación
3. Los AAB se subirán automáticamente

## 📞 Soporte

Si tienes problemas:
1. Revisa los logs en GitHub Actions
2. Verifica que el código compile localmente
3. Contacta al equipo de desarrollo
