import 'user_profile.dart';

enum EstadoSolicitud {
  pendiente,
  confirmada,
  enProgreso,
  completada,
  cancelada,
  facturada,
}

extension EstadoSolicitudExtension on EstadoSolicitud {
  String get displayName {
    switch (this) {
      case EstadoSolicitud.pendiente:
        return 'Pendiente';
      case EstadoSolicitud.confirmada:
        return 'Confirmada';
      case EstadoSolicitud.enProgreso:
        return 'En Progreso';
      case EstadoSolicitud.completada:
        return 'Completada';
      case EstadoSolicitud.cancelada:
        return 'Cancelada';
      case EstadoSolicitud.facturada:
        return 'Facturada';
    }
  }

  bool get isCompleted => this == EstadoSolicitud.completada;
  bool get isCancelled => this == EstadoSolicitud.cancelada;
  bool get canBeInvoiced => this == EstadoSolicitud.completada;
  bool get isInvoiced => this == EstadoSolicitud.facturada;
}

class SolicitudServicio {
  final String id;
  final String clienteId;
  final String proveedorId;
  final TipoServicio tipoServicio;
  final String descripcion;
  final String direccion;
  final DateTime fechaSolicitud;
  final DateTime? fechaProgramada;
  final DateTime? fechaInicio;
  final DateTime? fechaCompletado;
  final EstadoSolicitud estado;
  final double costoEstimado;
  final double? costoFinal;
  final String? observacionesProveedor;
  final String? observacionesCliente;
  final List<String> fotosAntes;
  final List<String> fotosDespues;
  final String? facturaId; // Referencia a la factura generada
  final Map<String, dynamic> metadatos;

  SolicitudServicio({
    required this.id,
    required this.clienteId,
    required this.proveedorId,
    required this.tipoServicio,
    required this.descripcion,
    required this.direccion,
    required this.fechaSolicitud,
    this.fechaProgramada,
    this.fechaInicio,
    this.fechaCompletado,
    this.estado = EstadoSolicitud.pendiente,
    required this.costoEstimado,
    this.costoFinal,
    this.observacionesProveedor,
    this.observacionesCliente,
    this.fotosAntes = const [],
    this.fotosDespues = const [],
    this.facturaId,
    this.metadatos = const {},
  });

  factory SolicitudServicio.fromJson(Map<String, dynamic> json) {
    return SolicitudServicio(
      id: json['id'] ?? '',
      clienteId: json['clienteId'] ?? '',
      proveedorId: json['proveedorId'] ?? '',
      tipoServicio: TipoServicio.values.firstWhere(
        (e) => e.toString() == json['tipoServicio'],
        orElse: () => TipoServicio.limpieza,
      ),
      descripcion: json['descripcion'] ?? '',
      direccion: json['direccion'] ?? '',
      fechaSolicitud: DateTime.parse(
        json['fechaSolicitud'] ?? DateTime.now().toIso8601String(),
      ),
      fechaProgramada: json['fechaProgramada'] != null
          ? DateTime.parse(json['fechaProgramada'])
          : null,
      fechaInicio: json['fechaInicio'] != null
          ? DateTime.parse(json['fechaInicio'])
          : null,
      fechaCompletado: json['fechaCompletado'] != null
          ? DateTime.parse(json['fechaCompletado'])
          : null,
      estado: EstadoSolicitud.values.firstWhere(
        (e) => e.toString() == json['estado'],
        orElse: () => EstadoSolicitud.pendiente,
      ),
      costoEstimado: (json['costoEstimado'] ?? 0.0).toDouble(),
      costoFinal: json['costoFinal'] != null
          ? (json['costoFinal'] as num).toDouble()
          : null,
      observacionesProveedor: json['observacionesProveedor'],
      observacionesCliente: json['observacionesCliente'],
      fotosAntes: List<String>.from(json['fotosAntes'] ?? []),
      fotosDespues: List<String>.from(json['fotosDespues'] ?? []),
      facturaId: json['facturaId'],
      metadatos: Map<String, dynamic>.from(json['metadatos'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clienteId': clienteId,
      'proveedorId': proveedorId,
      'tipoServicio': tipoServicio.toString(),
      'descripcion': descripcion,
      'direccion': direccion,
      'fechaSolicitud': fechaSolicitud.toIso8601String(),
      'fechaProgramada': fechaProgramada?.toIso8601String(),
      'fechaInicio': fechaInicio?.toIso8601String(),
      'fechaCompletado': fechaCompletado?.toIso8601String(),
      'estado': estado.toString(),
      'costoEstimado': costoEstimado,
      'costoFinal': costoFinal,
      'observacionesProveedor': observacionesProveedor,
      'observacionesCliente': observacionesCliente,
      'fotosAntes': fotosAntes,
      'fotosDespues': fotosDespues,
      'facturaId': facturaId,
      'metadatos': metadatos,
    };
  }

  SolicitudServicio copyWith({
    String? id,
    String? clienteId,
    String? proveedorId,
    TipoServicio? tipoServicio,
    String? descripcion,
    String? direccion,
    DateTime? fechaSolicitud,
    DateTime? fechaProgramada,
    DateTime? fechaInicio,
    DateTime? fechaCompletado,
    EstadoSolicitud? estado,
    double? costoEstimado,
    double? costoFinal,
    String? observacionesProveedor,
    String? observacionesCliente,
    List<String>? fotosAntes,
    List<String>? fotosDespues,
    String? facturaId,
    Map<String, dynamic>? metadatos,
  }) {
    return SolicitudServicio(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      proveedorId: proveedorId ?? this.proveedorId,
      tipoServicio: tipoServicio ?? this.tipoServicio,
      descripcion: descripcion ?? this.descripcion,
      direccion: direccion ?? this.direccion,
      fechaSolicitud: fechaSolicitud ?? this.fechaSolicitud,
      fechaProgramada: fechaProgramada ?? this.fechaProgramada,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaCompletado: fechaCompletado ?? this.fechaCompletado,
      estado: estado ?? this.estado,
      costoEstimado: costoEstimado ?? this.costoEstimado,
      costoFinal: costoFinal ?? this.costoFinal,
      observacionesProveedor:
          observacionesProveedor ?? this.observacionesProveedor,
      observacionesCliente: observacionesCliente ?? this.observacionesCliente,
      fotosAntes: fotosAntes ?? this.fotosAntes,
      fotosDespues: fotosDespues ?? this.fotosDespues,
      facturaId: facturaId ?? this.facturaId,
      metadatos: metadatos ?? this.metadatos,
    );
  }

  // Métodos de utilidad
  Duration? get duracionServicio {
    if (fechaInicio == null || fechaCompletado == null) return null;
    return fechaCompletado!.difference(fechaInicio!);
  }

  String get duracionText {
    final duracion = duracionServicio;
    if (duracion == null) return 'No disponible';

    final horas = duracion.inHours;
    final minutos = duracion.inMinutes % 60;

    if (horas > 0) {
      return '${horas}h ${minutos}m';
    } else {
      return '${minutos}m';
    }
  }

  String get costoFinalText {
    return costoFinal != null
        ? '\$${costoFinal!.toStringAsFixed(2)}'
        : '\$${costoEstimado.toStringAsFixed(2)} (estimado)';
  }

  bool get puedeCompletar => estado == EstadoSolicitud.enProgreso;
  bool get puedeFacturar =>
      estado == EstadoSolicitud.completada && facturaId == null;
  bool get yaFacturada => facturaId != null;
}
