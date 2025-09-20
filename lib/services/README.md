# Servicios de la Aplicación

Este directorio contiene todos los servicios principales de la aplicación Servicios Hogar RD.

## Servicios Implementados

### 1. AppService (`app_service.dart`)
**Servicio principal que coordina todos los demás servicios.**

- **Propósito**: Centralizar la gestión de todos los servicios de la aplicación
- **Funcionalidades**:
  - Inicialización de todos los servicios
  - Gestión de sesiones de usuario
  - Monitoreo del estado de la aplicación
  - Coordinación entre servicios

### 2. AuthService (`auth_service.dart`)
**Servicio de autenticación con Firebase.**

- **Propósito**: Gestionar la autenticación de usuarios
- **Funcionalidades**:
  - Registro e inicio de sesión con email/contraseña
  - Autenticación con Google
  - Gestión de perfiles de usuario
  - Recuperación de contraseñas
  - Gestión de sesiones

### 3. LocalizationService (`localization_service.dart`)
**Servicio de localización e internacionalización.**

- **Propósito**: Gestionar idiomas y configuraciones regionales
- **Funcionalidades**:
  - Cambio de idioma (Español/Inglés)
  - Persistencia de preferencias de idioma
  - Soporte para múltiples regiones
  - Gestión de monedas locales

### 4. SettingsService (`settings_service.dart`)
**Servicio de configuraciones de la aplicación.**

- **Propósito**: Gestionar todas las configuraciones del usuario
- **Funcionalidades**:
  - Configuraciones de notificaciones
  - Configuraciones de privacidad
  - Configuraciones de tema
  - Configuraciones de seguridad
  - Importar/exportar configuraciones

### 5. ProviderService (`provider_service.dart`)
**Servicio de gestión de proveedores.**

- **Propósito**: Gestionar datos de proveedores de servicios
- **Funcionalidades**:
  - Lista de proveedores por categoría
  - Búsqueda de proveedores
  - Filtrado por disponibilidad y verificación
  - Gestión de datos de proveedores

### 6. NotificationService (`notification_service.dart`)
**Servicio de notificaciones.**

- **Propósito**: Gestionar notificaciones locales y remotas
- **Funcionalidades**:
  - Notificaciones push
  - Notificaciones por email
  - Notificaciones SMS
  - Notificaciones locales
  - Configuración de preferencias

### 7. LocationService (`location_service.dart`)
**Servicio de geolocalización.**

- **Propósito**: Gestionar ubicación del usuario
- **Funcionalidades**:
  - Obtención de ubicación actual
  - Búsqueda de ubicaciones
  - Cálculo de distancias
  - Proveedores cercanos
  - Gestión de permisos

### 8. AnalyticsService (`analytics_service.dart`)
**Servicio de análisis y métricas.**

- **Propósito**: Recopilar datos de uso y comportamiento
- **Funcionalidades**:
  - Seguimiento de eventos
  - Métricas de rendimiento
  - Análisis de usuario
  - Reportes de uso
  - Privacidad de datos

## Configuración de Servicios

### Firebase
- **Configurado**: ✅
- **Archivo**: `firebase_options.dart`
- **Servicios**: Auth, Firestore, Analytics

### Dependencias
```yaml
dependencies:
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  cloud_firestore: ^5.4.3
  google_sign_in: ^6.2.1
  shared_preferences: ^2.2.2
  logger: ^2.4.0
  url_launcher: ^6.2.2
```

## Uso de Servicios

### Inicialización
```dart
// En main.dart
await AppService.instance.initialize();
```

### Acceso a Servicios
```dart
final appService = AppService.instance;

// Acceso a servicios específicos
final authService = appService.auth;
final settingsService = appService.settings;
final providerService = appService.providers;
```

### Ejemplo de Uso
```dart
// Autenticación
await appService.auth.signInWithEmailAndPassword(
  email: 'usuario@email.com',
  password: 'contraseña',
);

// Cambiar idioma
await appService.localization.changeLanguage('en');

// Obtener proveedores
final providers = appService.providers.getProvidersByCategory('Plomería');

// Enviar notificación
appService.notifications.showSuccessNotification(
  context,
  'Operación exitosa',
);
```

## Estado de los Servicios

| Servicio | Estado | Funcionalidad |
|----------|--------|---------------|
| AppService | ✅ Activo | Coordinación general |
| AuthService | ✅ Activo | Autenticación Firebase |
| LocalizationService | ✅ Activo | Multiidioma |
| SettingsService | ✅ Activo | Configuraciones |
| ProviderService | ✅ Activo | Gestión de proveedores |
| NotificationService | ✅ Activo | Notificaciones locales |
| LocationService | ✅ Activo | Geolocalización simulada |
| AnalyticsService | ✅ Activo | Métricas y análisis |

## Próximas Mejoras

1. **Integración con servicios reales**:
   - Geolocalización real con `geolocator`
   - Notificaciones push con `firebase_messaging`
   - Análisis real con `firebase_analytics`

2. **Servicios adicionales**:
   - PaymentService para pagos
   - ChatService para mensajería
   - ReviewService para reseñas
   - BookingService para reservas

3. **Optimizaciones**:
   - Cache de datos
   - Sincronización offline
   - Compresión de imágenes
   - Lazy loading

## Troubleshooting

### Problemas Comunes

1. **Firebase no inicializa**:
   - Verificar `google-services.json`
   - Verificar configuración de Firebase

2. **Servicios no cargan**:
   - Verificar inicialización en `main.dart`
   - Revisar logs de error

3. **Notificaciones no funcionan**:
   - Verificar permisos
   - Verificar configuración de notificaciones

### Logs
Todos los servicios usan el paquete `logger` para registro de eventos. Los logs se pueden ver en la consola de desarrollo.
