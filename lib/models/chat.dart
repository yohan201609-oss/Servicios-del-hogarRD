enum EstadoMensaje { enviado, entregado, leido, error }

extension EstadoMensajeExtension on EstadoMensaje {
  String get displayName {
    switch (this) {
      case EstadoMensaje.enviado:
        return 'Enviado';
      case EstadoMensaje.entregado:
        return 'Entregado';
      case EstadoMensaje.leido:
        return 'Leído';
      case EstadoMensaje.error:
        return 'Error';
    }
  }
}

enum TipoMensaje { texto, imagen, documento, audio, ubicacion }

extension TipoMensajeExtension on TipoMensaje {
  String get displayName {
    switch (this) {
      case TipoMensaje.texto:
        return 'Texto';
      case TipoMensaje.imagen:
        return 'Imagen';
      case TipoMensaje.documento:
        return 'Documento';
      case TipoMensaje.audio:
        return 'Audio';
      case TipoMensaje.ubicacion:
        return 'Ubicación';
    }
  }
}

class Mensaje {
  final String id;
  final String chatId;
  final String remitenteId;
  final String remitenteNombre;
  final String contenido;
  final TipoMensaje tipo;
  final DateTime fechaEnvio;
  final EstadoMensaje estado;
  final String? archivoUrl;
  final String? nombreArchivo;
  final Map<String, dynamic>? metadata;

  Mensaje({
    required this.id,
    required this.chatId,
    required this.remitenteId,
    required this.remitenteNombre,
    required this.contenido,
    required this.tipo,
    required this.fechaEnvio,
    required this.estado,
    this.archivoUrl,
    this.nombreArchivo,
    this.metadata,
  });

  factory Mensaje.fromJson(Map<String, dynamic> json) {
    return Mensaje(
      id: json['id'] as String,
      chatId: json['chatId'] as String,
      remitenteId: json['remitenteId'] as String,
      remitenteNombre: json['remitenteNombre'] as String,
      contenido: json['contenido'] as String,
      tipo: TipoMensaje.values.firstWhere(
        (e) => e.toString() == 'TipoMensaje.${json['tipo']}',
        orElse: () => TipoMensaje.texto,
      ),
      fechaEnvio: DateTime.parse(json['fechaEnvio'] as String),
      estado: EstadoMensaje.values.firstWhere(
        (e) => e.toString() == 'EstadoMensaje.${json['estado']}',
        orElse: () => EstadoMensaje.enviado,
      ),
      archivoUrl: json['archivoUrl'] as String?,
      nombreArchivo: json['nombreArchivo'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'remitenteId': remitenteId,
      'remitenteNombre': remitenteNombre,
      'contenido': contenido,
      'tipo': tipo.toString().split('.').last,
      'fechaEnvio': fechaEnvio.toIso8601String(),
      'estado': estado.toString().split('.').last,
      'archivoUrl': archivoUrl,
      'nombreArchivo': nombreArchivo,
      'metadata': metadata,
    };
  }

  Mensaje copyWith({
    String? id,
    String? chatId,
    String? remitenteId,
    String? remitenteNombre,
    String? contenido,
    TipoMensaje? tipo,
    DateTime? fechaEnvio,
    EstadoMensaje? estado,
    String? archivoUrl,
    String? nombreArchivo,
    Map<String, dynamic>? metadata,
  }) {
    return Mensaje(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      remitenteId: remitenteId ?? this.remitenteId,
      remitenteNombre: remitenteNombre ?? this.remitenteNombre,
      contenido: contenido ?? this.contenido,
      tipo: tipo ?? this.tipo,
      fechaEnvio: fechaEnvio ?? this.fechaEnvio,
      estado: estado ?? this.estado,
      archivoUrl: archivoUrl ?? this.archivoUrl,
      nombreArchivo: nombreArchivo ?? this.nombreArchivo,
      metadata: metadata ?? this.metadata,
    );
  }
}

class Chat {
  final String id;
  final String clienteId;
  final String clienteNombre;
  final String proveedorId;
  final String proveedorNombre;
  final String? servicioId;
  final String? tituloServicio;
  final DateTime fechaCreacion;
  final DateTime ultimaActividad;
  final Mensaje? ultimoMensaje;
  final bool clienteActivo;
  final bool proveedorActivo;
  final int mensajesNoLeidosCliente;
  final int mensajesNoLeidosProveedor;

