import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../models/invoice.dart';
import '../models/user_profile.dart';
import '../models/payment_method.dart';
import 'pdf_service.dart';
import 'email_service.dart';

class InvoiceService {
  static final _logger = Logger();
  static const String _facturasKey = 'facturas_guardadas';

  // Generar y guardar una nueva factura
  static Future<Factura?> generarFactura({
    required Usuario cliente,
    required Usuario proveedor,
    required List<ItemFactura> items,
    String? notas,
    MetodoPagoDetallado? metodoPago,
    int diasVencimiento = 30,
  }) async {
    try {
      _logger.i('Generando nueva factura para cliente ${cliente.id}');

      // Calcular totales
      final subtotal = items.fold(0.0, (sum, item) => sum + item.subtotal);
      final descuentos = items.fold(
        0.0,
        (sum, item) => sum + item.montoDescuento,
      );
      final impuestos = (subtotal - descuentos) * 0.18; // 18% ITBIS
      final total = subtotal - descuentos + impuestos;

      // Crear factura
      final factura = Factura(
        id: _generateInvoiceId(),
        numeroFactura: GeneradorNumeroFactura.generarNumeroFactura('AH'),
        cliente: cliente,
        proveedor: proveedor,
        fechaEmision: DateTime.now(),
        fechaVencimiento: DateTime.now().add(Duration(days: diasVencimiento)),
        items: items,
        subtotal: subtotal,
        impuestos: impuestos,
        descuentos: descuentos,
        total: total,
        notas: notas,
        metodoPago: metodoPago,
      );

      // Generar PDF
      final pdfPath = await PdfService.generarFacturaPdf(factura);

      // Actualizar factura con ruta del PDF
      final facturaConPdf = factura.copyWith(archivoPdf: pdfPath);

      // Guardar factura
      await _guardarFactura(facturaConPdf);

      // Enviar por email
      final emailEnviado = await EmailService.enviarFacturaPorEmail(
        factura: facturaConPdf,
        archivoPdf: pdfPath,
      );

      if (emailEnviado) {
        _logger.i(
          'Factura ${factura.numeroFactura} generada y enviada exitosamente',
        );
      } else {
        _logger.w(
          'Factura ${factura.numeroFactura} generada pero no se pudo enviar por email',
        );
      }

      return facturaConPdf;
    } catch (e) {
      _logger.e('Error generando factura: $e');
      return null;
    }
  }

