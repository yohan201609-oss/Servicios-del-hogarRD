import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'environment.dart';

/// Configuración centralizada de Firebase para todos los entornos
class FirebaseConfig {
  /// Obtiene la configuración de Firebase según el entorno actual
  static FirebaseOptions get currentOptions => Environment.firebaseOptions;

  /// Obtiene el ID del proyecto actual
  static String get currentProjectId => Environment.firebaseProjectId;

  /// Verifica si la configuración es válida
  static bool get isValid {
    try {
      final options = currentOptions;
      return options.apiKey.isNotEmpty &&
          options.appId.isNotEmpty &&
          options.projectId.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene información de debug sobre la configuración actual
  static Map<String, dynamic> get debugInfo {
    return {
      'environment': Environment.isDevelopment
          ? 'development'
          : Environment.isStaging
          ? 'staging'
          : 'production',
      'projectId': currentProjectId,
      'isValid': isValid,
      'apiKey': currentOptions.apiKey.substring(0, 8) + '...',
      'appId': currentOptions.appId,
    };
  }

  /// Imprime información de debug en consola
  static void printDebugInfo() {
    print('🔥 Firebase Configuration:');
    print('  Environment: ${debugInfo['environment']}');
    print('  Project ID: ${debugInfo['projectId']}');
    print('  Valid: ${debugInfo['isValid']}');
    print('  API Key: ${debugInfo['apiKey']}');
    print('  App ID: ${debugInfo['appId']}');
  }
}
