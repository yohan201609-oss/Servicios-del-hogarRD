import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static List<LocalizationsDelegate<dynamic>> get localizationsDelegates => [
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = [
    Locale('es', ''),
    Locale('en', ''),
  ];

  // App title
  String get appTitle {
    switch (locale.languageCode) {
      case 'en':
        return 'Home Services RD';
      case 'es':
      default:
        return 'Servicios Hogar RD';
    }
  }

  // Welcome message
  String welcomeMessage(String name) {
    switch (locale.languageCode) {
      case 'en':
        return 'Welcome$name to Home Services RD!';
      case 'es':
      default:
        return '¡Bienvenido$name a Servicios Hogar RD!';
    }
  }

  // Welcome subtitle
  String get welcomeSubtitle {
    switch (locale.languageCode) {
      case 'en':
        return 'Connecting Dominican homes with the best services';
      case 'es':
      default:
        return 'Conectamos hogares dominicanos con los mejores servicios';
    }
  }

  // Service categories
  String get serviceCategories {
    switch (locale.languageCode) {
      case 'en':
        return 'Available service categories:';
      case 'es':
      default:
        return 'Categorías de servicios disponibles:';
    }
  }

  // User types
  String get provider {
    switch (locale.languageCode) {
      case 'en':
        return 'Provider';
      case 'es':
      default:
        return 'Proveedor';
    }
  }

  String get client {
    switch (locale.languageCode) {
      case 'en':
        return 'Client';
      case 'es':
      default:
        return 'Cliente';
    }
  }

  // Navigation
  String get home {
    switch (locale.languageCode) {
      case 'en':
        return 'Home';
      case 'es':
      default:
        return 'Inicio';
    }
  }

  String get services {
    switch (locale.languageCode) {
      case 'en':
        return 'Services';
      case 'es':
      default:
        return 'Servicios';
    }
  }

  String get profile {
    switch (locale.languageCode) {
      case 'en':
        return 'Profile';
      case 'es':
      default:
        return 'Perfil';
    }
  }

  // Mode selection
  String get whatDoYouWantToDo {
    switch (locale.languageCode) {
      case 'en':
        return 'What do you want to do today?';
      case 'es':
      default:
        return '¿Qué quieres hacer hoy?';
    }
  }

  String get selectModeDescription {
    switch (locale.languageCode) {
      case 'en':
        return 'Select the mode that best suits what you need to do';
      case 'es':
      default:
        return 'Selecciona el modo que mejor se adapte a lo que necesitas hacer';
    }
  }

  String get searchService {
    switch (locale.languageCode) {
      case 'en':
        return 'Find a Service';
      case 'es':
      default:
        return 'Buscar un Servicio';
    }
  }

  String get searchServiceDescription {
    switch (locale.languageCode) {
      case 'en':
        return 'Hire professionals for home services';
      case 'es':
      default:
        return 'Contratar profesionales para servicios en mi hogar';
    }
  }

  String get offerService {
    switch (locale.languageCode) {
      case 'en':
        return 'Offer a Service';
      case 'es':
      default:
        return 'Ofrecer un Servicio';
    }
  }

  String get offerServiceDescription {
    switch (locale.languageCode) {
      case 'en':
        return 'Manage my business and offer professional services';
      case 'es':
      default:
        return 'Gestionar mi negocio y ofrecer servicios profesionales';
    }
  }

  // Settings
  String get settings {
    switch (locale.languageCode) {
      case 'en':
        return 'Settings';
      case 'es':
      default:
        return 'Configuración';
    }
  }

  String get save {
    switch (locale.languageCode) {
      case 'en':
        return 'Save';
      case 'es':
      default:
        return 'Guardar';
    }
  }

  String get account {
    switch (locale.languageCode) {
      case 'en':
        return 'Account';
      case 'es':
      default:
        return 'Cuenta';
    }
  }

  String get selectLanguage {
    switch (locale.languageCode) {
      case 'en':
        return 'Select Language';
      case 'es':
      default:
        return 'Seleccionar Idioma';
    }
  }

  String get cancel {
    switch (locale.languageCode) {
      case 'en':
        return 'Cancel';
      case 'es':
      default:
        return 'Cancelar';
    }
  }

  // Account section
  String get accountActive {
    switch (locale.languageCode) {
      case 'en':
        return 'Active Account';
      case 'es':
      default:
        return 'Cuenta Activa';
    }
  }

  String get accountActiveDescription {
    switch (locale.languageCode) {
      case 'en':
        return 'Your account is active and you can receive services';
      case 'es':
      default:
        return 'Tu cuenta está activa y puedes recibir servicios';
    }
  }

  String get editProfile {
    switch (locale.languageCode) {
      case 'en':
        return 'Edit Profile';
      case 'es':
      default:
        return 'Editar Perfil';
    }
  }

  String get logout {
    switch (locale.languageCode) {
      case 'en':
        return 'Logout';
      case 'es':
      default:
        return 'Cerrar Sesión';
    }
  }

  // Notifications section
  String get notifications {
    switch (locale.languageCode) {
      case 'en':
        return 'Notifications';
      case 'es':
      default:
        return 'Notificaciones';
    }
  }

  String get pushNotificationsDescription {
    switch (locale.languageCode) {
      case 'en':
        return 'Receive notifications on the device';
      case 'es':
      default:
        return 'Recibir notificaciones en el dispositivo';
    }
  }

  String get emailNotificationsDescription {
    switch (locale.languageCode) {
      case 'en':
        return 'Receive notifications by email';
      case 'es':
      default:
        return 'Recibir notificaciones por correo electrónico';
    }
  }

  String get smsNotificationsDescription {
    switch (locale.languageCode) {
      case 'en':
        return 'Receive notifications by text message';
      case 'es':
      default:
        return 'Recibir notificaciones por mensaje de texto';
    }
  }

  String get ordersAndServicesDescription {
    switch (locale.languageCode) {
      case 'en':
        return 'Notifications about orders and services';
      case 'es':
      default:
        return 'Notificaciones sobre pedidos y servicios';
    }
  }

  String get reviewsAndRatingsDescription {
    switch (locale.languageCode) {
      case 'en':
        return 'Notifications about received reviews';
      case 'es':
      default:
        return 'Notificaciones sobre reseñas recibidas';
    }
  }

  String get promotions {
    switch (locale.languageCode) {
      case 'en':
        return 'Promotions';
      case 'es':
      default:
        return 'Promociones';
    }
  }

  String get promotionsDescription {
    switch (locale.languageCode) {
      case 'en':
        return 'Notifications about offers and promotions';
      case 'es':
      default:
        return 'Notificaciones sobre ofertas y promociones';
    }
  }

  // Privacy section
  String get privacy {
    switch (locale.languageCode) {
      case 'en':
        return 'Privacy';
      case 'es':
      default:
        return 'Privacidad';
    }
  }

  String get publicProfileDescription {
    switch (locale.languageCode) {
      case 'en':
        return 'Your profile is visible to other users';
      case 'es':
      default:
        return 'Tu perfil es visible para otros usuarios';
    }
  }

  String get showPhoneDescription {
    switch (locale.languageCode) {
      case 'en':
        return 'Show your phone number in the profile';
      case 'es':
      default:
        return 'Mostrar tu número de teléfono en el perfil';
    }
  }

  String get showLocationDescription {
    switch (locale.languageCode) {
      case 'en':
        return 'Show your approximate location';
      case 'es':
      default:
        return 'Mostrar tu ubicación aproximada';
    }
  }

  String get allowMessagesDescription {
    switch (locale.languageCode) {
      case 'en':
        return 'Allow other users to send you messages';
      case 'es':
      default:
        return 'Permitir que otros usuarios te envíen mensajes';
    }
  }

  // Language section
  String get language {
    switch (locale.languageCode) {
      case 'en':
        return 'Language';
      case 'es':
      default:
        return 'Idioma';
    }
  }

  String get region {
    switch (locale.languageCode) {
      case 'en':
        return 'Region';
      case 'es':
      default:
        return 'Región';
    }
  }

  String get settingsSavedSuccessfully {
    switch (locale.languageCode) {
      case 'en':
        return 'Settings saved successfully';
      case 'es':
      default:
        return 'Configuraciones guardadas exitosamente';
    }
  }

  String get settingsError {
    switch (locale.languageCode) {
      case 'en':
        return 'Error saving settings';
      case 'es':
      default:
        return 'Error guardando configuraciones';
    }
  }

  // Additional missing getters for settings screen
  String get languageAndRegion {
    switch (locale.languageCode) {
      case 'en':
        return 'Language and Region';
      case 'es':
      default:
        return 'Idioma y Región';
    }
  }

  String get appearance {
    switch (locale.languageCode) {
      case 'en':
        return 'Appearance';
      case 'es':
      default:
        return 'Apariencia';
    }
  }

  String get currency {
    switch (locale.languageCode) {
      case 'en':
        return 'Currency';
      case 'es':
      default:
        return 'Moneda';
    }
  }

  String get theme {
    switch (locale.languageCode) {
      case 'en':
        return 'Theme';
      case 'es':
      default:
        return 'Tema';
    }
  }

  String get system {
    switch (locale.languageCode) {
      case 'en':
        return 'System';
      case 'es':
      default:
        return 'Sistema';
    }
  }

  String get light {
    switch (locale.languageCode) {
      case 'en':
        return 'Light';
      case 'es':
      default:
        return 'Claro';
    }
  }

  String get dark {
    switch (locale.languageCode) {
      case 'en':
        return 'Dark';
      case 'es':
      default:
        return 'Oscuro';
    }
  }

  String get darkMode {
    switch (locale.languageCode) {
      case 'en':
        return 'Dark Mode';
      case 'es':
      default:
        return 'Modo Oscuro';
    }
  }

  String get darkModeDescription {
    switch (locale.languageCode) {
      case 'en':
        return 'Use dark theme for the app';
      case 'es':
      default:
        return 'Usar tema oscuro para la aplicación';
    }
  }

  String get pushNotifications {
    switch (locale.languageCode) {
      case 'en':
        return 'Push Notifications';
      case 'es':
      default:
        return 'Notificaciones Push';
    }
  }

  String get emailNotifications {
    switch (locale.languageCode) {
      case 'en':
        return 'Email Notifications';
      case 'es':
      default:
        return 'Notificaciones por Email';
    }
  }

  String get smsNotifications {
    switch (locale.languageCode) {
      case 'en':
        return 'SMS Notifications';
      case 'es':
      default:
        return 'Notificaciones por SMS';
    }
  }

  String get notificationTypes {
    switch (locale.languageCode) {
      case 'en':
        return 'Notification Types';
      case 'es':
      default:
        return 'Tipos de Notificaciones';
    }
  }

  String get ordersAndServices {
    switch (locale.languageCode) {
      case 'en':
        return 'Orders and Services';
      case 'es':
      default:
        return 'Pedidos y Servicios';
    }
  }

  String get reviewsAndRatings {
    switch (locale.languageCode) {
      case 'en':
        return 'Reviews and Ratings';
      case 'es':
      default:
        return 'Reseñas y Valoraciones';
    }
  }

  String get publicProfile {
    switch (locale.languageCode) {
      case 'en':
        return 'Public Profile';
      case 'es':
      default:
        return 'Perfil Público';
    }
  }

  String get showPhone {
    switch (locale.languageCode) {
      case 'en':
        return 'Show Phone';
      case 'es':
      default:
        return 'Mostrar Teléfono';
    }
  }

  String get showLocation {
    switch (locale.languageCode) {
      case 'en':
        return 'Show Location';
      case 'es':
      default:
        return 'Mostrar Ubicación';
    }
  }

  String get allowMessages {
    switch (locale.languageCode) {
      case 'en':
        return 'Allow Messages';
      case 'es':
      default:
        return 'Permitir Mensajes';
    }
  }

  String get twoFactorAuth {
    switch (locale.languageCode) {
      case 'en':
        return 'Two-Factor Authentication';
      case 'es':
      default:
        return 'Autenticación de Dos Factores';
    }
  }

  String get twoFactorAuthDescription {
    switch (locale.languageCode) {
      case 'en':
        return 'Add an extra layer of security to your account';
      case 'es':
      default:
        return 'Añadir una capa extra de seguridad a tu cuenta';
    }
  }

  String get changePassword {
    switch (locale.languageCode) {
      case 'en':
        return 'Change Password';
      case 'es':
      default:
        return 'Cambiar Contraseña';
    }
  }

  String get activeSessions {
    switch (locale.languageCode) {
      case 'en':
        return 'Active Sessions';
      case 'es':
      default:
        return 'Sesiones Activas';
    }
  }

  String get helpCenter {
    switch (locale.languageCode) {
      case 'en':
        return 'Help Center';
      case 'es':
      default:
        return 'Centro de Ayuda';
    }
  }

  String get contactSupport {
    switch (locale.languageCode) {
      case 'en':
        return 'Contact Support';
      case 'es':
      default:
        return 'Contactar Soporte';
    }
  }

  String get reportProblem {
    switch (locale.languageCode) {
      case 'en':
        return 'Report Problem';
      case 'es':
      default:
        return 'Reportar Problema';
    }
  }

  String get sendFeedback {
    switch (locale.languageCode) {
      case 'en':
        return 'Send Feedback';
      case 'es':
      default:
        return 'Enviar Comentarios';
    }
  }

  String get appVersion {
    switch (locale.languageCode) {
      case 'en':
        return 'App Version';
      case 'es':
      default:
        return 'Versión de la App';
    }
  }

  String get termsAndConditions {
    switch (locale.languageCode) {
      case 'en':
        return 'Terms and Conditions';
      case 'es':
      default:
        return 'Términos y Condiciones';
    }
  }

  String get privacyPolicy {
    switch (locale.languageCode) {
      case 'en':
        return 'Privacy Policy';
      case 'es':
      default:
        return 'Política de Privacidad';
    }
  }

  String get licenses {
    switch (locale.languageCode) {
      case 'en':
        return 'Licenses';
      case 'es':
      default:
        return 'Licencias';
    }
  }

  String get selectRegion {
    switch (locale.languageCode) {
      case 'en':
        return 'Select Region';
      case 'es':
      default:
        return 'Seleccionar Región';
    }
  }

  String get selectCurrency {
    switch (locale.languageCode) {
      case 'en':
        return 'Select Currency';
      case 'es':
      default:
        return 'Seleccionar Moneda';
    }
  }

  String get selectTheme {
    switch (locale.languageCode) {
      case 'en':
        return 'Select Theme';
      case 'es':
      default:
        return 'Seleccionar Tema';
    }
  }

  String get confirmLogout {
    switch (locale.languageCode) {
      case 'en':
        return 'Confirm Logout';
      case 'es':
      default:
        return 'Confirmar Cierre de Sesión';
    }
  }

  String get confirmLogoutMessage {
    switch (locale.languageCode) {
      case 'en':
        return 'Are you sure you want to logout?';
      case 'es':
      default:
        return '¿Estás seguro de que quieres cerrar sesión?';
    }
  }

  String get comingSoonFeature {
    switch (locale.languageCode) {
      case 'en':
        return 'This feature will be available soon';
      case 'es':
      default:
        return 'Esta funcionalidad estará disponible próximamente';
    }
  }

  String get support {
    switch (locale.languageCode) {
      case 'en':
        return 'Support';
      case 'es':
      default:
        return 'Soporte';
    }
  }

  // Service categories page
  String get serviceCategoriesTitle {
    switch (locale.languageCode) {
      case 'en':
        return 'Service Categories';
      case 'es':
      default:
        return 'Categorías de Servicios';
    }
  }

  String get selectServiceType {
    switch (locale.languageCode) {
      case 'en':
        return 'Select the type of service you need';
      case 'es':
      default:
        return 'Selecciona el tipo de servicio que necesitas';
    }
  }

  String get comingSoonProviders {
    switch (locale.languageCode) {
      case 'en':
        return 'Coming soon: List of available providers';
      case 'es':
      default:
        return 'Próximamente: Lista de proveedores disponibles';
    }
  }

  String servicesOf(String category) {
    switch (locale.languageCode) {
      case 'en':
        return 'Services of $category';
      case 'es':
      default:
        return 'Servicios de $category';
    }
  }

  // Login screen
  String get loginTitle {
    switch (locale.languageCode) {
      case 'en':
        return 'Sign In';
      case 'es':
      default:
        return 'Iniciar Sesión';
    }
  }

  String get loginSubtitle {
    switch (locale.languageCode) {
      case 'en':
        return 'Find home services in Dominican Republic';
      case 'es':
      default:
        return 'Encuentra servicios para tu hogar en República Dominicana';
    }
  }

  String get emailLabel {
    switch (locale.languageCode) {
      case 'en':
        return 'Email';
      case 'es':
      default:
        return 'Correo electrónico';
    }
  }

  String get passwordLabel {
    switch (locale.languageCode) {
      case 'en':
        return 'Password';
      case 'es':
      default:
        return 'Contraseña';
    }
  }

  String get rememberUser {
    switch (locale.languageCode) {
      case 'en':
        return 'Remember user';
      case 'es':
      default:
        return 'Recordar usuario';
    }
  }

  String get loginButton {
    switch (locale.languageCode) {
      case 'en':
        return 'Sign In';
      case 'es':
      default:
        return 'Iniciar Sesión';
    }
  }

  String get noAccount {
    switch (locale.languageCode) {
      case 'en':
        return "Don't have an account? ";
      case 'es':
      default:
        return '¿No tienes cuenta? ';
    }
  }

  String get register {
    switch (locale.languageCode) {
      case 'en':
        return 'Sign Up';
      case 'es':
      default:
        return 'Regístrate';
    }
  }

  // Validation messages
  String get pleaseEnterEmail {
    switch (locale.languageCode) {
      case 'en':
        return 'Please enter your email';
      case 'es':
      default:
        return 'Por favor ingresa tu correo electrónico';
    }
  }

  String get pleaseEnterValidEmail {
    switch (locale.languageCode) {
      case 'en':
        return 'Please enter a valid email';
      case 'es':
      default:
        return 'Por favor ingresa un correo válido';
    }
  }

  String get pleaseEnterPassword {
    switch (locale.languageCode) {
      case 'en':
        return 'Please enter your password';
      case 'es':
      default:
        return 'Por favor ingresa tu contraseña';
    }
  }

  String get passwordMinLength {
    switch (locale.languageCode) {
      case 'en':
        return 'Password must be at least 6 characters';
      case 'es':
      default:
        return 'La contraseña debe tener al menos 6 caracteres';
    }
  }

  // Service booking screen
  String requestService(String serviceName) {
    switch (locale.languageCode) {
      case 'en':
        return 'Request $serviceName';
      case 'es':
      default:
        return 'Solicitar $serviceName';
    }
  }

  String get serviceDescription {
    switch (locale.languageCode) {
      case 'en':
        return 'Service description';
      case 'es':
      default:
        return 'Descripción del servicio';
    }
  }

  String get serviceDescriptionHint {
    switch (locale.languageCode) {
      case 'en':
        return 'Describe in detail the service you need...';
      case 'es':
      default:
        return 'Describe detalladamente el servicio que necesitas...';
    }
  }

  String get dateAndTime {
    switch (locale.languageCode) {
      case 'en':
        return 'Date and time';
      case 'es':
      default:
        return 'Fecha y hora';
    }
  }

  String get selectDate {
    switch (locale.languageCode) {
      case 'en':
        return 'Select date';
      case 'es':
      default:
        return 'Seleccionar fecha';
    }
  }

  String get selectTime {
    switch (locale.languageCode) {
      case 'en':
        return 'Select time';
      case 'es':
      default:
        return 'Seleccionar hora';
    }
  }

  String get serviceAddress {
    switch (locale.languageCode) {
      case 'en':
        return 'Service address';
      case 'es':
      default:
        return 'Dirección del servicio';
    }
  }

  String get serviceAddressHint {
    switch (locale.languageCode) {
      case 'en':
        return 'Enter the address where the service will be performed';
      case 'es':
      default:
        return 'Ingresa la dirección donde se realizará el servicio';
    }
  }

  String get phoneNumber {
    switch (locale.languageCode) {
      case 'en':
        return 'Phone number';
      case 'es':
      default:
        return 'Número de teléfono';
    }
  }

  String get phoneNumberHint {
    switch (locale.languageCode) {
      case 'en':
        return 'Enter your phone number';
      case 'es':
      default:
        return 'Ingresa tu número de teléfono';
    }
  }

  String get urgentService {
    switch (locale.languageCode) {
      case 'en':
        return 'Urgent service';
      case 'es':
      default:
        return 'Servicio urgente';
    }
  }

  String get urgentServiceSubtitle {
    switch (locale.languageCode) {
      case 'en':
        return 'I need the service as soon as possible';
      case 'es':
      default:
        return 'Necesito el servicio lo antes posible';
    }
  }

  String get sendRequest {
    switch (locale.languageCode) {
      case 'en':
        return 'Send Request';
      case 'es':
      default:
        return 'Enviar Solicitud';
    }
  }

  String get professionalService {
    switch (locale.languageCode) {
      case 'en':
        return 'Professional specialized service';
      case 'es':
      default:
        return 'Servicio profesional especializado';
    }
  }

  String get contactInfo {
    switch (locale.languageCode) {
      case 'en':
        return 'We will contact you within the next 24 hours to confirm the appointment and provide you with a detailed quote.';
      case 'es':
      default:
        return 'Te contactaremos en las próximas 24 horas para confirmar la cita y proporcionarte un presupuesto detallado.';
    }
  }

  // Validation messages for service booking
  String get pleaseSelectDate {
    switch (locale.languageCode) {
      case 'en':
        return 'Please select a date';
      case 'es':
      default:
        return 'Por favor selecciona una fecha';
    }
  }

  String get pleaseSelectTime {
    switch (locale.languageCode) {
      case 'en':
        return 'Please select a time';
      case 'es':
      default:
        return 'Por favor selecciona una hora';
    }
  }

  String get pleaseDescribeService {
    switch (locale.languageCode) {
      case 'en':
        return 'Please describe the service you need';
      case 'es':
      default:
        return 'Por favor describe el servicio que necesitas';
    }
  }

  String get pleaseEnterAddress {
    switch (locale.languageCode) {
      case 'en':
        return 'Please enter the service address';
      case 'es':
      default:
        return 'Por favor ingresa la dirección del servicio';
    }
  }

  String get pleaseEnterPhone {
    switch (locale.languageCode) {
      case 'en':
        return 'Please enter your phone number';
      case 'es':
      default:
        return 'Por favor ingresa tu número de teléfono';
    }
  }

  String get phoneMinLength {
    switch (locale.languageCode) {
      case 'en':
        return 'Phone number must have at least 10 digits';
      case 'es':
      default:
        return 'El número de teléfono debe tener al menos 10 dígitos';
    }
  }

  String serviceRequestSent(String serviceName) {
    switch (locale.languageCode) {
      case 'en':
        return '$serviceName request sent successfully';
      case 'es':
      default:
        return 'Solicitud de $serviceName enviada exitosamente';
    }
  }

  String get requestError {
    switch (locale.languageCode) {
      case 'en':
        return 'Error sending request. Please try again.';
      case 'es':
      default:
        return 'Error al enviar la solicitud. Inténtalo de nuevo.';
    }
  }

  // Home screen additional texts
  String get myServices {
    switch (locale.languageCode) {
      case 'en':
        return 'My Services';
      case 'es':
      default:
        return 'Mis Servicios';
    }
  }

  String get myProfile {
    switch (locale.languageCode) {
      case 'en':
        return 'My Profile';
      case 'es':
      default:
        return 'Mi Perfil';
    }
  }

  String get serviceDescriptionLabel {
    switch (locale.languageCode) {
      case 'en':
        return 'Service description:';
      case 'es':
      default:
        return 'Descripción del servicio:';
    }
  }

  String get availableServices {
    switch (locale.languageCode) {
      case 'en':
        return 'Available services:';
      case 'es':
      default:
        return 'Servicios disponibles:';
    }
  }

  String get close {
    switch (locale.languageCode) {
      case 'en':
        return 'Close';
      case 'es':
      default:
        return 'Cerrar';
    }
  }

  String get requestServiceButton {
    switch (locale.languageCode) {
      case 'en':
        return 'Request Service';
      case 'es':
      default:
        return 'Solicitar Servicio';
    }
  }

  String get completed {
    switch (locale.languageCode) {
      case 'en':
        return 'Completed';
      case 'es':
      default:
        return 'Completado';
    }
  }

  String get inProgress {
    switch (locale.languageCode) {
      case 'en':
        return 'In Progress';
      case 'es':
      default:
        return 'En progreso';
    }
  }

  String get pending {
    switch (locale.languageCode) {
      case 'en':
        return 'Pending';
      case 'es':
      default:
        return 'Pendiente';
    }
  }

  String get servicesLabel {
    switch (locale.languageCode) {
      case 'en':
        return 'Services';
      case 'es':
      default:
        return 'Servicios';
    }
  }

  String get completedServices {
    switch (locale.languageCode) {
      case 'en':
        return 'Completed';
      case 'es':
      default:
        return 'Completados';
    }
  }

  String get pendingServices {
    switch (locale.languageCode) {
      case 'en':
        return 'Pending';
      case 'es':
      default:
        return 'Pendientes';
    }
  }

  String get editProfileButton {
    switch (locale.languageCode) {
      case 'en':
        return 'Edit Profile';
      case 'es':
      default:
        return 'Editar Perfil';
    }
  }

  String get help {
    switch (locale.languageCode) {
      case 'en':
        return 'Help';
      case 'es':
      default:
        return 'Ayuda';
    }
  }

  String get about {
    switch (locale.languageCode) {
      case 'en':
        return 'About';
      case 'es':
      default:
        return 'Acerca de';
    }
  }

  String get providerPanel {
    switch (locale.languageCode) {
      case 'en':
        return 'Provider Panel';
      case 'es':
      default:
        return 'Panel de Proveedor';
    }
  }

  String get helpMessage {
    switch (locale.languageCode) {
      case 'en':
        return 'Need help? Contact our support team at ${AppConstants.supportPhone} or send an email to ${AppConstants.supportEmail}';
      case 'es':
      default:
        return '¿Necesitas ayuda? Contacta con nuestro equipo de soporte al ${AppConstants.supportPhone} o envía un email a ${AppConstants.supportEmail}';
    }
  }

  String get aboutMessage {
    switch (locale.languageCode) {
      case 'en':
        return 'Servicios Hogar RD v1.0\n\nConnecting Dominican homes with the best professional services.';
      case 'es':
      default:
        return 'Servicios Hogar RD v1.0\n\nConectamos hogares dominicanos con los mejores servicios profesionales.';
    }
  }

  String get comingSoon {
    switch (locale.languageCode) {
      case 'en':
        return 'This functionality will be available soon.';
      case 'es':
      default:
        return 'Esta funcionalidad estará disponible próximamente.';
    }
  }

  String get noUserData {
    switch (locale.languageCode) {
      case 'en':
        return 'No user data found';
      case 'es':
      default:
        return 'No se encontró información del usuario';
    }
  }

  String get errorLoadingProfile {
    switch (locale.languageCode) {
      case 'en':
        return 'Error loading profile';
      case 'es':
      default:
        return 'Error cargando perfil';
    }
  }

  // Service categories names
  String get plumbing {
    switch (locale.languageCode) {
      case 'en':
        return 'Plumbing';
      case 'es':
      default:
        return 'Plomería';
    }
  }

  String get electricity {
    switch (locale.languageCode) {
      case 'en':
        return 'Electricity';
      case 'es':
      default:
        return 'Electricidad';
    }
  }

  String get cleaning {
    switch (locale.languageCode) {
      case 'en':
        return 'Cleaning';
      case 'es':
      default:
        return 'Limpieza';
    }
  }

  String get gardening {
    switch (locale.languageCode) {
      case 'en':
        return 'Gardening';
      case 'es':
      default:
        return 'Jardinería';
    }
  }

  String get painting {
    switch (locale.languageCode) {
      case 'en':
        return 'Painting';
      case 'es':
      default:
        return 'Pintura';
    }
  }

  String get carpentry {
    switch (locale.languageCode) {
      case 'en':
        return 'Carpentry';
      case 'es':
      default:
        return 'Carpintería';
    }
  }

  String get airConditioning {
    switch (locale.languageCode) {
      case 'en':
        return 'Air Conditioning';
      case 'es':
      default:
        return 'Aire Acondicionado';
    }
  }

  String get locksmith {
    switch (locale.languageCode) {
      case 'en':
        return 'Locksmith';
      case 'es':
      default:
        return 'Cerrajería';
    }
  }

  String get masonry {
    switch (locale.languageCode) {
      case 'en':
        return 'Masonry';
      case 'es':
      default:
        return 'Albañilería';
    }
  }

  String get poolCleaning {
    switch (locale.languageCode) {
      case 'en':
        return 'Pool Cleaning';
      case 'es':
      default:
        return 'Limpieza de Piscinas';
    }
  }

  String get security {
    switch (locale.languageCode) {
      case 'en':
        return 'Security';
      case 'es':
      default:
        return 'Seguridad';
    }
  }

  String get moving {
    switch (locale.languageCode) {
      case 'en':
        return 'Moving';
      case 'es':
      default:
        return 'Mudanzas';
    }
  }

  // Service descriptions
  String get plumbingDescription {
    switch (locale.languageCode) {
      case 'en':
        return 'Repair and installation of plumbing systems, faucets, pipes and drains.';
      case 'es':
      default:
        return 'Reparación e instalación de sistemas de plomería, grifos, tuberías y desagües.';
    }
  }

  String get electricityDescription {
    switch (locale.languageCode) {
      case 'en':
        return 'Installation, repair and maintenance of residential electrical systems.';
      case 'es':
      default:
        return 'Instalación, reparación y mantenimiento de sistemas eléctricos residenciales.';
    }
  }

  String get cleaningDescription {
    switch (locale.languageCode) {
      case 'en':
        return 'Residential and commercial cleaning services with professional products.';
      case 'es':
      default:
        return 'Servicios de limpieza residencial y comercial con productos profesionales.';
    }
  }

  String get gardeningDescription {
    switch (locale.languageCode) {
      case 'en':
        return 'Garden maintenance, tree pruning and green space design.';
      case 'es':
      default:
        return 'Mantenimiento de jardines, poda de árboles y diseño de espacios verdes.';
    }
  }

  String get paintingDescription {
    switch (locale.languageCode) {
      case 'en':
        return 'Interior and exterior painting, surface preparation and finishes.';
      case 'es':
      default:
        return 'Pintura interior y exterior, preparación de superficies y acabados.';
    }
  }

  String get carpentryDescription {
    switch (locale.languageCode) {
      case 'en':
        return 'Manufacturing and repair of furniture and wooden structures.';
      case 'es':
      default:
        return 'Fabricación y reparación de muebles y estructuras de madera.';
    }
  }

  String get airConditioningDescription {
    switch (locale.languageCode) {
      case 'en':
        return 'Installation, repair and maintenance of air conditioning systems.';
      case 'es':
      default:
        return 'Instalación, reparación y mantenimiento de sistemas de aire acondicionado.';
    }
  }

  String get locksmithDescription {
    switch (locale.languageCode) {
      case 'en':
        return 'Repair and replacement of locks, key duplication and security.';
      case 'es':
      default:
        return 'Reparación y cambio de cerraduras, duplicado de llaves y seguridad.';
    }
  }

  String get masonryDescription {
    switch (locale.languageCode) {
      case 'en':
        return 'Construction, repair and remodeling of concrete structures.';
      case 'es':
      default:
        return 'Construcción, reparación y remodelación de estructuras de concreto.';
    }
  }

  String get poolCleaningDescription {
    switch (locale.languageCode) {
      case 'en':
        return 'Maintenance, cleaning and chemical treatment of pools.';
      case 'es':
      default:
        return 'Mantenimiento, limpieza y tratamiento químico de piscinas.';
    }
  }

  String get securityDescription {
    switch (locale.languageCode) {
      case 'en':
        return 'Installation and maintenance of security and surveillance systems.';
      case 'es':
      default:
        return 'Instalación y mantenimiento de sistemas de seguridad y vigilancia.';
    }
  }

  String get movingDescription {
    switch (locale.languageCode) {
      case 'en':
        return 'Moving and transportation services for furniture and belongings.';
      case 'es':
      default:
        return 'Servicios de mudanza y transporte de muebles y pertenencias.';
    }
  }

  // Service lists
  List<String> get plumbingServices {
    switch (locale.languageCode) {
      case 'en':
        return ['Faucet repair', 'Pipe unclogging', 'Toilet installation'];
      case 'es':
      default:
        return [
          'Reparación de grifos',
          'Desatasco de tuberías',
          'Instalación de sanitarios',
        ];
    }
  }

  List<String> get electricityServices {
    switch (locale.languageCode) {
      case 'en':
        return [
          'Outlet installation',
          'Short circuit repair',
          'Electrical wiring',
        ];
      case 'es':
      default:
        return [
          'Instalación de tomas',
          'Reparación de cortocircuitos',
          'Cableado eléctrico',
        ];
    }
  }

  List<String> get cleaningServices {
    switch (locale.languageCode) {
      case 'en':
        return [
          'General cleaning',
          'Deep cleaning',
          'Post-construction cleaning',
        ];
      case 'es':
      default:
        return ['Limpieza general', 'Limpieza profunda', 'Limpieza post-obra'];
    }
  }

  List<String> get gardeningServices {
    switch (locale.languageCode) {
      case 'en':
        return ['Tree pruning', 'Lawn maintenance', 'Garden design'];
      case 'es':
      default:
        return [
          'Poda de árboles',
          'Mantenimiento de césped',
          'Diseño de jardines',
        ];
    }
  }

  List<String> get paintingServices {
    switch (locale.languageCode) {
      case 'en':
        return [
          'Interior painting',
          'Exterior painting',
          'Surface preparation',
        ];
      case 'es':
      default:
        return [
          'Pintura interior',
          'Pintura exterior',
          'Preparación de superficies',
        ];
    }
  }

  List<String> get carpentryServices {
    switch (locale.languageCode) {
      case 'en':
        return ['Furniture repair', 'Custom manufacturing', 'Restoration'];
      case 'es':
      default:
        return [
          'Reparación de muebles',
          'Fabricación a medida',
          'Restauración',
        ];
    }
  }

  List<String> get airConditioningServices {
    switch (locale.languageCode) {
      case 'en':
        return ['Installation', 'Maintenance', 'Repair'];
      case 'es':
      default:
        return ['Instalación', 'Mantenimiento', 'Reparación'];
    }
  }

  List<String> get locksmithServices {
    switch (locale.languageCode) {
      case 'en':
        return ['Lock replacement', 'Key duplication', 'Lock repair'];
      case 'es':
      default:
        return [
          'Cambio de cerraduras',
          'Duplicado de llaves',
          'Reparación de cerrojos',
        ];
    }
  }

  List<String> get masonryServices {
    switch (locale.languageCode) {
      case 'en':
        return ['Construction', 'Wall repair', 'Remodeling'];
      case 'es':
      default:
        return ['Construcción', 'Reparación de paredes', 'Remodelación'];
    }
  }

  List<String> get poolCleaningServices {
    switch (locale.languageCode) {
      case 'en':
        return ['Manual cleaning', 'Chemical treatment', 'Filter maintenance'];
      case 'es':
      default:
        return [
          'Limpieza manual',
          'Tratamiento químico',
          'Mantenimiento de filtros',
        ];
    }
  }

  List<String> get securityServices {
    switch (locale.languageCode) {
      case 'en':
        return ['Camera installation', 'Alarm systems', 'Electric fence'];
      case 'es':
      default:
        return [
          'Instalación de cámaras',
          'Sistemas de alarma',
          'Cerco eléctrico',
        ];
    }
  }

  List<String> get movingServices {
    switch (locale.languageCode) {
      case 'en':
        return ['Local moving', 'Packing', 'Specialized transport'];
      case 'es':
      default:
        return ['Mudanza local', 'Embalaje', 'Transporte especializado'];
    }
  }

  List<String> get generalServices {
    switch (locale.languageCode) {
      case 'en':
        return ['General consultation', 'Evaluation', 'Quote'];
      case 'es':
      default:
        return ['Consulta general', 'Evaluación', 'Presupuesto'];
    }
  }

  // Settings screen translations

  // Language names
  String get spanish {
    switch (locale.languageCode) {
      case 'en':
        return 'Spanish';
      case 'es':
      default:
        return 'Español';
    }
  }

  String get english {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'es':
      default:
        return 'English';
    }
  }

  // Region names
  String get dominicanRepublic {
    switch (locale.languageCode) {
      case 'en':
        return 'Dominican Republic';
      case 'es':
      default:
        return 'República Dominicana';
    }
  }

  String get unitedStates {
    switch (locale.languageCode) {
      case 'en':
        return 'United States';
      case 'es':
      default:
        return 'Estados Unidos';
    }
  }

  String get mexico {
    switch (locale.languageCode) {
      case 'en':
        return 'Mexico';
      case 'es':
      default:
        return 'México';
    }
  }

  String get spain {
    switch (locale.languageCode) {
      case 'en':
        return 'Spain';
      case 'es':
      default:
        return 'España';
    }
  }

  String get france {
    switch (locale.languageCode) {
      case 'en':
        return 'France';
      case 'es':
      default:
        return 'Francia';
    }
  }

  String get brazil {
    switch (locale.languageCode) {
      case 'en':
        return 'Brazil';
      case 'es':
      default:
        return 'Brasil';
    }
  }

  String get italy {
    switch (locale.languageCode) {
      case 'en':
        return 'Italy';
      case 'es':
      default:
        return 'Italia';
    }
  }

  String get germany {
    switch (locale.languageCode) {
      case 'en':
        return 'Germany';
      case 'es':
      default:
        return 'Alemania';
    }
  }

  String get china {
    switch (locale.languageCode) {
      case 'en':
        return 'China';
      case 'es':
      default:
        return 'China';
    }
  }

  String get japan {
    switch (locale.languageCode) {
      case 'en':
        return 'Japan';
      case 'es':
      default:
        return 'Japón';
    }
  }

  String get southKorea {
    switch (locale.languageCode) {
      case 'en':
        return 'South Korea';
      case 'es':
      default:
        return 'Corea del Sur';
    }
  }

  String get uae {
    switch (locale.languageCode) {
      case 'en':
        return 'United Arab Emirates';
      case 'es':
      default:
        return 'Emiratos Árabes Unidos';
    }
  }

  String get russia {
    switch (locale.languageCode) {
      case 'en':
        return 'Russia';
      case 'es':
      default:
        return 'Rusia';
    }
  }

  String get india {
    switch (locale.languageCode) {
      case 'en':
        return 'India';
      case 'es':
      default:
        return 'India';
    }
  }

  // Currency names
  String get dominicanPeso {
    switch (locale.languageCode) {
      case 'en':
        return 'Dominican Peso (DOP)';
      case 'es':
      default:
        return 'Peso Dominicano (DOP)';
    }
  }

  String get usDollar {
    switch (locale.languageCode) {
      case 'en':
        return 'US Dollar (USD)';
      case 'es':
      default:
        return 'Dólar Americano (USD)';
    }
  }

  String get mexicanPeso {
    switch (locale.languageCode) {
      case 'en':
        return 'Mexican Peso (MXN)';
      case 'es':
      default:
        return 'Peso Mexicano (MXN)';
    }
  }

  String get euro {
    switch (locale.languageCode) {
      case 'en':
        return 'Euro (EUR)';
      case 'es':
      default:
        return 'Euro (EUR)';
    }
  }

  String get brazilianReal {
    switch (locale.languageCode) {
      case 'en':
        return 'Brazilian Real (BRL)';
      case 'es':
      default:
        return 'Real Brasileño (BRL)';
    }
  }

  String get chineseYuan {
    switch (locale.languageCode) {
      case 'en':
        return 'Chinese Yuan (CNY)';
      case 'es':
      default:
        return 'Yuan Chino (CNY)';
    }
  }

  String get japaneseYen {
    switch (locale.languageCode) {
      case 'en':
        return 'Japanese Yen (JPY)';
      case 'es':
      default:
        return 'Yen Japonés (JPY)';
    }
  }

  String get koreanWon {
    switch (locale.languageCode) {
      case 'en':
        return 'Korean Won (KRW)';
      case 'es':
      default:
        return 'Won Coreano (KRW)';
    }
  }

  String get uaeDirham {
    switch (locale.languageCode) {
      case 'en':
        return 'UAE Dirham (AED)';
      case 'es':
      default:
        return 'Dirham de los Emiratos (AED)';
    }
  }

  String get russianRuble {
    switch (locale.languageCode) {
      case 'en':
        return 'Russian Ruble (RUB)';
      case 'es':
      default:
        return 'Rublo Ruso (RUB)';
    }
  }

  String get indianRupee {
    switch (locale.languageCode) {
      case 'en':
        return 'Indian Rupee (INR)';
      case 'es':
      default:
        return 'Rupia India (INR)';
    }
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future.value(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
