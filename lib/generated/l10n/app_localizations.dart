import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// The title of the application
  ///
  /// In es, this message translates to:
  /// **'Servicios Hogar RD'**
  String get appTitle;

  /// Welcome message with user name
  ///
  /// In es, this message translates to:
  /// **'¡Bienvenido{name} a Servicios Hogar RD!'**
  String welcomeMessage(String name);

  /// Subtitle for the welcome section
  ///
  /// In es, this message translates to:
  /// **'Conectamos hogares dominicanos con los mejores servicios'**
  String get welcomeSubtitle;

  /// Title for service categories section
  ///
  /// In es, this message translates to:
  /// **'Categorías de servicios disponibles:'**
  String get serviceCategories;

  /// Home tab label
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get home;

  /// Services tab label
  ///
  /// In es, this message translates to:
  /// **'Servicios'**
  String get services;

  /// Profile tab label
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get profile;

  /// Search service option
  ///
  /// In es, this message translates to:
  /// **'Buscar un Servicio'**
  String get searchService;

  /// Description for search service option
  ///
  /// In es, this message translates to:
  /// **'Contratar profesionales para servicios en mi hogar'**
  String get searchServiceDescription;

  /// Offer service option
  ///
  /// In es, this message translates to:
  /// **'Ofrecer un Servicio'**
  String get offerService;

  /// Description for offer service option
  ///
  /// In es, this message translates to:
  /// **'Gestionar mi negocio y ofrecer servicios profesionales'**
  String get offerServiceDescription;

  /// Question for mode selection
  ///
  /// In es, this message translates to:
  /// **'¿Qué quieres hacer hoy?'**
  String get whatDoYouWantToDo;

  /// Description for mode selection
  ///
  /// In es, this message translates to:
  /// **'Selecciona el modo que mejor se adapte a lo que necesitas hacer'**
  String get selectModeDescription;

  /// Client mode
  ///
  /// In es, this message translates to:
  /// **'Cliente'**
  String get client;

  /// Provider mode
  ///
  /// In es, this message translates to:
  /// **'Proveedor'**
  String get provider;

  /// Settings title
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get settings;

  /// Save button
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// Account section
  ///
  /// In es, this message translates to:
  /// **'Cuenta'**
  String get account;

  /// Notifications section
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get notifications;

  /// Privacy section
  ///
  /// In es, this message translates to:
  /// **'Privacidad'**
  String get privacy;

  /// Language and region section
  ///
  /// In es, this message translates to:
  /// **'Idioma y Región'**
  String get languageAndRegion;

  /// Appearance section
  ///
  /// In es, this message translates to:
  /// **'Apariencia'**
  String get appearance;

  /// Security section
  ///
  /// In es, this message translates to:
  /// **'Seguridad'**
  String get security;

  /// Support section
  ///
  /// In es, this message translates to:
  /// **'Soporte'**
  String get support;

  /// About section
  ///
  /// In es, this message translates to:
  /// **'Acerca de'**
  String get about;

  /// Language setting
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// Region setting
  ///
  /// In es, this message translates to:
  /// **'Región'**
  String get region;

  /// Currency setting
  ///
  /// In es, this message translates to:
  /// **'Moneda'**
  String get currency;

  /// Theme setting
  ///
  /// In es, this message translates to:
  /// **'Tema'**
  String get theme;

  /// Spanish language
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get spanish;

  /// English language
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get english;

  /// Dominican Republic
  ///
  /// In es, this message translates to:
  /// **'República Dominicana'**
  String get dominicanRepublic;

  /// United States
  ///
  /// In es, this message translates to:
  /// **'Estados Unidos'**
  String get unitedStates;

  /// Dominican Peso currency
  ///
  /// In es, this message translates to:
  /// **'Peso Dominicano (DOP)'**
  String get dominicanPeso;

  /// US Dollar currency
  ///
  /// In es, this message translates to:
  /// **'Dólar Americano (USD)'**
  String get usDollar;

  /// System theme
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get system;

  /// Light theme
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get light;

  /// Dark theme
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get dark;

  /// Logout action
  ///
  /// In es, this message translates to:
  /// **'Cerrar Sesión'**
  String get logout;

  /// Cancel action
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// Close action
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get close;

  /// Edit profile action
  ///
  /// In es, this message translates to:
  /// **'Editar Perfil'**
  String get editProfile;

  /// Active account setting
  ///
  /// In es, this message translates to:
  /// **'Cuenta Activa'**
  String get activeAccount;

  /// Description for active account setting
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta está activa y puedes recibir servicios'**
  String get activeAccountDescription;

  /// Push notifications setting
  ///
  /// In es, this message translates to:
  /// **'Notificaciones Push'**
  String get pushNotifications;

  /// Description for push notifications
  ///
  /// In es, this message translates to:
  /// **'Recibir notificaciones en el dispositivo'**
  String get pushNotificationsDescription;

  /// Email notifications setting
  ///
  /// In es, this message translates to:
  /// **'Notificaciones por Email'**
  String get emailNotifications;

  /// Description for email notifications
  ///
  /// In es, this message translates to:
  /// **'Recibir notificaciones por correo electrónico'**
  String get emailNotificationsDescription;

  /// SMS notifications setting
  ///
  /// In es, this message translates to:
  /// **'Notificaciones por SMS'**
  String get smsNotifications;

  /// Description for SMS notifications
  ///
  /// In es, this message translates to:
  /// **'Recibir notificaciones por mensaje de texto'**
  String get smsNotificationsDescription;

  /// Notification types section
  ///
  /// In es, this message translates to:
  /// **'Tipos de Notificaciones'**
  String get notificationTypes;

  /// Orders and services notifications
  ///
  /// In es, this message translates to:
  /// **'Pedidos y Servicios'**
  String get ordersAndServices;

  /// Description for orders and services notifications
  ///
  /// In es, this message translates to:
  /// **'Notificaciones sobre pedidos y servicios'**
  String get ordersAndServicesDescription;

  /// Reviews and ratings notifications
  ///
  /// In es, this message translates to:
  /// **'Reseñas y Valoraciones'**
  String get reviewsAndRatings;

  /// Description for reviews and ratings notifications
  ///
  /// In es, this message translates to:
  /// **'Notificaciones sobre reseñas recibidas'**
  String get reviewsAndRatingsDescription;

  /// Promotions notifications
  ///
  /// In es, this message translates to:
  /// **'Promociones'**
  String get promotions;

  /// Description for promotions notifications
  ///
  /// In es, this message translates to:
  /// **'Notificaciones sobre ofertas y promociones'**
  String get promotionsDescription;

  /// Public profile setting
  ///
  /// In es, this message translates to:
  /// **'Perfil Público'**
  String get publicProfile;

  /// Description for public profile setting
  ///
  /// In es, this message translates to:
  /// **'Tu perfil es visible para otros usuarios'**
  String get publicProfileDescription;

  /// Show phone setting
  ///
  /// In es, this message translates to:
  /// **'Mostrar Teléfono'**
  String get showPhone;

  /// Description for show phone setting
  ///
  /// In es, this message translates to:
  /// **'Mostrar tu número de teléfono en el perfil'**
  String get showPhoneDescription;

  /// Show location setting
  ///
  /// In es, this message translates to:
  /// **'Mostrar Ubicación'**
  String get showLocation;

  /// Description for show location setting
  ///
  /// In es, this message translates to:
  /// **'Mostrar tu ubicación aproximada'**
  String get showLocationDescription;

  /// Allow messages setting
  ///
  /// In es, this message translates to:
  /// **'Permitir Mensajes'**
  String get allowMessages;

  /// Description for allow messages setting
  ///
  /// In es, this message translates to:
  /// **'Permitir que otros usuarios te envíen mensajes'**
  String get allowMessagesDescription;

  /// Two factor verification setting
  ///
  /// In es, this message translates to:
  /// **'Verificación en Dos Pasos'**
  String get twoFactorVerification;

  /// Description for two factor verification
  ///
  /// In es, this message translates to:
  /// **'Añadir una capa extra de seguridad'**
  String get twoFactorVerificationDescription;

  /// Change password action
  ///
  /// In es, this message translates to:
  /// **'Cambiar Contraseña'**
  String get changePassword;

  /// Active sessions action
  ///
  /// In es, this message translates to:
  /// **'Sesiones Activas'**
  String get activeSessions;

  /// Help center action
  ///
  /// In es, this message translates to:
  /// **'Centro de Ayuda'**
  String get helpCenter;

  /// Contact support action
  ///
  /// In es, this message translates to:
  /// **'Contactar Soporte'**
  String get contactSupport;

  /// Report problem action
  ///
  /// In es, this message translates to:
  /// **'Reportar Problema'**
  String get reportProblem;

  /// Send feedback action
  ///
  /// In es, this message translates to:
  /// **'Enviar Comentarios'**
  String get sendFeedback;

  /// App version label
  ///
  /// In es, this message translates to:
  /// **'Versión de la App'**
  String get appVersion;

  /// Terms and conditions action
  ///
  /// In es, this message translates to:
  /// **'Términos y Condiciones'**
  String get termsAndConditions;

  /// Privacy policy action
  ///
  /// In es, this message translates to:
  /// **'Política de Privacidad'**
  String get privacyPolicy;

  /// Licenses action
  ///
  /// In es, this message translates to:
  /// **'Licencias'**
  String get licenses;

  /// Select language dialog title
  ///
  /// In es, this message translates to:
  /// **'Seleccionar Idioma'**
  String get selectLanguage;

  /// Select region dialog title
  ///
  /// In es, this message translates to:
  /// **'Seleccionar Región'**
  String get selectRegion;

  /// Select currency dialog title
  ///
  /// In es, this message translates to:
  /// **'Seleccionar Moneda'**
  String get selectCurrency;

  /// Select theme dialog title
  ///
  /// In es, this message translates to:
  /// **'Seleccionar Tema'**
  String get selectTheme;

  /// Logout confirmation message
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres cerrar sesión?'**
  String get logoutConfirmation;

  /// Settings saved success message
  ///
  /// In es, this message translates to:
  /// **'Configuraciones guardadas exitosamente'**
  String get settingsSaved;

  /// Settings save error message
  ///
  /// In es, this message translates to:
  /// **'Error guardando configuraciones'**
  String get settingsError;

  /// Coming soon message
  ///
  /// In es, this message translates to:
  /// **'Esta funcionalidad estará disponible próximamente.'**
  String get comingSoon;

  /// No user data found message
  ///
  /// In es, this message translates to:
  /// **'No se encontró información del usuario'**
  String get noUserData;

  /// Error loading profile message
  ///
  /// In es, this message translates to:
  /// **'Error cargando perfil'**
  String get errorLoadingProfile;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
