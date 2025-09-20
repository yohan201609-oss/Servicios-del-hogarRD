import 'package:flutter/material.dart';

enum TipoUsuario { cliente, proveedor, ambos }

enum UserType { cliente, proveedor }

class UserProfile {
  final String id;
  final String name;
  final String email;
  final UserType userType;
  final bool isProfileComplete;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.userType,
    this.isProfileComplete = false,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'userType': userType.name,
      'isProfileComplete': isProfileComplete,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      userType: UserType.values.firstWhere(
        (e) => e.name == map['userType'],
        orElse: () => UserType.cliente,
      ),
      isProfileComplete: map['isProfileComplete'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
    );
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    UserType? userType,
    bool? isProfileComplete,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum MetodoPago { tarjeta, transferencia, efectivo, billeteraDigital }

enum TipoServicio {
  plomeria,
  electricidad,
  limpieza,
  jardineria,
  pintura,
  carpinteria,
  aireAcondicionado,
  cerrajeria,
  albanileria,
  limpiezaPiscinas,
  seguridad,
  mudanzas,
}

class Usuario {
  final String id;
  final String email;
  final String password;
  final TipoUsuario tipoUsuario;
  final DateTime fechaCreacion;
  final bool activo;
  final PerfilCliente? perfilCliente;
  final PerfilProveedor? perfilProveedor;

  Usuario({
    required this.id,
    required this.email,
    required this.password,
    required this.tipoUsuario,
    required this.fechaCreacion,
    this.activo = true,
    this.perfilCliente,
    this.perfilProveedor,
  });

  Usuario copyWith({
    String? id,
    String? email,
    String? password,
    TipoUsuario? tipoUsuario,
    DateTime? fechaCreacion,
    bool? activo,
    PerfilCliente? perfilCliente,
    PerfilProveedor? perfilProveedor,
  }) {
    return Usuario(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      tipoUsuario: tipoUsuario ?? this.tipoUsuario,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      activo: activo ?? this.activo,
      perfilCliente: perfilCliente ?? this.perfilCliente,
      perfilProveedor: perfilProveedor ?? this.perfilProveedor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'tipoUsuario': tipoUsuario.toString(),
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'activo': activo,
      'perfilCliente': perfilCliente?.toJson(),
      'perfilProveedor': perfilProveedor?.toJson(),
    };
  }

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      email: json['email'],
      password: json['password'],
      tipoUsuario: TipoUsuario.values.firstWhere(
        (e) => e.toString() == json['tipoUsuario'],
      ),
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
      activo: json['activo'] ?? true,
      perfilCliente: json['perfilCliente'] != null
          ? PerfilCliente.fromJson(json['perfilCliente'])
          : null,
      perfilProveedor: json['perfilProveedor'] != null
          ? PerfilProveedor.fromJson(json['perfilProveedor'])
          : null,
    );
  }
}

class PerfilCliente {
  final String usuarioId;
  final String nombre;
  final String apellido;
  final String telefono;
  final String direccionPrincipal;
  final List<MetodoPago> metodosPago;
  final List<DireccionGuardada> direccionesGuardadas;
  final PreferenciasCliente preferencias;
  final List<HistorialServicio> historialServicios;
  final double valoracionPromedio;
  final List<ResenaCliente> resenas;

  PerfilCliente({
    required this.usuarioId,
    required this.nombre,
    required this.apellido,
    required this.telefono,
    required this.direccionPrincipal,
    this.metodosPago = const [],
    this.direccionesGuardadas = const [],
    required this.preferencias,
    this.historialServicios = const [],
    this.valoracionPromedio = 0.0,
    this.resenas = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'usuarioId': usuarioId,
      'nombre': nombre,
      'apellido': apellido,
      'telefono': telefono,
      'direccionPrincipal': direccionPrincipal,
      'metodosPago': metodosPago.map((e) => e.toString()).toList(),
      'direccionesGuardadas': direccionesGuardadas
          .map((e) => e.toJson())
          .toList(),
      'preferencias': preferencias.toJson(),
      'historialServicios': historialServicios.map((e) => e.toJson()).toList(),
      'valoracionPromedio': valoracionPromedio,
      'resenas': resenas.map((e) => e.toJson()).toList(),
    };
  }

