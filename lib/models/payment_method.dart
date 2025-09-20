import 'package:flutter/material.dart';

enum TipoMetodoPago {
  tarjetaCredito,
  tarjetaDebito,
  paypal,
  transferenciaBancaria,
  efectivo,
  billeteraDigital,
  applePay,
  googlePay,
  stripe,
  mercadoPago,
}

// Lista de bancos dominicanos y populares
class BancoInfo {
  final String codigo;
  final String nombre;
  final String? logo; // Para futuras implementaciones
  final String pais;

  const BancoInfo({
    required this.codigo,
    required this.nombre,
    this.logo,
    required this.pais,
  });

  @override
  String toString() => nombre;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BancoInfo &&
          runtimeType == other.runtimeType &&
          codigo == other.codigo;

  @override
  int get hashCode => codigo.hashCode;
}

class BancosRepository {
  static const List<BancoInfo> bancosDominicanos = [
    BancoInfo(codigo: 'BPD', nombre: 'Banco Popular Dominicano', pais: 'RD'),
    BancoInfo(codigo: 'BHD', nombre: 'Banco BHD León', pais: 'RD'),
    BancoInfo(codigo: 'SCOTIABANK', nombre: 'Scotiabank', pais: 'RD'),
    BancoInfo(codigo: 'BANRESERVAS', nombre: 'Banco de Reservas', pais: 'RD'),
    BancoInfo(codigo: 'BANCOPROGRESO', nombre: 'Banco Progreso', pais: 'RD'),
    BancoInfo(codigo: 'SANTANDER', nombre: 'Banco Santander', pais: 'RD'),
    BancoInfo(codigo: 'CITIBANK', nombre: 'Citibank', pais: 'RD'),
    BancoInfo(codigo: 'BANCOLEON', nombre: 'Banco León', pais: 'RD'),
    BancoInfo(codigo: 'BANCOVIMENCA', nombre: 'Banco Vimenca', pais: 'RD'),
    BancoInfo(codigo: 'BANCOADEMI', nombre: 'Banco Ademi', pais: 'RD'),
    BancoInfo(codigo: 'BANCOADOPEM', nombre: 'Banco Adopem', pais: 'RD'),
    BancoInfo(codigo: 'BANCAMERICANO', nombre: 'Banco Americano', pais: 'RD'),
    BancoInfo(codigo: 'BANCOLOPEZ', nombre: 'Banco López de Haro', pais: 'RD'),
    BancoInfo(
      codigo: 'BANCOFONDOMICRO',
      nombre: 'Banco Fondomicro',
      pais: 'RD',
    ),
    BancoInfo(
      codigo: 'BANCOHIPOTECARIO',
      nombre: 'Banco Hipotecario Dominicano',
      pais: 'RD',
    ),
    BancoInfo(codigo: 'BANCOTRUST', nombre: 'Banco Trust', pais: 'RD'),
    BancoInfo(codigo: 'BANCOPPD', nombre: 'Banco Promerica', pais: 'RD'),
    BancoInfo(codigo: 'BANCOSTD', nombre: 'Banco Santa Cruz', pais: 'RD'),
  ];

  static const List<BancoInfo> bancosInternacionales = [
    BancoInfo(codigo: 'CHASE', nombre: 'JPMorgan Chase', pais: 'US'),
    BancoInfo(codigo: 'BANKOFAMERICA', nombre: 'Bank of America', pais: 'US'),
    BancoInfo(codigo: 'WELLSFARGO', nombre: 'Wells Fargo', pais: 'US'),
    BancoInfo(codigo: 'CITI', nombre: 'Citibank', pais: 'US'),
    BancoInfo(codigo: 'USBANK', nombre: 'U.S. Bank', pais: 'US'),
    BancoInfo(codigo: 'BBVA', nombre: 'BBVA', pais: 'ES'),
    BancoInfo(codigo: 'SANTANDER', nombre: 'Santander', pais: 'ES'),
    BancoInfo(codigo: 'HSBC', nombre: 'HSBC', pais: 'GB'),
    BancoInfo(codigo: 'DEUTSCHE', nombre: 'Deutsche Bank', pais: 'DE'),
    BancoInfo(codigo: 'BNP', nombre: 'BNP Paribas', pais: 'FR'),
    BancoInfo(codigo: 'CREDITSUISSE', nombre: 'Credit Suisse', pais: 'CH'),
    BancoInfo(codigo: 'UBS', nombre: 'UBS', pais: 'CH'),
  ];

