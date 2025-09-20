import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class LocalizationService extends ChangeNotifier {
  final _logger = Logger();
  static const String _languageKey = 'selected_language';

  // Singleton pattern
  static LocalizationService? _instance;
  static LocalizationService get instance {
    _instance ??= LocalizationService._internal();
    return _instance!;
  }

  LocalizationService._internal();

  Locale _currentLocale = const Locale('es', '');

  Locale get currentLocale => _currentLocale;

  String get currentLanguageCode => _currentLocale.languageCode;

  Future<void> loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey);

      if (savedLanguage != null && ['es', 'en'].contains(savedLanguage)) {
        _currentLocale = Locale(savedLanguage);
        _logger.i('Loaded saved language: $savedLanguage');
      } else {
        // Use system locale if available, otherwise default to Spanish
        final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
        if (systemLocale.languageCode == 'en') {
          _currentLocale = const Locale('en');
        } else {
          _currentLocale = const Locale('es');
        }
        _logger.i('Using system locale: ${_currentLocale.languageCode}');
      }
    } catch (e) {
      _logger.e('Error loading saved language: $e');
      _currentLocale = const Locale('es');
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    if (_currentLocale.languageCode == languageCode) return;

    // Solo permitir idiomas soportados
    if (!['es', 'en'].contains(languageCode)) {
      _logger.w(
        'Unsupported language code: $languageCode, falling back to Spanish',
      );
      languageCode = 'es';
    }

    try {
      _currentLocale = Locale(languageCode);
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);

      _logger.i('Language changed to: $languageCode');
    } catch (e) {
      _logger.e('Error changing language: $e');
    }
  }

  bool isSpanish() => _currentLocale.languageCode == 'es';
  bool isEnglish() => _currentLocale.languageCode == 'en';

  String getLanguageName(String code) {
    switch (code) {
      case 'es':
        return 'Español';
      case 'en':
        return 'English';
      default:
        return 'Español';
    }
  }

  String getRegionName(String code) {
    switch (code) {
      case 'DO':
        return 'República Dominicana';
      case 'US':
        return 'Estados Unidos';
      case 'MX':
        return 'México';
      case 'ES':
        return 'España';
      case 'FR':
        return 'Francia';
      case 'BR':
        return 'Brasil';
      case 'IT':
        return 'Italia';
      case 'DE':
        return 'Alemania';
      case 'CN':
        return 'China';
      case 'JP':
        return 'Japón';
      case 'KR':
        return 'Corea del Sur';
      case 'AE':
        return 'Emiratos Árabes Unidos';
      case 'RU':
        return 'Rusia';
      case 'IN':
        return 'India';
      default:
        return 'República Dominicana';
    }
  }

  String getCurrencyName(String code) {
    switch (code) {
      case 'DOP':
        return 'Peso Dominicano (DOP)';
      case 'USD':
        return 'Dólar Americano (USD)';
      case 'MXN':
        return 'Peso Mexicano (MXN)';
      case 'EUR':
        return 'Euro (EUR)';
      case 'BRL':
        return 'Real Brasileño (BRL)';
      case 'CNY':
        return 'Yuan Chino (CNY)';
      case 'JPY':
        return 'Yen Japonés (JPY)';
      case 'KRW':
        return 'Won Coreano (KRW)';
      case 'AED':
        return 'Dirham de los Emiratos (AED)';
      case 'RUB':
        return 'Rublo Ruso (RUB)';
      case 'INR':
        return 'Rupia India (INR)';
      default:
        return 'Peso Dominicano (DOP)';
    }
  }
}
