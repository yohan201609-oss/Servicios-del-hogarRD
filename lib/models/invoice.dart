import 'package:flutter/material.dart';
import 'user_profile.dart';
import 'payment_method.dart';

enum EstadoFactura { pendiente, pagada, cancelada, reembolsada }

extension EstadoFacturaExtension on EstadoFactura {
  String get displayName {
    switch (this) {
      case EstadoFactura.pendiente:
        return 'Pendiente';
      case EstadoFactura.pagada:
        return 'Pagada';
      case EstadoFactura.cancelada:
        return 'Cancelada';
      case EstadoFactura.reembolsada:
        return 'Reembolsada';
    }
  }

  Color get color {
    switch (this) {
      case EstadoFactura.pendiente:
        return Colors.orange;
      case EstadoFactura.pagada:
        return Colors.green;
      case EstadoFactura.cancelada:
        return Colors.red;
      case EstadoFactura.reembolsada:
        return Colors.blue;
    }
  }

  IconData get icon {
    switch (this) {
      case EstadoFactura.pendiente:
        return Icons.pending;
      case EstadoFactura.pagada:
        return Icons.check_circle;
      case EstadoFactura.cancelada:
        return Icons.cancel;
      case EstadoFactura.reembolsada:
        return Icons.refresh;
    }
  }
}

class ItemFactura {
  final String id;
  final String descripcion;
  final int cantidad;
  final double precioUnitario;
  final double descuento; // En porcentaje (0-100)
  final String? notas;

  const ItemFactura({
    required this.id,
    required this.descripcion,
    required this.cantidad,
    required this.precioUnitario,
    this.descuento = 0.0,
    this.notas,
  });

  double get subtotal => cantidad * precioUnitario;
  double get montoDescuento => subtotal * (descuento / 100);
  double get total => subtotal - montoDescuento;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descripcion': descripcion,
      'cantidad': cantidad,
      'precioUnitario': precioUnitario,
      'descuento': descuento,
      'notas': notas,
    };
  }

  factory ItemFactura.fromJson(Map<String, dynamic> json) {
    return ItemFactura(
      id: json['id'],
      descripcion: json['descripcion'],
      cantidad: json['cantidad'],
      precioUnitario: json['precioUnitario'].toDouble(),
      descuento: json['descuento']?.toDouble() ?? 0.0,
      notas: json['notas'],
    );
  }
}

class Factura {
  final String id;
  final String numeroFactura;
  final Usuario cliente;
  final Usuario proveedor;
  final DateTime fechaEmision;
  final DateTime fechaVencimiento;
  final DateTime? fechaPago;
  final List<ItemFactura> items;
  final double subtotal;
  final double impuestos; // ITBIS o impuestos aplicables
  final double descuentos;
  final double total;
  final EstadoFactura estado;
  final MetodoPagoDetallado? metodoPago;
  final String? notas;
  final String? archivoPdf; // Ruta del archivo PDF generado
  final Map<String, dynamic>? datosAdicionales;

  const Factura({
    required this.id,
    required this.numeroFactura,
    required this.cliente,
    required this.proveedor,
    required this.fechaEmision,
    required this.fechaVencimiento,
    this.fechaPago,
    required this.items,
    required this.subtotal,
    required this.impuestos,
    required this.descuentos,
    required this.total,
    this.estado = EstadoFactura.pendiente,
    this.metodoPago,
    this.notas,
    this.archivoPdf,
    this.datosAdicionales,
  });

  Factura copyWith({
    String? id,
    String? numeroFactura,
    Usuario? cliente,
    Usuario? proveedor,
    DateTime? fechaEmision,
    DateTime? fechaVencimiento,
    DateTime? fechaPago,
    List<ItemFactura>? items,
    double? subtotal,
    double? impuestos,
    double? descuentos,
    double? total,
    EstadoFactura? estado,
    MetodoPagoDetallado? metodoPago,
    String? notas,
    String? archivoPdf,
    Map<String, dynamic>? datosAdicionales,
  }) {
    return Factura(
      id: id ?? this.id,
      numeroFactura: numeroFactura ?? this.numeroFactura,
      cliente: cliente ?? this.cliente,
      proveedor: proveedor ?? this.proveedor,
      fechaEmision: fechaEmision ?? this.fechaEmision,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      fechaPago: fechaPago ?? this.fechaPago,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      impuestos: impuestos ?? this.impuestos,
      descuentos: descuentos ?? this.descuentos,
      total: total ?? this.total,
      estado: estado ?? this.estado,
      metodoPago: metodoPago ?? this.metodoPago,
      notas: notas ?? this.notas,
      archivoPdf: archivoPdf ?? this.archivoPdf,
      datosAdicionales: datosAdicionales ?? this.datosAdicionales,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numeroFactura': numeroFactura,
      'cliente': cliente.toJson(),
      'proveedor': proveedor.toJson(),
      'fechaEmision': fechaEmision.toIso8601String(),
      'fechaVencimiento': fechaVencimiento.toIso8601String(),
      'fechaPago': fechaPago?.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'impuestos': impuestos,
      'descuentos': descuentos,
      'total': total,
      'estado': estado.toString(),
      'metodoPago': metodoPago?.toJson(),
      'notas': notas,
      'archivoPdf': archivoPdf,
      'datosAdicionales': datosAdicionales,
    };
  }

  factory Factura.fromJson(Map<String, dynamic> json) {
    return Factura(
      id: json['id'],
      numeroFactura: json['numeroFactura'],
      cliente: Usuario.fromJson(json['cliente']),
      proveedor: Usuario.fromJson(json['proveedor']),
      fechaEmision: DateTime.parse(json['fechaEmision']),
      fechaVencimiento: DateTime.parse(json['fechaVencimiento']),
      fechaPago: json['fechaPago'] != null
          ? DateTime.parse(json['fechaPago'])
          : null,
      items: (json['items'] as List)
          .map((item) => ItemFactura.fromJson(item))
          .toList(),
      subtotal: json['subtotal'].toDouble(),
      impuestos: json['impuestos'].toDouble(),
      descuentos: json['descuentos'].toDouble(),
      total: json['total'].toDouble(),
      estado: EstadoFactura.values.firstWhere(
        (e) => e.toString() == json['estado'],
        orElse: () => EstadoFactura.pendiente,
      ),
      metodoPago: json['metodoPago'] != null
          ? MetodoPagoDetallado.fromJson(json['metodoPago'])
          : null,
      notas: json['notas'],
      archivoPdf: json['archivoPdf'],
      datosAdicionales: json['datosAdicionales'] != null
          ? Map<String, dynamic>.from(json['datosAdicionales'])
          : null,
    );
  }

  // Métodos de utilidad
  bool get isVencida =>
      estado == EstadoFactura.pendiente &&
      DateTime.now().isAfter(fechaVencimiento);

  bool get isPagada => estado == EstadoFactura.pagada;

  int get diasVencimiento {
    if (isPagada) return 0;
    return DateTime.now().difference(fechaVencimiento).inDays;
  }

  String get resumenItems {
    if (items.isEmpty) return 'Sin items';
    if (items.length == 1) return items.first.descripcion;
    return '${items.length} items';
  }
}

// Clase para generar números de factura
class GeneradorNumeroFactura {
  static String generarNumeroFactura(String prefijo) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return '$prefijo-$timestamp-$random';
  }
}