  // Obtener todas las facturas de un usuario
  static Future<List<Factura>> obtenerFacturasUsuario(String usuarioId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final facturasJson = prefs.getStringList(_facturasKey) ?? [];

      final facturas = facturasJson
          .map((json) => Factura.fromJson(jsonDecode(json)))
          .where(
            (factura) =>
                factura.cliente.id == usuarioId ||
                factura.proveedor.id == usuarioId,
          )
          .toList();

      // Ordenar por fecha de emisión (más recientes primero)
      facturas.sort((a, b) => b.fechaEmision.compareTo(a.fechaEmision));

      return facturas;
    } catch (e) {
      _logger.e('Error obteniendo facturas del usuario: $e');
      return [];
    }
  }

  // Obtener facturas por estado
  static Future<List<Factura>> obtenerFacturasPorEstado(
    String usuarioId,
    EstadoFactura estado,
  ) async {
    final facturas = await obtenerFacturasUsuario(usuarioId);
    return facturas.where((factura) => factura.estado == estado).toList();
  }

  // Marcar factura como pagada
  static Future<bool> marcarFacturaComoPagada(String facturaId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final facturasJson = prefs.getStringList(_facturasKey) ?? [];

      bool actualizada = false;
      final facturasActualizadas = facturasJson.map((json) {
        final factura = Factura.fromJson(jsonDecode(json));
        if (factura.id == facturaId) {
          actualizada = true;
          final facturaActualizada = factura.copyWith(
            estado: EstadoFactura.pagada,
            fechaPago: DateTime.now(),
          );

          // Enviar confirmación de pago
          EmailService.enviarConfirmacionPago(facturaActualizada);

          return jsonEncode(facturaActualizada.toJson());
        }
        return json;
      }).toList();

      if (actualizada) {
        await prefs.setStringList(_facturasKey, facturasActualizadas);
        _logger.i('Factura $facturaId marcada como pagada');
        return true;
      }

      return false;
    } catch (e) {
      _logger.e('Error marcando factura como pagada: $e');
      return false;
    }
  }

  // Cancelar factura
  static Future<bool> cancelarFactura(String facturaId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final facturasJson = prefs.getStringList(_facturasKey) ?? [];

      bool actualizada = false;
      final facturasActualizadas = facturasJson.map((json) {
        final factura = Factura.fromJson(jsonDecode(json));
        if (factura.id == facturaId) {
          actualizada = true;
          return jsonEncode(
            factura.copyWith(estado: EstadoFactura.cancelada).toJson(),
          );
        }
        return json;
      }).toList();

      if (actualizada) {
        await prefs.setStringList(_facturasKey, facturasActualizadas);
        _logger.i('Factura $facturaId cancelada');
        return true;
      }

      return false;
    } catch (e) {
      _logger.e('Error cancelando factura: $e');
      return false;
    }
  }

  // Obtener estadísticas de facturas
  static Future<Map<String, dynamic>> obtenerEstadisticasFacturas(
    String usuarioId,
  ) async {
    try {
      final facturas = await obtenerFacturasUsuario(usuarioId);

      final estadisticas = {
        'totalFacturas': facturas.length,
        'facturasPendientes': facturas
            .where((f) => f.estado == EstadoFactura.pendiente)
            .length,
        'facturasPagadas': facturas
            .where((f) => f.estado == EstadoFactura.pagada)
            .length,
        'facturasCanceladas': facturas
            .where((f) => f.estado == EstadoFactura.cancelada)
            .length,
        'totalIngresos': facturas
            .where((f) => f.estado == EstadoFactura.pagada)
            .fold(0.0, (sum, f) => sum + f.total),
        'totalPendiente': facturas
            .where((f) => f.estado == EstadoFactura.pendiente)
            .fold(0.0, (sum, f) => sum + f.total),
        'facturasVencidas': facturas.where((f) => f.isVencida).length,
      };

      return estadisticas;
    } catch (e) {
      _logger.e('Error obteniendo estadísticas: $e');
      return {};
    }
  }

  // Reenviar factura por email
  static Future<bool> reenviarFactura(
    String facturaId,
    String? emailPersonalizado,
  ) async {
    try {
      final factura = await _obtenerFacturaPorId(facturaId);
      if (factura == null || factura.archivoPdf == null) {
        return false;
      }

      final enviado = await EmailService.enviarFacturaPorEmail(
        factura: factura,
        archivoPdf: factura.archivoPdf!,
        emailPersonalizado: emailPersonalizado,
      );

      if (enviado) {
        _logger.i('Factura $facturaId reenviada exitosamente');
      }

      return enviado;
    } catch (e) {
      _logger.e('Error reenviando factura: $e');
      return false;
    }
  }

  // Enviar recordatorios de pago
  static Future<int> enviarRecordatoriosPago() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final facturasJson = prefs.getStringList(_facturasKey) ?? [];

      int recordatoriosEnviados = 0;
      final hoy = DateTime.now();

      for (final json in facturasJson) {
        final factura = Factura.fromJson(jsonDecode(json));

        // Enviar recordatorio si la factura vence en 3 días o está vencida
        if (factura.estado == EstadoFactura.pendiente) {
          final diasParaVencimiento = factura.fechaVencimiento
              .difference(hoy)
              .inDays;

          if (diasParaVencimiento <= 3) {
            final enviado = await EmailService.enviarRecordatorioPago(factura);
            if (enviado) {
              recordatoriosEnviados++;
            }
          }
        }
      }

      _logger.i('$recordatoriosEnviados recordatorios de pago enviados');
      return recordatoriosEnviados;
    } catch (e) {
      _logger.e('Error enviando recordatorios: $e');
      return 0;
    }
  }

  // Métodos privados
  static Future<void> _guardarFactura(Factura factura) async {
    final prefs = await SharedPreferences.getInstance();
    final facturasJson = prefs.getStringList(_facturasKey) ?? [];

    facturasJson.add(jsonEncode(factura.toJson()));
    await prefs.setStringList(_facturasKey, facturasJson);
  }

  static Future<Factura?> _obtenerFacturaPorId(String facturaId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final facturasJson = prefs.getStringList(_facturasKey) ?? [];

      for (final json in facturasJson) {
        final factura = Factura.fromJson(jsonDecode(json));
        if (factura.id == facturaId) {
          return factura;
        }
      }
      return null;
    } catch (e) {
      _logger.e('Error obteniendo factura por ID: $e');
      return null;
    }
  }

  static String _generateInvoiceId() {
    return 'inv_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  // Limpiar facturas antiguas (método de mantenimiento)
  static Future<void> limpiarFacturasAntiguas({int diasRetencion = 365}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final facturasJson = prefs.getStringList(_facturasKey) ?? [];

      final cutoffDate = DateTime.now().subtract(Duration(days: diasRetencion));
      final facturasActualizadas = <String>[];

      for (final json in facturasJson) {
        final factura = Factura.fromJson(jsonDecode(json));
        if (factura.fechaEmision.isAfter(cutoffDate)) {
          facturasActualizadas.add(json);
        }
      }

      await prefs.setStringList(_facturasKey, facturasActualizadas);

      // También limpiar archivos PDF antiguos
      await PdfService.limpiarFacturasAntiguas(diasRetencion: diasRetencion);

      _logger.i(
        'Facturas antiguas limpiadas (${facturasJson.length - facturasActualizadas.length} eliminadas)',
      );
    } catch (e) {
      _logger.e('Error limpiando facturas antiguas: $e');
    }
  }
}
