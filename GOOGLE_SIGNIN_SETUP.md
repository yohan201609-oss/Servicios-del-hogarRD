# Configuración de Google Sign-In

## Pasos para Habilitar Google Sign-In

### 1. Configuración en Firebase Console

1. **Ve a Firebase Console**: https://console.firebase.google.com/
2. **Selecciona tu proyecto**
3. **Ve a Authentication > Sign-in method**
4. **Habilita Google Sign-In**:
   - Haz clic en "Google"
   - Activa el toggle
   - Agrega el email de soporte del proyecto
   - Guarda los cambios

### 2. Configuración para Android

#### 2.1 Obtener SHA-1 Fingerprint

Ejecuta este comando en la terminal desde la raíz del proyecto:

```bash
# Para debug
cd android
./gradlew signingReport
```

O usando keytool:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

#### 2.2 Configurar SHA-1 en Firebase

1. Ve a **Project Settings** en Firebase Console
2. Selecciona la pestaña **General**
3. En la sección **Your apps**, encuentra tu app Android
4. Haz clic en **Add fingerprint**
5. Pega el SHA-1 fingerprint obtenido en el paso anterior

#### 2.3 Descargar google-services.json actualizado

1. Después de agregar el SHA-1, descarga el nuevo `google-services.json`
2. Reemplaza el archivo existente en `android/app/`

### 3. Configuración para iOS

#### 3.1 Configurar URL Scheme

1. Ve a **Project Settings** en Firebase Console
2. En la sección **Your apps**, encuentra tu app iOS
3. Copia el **REVERSED_CLIENT_ID**
4. Abre `ios/Runner/Info.plist`
5. Agrega la siguiente configuración:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>REVERSED_CLIENT_ID</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>YOUR_REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

### 4. Configuración Adicional para Android

#### 4.1 Actualizar build.gradle (app level)

Asegúrate de que tu `android/app/build.gradle.kts` tenga las siguientes dependencias:

```kotlin
dependencies {
    // Firebase
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    
    // Google Sign-In
    implementation("com.google.android.gms:play-services-auth:20.7.0")
}
```

### 5. Verificación

#### 5.1 Probar en Dispositivo Real

Google Sign-In no funciona en el emulador por defecto. Necesitas:

1. **Usar un dispositivo real** o
2. **Configurar el emulador con Google Play Services**

#### 5.2 Configurar Emulador con Google Play

1. Crea un nuevo AVD (Android Virtual Device)
2. Asegúrate de seleccionar una imagen que incluya **Google Play**
3. Ejemplo: "Pixel 6 API 33" con Google Play

### 6. Troubleshooting

#### Error: "DEVELOPER_ERROR"

- Verifica que el SHA-1 fingerprint esté correctamente configurado
- Asegúrate de que el `google-services.json` esté actualizado
- Verifica que el package name coincida

#### Error: "NETWORK_ERROR"

- Verifica la conexión a internet
- Asegúrate de que Google Play Services esté actualizado en el dispositivo

#### Error: "SIGN_IN_CANCELLED"

- El usuario canceló el proceso de sign-in
- No es un error, maneja este caso normalmente

### 7. Comandos Útiles

```bash
# Limpiar y reconstruir
flutter clean
flutter pub get
cd android && ./gradlew clean && cd ..

# Ejecutar en dispositivo
flutter run

# Verificar configuración
flutter doctor
```

### 8. Testing

Para probar Google Sign-In:

1. Ejecuta la app en un dispositivo real con Google Play Services
2. Toca el botón "Continuar con Google"
3. Selecciona una cuenta de Google
4. Verifica que el login sea exitoso

### 9. Notas Importantes

- **SHA-1 para Release**: Cuando generes un APK de producción, necesitarás generar un nuevo SHA-1 fingerprint para la keystore de producción
- **Google Play Console**: Si planeas publicar en Google Play, también necesitarás configurar el SHA-1 de producción en Google Play Console
- **iOS Simulator**: Google Sign-In funciona en iOS Simulator, pero es mejor probar en dispositivos reales

### 10. Archivos de Configuración

Asegúrate de que estos archivos estén correctamente configurados:

- `android/app/google-services.json` (descargado de Firebase)
- `ios/Runner/GoogleService-Info.plist` (descargado de Firebase)
- `ios/Runner/Info.plist` (con URL scheme configurado)
- `android/app/build.gradle.kts` (con dependencias correctas)
