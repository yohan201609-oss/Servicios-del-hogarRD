import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService extends ChangeNotifier {
  final _logger = Logger();
  static const String _notificationsKey = 'notifications_enabled';
  static const String _pushNotificationsKey = 'push_notifications_enabled';
  static const String _emailNotificationsKey = 'email_notifications_enabled';
  static const String _smsNotificationsKey = 'sms_notifications_enabled';

  // Singleton pattern
  static NotificationService? _instance;
  static NotificationService get instance {
    _instance ??= NotificationService._internal();
    return _instance!;
  }

  NotificationService._internal();

  bool _notificationsEnabled = true;
  bool _pushNotificationsEnabled = true;
  bool _emailNotificationsEnabled = true;
  bool _smsNotificationsEnabled = false;

  // Getters
  bool get notificationsEnabled => _notificationsEnabled;
  bool get pushNotificationsEnabled => _pushNotificationsEnabled;
  bool get emailNotificationsEnabled => _emailNotificationsEnabled;
  bool get smsNotificationsEnabled => _smsNotificationsEnabled;

  // Load notification settings
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
      _pushNotificationsEnabled = prefs.getBool(_pushNotificationsKey) ?? true;
      _emailNotificationsEnabled =
          prefs.getBool(_emailNotificationsKey) ?? true;
      _smsNotificationsEnabled = prefs.getBool(_smsNotificationsKey) ?? false;

      _logger.i('Notification settings loaded');
      notifyListeners();
    } catch (e) {
      _logger.e('Error loading notification settings: $e');
    }
  }

  // Save notification settings
  Future<bool> saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationsKey, _notificationsEnabled);
      await prefs.setBool(_pushNotificationsKey, _pushNotificationsEnabled);
      await prefs.setBool(_emailNotificationsKey, _emailNotificationsEnabled);
      await prefs.setBool(_smsNotificationsKey, _smsNotificationsEnabled);

      _logger.i('Notification settings saved');
      return true;
    } catch (e) {
      _logger.e('Error saving notification settings: $e');
      return false;
    }
  }

  // Update notification settings
  Future<void> updateNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await saveSettings();
    notifyListeners();
  }

  Future<void> updatePushNotificationsEnabled(bool enabled) async {
    _pushNotificationsEnabled = enabled;
    await saveSettings();
    notifyListeners();
  }

  Future<void> updateEmailNotificationsEnabled(bool enabled) async {
    _emailNotificationsEnabled = enabled;
    await saveSettings();
    notifyListeners();
  }

  Future<void> updateSmsNotificationsEnabled(bool enabled) async {
    _smsNotificationsEnabled = enabled;
    await saveSettings();
    notifyListeners();
  }

  // Show local notification
  void showLocalNotification(
    BuildContext context, {
    required String title,
    required String message,
    String? action,
    VoidCallback? onTap,
  }) {
    if (!_notificationsEnabled || !_pushNotificationsEnabled) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(message, style: const TextStyle(color: Colors.white70)),
          ],
        ),
        backgroundColor: Colors.blue[600],
        duration: const Duration(seconds: 4),
        action: action != null
            ? SnackBarAction(
                label: action,
                textColor: Colors.white,
                onPressed: onTap ?? () {},
              )
            : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Show success notification
  void showSuccessNotification(BuildContext context, String message) {
    showLocalNotification(context, title: 'Éxito', message: message);
  }

  // Show error notification
  void showErrorNotification(BuildContext context, String message) {
    showLocalNotification(context, title: 'Error', message: message);
  }

  // Show info notification
  void showInfoNotification(BuildContext context, String message) {
    showLocalNotification(context, title: 'Información', message: message);
  }

  // Show warning notification
  void showWarningNotification(BuildContext context, String message) {
    showLocalNotification(context, title: 'Advertencia', message: message);
  }

  // Simulate sending email notification
  Future<void> sendEmailNotification({
    required String to,
    required String subject,
    required String body,
  }) async {
    if (!_notificationsEnabled || !_emailNotificationsEnabled) return;

    _logger.i('Sending email notification to: $to');
    _logger.i('Subject: $subject');
    _logger.i('Body: $body');

    // In a real app, this would integrate with an email service
    // For now, just log the notification
  }

  // Simulate sending SMS notification
  Future<void> sendSmsNotification({
    required String to,
    required String message,
  }) async {
    if (!_notificationsEnabled || !_smsNotificationsEnabled) return;

    _logger.i('Sending SMS notification to: $to');
    _logger.i('Message: $message');

    // In a real app, this would integrate with an SMS service
    // For now, just log the notification
  }

  // Send provider notification
  Future<void> notifyProvider({
    required String providerId,
    required String title,
    required String message,
    required String type, // 'new_request', 'cancellation', 'review', etc.
  }) async {
    _logger.i('Notifying provider $providerId: $title');

    // In a real app, this would send push notifications to the provider
    // For now, just log the notification
  }

  // Send client notification
  Future<void> notifyClient({
    required String clientId,
    required String title,
    required String message,
    required String type, // 'provider_response', 'service_completed', etc.
  }) async {
    _logger.i('Notifying client $clientId: $title');

    // In a real app, this would send push notifications to the client
    // For now, just log the notification
  }

  // Get notification settings as map
  Map<String, bool> getSettings() {
    return {
      'notifications': _notificationsEnabled,
      'push': _pushNotificationsEnabled,
      'email': _emailNotificationsEnabled,
      'sms': _smsNotificationsEnabled,
    };
  }

  // Reset to default settings
  Future<void> resetToDefaults() async {
    _notificationsEnabled = true;
    _pushNotificationsEnabled = true;
    _emailNotificationsEnabled = true;
    _smsNotificationsEnabled = false;

    await saveSettings();
    notifyListeners();
  }
}
