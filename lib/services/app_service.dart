import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'auth_service.dart';
import 'localization_service.dart';
import 'settings_service.dart';
import 'provider_service.dart';
import 'notification_service.dart';
import 'location_service.dart';
import 'analytics_service.dart';
import 'service_request_service.dart';
import 'invoice_service.dart';
import 'chat_service.dart';

class AppService extends ChangeNotifier {
  final _logger = Logger();

  // Singleton pattern
  static AppService? _instance;
  static AppService get instance {
    _instance ??= AppService._internal();
    return _instance!;
  }

  AppService._internal();

  // Service instances
  late final AuthService _authService;
  late final LocalizationService _localizationService;
  late final SettingsService _settingsService;
  late final ProviderService _providerService;
  late final NotificationService _notificationService;
  late final LocationService _locationService;
  late final AnalyticsService _analyticsService;
  late final ServiceRequestService _serviceRequestService;
  late final InvoiceService _invoiceService;
  late final ChatService _chatService;

  // Service getters
  AuthService get auth => _authService;
  LocalizationService get localization => _localizationService;
  SettingsService get settings => _settingsService;
  ProviderService get providers => _providerService;
  NotificationService get notifications => _notificationService;
  LocationService get location => _locationService;
  AnalyticsService get analytics => _analyticsService;
  ServiceRequestService get serviceRequests => _serviceRequestService;
  InvoiceService get invoices => _invoiceService;
  ChatService get chat => _chatService;

  // App state
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _currentUserId;
  String? _currentUserType;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get currentUserId => _currentUserId;
  String? get currentUserType => _currentUserType;

  // Initialize all services
  Future<void> initialize() async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      _logger.i('Initializing AppService...');

      // Initialize services
      _authService = AuthService();
      _localizationService = LocalizationService.instance;
      _settingsService = SettingsService();
      _providerService = ProviderService();
      _notificationService = NotificationService.instance;
      _locationService = LocationService.instance;
      _analyticsService = AnalyticsService.instance;
      _serviceRequestService = ServiceRequestService.instance;
      _invoiceService = InvoiceService();
      _chatService = ChatService.instance;

      // Load service settings
      await _localizationService.loadSavedLanguage();
      await _notificationService.loadSettings();
      await _locationService.loadSettings();
      await _analyticsService.loadSettings();
      await _serviceRequestService.initialize();
      await _chatService.initialize();

      // Track app initialization
      _analyticsService.trackEvent('app_initialized');

      _isInitialized = true;
      _logger.i('AppService initialized successfully');
    } catch (e) {
      _logger.e('Error initializing AppService: $e');
      _analyticsService.trackError('app_initialization_error', e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Initialize user session
  Future<void> initializeUserSession(String userId, String userType) async {
    try {
      _currentUserId = userId;
      _currentUserType = userType;

      // Initialize chat service with user data
      await _chatService.initializeWithUser(userId);

      // Track user session start
      _analyticsService.trackEvent(
        'user_session_started',
        userId: userId,
        parameters: {'user_type': userType},
      );

      _logger.i('User session initialized: $userId ($userType)');
      notifyListeners();
    } catch (e) {
      _logger.e('Error initializing user session: $e');
      _analyticsService.trackError(
        'user_session_initialization_error',
        e.toString(),
      );
    }
  }

  // Clear user session
  Future<void> clearUserSession() async {
    try {
      if (_currentUserId != null) {
        _analyticsService.trackEvent(
          'user_session_ended',
          userId: _currentUserId,
        );
      }

      _currentUserId = null;
      _currentUserType = null;

      _logger.i('User session cleared');
      notifyListeners();
    } catch (e) {
      _logger.e('Error clearing user session: $e');
    }
  }

  // Get app status
  Map<String, dynamic> getAppStatus() {
    return {
      'is_initialized': _isInitialized,
      'is_loading': _isLoading,
      'current_user_id': _currentUserId,
      'current_user_type': _currentUserType,
      'services': {
        'auth': _authService.currentUser != null,
        'localization': _localizationService.currentLocale.languageCode,
        'notifications': _notificationService.notificationsEnabled,
        'location': _locationService.hasLocation,
        'analytics': _analyticsService.analyticsEnabled,
      },
    };
  }

  // Reset all services
  Future<void> resetAllServices() async {
    try {
      _logger.i('Resetting all services...');

      await _notificationService.resetToDefaults();
      await _locationService.clearLocationData();
      await _analyticsService.clearAnalyticsData();

      _logger.i('All services reset successfully');
    } catch (e) {
      _logger.e('Error resetting services: $e');
    }
  }

  // Get service health status
  Map<String, String> getServiceHealth() {
    return {
      'auth_service': _authService.currentUser != null ? 'healthy' : 'no_user',
      'localization_service': 'healthy',
      'settings_service': 'healthy',
      'provider_service': 'healthy',
      'notification_service': _notificationService.notificationsEnabled
          ? 'healthy'
          : 'disabled',
      'location_service': _locationService.hasLocation
          ? 'healthy'
          : 'no_location',
      'analytics_service': _analyticsService.analyticsEnabled
          ? 'healthy'
          : 'disabled',
    };
  }

  // Handle app lifecycle events
  void onAppResumed() {
    _analyticsService.trackEvent('app_resumed', userId: _currentUserId);
    _logger.i('App resumed');
  }

  void onAppPaused() {
    _analyticsService.trackEvent('app_paused', userId: _currentUserId);
    _logger.i('App paused');
  }

  void onAppDetached() {
    _analyticsService.trackEvent('app_detached', userId: _currentUserId);
    _logger.i('App detached');
  }

  // Get app configuration
  Map<String, dynamic> getAppConfiguration() {
    return {
      'version': '1.0.0',
      'build_number': 1,
      'environment': 'development',
      'firebase_enabled': true,
      'analytics_enabled': _analyticsService.analyticsEnabled,
      'notifications_enabled': _notificationService.notificationsEnabled,
      'location_enabled': _locationService.locationPermissionGranted,
      'supported_languages': ['es', 'en'],
      'default_language': 'es',
      'supported_regions': ['DO', 'US', 'MX'],
      'default_region': 'DO',
    };
  }

  // Dispose all services
  @override
  void dispose() {
    _logger.i('Disposing AppService...');
    super.dispose();
  }
}
