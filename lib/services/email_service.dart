import 'package:logger/logger.dart';
import '../models/invoice.dart';

class EmailService {
  static final _logger = Logger();

  // Simulación del servicio de email (en producción usarías un servicio real como SendGrid, AWS SES, etc.)
  static Future<bool> enviarFacturaPorEmail({
    required Factura factura,
    required String archivoPdf,
    String? emailPersonalizado,
  }) async {
    try {
      _logger.i(
        'Iniciando envío de factura ${factura.numeroFactura} por email',
      );

      // Obtener email del cliente
      final emailCliente = emailPersonalizado ?? factura.cliente.email;

      // Simular delay de envío
      await Future.delayed(const Duration(seconds: 2));

      // En un entorno real, aquí harías:
      // 1. Configurar el cliente SMTP
      // 2. Crear el mensaje HTML
      // 3. Adjuntar el PDF
      // 4. Enviar el email

      _logger.i('Factura enviada exitosamente a $emailCliente');

      // Simular éxito (90% de probabilidad)
      return DateTime.now().millisecondsSinceEpoch % 10 != 0;
    } catch (e) {
      _logger.e('Error enviando factura por email: $e');
      return false;
    }
  }

  // Método para enviar recordatorio de pago
  static Future<bool> enviarRecordatorioPago(Factura factura) async {
    try {
      _logger.i(
        'Enviando recordatorio de pago para factura ${factura.numeroFactura}',
      );

      // Simular delay
      await Future.delayed(const Duration(seconds: 1));

      _logger.i('Recordatorio enviado exitosamente');
      return true;
    } catch (e) {
      _logger.e('Error enviando recordatorio: $e');
      return false;
    }
  }

  // Método para enviar confirmación de pago
  static Future<bool> enviarConfirmacionPago(Factura factura) async {
    try {
      _logger.i(
        'Enviando confirmación de pago para factura ${factura.numeroFactura}',
      );

      // Simular delay
      await Future.delayed(const Duration(seconds: 1));

      _logger.i('Confirmación enviada exitosamente');
      return true;
    } catch (e) {
      _logger.e('Error enviando confirmación: $e');
      return false;
    }
  }
}

// Clase para manejar plantillas de email
class EmailTemplates {
  static String get plantillaFactura => '''
    Estimado/a {nombreCliente},
    
    Le adjuntamos la factura {numeroFactura} por el servicio realizado.
    
    Detalles:
    - Proveedor: {nombreProveedor}
    - Total: \${total}
    - Fecha: {fecha}
    
    Gracias por usar App Hogar.
  ''';

  static String get plantillaRecordatorio => '''
    Estimado/a {nombreCliente},
    
    Le recordamos que la factura {numeroFactura} vence el {fechaVencimiento}.
    
    Total pendiente: \${total}
    
    Por favor, realice el pago a la brevedad.
  ''';

  static String get plantillaConfirmacion => '''
    Estimado/a {nombreCliente},
    
    Hemos recibido su pago por la factura {numeroFactura}.
    
    Muchas gracias por su pago puntual.
  ''';
}

// Clase para simular configuración de email (en producción sería real)
class EmailConfig {
  static const String smtpServer = 'smtp.apphogar.com';
  static const int smtpPort = 587;
  static const String username = 'facturas@apphogar.com';
  static const String password = 'secure_password';
  static const bool useTLS = true;

  // Método para validar configuración
  static bool isConfigurado() {
    return smtpServer.isNotEmpty && username.isNotEmpty && password.isNotEmpty;
  }
}
