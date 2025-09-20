import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import '../models/invoice.dart';
import '../models/user_profile.dart';

class PdfService {
  static Future<String> generarFacturaPdf(Factura factura) async {
    final pdf = pw.Document();

    // Configurar página
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(factura),
                pw.SizedBox(height: 30),
                _buildClientProviderInfo(factura),
                pw.SizedBox(height: 30),
                _buildItemsTable(factura),
                pw.SizedBox(height: 30),
                _buildTotals(factura),
                pw.SizedBox(height: 30),
                _buildFooter(factura),
              ],
            ),
          );
        },
      ),
    );

    // Guardar PDF según la plataforma
    if (kIsWeb) {
      // En web, solo devolvemos un identificador simulado
      // En una implementación real, podrías usar downloader_web o similar
      return 'web_factura_${factura.numeroFactura}.pdf';
    } else {
      // En móvil/desktop, guardamos en el sistema de archivos
      final directory = await getApplicationDocumentsDirectory();
      final invoicesDir = Directory(path.join(directory.path, 'invoices'));
      if (!await invoicesDir.exists()) {
        await invoicesDir.create(recursive: true);
      }

      final fileName = 'factura_${factura.numeroFactura}.pdf';
      final filePath = path.join(invoicesDir.path, fileName);
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      return filePath;
    }
  }

  static pw.Widget _buildHeader(Factura factura) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'FACTURA',
                style: pw.TextStyle(
                  fontSize: 32,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'N° ${factura.numeroFactura}',
                style: pw.TextStyle(fontSize: 16, color: PdfColors.grey700),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'App Hogar',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Servicios para el Hogar',
                style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Fecha: ${_formatDate(factura.fechaEmision)}',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                'Vence: ${_formatDate(factura.fechaVencimiento)}',
                style: pw.TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildClientProviderInfo(Factura factura) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'FACTURAR A:',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  _getUsuarioNombre(factura.cliente),
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                if (factura.cliente.perfilCliente != null) ...[
                  pw.Text(
                    'Tel: ${factura.cliente.perfilCliente!.telefono}',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Email: ${factura.cliente.email}',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Dir: ${factura.cliente.perfilCliente!.direccionPrincipal}',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ),
        pw.SizedBox(width: 20),
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'PROVEEDOR:',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  _getUsuarioNombre(factura.proveedor),
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                if (factura.proveedor.perfilProveedor != null) ...[
                  pw.Text(
                    'Proveedor registrado',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Email: ${factura.proveedor.email}',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildItemsTable(Factura factura) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          // Header de la tabla
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: const pw.BoxDecoration(color: PdfColors.grey100),
            child: pw.Row(
              children: [
                pw.Expanded(
                  flex: 3,
                  child: pw.Text(
                    'DESCRIPCIÓN',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Text(
                    'CANT.',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Text(
                    'PRECIO',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Text(
                    'DESC.',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Text(
                    'TOTAL',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12,
                    ),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          // Items
          ...factura.items.map(
            (item) => pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: const pw.Border(
                  top: pw.BorderSide(color: PdfColors.grey300),
                ),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          item.descripcion,
                          style: pw.TextStyle(fontSize: 12),
                        ),
                        if (item.notas != null) ...[
                          pw.SizedBox(height: 4),
                          pw.Text(
                            item.notas!,
                            style: pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text(
                      '${item.cantidad}',
                      style: pw.TextStyle(fontSize: 12),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text(
                      '\$${_formatCurrency(item.precioUnitario)}',
                      style: pw.TextStyle(fontSize: 12),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text(
                      item.descuento > 0
                          ? '${item.descuento.toStringAsFixed(0)}%'
                          : '-',
                      style: pw.TextStyle(fontSize: 12),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text(
                      '\$${_formatCurrency(item.total)}',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTotals(Factura factura) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Subtotal:', style: pw.TextStyle(fontSize: 14)),
              pw.Text(
                '\$${_formatCurrency(factura.subtotal)}',
                style: pw.TextStyle(fontSize: 14),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Descuentos:', style: pw.TextStyle(fontSize: 14)),
              pw.Text(
                '-\$${_formatCurrency(factura.descuentos)}',
                style: pw.TextStyle(fontSize: 14),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('ITBIS (18%):', style: pw.TextStyle(fontSize: 14)),
              pw.Text(
                '\$${_formatCurrency(factura.impuestos)}',
                style: pw.TextStyle(fontSize: 14),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Divider(color: PdfColors.grey400),
          pw.SizedBox(height: 12),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'TOTAL:',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  '\$${_formatCurrency(factura.total)}',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(Factura factura) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Estado: ${factura.estado.displayName}',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          if (factura.metodoPago != null) ...[
            pw.SizedBox(height: 8),
            pw.Text(
              'Método de Pago: ${factura.metodoPago!.nombre}',
              style: pw.TextStyle(fontSize: 12),
            ),
          ],
          if (factura.notas != null) ...[
            pw.SizedBox(height: 12),
            pw.Text(
              'Notas:',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(factura.notas!, style: pw.TextStyle(fontSize: 12)),
          ],
          pw.SizedBox(height: 20),
          pw.Text(
            'Gracias por usar App Hogar para sus servicios domésticos.',
            style: pw.TextStyle(
              fontSize: 12,
              fontStyle: pw.FontStyle.italic,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  // Métodos de utilidad
  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String _formatCurrency(double amount) {
    return amount.toStringAsFixed(2);
  }

  static String _getUsuarioNombre(Usuario usuario) {
    if (usuario.perfilCliente != null) {
      return '${usuario.perfilCliente!.nombre} ${usuario.perfilCliente!.apellido}';
    } else if (usuario.perfilProveedor != null) {
      return usuario.perfilProveedor!.nombreCompleto;
    }
    return usuario.email;
  }

  // Método para eliminar archivos PDF antiguos
  static Future<void> limpiarFacturasAntiguas({int diasRetencion = 30}) async {
    if (kIsWeb) {
      // En web no podemos limpiar archivos del sistema
      return;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final invoicesDir = Directory(path.join(directory.path, 'invoices'));

      if (await invoicesDir.exists()) {
        final cutoffDate = DateTime.now().subtract(
          Duration(days: diasRetencion),
        );

        await for (final entity in invoicesDir.list()) {
          if (entity is File) {
            final stat = await entity.stat();
            if (stat.modified.isBefore(cutoffDate)) {
              await entity.delete();
            }
          }
        }
      }
    } catch (e) {
      // Log error pero no fallar
      print('Error limpiando facturas antiguas: $e');
    }
  }
}