  static List<BancoInfo> get todosLosBancos => [
    ...bancosDominicanos,
    ...bancosInternacionales,
  ];

  static List<BancoInfo> buscarBancos(String query) {
    if (query.isEmpty) return todosLosBancos;

    final queryLower = query.toLowerCase();
    return todosLosBancos
        .where(
          (banco) =>
              banco.nombre.toLowerCase().contains(queryLower) ||
              banco.codigo.toLowerCase().contains(queryLower),
        )
        .toList();
  }

  static BancoInfo? obtenerBancoPorCodigo(String codigo) {
    try {
      return todosLosBancos.firstWhere((banco) => banco.codigo == codigo);
    } catch (e) {
      return null;
    }
  }
}

class MetodoPagoDetallado {
  final String id;
  final TipoMetodoPago tipo;
  final String nombre;
  final String? numeroTarjeta; // Últimos 4 dígitos para tarjetas
  final String? banco; // Nombre del banco (para compatibilidad)
  final BancoInfo? bancoInfo; // Información detallada del banco
  final String? titular;
  final DateTime fechaAgregado;
  final bool esDefault;
  final bool activo;
  final Map<String, dynamic>?
  datosAdicionales; // Para datos específicos de cada plataforma

  MetodoPagoDetallado({
    required this.id,
    required this.tipo,
    required this.nombre,
    this.numeroTarjeta,
    this.banco,
    this.bancoInfo,
    this.titular,
    required this.fechaAgregado,
    this.esDefault = false,
    this.activo = true,
    this.datosAdicionales,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo.toString(),
      'nombre': nombre,
      'numeroTarjeta': numeroTarjeta,
      'banco': banco,
      'bancoInfo': bancoInfo?.codigo,
      'titular': titular,
      'fechaAgregado': fechaAgregado.toIso8601String(),
      'esDefault': esDefault,
      'activo': activo,
      'datosAdicionales': datosAdicionales,
    };
  }

  factory MetodoPagoDetallado.fromJson(Map<String, dynamic> json) {
    return MetodoPagoDetallado(
      id: json['id'],
      tipo: TipoMetodoPago.values.firstWhere(
        (e) => e.toString() == json['tipo'],
        orElse: () => TipoMetodoPago.efectivo,
      ),
      nombre: json['nombre'],
      numeroTarjeta: json['numeroTarjeta'],
      banco: json['banco'],
      bancoInfo: json['bancoInfo'] != null
          ? BancosRepository.obtenerBancoPorCodigo(json['bancoInfo'])
          : null,
      titular: json['titular'],
      fechaAgregado: DateTime.parse(json['fechaAgregado']),
      esDefault: json['esDefault'] ?? false,
      activo: json['activo'] ?? true,
      datosAdicionales: json['datosAdicionales'],
    );
  }

  MetodoPagoDetallado copyWith({
    String? id,
    TipoMetodoPago? tipo,
    String? nombre,
    String? numeroTarjeta,
    String? banco,
    BancoInfo? bancoInfo,
    String? titular,
    DateTime? fechaAgregado,
    bool? esDefault,
    bool? activo,
    Map<String, dynamic>? datosAdicionales,
  }) {
    return MetodoPagoDetallado(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      nombre: nombre ?? this.nombre,
      numeroTarjeta: numeroTarjeta ?? this.numeroTarjeta,
      banco: banco ?? this.banco,
      bancoInfo: bancoInfo ?? this.bancoInfo,
      titular: titular ?? this.titular,
      fechaAgregado: fechaAgregado ?? this.fechaAgregado,
      esDefault: esDefault ?? this.esDefault,
      activo: activo ?? this.activo,
      datosAdicionales: datosAdicionales ?? this.datosAdicionales,
    );
  }
}

