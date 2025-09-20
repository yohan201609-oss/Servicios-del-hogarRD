# Implementación de Login con Firebase

## Resumen

Se ha implementado un sistema completo de autenticación con Firebase para la aplicación de servicios del hogar. El sistema incluye login, registro, restablecimiento de contraseña y manejo de sesiones.

## Características Implementadas

### 1. Autenticación con Email y Contraseña
- ✅ Login con email y contraseña
- ✅ Registro de nuevos usuarios
- ✅ Restablecimiento de contraseña
- ✅ Validación de formularios
- ✅ Manejo de errores en español

### 2. Gestión de Sesiones
- ✅ Verificación automática del estado de autenticación
- ✅ Logout seguro
- ✅ Persistencia de credenciales (opcional)
- ✅ Navegación automática según el estado del usuario

### 3. Integración con Firebase
- ✅ Configuración multi-entorno (dev, staging, prod)
- ✅ Almacenamiento de perfiles de usuario en Firestore
- ✅ Manejo de tipos de usuario (cliente, proveedor, ambos)

### 4. Interfaz de Usuario
- ✅ Pantalla de login moderna y atractiva
- ✅ Pantalla de registro completa
- ✅ Indicadores de carga
- ✅ Mensajes de error claros
- ✅ Validación en tiempo real

## Archivos Modificados

### Archivos Principales
1. **`lib/main.dart`**
   - Actualizado `AuthWrapper` para usar Firebase Auth
   - Implementado `StreamBuilder` para escuchar cambios de autenticación

2. **`lib/services/auth_service.dart`**
   - Métodos de login y registro con Firebase
   - Restablecimiento de contraseña
   - Gestión de perfiles de usuario
   - Google Sign-In (temporalmente deshabilitado por problemas de API)

3. **`lib/screens/simple_login_screen.dart`**
   - Integración completa con Firebase Auth
   - Manejo de errores mejorado
   - Diálogo de restablecimiento de contraseña
   - Navegación inteligente según el estado del perfil

4. **`lib/screens/register_screen.dart`**
   - Pantalla de registro completamente nueva
   - Validación de formularios
   - Integración con Firebase Auth
   - Diseño consistente con la pantalla de login

5. **`lib/screens/simple_home_screen.dart`**
   - Botón de logout actualizado para usar Firebase
   - Limpieza de credenciales al cerrar sesión

## Flujo de Autenticación

### 1. Usuario No Autenticado
```
AuthWrapper → SimpleLoginScreen
```

### 2. Usuario Autenticado sin Perfil Completo
```
AuthWrapper → UserTypeSelectionScreen
```

### 3. Usuario Autenticado con Perfil Completo
```
AuthWrapper → SimpleHomeScreen
```

### 4. Proceso de Login
```
SimpleLoginScreen → Firebase Auth → Verificar Perfil → Navegación Apropiada
```

### 5. Proceso de Registro
```
RegisterScreen → Firebase Auth → UserTypeSelectionScreen
```

## Características de Seguridad

- ✅ Validación de email y contraseña
- ✅ Contraseñas mínimas de 6 caracteres
- ✅ Confirmación de contraseña en registro
- ✅ Restablecimiento seguro de contraseña
- ✅ Logout completo (Firebase + Google si está habilitado)
- ✅ Limpieza de credenciales guardadas

## Manejo de Errores

Todos los errores de Firebase Auth se traducen a mensajes en español:
- `user-not-found` → "No se encontró un usuario con este correo electrónico"
- `wrong-password` → "Contraseña incorrecta"
- `email-already-in-use` → "Ya existe una cuenta con este correo electrónico"
- `weak-password` → "La contraseña es muy débil"
- `invalid-email` → "El correo electrónico no es válido"
- `too-many-requests` → "Demasiados intentos. Intenta más tarde"

## Configuración Requerida

### Firebase
- Proyecto Firebase configurado
- Authentication habilitado (Email/Password)
- Firestore configurado
- Reglas de seguridad apropiadas

### Dependencias
```yaml
firebase_core: ^4.1.0
firebase_auth: ^6.0.2
cloud_firestore: ^6.0.1
google_sign_in: ^7.2.0  # Temporalmente deshabilitado
shared_preferences: ^2.2.2
```

## Estado Actual

### ✅ Completado
- Login con email/contraseña
- Registro de usuarios
- Restablecimiento de contraseña
- Gestión de sesiones
- Integración con Firestore
- Interfaz de usuario completa

### ⚠️ Temporalmente Deshabilitado
- Google Sign-In (problemas de compatibilidad con la API actual)

### 🔄 Próximos Pasos
1. Resolver problemas de API de Google Sign-In
2. Implementar verificación de email
3. Agregar autenticación de dos factores
4. Implementar roles y permisos avanzados

## Uso

### Para Desarrolladores
1. Asegúrate de que Firebase esté configurado correctamente
2. Ejecuta `flutter pub get` para instalar dependencias
3. Configura los archivos de configuración de Firebase según el entorno
4. Ejecuta la aplicación

### Para Usuarios
1. Abre la aplicación
2. Si no tienes cuenta, toca "Registrarse"
3. Completa el formulario de registro
4. Selecciona tu tipo de usuario
5. Completa tu perfil
6. ¡Ya puedes usar la aplicación!

## Notas Técnicas

- El sistema usa `StreamBuilder` para escuchar cambios de autenticación en tiempo real
- Los perfiles de usuario se almacenan en Firestore bajo la colección `users`
- Las credenciales se pueden guardar localmente (opcional)
- El sistema maneja automáticamente la navegación según el estado del usuario
- Todos los errores se manejan de forma elegante con mensajes en español
