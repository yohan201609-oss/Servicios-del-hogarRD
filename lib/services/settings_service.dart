import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  final _logger = Logger();
  static const String _settingsKey = 'app_settings';

  // Configuraciones por defecto
  static const Map<String, dynamic> _defaultSettings = {
    // Notificaciones
    'notificaciones_push': true,
    'notificaciones_email': true,
    'notificaciones_sms': false,
    'notificaciones_pedidos': true,
    'notificaciones_resenas': true,
    'notificaciones_promociones': false,

    // Privacidad
    'perfil_publico': true,
    'mostrar_telefono': true,
    'mostrar_ubicacion': false,
    'permitir_mensajes': true,

    // Idioma y región
    'idioma': 'es',
    'region': 'DO',
    'moneda': 'DOP',

    // Tema
    'tema': 'sistema',
    'modo_oscuro': false,

    // Cuenta
    'cuenta_activa': true,
    'verificacion_dos_factores': false,
  };

  /// Cargar todas las configuraciones
  Future<Map<String, dynamic>> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);

      if (settingsJson != null) {
        final settings = jsonDecode(settingsJson) as Map<String, dynamic>;
        // Combinar con configuraciones por defecto para asegurar que todas las claves existan
        return {..._defaultSettings, ...settings};
      }

      return Map<String, dynamic>.from(_defaultSettings);
    } catch (e) {
      _logger.e('Error cargando configuraciones: $e');
      return Map<String, dynamic>.from(_defaultSettings);
    }
  }

  /// Guardar todas las configuraciones
  Future<bool> saveSettings(Map<String, dynamic> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_settingsKey, jsonEncode(settings));
      _logger.i('Configuraciones guardadas exitosamente');
      return true;
    } catch (e) {
      _logger.e('Error guardando configuraciones: $e');
      return false;
    }
  }

  /// Obtener una configuración específica
  Future<T> getSetting<T>(String key, T defaultValue) async {
    try {
      final settings = await loadSettings();
      return settings[key] as T? ?? defaultValue;
    } catch (e) {
      _logger.e('Error obteniendo configuración $key: $e');
      return defaultValue;
    }
  }

  /// Establecer una configuración específica
  Future<bool> setSetting(String key, dynamic value) async {
    try {
      final settings = await loadSettings();
      settings[key] = value;
      return await saveSettings(settings);
    } catch (e) {
      _logger.e('Error estableciendo configuración $key: $e');
      return false;
    }
  }

  /// Resetear todas las configuraciones a los valores por defecto
  Future<bool> resetSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_settingsKey);
      _logger.i('Configuraciones reseteadas a valores por defecto');
      return true;
    } catch (e) {
      _logger.e('Error reseteando configuraciones: $e');
      return false;
    }
  }

  /// Obtener configuraciones de notificaciones
  Future<Map<String, bool>> getNotificationSettings() async {
    return {
      'push': await getSetting('notificaciones_push', true),
      'email': await getSetting('notificaciones_email', true),
      'sms': await getSetting('notificaciones_sms', false),
      'pedidos': await getSetting('notificaciones_pedidos', true),
      'resenas': await getSetting('notificaciones_resenas', true),
      'promociones': await getSetting('notificaciones_promociones', false),
    };
  }

  /// Obtener configuraciones de privacidad
  Future<Map<String, bool>> getPrivacySettings() async {
    return {
      'perfil_publico': await getSetting('perfil_publico', true),
      'mostrar_telefono': await getSetting('mostrar_telefono', true),
      'mostrar_ubicacion': await getSetting('mostrar_ubicacion', false),
      'permitir_mensajes': await getSetting('permitir_mensajes', true),
    };
  }

  /// Obtener configuraciones de idioma y región
  Future<Map<String, String>> getLanguageSettings() async {
    return {
      'idioma': await getSetting('idioma', 'es'),
      'region': await getSetting('region', 'DO'),
      'moneda': await getSetting('moneda', 'DOP'),
    };
  }

  /// Obtener configuraciones de tema
  Future<Map<String, dynamic>> getThemeSettings() async {
    return {
      'tema': await getSetting('tema', 'sistema'),
      'modo_oscuro': await getSetting('modo_oscuro', false),
    };
  }

  /// Obtener configuraciones de seguridad
  Future<Map<String, bool>> getSecuritySettings() async {
    return {
      'cuenta_activa': await getSetting('cuenta_activa', true),
      'verificacion_dos_factores': await getSetting(
        'verificacion_dos_factores',
        false,
      ),
    };
  }

  /// Validar configuración
  bool validateSetting(String key, dynamic value) {
    switch (key) {
      case 'idioma':
        return [
          'es',
          'en',
          'fr',
          'pt',
          'it',
          'de',
          'zh',
          'ja',
          'ko',
          'ar',
          'ru',
          'hi',
        ].contains(value);
      case 'region':
        return [
          'DO',
          'US',
          'MX',
          'ES',
          'FR',
          'BR',
          'IT',
          'DE',
          'CN',
          'JP',
          'KR',
          'AE',
          'RU',
          'IN',
        ].contains(value);
      case 'moneda':
        return [
          'DOP',
          'USD',
          'MXN',
          'EUR',
          'BRL',
          'CNY',
          'JPY',
          'KRW',
          'AED',
          'RUB',
          'INR',
        ].contains(value);
      case 'tema':
        return ['sistema', 'claro', 'oscuro'].contains(value);
      case 'notificaciones_push':
      case 'notificaciones_email':
      case 'notificaciones_sms':
      case 'notificaciones_pedidos':
      case 'notificaciones_resenas':
      case 'notificaciones_promociones':
      case 'perfil_publico':
      case 'mostrar_telefono':
      case 'mostrar_ubicacion':
      case 'permitir_mensajes':
      case 'modo_oscuro':
      case 'cuenta_activa':
      case 'verificacion_dos_factores':
        return value is bool;
      default:
        return true;
    }
  }

  /// Exportar configuraciones (para backup)
  Future<String?> exportSettings() async {
    try {
      final settings = await loadSettings();
      return jsonEncode(settings);
    } catch (e) {
      _logger.e('Error exportando configuraciones: $e');
      return null;
    }
  }

  /// Importar configuraciones (desde backup)
  Future<bool> importSettings(String settingsJson) async {
    try {
      final settings = jsonDecode(settingsJson) as Map<String, dynamic>;

      // Validar configuraciones antes de importar
      for (final entry in settings.entries) {
        if (!validateSetting(entry.key, entry.value)) {
          _logger.w('Configuración inválida: ${entry.key} = ${entry.value}');
          return false;
        }
      }

      return await saveSettings(settings);
    } catch (e) {
      _logger.e('Error importando configuraciones: $e');
      return false;
    }
  }
}