// Extensiones para obtener información visual de los tipos de pago
extension TipoMetodoPagoExtension on TipoMetodoPago {
  String get displayName {
    switch (this) {
      case TipoMetodoPago.tarjetaCredito:
        return 'Tarjeta de Crédito';
      case TipoMetodoPago.tarjetaDebito:
        return 'Tarjeta de Débito';
      case TipoMetodoPago.paypal:
        return 'PayPal';
      case TipoMetodoPago.transferenciaBancaria:
        return 'Transferencia Bancaria';
      case TipoMetodoPago.efectivo:
        return 'Efectivo';
      case TipoMetodoPago.billeteraDigital:
        return 'Billetera Digital';
      case TipoMetodoPago.applePay:
        return 'Apple Pay';
      case TipoMetodoPago.googlePay:
        return 'Google Pay';
      case TipoMetodoPago.stripe:
        return 'Stripe';
      case TipoMetodoPago.mercadoPago:
        return 'MercadoPago';
    }
  }

  IconData get icon {
    switch (this) {
      case TipoMetodoPago.tarjetaCredito:
        return Icons.credit_card;
      case TipoMetodoPago.tarjetaDebito:
        return Icons.credit_card_outlined;
      case TipoMetodoPago.paypal:
        return Icons.account_balance_wallet;
      case TipoMetodoPago.transferenciaBancaria:
        return Icons.account_balance;
      case TipoMetodoPago.efectivo:
        return Icons.money;
      case TipoMetodoPago.billeteraDigital:
        return Icons.account_balance_wallet_outlined;
      case TipoMetodoPago.applePay:
        return Icons.phone_android;
      case TipoMetodoPago.googlePay:
        return Icons.payment;
      case TipoMetodoPago.stripe:
        return Icons.payment;
      case TipoMetodoPago.mercadoPago:
        return Icons.payment;
    }
  }

  Color get color {
    switch (this) {
      case TipoMetodoPago.tarjetaCredito:
        return Colors.blue;
      case TipoMetodoPago.tarjetaDebito:
        return Colors.indigo;
      case TipoMetodoPago.paypal:
        return const Color(0xFF0070BA);
      case TipoMetodoPago.transferenciaBancaria:
        return Colors.green;
      case TipoMetodoPago.efectivo:
        return Colors.orange;
      case TipoMetodoPago.billeteraDigital:
        return Colors.purple;
      case TipoMetodoPago.applePay:
        return Colors.black;
      case TipoMetodoPago.googlePay:
        return const Color(0xFF4285F4);
      case TipoMetodoPago.stripe:
        return const Color(0xFF635BFF);
      case TipoMetodoPago.mercadoPago:
        return const Color(0xFF00A1E0);
    }
  }

  String get description {
    switch (this) {
      case TipoMetodoPago.tarjetaCredito:
        return 'Agrega una tarjeta de crédito para pagos seguros';
      case TipoMetodoPago.tarjetaDebito:
        return 'Agrega una tarjeta de débito para pagos directos';
      case TipoMetodoPago.paypal:
        return 'Conecta tu cuenta de PayPal';
      case TipoMetodoPago.transferenciaBancaria:
        return 'Configura transferencias bancarias';
      case TipoMetodoPago.efectivo:
        return 'Pagos en efectivo al recibir el servicio';
      case TipoMetodoPago.billeteraDigital:
        return 'Agrega tu billetera digital';
      case TipoMetodoPago.applePay:
        return 'Usa Apple Pay para pagos rápidos';
      case TipoMetodoPago.googlePay:
        return 'Usa Google Pay para pagos rápidos';
      case TipoMetodoPago.stripe:
        return 'Configura pagos con Stripe';
      case TipoMetodoPago.mercadoPago:
        return 'Conecta tu cuenta de MercadoPago';
    }
  }

  bool get requiereConfiguracion {
    switch (this) {
      case TipoMetodoPago.efectivo:
        return false;
      default:
        return true;
    }
  }
}