  factory PerfilCliente.fromJson(Map<String, dynamic> json) {
    return PerfilCliente(
      usuarioId: json['usuarioId'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      telefono: json['telefono'],
      direccionPrincipal: json['direccionPrincipal'],
      metodosPago:
          (json['metodosPago'] as List<dynamic>?)
              ?.map(
                (e) => MetodoPago.values.firstWhere((mp) => mp.toString() == e),
              )
              .toList() ??
          [],
      direccionesGuardadas:
          (json['direccionesGuardadas'] as List<dynamic>?)
              ?.map((e) => DireccionGuardada.fromJson(e))
              .toList() ??
          [],
      preferencias: PreferenciasCliente.fromJson(json['preferencias']),
      historialServicios:
          (json['historialServicios'] as List<dynamic>?)
              ?.map((e) => HistorialServicio.fromJson(e))
              .toList() ??
          [],
      valoracionPromedio: json['valoracionPromedio']?.toDouble() ?? 0.0,
      resenas:
          (json['resenas'] as List<dynamic>?)
              ?.map((e) => ResenaCliente.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class PerfilProveedor {
  final String usuarioId;
  final String nombreCompleto;
  final String cedulaRnc;
  final List<TipoServicio> categoriasServicios;
  final String experiencia;
  final String descripcion;
  final List<String> portafolioFotos;
  final DisponibilidadProveedor disponibilidad;
  final String ubicacionBase;
  final List<String> certificaciones;
  final List<String> licencias;
  final bool tieneSeguro;
  final List<MetodoPago> metodosCobro;
  final double valoracionPromedio;
  final List<ResenaProveedor> resenas;
  final int totalServicios;

  PerfilProveedor({
    required this.usuarioId,
    required this.nombreCompleto,
    required this.cedulaRnc,
    required this.categoriasServicios,
    required this.experiencia,
    required this.descripcion,
    this.portafolioFotos = const [],
    required this.disponibilidad,
    required this.ubicacionBase,
    this.certificaciones = const [],
    this.licencias = const [],
    this.tieneSeguro = false,
    this.metodosCobro = const [],
    this.valoracionPromedio = 0.0,
    this.resenas = const [],
    this.totalServicios = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'usuarioId': usuarioId,
      'nombreCompleto': nombreCompleto,
      'cedulaRnc': cedulaRnc,
      'categoriasServicios': categoriasServicios
          .map((e) => e.toString())
          .toList(),
      'experiencia': experiencia,
      'descripcion': descripcion,
      'portafolioFotos': portafolioFotos,
      'disponibilidad': disponibilidad.toJson(),
      'ubicacionBase': ubicacionBase,
      'certificaciones': certificaciones,
      'licencias': licencias,
      'tieneSeguro': tieneSeguro,
      'metodosCobro': metodosCobro.map((e) => e.toString()).toList(),
      'valoracionPromedio': valoracionPromedio,
      'resenas': resenas.map((e) => e.toJson()).toList(),
      'totalServicios': totalServicios,
    };
  }

  factory PerfilProveedor.fromJson(Map<String, dynamic> json) {
    return PerfilProveedor(
      usuarioId: json['usuarioId'],
      nombreCompleto: json['nombreCompleto'],
      cedulaRnc: json['cedulaRnc'],
      categoriasServicios:
          (json['categoriasServicios'] as List<dynamic>?)
              ?.map(
                (e) =>
                    TipoServicio.values.firstWhere((ts) => ts.toString() == e),
              )
              .toList() ??
          [],
      experiencia: json['experiencia'],
      descripcion: json['descripcion'],
      portafolioFotos:
          (json['portafolioFotos'] as List<dynamic>?)?.cast<String>() ?? [],
      disponibilidad: DisponibilidadProveedor.fromJson(json['disponibilidad']),
      ubicacionBase: json['ubicacionBase'],
      certificaciones:
          (json['certificaciones'] as List<dynamic>?)?.cast<String>() ?? [],
      licencias: (json['licencias'] as List<dynamic>?)?.cast<String>() ?? [],
      tieneSeguro: json['tieneSeguro'] ?? false,
      metodosCobro:
          (json['metodosCobro'] as List<dynamic>?)
              ?.map(
                (e) => MetodoPago.values.firstWhere((mp) => mp.toString() == e),
              )
              .toList() ??
          [],
      valoracionPromedio: json['valoracionPromedio']?.toDouble() ?? 0.0,
      resenas:
          (json['resenas'] as List<dynamic>?)
              ?.map((e) => ResenaProveedor.fromJson(e))
              .toList() ??
          [],
      totalServicios: json['totalServicios'] ?? 0,
    );
  }
}

class DireccionGuardada {
  final String id;
  final String nombre;
  final String direccion;
  final String? referencia;

  DireccionGuardada({
    required this.id,
    required this.nombre,
    required this.direccion,
    this.referencia,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'direccion': direccion,
      'referencia': referencia,
    };
  }

  factory DireccionGuardada.fromJson(Map<String, dynamic> json) {
    return DireccionGuardada(
      id: json['id'],
      nombre: json['nombre'],
      direccion: json['direccion'],
      referencia: json['referencia'],
    );
  }
}

class PreferenciasCliente {
  final List<String> horariosDisponibles;
  final List<TipoServicio> tiposServiciosFrecuentes;
  final bool recibeNotificaciones;
  final String idioma;

  PreferenciasCliente({
    this.horariosDisponibles = const [],
    this.tiposServiciosFrecuentes = const [],
    this.recibeNotificaciones = true,
    this.idioma = 'es',
  });

  Map<String, dynamic> toJson() {
    return {
      'horariosDisponibles': horariosDisponibles,
      'tiposServiciosFrecuentes': tiposServiciosFrecuentes
          .map((e) => e.toString())
          .toList(),
      'recibeNotificaciones': recibeNotificaciones,
      'idioma': idioma,
    };
  }

  factory PreferenciasCliente.fromJson(Map<String, dynamic> json) {
    return PreferenciasCliente(
      horariosDisponibles:
          (json['horariosDisponibles'] as List<dynamic>?)?.cast<String>() ?? [],
      tiposServiciosFrecuentes:
          (json['tiposServiciosFrecuentes'] as List<dynamic>?)
              ?.map(
                (e) =>
                    TipoServicio.values.firstWhere((ts) => ts.toString() == e),
              )
              .toList() ??
          [],
      recibeNotificaciones: json['recibeNotificaciones'] ?? true,
      idioma: json['idioma'] ?? 'es',
    );
  }
}

class HistorialServicio {
  final String id;
  final String proveedorId;
  final TipoServicio tipoServicio;
  final DateTime fecha;
  final double costo;
  final String estado;
  final String? resena;
  final int valoracion;

  HistorialServicio({
    required this.id,
    required this.proveedorId,
    required this.tipoServicio,
    required this.fecha,
    required this.costo,
    required this.estado,
    this.resena,
    this.valoracion = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'proveedorId': proveedorId,
      'tipoServicio': tipoServicio.toString(),
      'fecha': fecha.toIso8601String(),
      'costo': costo,
      'estado': estado,
      'resena': resena,
      'valoracion': valoracion,
    };
  }

  factory HistorialServicio.fromJson(Map<String, dynamic> json) {
    return HistorialServicio(
      id: json['id'],
      proveedorId: json['proveedorId'],
      tipoServicio: TipoServicio.values.firstWhere(
        (e) => e.toString() == json['tipoServicio'],
      ),
      fecha: DateTime.parse(json['fecha']),
      costo: json['costo'].toDouble(),
      estado: json['estado'],
      resena: json['resena'],
      valoracion: json['valoracion'] ?? 0,
    );
  }
}

class ResenaCliente {
  final String id;
  final String proveedorId;
  final String comentario;
  final int valoracion;
  final DateTime fecha;

  ResenaCliente({
    required this.id,
    required this.proveedorId,
    required this.comentario,
    required this.valoracion,
    required this.fecha,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'proveedorId': proveedorId,
      'comentario': comentario,
      'valoracion': valoracion,
      'fecha': fecha.toIso8601String(),
    };
  }

  factory ResenaCliente.fromJson(Map<String, dynamic> json) {
    return ResenaCliente(
      id: json['id'],
      proveedorId: json['proveedorId'],
      comentario: json['comentario'],
      valoracion: json['valoracion'],
      fecha: DateTime.parse(json['fecha']),
    );
  }
}

class DisponibilidadProveedor {
  final List<String> diasDisponibles;
  final String horarioInicio;
  final String horarioFin;
  final bool serviciosEmergencia;
  final List<String> areasCobertura;

  DisponibilidadProveedor({
    this.diasDisponibles = const [],
    required this.horarioInicio,
    required this.horarioFin,
    this.serviciosEmergencia = false,
    this.areasCobertura = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'diasDisponibles': diasDisponibles,
      'horarioInicio': horarioInicio,
      'horarioFin': horarioFin,
      'serviciosEmergencia': serviciosEmergencia,
      'areasCobertura': areasCobertura,
    };
  }

  factory DisponibilidadProveedor.fromJson(Map<String, dynamic> json) {
    return DisponibilidadProveedor(
      diasDisponibles:
          (json['diasDisponibles'] as List<dynamic>?)?.cast<String>() ?? [],
      horarioInicio: json['horarioInicio'],
      horarioFin: json['horarioFin'],
      serviciosEmergencia: json['serviciosEmergencia'] ?? false,
      areasCobertura:
          (json['areasCobertura'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}

class ResenaProveedor {
  final String id;
  final String clienteId;
  final String clienteNombre;
  final String comentario;
  final int valoracion;
  final DateTime fecha;

  ResenaProveedor({
    required this.id,
    required this.clienteId,
    required this.clienteNombre,
    required this.comentario,
    required this.valoracion,
    required this.fecha,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clienteId': clienteId,
      'clienteNombre': clienteNombre,
      'comentario': comentario,
      'valoracion': valoracion,
      'fecha': fecha.toIso8601String(),
    };
  }

  factory ResenaProveedor.fromJson(Map<String, dynamic> json) {
    return ResenaProveedor(
      id: json['id'],
      clienteId: json['clienteId'],
      clienteNombre: json['clienteNombre'] ?? 'Cliente',
      comentario: json['comentario'],
      valoracion: json['valoracion'],
      fecha: DateTime.parse(json['fecha']),
    );
  }
}

// Extensiones para obtener texto legible de los enums
extension TipoUsuarioExtension on TipoUsuario {
  String get displayName {
    switch (this) {
      case TipoUsuario.cliente:
        return 'Cliente';
      case TipoUsuario.proveedor:
        return 'Proveedor';
      case TipoUsuario.ambos:
        return 'Cliente y Proveedor';
    }
  }

  IconData get icon {
    switch (this) {
      case TipoUsuario.cliente:
        return Icons.person;
      case TipoUsuario.proveedor:
        return Icons.build;
      case TipoUsuario.ambos:
        return Icons.supervisor_account;
    }
  }
}

extension TipoServicioExtension on TipoServicio {
  String get displayName {
    switch (this) {
      case TipoServicio.plomeria:
        return 'Plomería';
      case TipoServicio.electricidad:
        return 'Electricidad';
      case TipoServicio.limpieza:
        return 'Limpieza';
      case TipoServicio.jardineria:
        return 'Jardinería';
      case TipoServicio.pintura:
        return 'Pintura';
      case TipoServicio.carpinteria:
        return 'Carpintería';
      case TipoServicio.aireAcondicionado:
        return 'Aire Acondicionado';
      case TipoServicio.cerrajeria:
        return 'Cerrajería';
      case TipoServicio.albanileria:
        return 'Albañilería';
      case TipoServicio.limpiezaPiscinas:
        return 'Limpieza de Piscinas';
      case TipoServicio.seguridad:
        return 'Seguridad';
      case TipoServicio.mudanzas:
        return 'Mudanzas';
    }
  }

  IconData get icon {
    switch (this) {
      case TipoServicio.plomeria:
        return Icons.plumbing;
      case TipoServicio.electricidad:
        return Icons.electrical_services;
      case TipoServicio.limpieza:
        return Icons.cleaning_services;
      case TipoServicio.jardineria:
        return Icons.yard;
      case TipoServicio.pintura:
        return Icons.format_paint;
      case TipoServicio.carpinteria:
        return Icons.build;
      case TipoServicio.aireAcondicionado:
        return Icons.ac_unit;
      case TipoServicio.cerrajeria:
        return Icons.lock;
      case TipoServicio.albanileria:
        return Icons.construction;
      case TipoServicio.limpiezaPiscinas:
        return Icons.pool;
      case TipoServicio.seguridad:
        return Icons.security;
      case TipoServicio.mudanzas:
        return Icons.local_shipping;
    }
  }

  Color get color {
    switch (this) {
      case TipoServicio.plomeria:
        return Colors.blue;
      case TipoServicio.electricidad:
        return Colors.orange;
      case TipoServicio.limpieza:
        return Colors.green;
      case TipoServicio.jardineria:
        return Colors.brown;
      case TipoServicio.pintura:
        return Colors.purple;
      case TipoServicio.carpinteria:
        return Colors.amber;
      case TipoServicio.aireAcondicionado:
        return Colors.cyan;
      case TipoServicio.cerrajeria:
        return Colors.grey;
      case TipoServicio.albanileria:
        return Colors.deepOrange;
      case TipoServicio.limpiezaPiscinas:
        return Colors.lightBlue;
      case TipoServicio.seguridad:
        return Colors.red;
      case TipoServicio.mudanzas:
        return Colors.teal;
    }
  }
}

extension MetodoPagoExtension on MetodoPago {
  String get displayName {
    switch (this) {
      case MetodoPago.tarjeta:
        return 'Tarjeta';
      case MetodoPago.transferencia:
        return 'Transferencia';
      case MetodoPago.efectivo:
        return 'Efectivo';
      case MetodoPago.billeteraDigital:
        return 'Billetera Digital';
    }
  }

  IconData get icon {
    switch (this) {
      case MetodoPago.tarjeta:
        return Icons.credit_card;
      case MetodoPago.transferencia:
        return Icons.account_balance;
      case MetodoPago.efectivo:
        return Icons.money;
      case MetodoPago.billeteraDigital:
        return Icons.account_balance_wallet;
    }
  }
}
