import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import '../firebase_options_dev.dart' as dev;
import '../firebase_options_staging.dart' as staging;
import '../firebase_options_prod.dart' as prod;

class Environment {
  static const String _environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  static bool get isDevelopment => _environment == 'development';
  static bool get isStaging => _environment == 'staging';
  static bool get isProduction => _environment == 'production';

  // URLs de API
  static String get apiUrl {
    switch (_environment) {
      case 'production':
        return 'https://api.servicioshogarrd.com';
      case 'staging':
        return 'https://staging-api.servicioshogarrd.com';
      default:
        return 'http://localhost:3000';
    }
  }

  // Configuraciones de Firebase
  static String get firebaseProjectId {
    switch (_environment) {
      case 'production':
        return 'servicios-hogar-rd-prod';
      case 'staging':
        return 'servicios-hogar-rd-staging';
      default:
        return 'servicios-hogar-rd-dev';
    }
  }

  // Configuración dinámica de Firebase basada en el entorno
  static FirebaseOptions get firebaseOptions {
    switch (_environment) {
      case 'production':
        return prod.DefaultFirebaseOptions.currentPlatform;
      case 'staging':
        return staging.DefaultFirebaseOptions.currentPlatform;
      default:
        return dev.DefaultFirebaseOptions.currentPlatform;
    }
  }
}
