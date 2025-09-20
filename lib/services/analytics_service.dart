import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnalyticsService extends ChangeNotifier {
  final _logger = Logger();
  static const String _analyticsKey = 'analytics_enabled';
  static const String _eventsKey = 'analytics_events';

  // Singleton pattern
  static AnalyticsService? _instance;
  static AnalyticsService get instance {
    _instance ??= AnalyticsService._internal();
    return _instance!;
  }

  AnalyticsService._internal();

  bool _analyticsEnabled = true;
  List<Map<String, dynamic>> _events = [];

  // Getters
  bool get analyticsEnabled => _analyticsEnabled;
  List<Map<String, dynamic>> get events => List.unmodifiable(_events);

  // Load analytics settings
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _analyticsEnabled = prefs.getBool(_analyticsKey) ?? true;

      // Load events from storage (in a real app, this would be more sophisticated)
      final eventsJson = prefs.getString(_eventsKey);
      if (eventsJson != null) {
        // Parse events from JSON (simplified)
        _events = [];
      }

      _logger.i('Analytics settings loaded');
      notifyListeners();
    } catch (e) {
      _logger.e('Error loading analytics settings: $e');
    }
  }

  // Save analytics settings
  Future<bool> saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_analyticsKey, _analyticsEnabled);

      _logger.i('Analytics settings saved');
      return true;
    } catch (e) {
      _logger.e('Error saving analytics settings: $e');
      return false;
    }
  }

  // Update analytics enabled status
  Future<void> updateAnalyticsEnabled(bool enabled) async {
    _analyticsEnabled = enabled;
    await saveSettings();
    notifyListeners();
  }

  // Track event
  void trackEvent(
    String eventName, {
    Map<String, dynamic>? parameters,
    String? userId,
  }) {
    if (!_analyticsEnabled) return;

    final event = {
      'event_name': eventName,
      'timestamp': DateTime.now().toIso8601String(),
      'user_id': userId,
      'parameters': parameters ?? {},
    };

    _events.add(event);

    // Keep only last 100 events in memory
    if (_events.length > 100) {
      _events.removeAt(0);
    }

    _logger.i('Event tracked: $eventName');

    // In a real app, this would send to analytics service (Firebase Analytics, etc.)
    _sendEventToService(event);
  }

  // Send event to analytics service (simulated)
  void _sendEventToService(Map<String, dynamic> event) {
    // In a real app, this would integrate with Firebase Analytics or similar
    _logger.d('Sending event to analytics service: ${event['event_name']}');
  }

  // Track screen view
  void trackScreenView(
    String screenName, {
    String? userId,
    Map<String, dynamic>? parameters,
  }) {
    trackEvent(
      'screen_view',
      parameters: {'screen_name': screenName, ...?parameters},
      userId: userId,
    );
  }

  // Track user action
  void trackUserAction(
    String action, {
    String? category,
    String? label,
    double? value,
    String? userId,
    Map<String, dynamic>? parameters,
  }) {
    trackEvent(
      'user_action',
      parameters: {
        'action': action,
        if (category != null) 'category': category,
        if (label != null) 'label': label,
        if (value != null) 'value': value,
        ...?parameters,
      },
      userId: userId,
    );
  }

  // Track service interaction
  void trackServiceInteraction(
    String serviceName,
    String interactionType, {
    String? providerId,
    String? userId,
    Map<String, dynamic>? parameters,
  }) {
    trackEvent(
      'service_interaction',
      parameters: {
        'service_name': serviceName,
        'interaction_type': interactionType,
        if (providerId != null) 'provider_id': providerId,
        ...?parameters,
      },
      userId: userId,
    );
  }

  // Track search
  void trackSearch(
    String query, {
    String? category,
    int? resultCount,
    String? userId,
  }) {
    trackEvent(
      'search',
      parameters: {
        'query': query,
        if (category != null) 'category': category,
        if (resultCount != null) 'result_count': resultCount,
      },
      userId: userId,
    );
  }

  // Track provider contact
  void trackProviderContact(
    String providerId,
    String contactMethod, {
    String? userId,
    Map<String, dynamic>? parameters,
  }) {
    trackEvent(
      'provider_contact',
      parameters: {
        'provider_id': providerId,
        'contact_method': contactMethod,
        ...?parameters,
      },
      userId: userId,
    );
  }

  // Track app performance
  void trackPerformance(
    String metricName,
    double value, {
    String? userId,
    Map<String, dynamic>? parameters,
  }) {
    trackEvent(
      'performance',
      parameters: {'metric_name': metricName, 'value': value, ...?parameters},
      userId: userId,
    );
  }

  // Track error
  void trackError(
    String errorType,
    String errorMessage, {
    String? stackTrace,
    String? userId,
    Map<String, dynamic>? parameters,
  }) {
    trackEvent(
      'error',
      parameters: {
        'error_type': errorType,
        'error_message': errorMessage,
        if (stackTrace != null) 'stack_trace': stackTrace,
        ...?parameters,
      },
      userId: userId,
    );
  }

  // Track user engagement
  void trackEngagement(
    String engagementType, {
    String? contentId,
    String? userId,
    Map<String, dynamic>? parameters,
  }) {
    trackEvent(
      'engagement',
      parameters: {
        'engagement_type': engagementType,
        if (contentId != null) 'content_id': contentId,
        ...?parameters,
      },
      userId: userId,
    );
  }

  // Get analytics summary
  Map<String, dynamic> getAnalyticsSummary() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));

    final recentEvents = _events.where((event) {
      final eventTime = DateTime.parse(event['timestamp']);
      return eventTime.isAfter(weekAgo);
    }).toList();

    final eventCounts = <String, int>{};
    for (final event in recentEvents) {
      final eventName = event['event_name'] as String;
      eventCounts[eventName] = (eventCounts[eventName] ?? 0) + 1;
    }

    return {
      'total_events': _events.length,
      'recent_events': recentEvents.length,
      'event_counts': eventCounts,
      'analytics_enabled': _analyticsEnabled,
    };
  }

  // Clear analytics data
  Future<void> clearAnalyticsData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_eventsKey);

      _events.clear();

      _logger.i('Analytics data cleared');
      notifyListeners();
    } catch (e) {
      _logger.e('Error clearing analytics data: $e');
    }
  }

  // Export analytics data
  String exportAnalyticsData() {
    return {
      'analytics_enabled': _analyticsEnabled,
      'total_events': _events.length,
      'events': _events,
    }.toString();
  }

  // Get user journey
  List<Map<String, dynamic>> getUserJourney(String userId) {
    return _events.where((event) => event['user_id'] == userId).toList();
  }

  // Get popular services
  List<Map<String, dynamic>> getPopularServices() {
    final serviceEvents = _events
        .where((event) => event['event_name'] == 'service_interaction')
        .toList();

    final serviceCounts = <String, int>{};
    for (final event in serviceEvents) {
      final serviceName = event['parameters']?['service_name'] as String?;
      if (serviceName != null) {
        serviceCounts[serviceName] = (serviceCounts[serviceName] ?? 0) + 1;
      }
    }

    return serviceCounts.entries
        .map(
          (entry) => {
            'service_name': entry.key,
            'interaction_count': entry.value,
          },
        )
        .toList()
      ..sort(
        (a, b) => (b['interaction_count'] as int).compareTo(
          a['interaction_count'] as int,
        ),
      );
  }
}