  Chat({
    required this.id,
    required this.clienteId,
    required this.clienteNombre,
    required this.proveedorId,
    required this.proveedorNombre,
    this.servicioId,
    this.tituloServicio,
    required this.fechaCreacion,
    required this.ultimaActividad,
    this.ultimoMensaje,
    required this.clienteActivo,
    required this.proveedorActivo,
    required this.mensajesNoLeidosCliente,
    required this.mensajesNoLeidosProveedor,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'] as String,
      clienteId: json['clienteId'] as String,
      clienteNombre: json['clienteNombre'] as String,
      proveedorId: json['proveedorId'] as String,
      proveedorNombre: json['proveedorNombre'] as String,
      servicioId: json['servicioId'] as String?,
      tituloServicio: json['tituloServicio'] as String?,
      fechaCreacion: DateTime.parse(json['fechaCreacion'] as String),
      ultimaActividad: DateTime.parse(json['ultimaActividad'] as String),
      ultimoMensaje: json['ultimoMensaje'] != null
          ? Mensaje.fromJson(json['ultimoMensaje'] as Map<String, dynamic>)
          : null,
      clienteActivo: json['clienteActivo'] as bool,
      proveedorActivo: json['proveedorActivo'] as bool,
      mensajesNoLeidosCliente: json['mensajesNoLeidosCliente'] as int,
      mensajesNoLeidosProveedor: json['mensajesNoLeidosProveedor'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clienteId': clienteId,
      'clienteNombre': clienteNombre,
      'proveedorId': proveedorId,
      'proveedorNombre': proveedorNombre,
      'servicioId': servicioId,
      'tituloServicio': tituloServicio,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'ultimaActividad': ultimaActividad.toIso8601String(),
      'ultimoMensaje': ultimoMensaje?.toJson(),
      'clienteActivo': clienteActivo,
      'proveedorActivo': proveedorActivo,
      'mensajesNoLeidosCliente': mensajesNoLeidosCliente,
      'mensajesNoLeidosProveedor': mensajesNoLeidosProveedor,
    };
  }

  Chat copyWith({
    String? id,
    String? clienteId,
    String? clienteNombre,
    String? proveedorId,
    String? proveedorNombre,
    String? servicioId,
    String? tituloServicio,
    DateTime? fechaCreacion,
    DateTime? ultimaActividad,
    Mensaje? ultimoMensaje,
    bool? clienteActivo,
    bool? proveedorActivo,
    int? mensajesNoLeidosCliente,
    int? mensajesNoLeidosProveedor,
  }) {
    return Chat(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      clienteNombre: clienteNombre ?? this.clienteNombre,
      proveedorId: proveedorId ?? this.proveedorId,
      proveedorNombre: proveedorNombre ?? this.proveedorNombre,
      servicioId: servicioId ?? this.servicioId,
      tituloServicio: tituloServicio ?? this.tituloServicio,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      ultimaActividad: ultimaActividad ?? this.ultimaActividad,
      ultimoMensaje: ultimoMensaje ?? this.ultimoMensaje,
      clienteActivo: clienteActivo ?? this.clienteActivo,
      proveedorActivo: proveedorActivo ?? this.proveedorActivo,
      mensajesNoLeidosCliente:
          mensajesNoLeidosCliente ?? this.mensajesNoLeidosCliente,
      mensajesNoLeidosProveedor:
          mensajesNoLeidosProveedor ?? this.mensajesNoLeidosProveedor,
    );
  }

  // Helper methods
  String getNombreOponente(String usuarioId) {
    if (usuarioId == clienteId) {
      return proveedorNombre;
    } else {
      return clienteNombre;
    }
  }

  int getMensajesNoLeidos(String usuarioId) {
    if (usuarioId == clienteId) {
      return mensajesNoLeidosCliente;
    } else {
      return mensajesNoLeidosProveedor;
    }
  }

  bool getTieneMensajesNoLeidos(String usuarioId) {
    return getMensajesNoLeidos(usuarioId) > 0;
  }

  String getResumenMensaje() {
    if (ultimoMensaje == null) {
      return 'Sin mensajes';
    }

    switch (ultimoMensaje!.tipo) {
      case TipoMensaje.texto:
        return ultimoMensaje!.contenido;
      case TipoMensaje.imagen:
        return '📷 Imagen';
      case TipoMensaje.documento:
        return '📄 Documento';
      case TipoMensaje.audio:
        return '🎵 Audio';
      case TipoMensaje.ubicacion:
        return '📍 Ubicación';
    }
  }
}
