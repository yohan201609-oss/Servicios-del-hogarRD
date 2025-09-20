import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../models/service_request.dart';
import '../models/user_profile.dart';
import '../models/invoice.dart';
import 'invoice_service.dart';

class ServiceRequestService {
  static const String _key = 'service_requests';
  static final ServiceRequestService _instance =
      ServiceRequestService._internal();
  static ServiceRequestService get instance => _instance;

  final Logger _logger = Logger();
  List<SolicitudServicio> _solicitudes = [];

  ServiceRequestService._internal();

  // Inicializar el servicio
  Future<void> initialize() async {
    await _loadSolicitudes();
    _logger.i(
      'ServiceRequestService initialized with ${_solicitudes.length} requests',
    );
  }

  // Cargar solicitudes desde SharedPreferences
  Future<void> _loadSolicitudes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final solicitudesJson = prefs.getStringList(_key) ?? [];

      _solicitudes = solicitudesJson
          .map((json) => SolicitudServicio.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      _logger.e('Error loading service requests: $e');
      _solicitudes = [];
    }
  }

  // Guardar solicitudes en SharedPreferences
  Future<void> _saveSolicitudes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final solicitudesJson = _solicitudes
          .map((solicitud) => jsonEncode(solicitud.toJson()))
          .toList();

      await prefs.setStringList(_key, solicitudesJson);
    } catch (e) {
      _logger.e('Error saving service requests: $e');
    }
  }

  // Crear nueva solicitud de servicio
  Future<SolicitudServicio> crearSolicitud({
    required String clienteId,
    required String proveedorId,
    required TipoServicio tipoServicio,
    required String descripcion,
    required String direccion,
    required double costoEstimado,
    DateTime? fechaProgramada,
  }) async {
    final solicitud = SolicitudServicio(
      id: _generateId(),
      clienteId: clienteId,
      proveedorId: proveedorId,
      tipoServicio: tipoServicio,
      descripcion: descripcion,
      direccion: direccion,
      fechaSolicitud: DateTime.now(),
      fechaProgramada: fechaProgramada,
      costoEstimado: costoEstimado,
    );

    _solicitudes.add(solicitud);
    await _saveSolicitudes();

    _logger.i('Nueva solicitud creada: ${solicitud.id}');
    return solicitud;
  }

  // Obtener solicitudes por cliente
  List<SolicitudServicio> getSolicitudesPorCliente(String clienteId) {
    return _solicitudes.where((s) => s.clienteId == clienteId).toList();
  }

  // Obtener solicitudes por proveedor
  List<SolicitudServicio> getSolicitudesPorProveedor(String proveedorId) {
    return _solicitudes.where((s) => s.proveedorId == proveedorId).toList();
  }

  // Obtener solicitud por ID
  SolicitudServicio? getSolicitudPorId(String id) {
    try {
      return _solicitudes.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  // Confirmar solicitud (proveedor acepta)
  Future<bool> confirmarSolicitud(String solicitudId) async {
    final solicitud = getSolicitudPorId(solicitudId);
    if (solicitud == null || solicitud.estado != EstadoSolicitud.pendiente) {
      return false;
    }

    final solicitudActualizada = solicitud.copyWith(
      estado: EstadoSolicitud.confirmada,
    );

    await _actualizarSolicitud(solicitudActualizada);
    _logger.i('Solicitud confirmada: $solicitudId');
    return true;
  }

  // Iniciar servicio
  Future<bool> iniciarServicio(String solicitudId) async {
    final solicitud = getSolicitudPorId(solicitudId);
    if (solicitud == null || solicitud.estado != EstadoSolicitud.confirmada) {
      return false;
    }

    final solicitudActualizada = solicitud.copyWith(
      estado: EstadoSolicitud.enProgreso,
      fechaInicio: DateTime.now(),
    );

    await _actualizarSolicitud(solicitudActualizada);
    _logger.i('Servicio iniciado: $solicitudId');
    return true;
  }

  // Completar servicio (esto disparará la generación automática de factura)
  Future<bool> completarServicio({
    required String solicitudId,
    required double costoFinal,
    String? observacionesProveedor,
    List<String>? fotosDespues,
  }) async {
    final solicitud = getSolicitudPorId(solicitudId);
    if (solicitud == null || !solicitud.puedeCompletar) {
      return false;
    }

    final solicitudActualizada = solicitud.copyWith(
      estado: EstadoSolicitud.completada,
      fechaCompletado: DateTime.now(),
      costoFinal: costoFinal,
      observacionesProveedor: observacionesProveedor,
      fotosDespues: fotosDespues ?? solicitud.fotosDespues,
    );

    await _actualizarSolicitud(solicitudActualizada);
    _logger.i('Servicio completado: $solicitudId');

    // Generar factura automáticamente
    await _generarFacturaAutomatica(solicitudActualizada);

    return true;
  }

  // Cancelar solicitud
  Future<bool> cancelarSolicitud(String solicitudId, {String? motivo}) async {
    final solicitud = getSolicitudPorId(solicitudId);
    if (solicitud == null ||
        solicitud.estado.isCompleted ||
        solicitud.estado.isCancelled) {
      return false;
    }

    final solicitudActualizada = solicitud.copyWith(
      estado: EstadoSolicitud.cancelada,
      observacionesProveedor: motivo ?? solicitud.observacionesProveedor,
    );

    await _actualizarSolicitud(solicitudActualizada);
    _logger.i('Solicitud cancelada: $solicitudId');
    return true;
  }

  // Actualizar solicitud en la lista
  Future<void> _actualizarSolicitud(
    SolicitudServicio solicitudActualizada,
  ) async {
    final index = _solicitudes.indexWhere(
      (s) => s.id == solicitudActualizada.id,
    );
    if (index != -1) {
      _solicitudes[index] = solicitudActualizada;
      await _saveSolicitudes();
    }
  }

  // Generar factura automáticamente cuando se completa un servicio
  Future<void> _generarFacturaAutomatica(SolicitudServicio solicitud) async {
    try {
      _logger.i('Generando factura automática para servicio: ${solicitud.id}');

      // Crear usuarios simulados (en una app real, estos vendrían de la base de datos)
      final cliente = _crearUsuarioCliente(solicitud.clienteId);
      final proveedor = _crearUsuarioProveedor(solicitud.proveedorId);

      // Crear items de la factura basados en el servicio
      final items = [
        ItemFactura(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          descripcion: solicitud.tipoServicio.displayName,
          cantidad: 1,
          precioUnitario: solicitud.costoFinal ?? solicitud.costoEstimado,
          descuento: 0.0,
        ),
      ];

      // Generar la factura
      final factura = await InvoiceService.generarFactura(
        cliente: cliente,
        proveedor: proveedor,
        items: items,
        notas:
            solicitud.observacionesProveedor ??
            'Servicio completado exitosamente',
        diasVencimiento: 30,
      );

      if (factura != null) {
        // Actualizar la solicitud con el ID de la factura
        final solicitudFacturada = solicitud.copyWith(
          estado: EstadoSolicitud.facturada,
          facturaId: factura.id,
        );

        await _actualizarSolicitud(solicitudFacturada);

        _logger.i(
          'Factura ${factura.numeroFactura} generada automáticamente para servicio ${solicitud.id}',
        );
      }
    } catch (e) {
      _logger.e('Error generando factura automática: $e');
    }
  }

  // Crear usuario cliente simulado (en producción vendría de la base de datos)
  Usuario _crearUsuarioCliente(String clienteId) {
    return Usuario(
      id: clienteId,
      email: 'cliente@ejemplo.com',
      tipoUsuario: TipoUsuario.cliente,
      password: 'password',
      fechaCreacion: DateTime.now(),
      perfilCliente: PerfilCliente(
        usuarioId: clienteId,
        nombre: 'Cliente',
        apellido: 'Ejemplo',
        telefono: '809-123-4567',
        direccionPrincipal: 'Dirección del Cliente',
        metodosPago: [MetodoPago.tarjeta],
        preferencias: PreferenciasCliente(tiposServiciosFrecuentes: []),
      ),
    );
  }

  // Crear usuario proveedor simulado (en producción vendría de la base de datos)
  Usuario _crearUsuarioProveedor(String proveedorId) {
    return Usuario(
      id: proveedorId,
      email: 'proveedor@ejemplo.com',
      tipoUsuario: TipoUsuario.proveedor,
      password: 'password',
      fechaCreacion: DateTime.now(),
      perfilProveedor: PerfilProveedor(
        usuarioId: proveedorId,
        nombreCompleto: 'Proveedor Ejemplo',
        cedulaRnc: '12345678901',
        categoriasServicios: [TipoServicio.limpieza],
        experiencia: '5 años',
        descripcion: 'Servicios profesionales',
        portafolioFotos: [],
        disponibilidad: DisponibilidadProveedor(
          diasDisponibles: [
            'Lunes',
            'Martes',
            'Miércoles',
            'Jueves',
            'Viernes',
          ],
          horarioInicio: '08:00',
          horarioFin: '18:00',
          serviciosEmergencia: true,
          areasCobertura: ['Santo Domingo'],
        ),
        ubicacionBase: 'Santo Domingo',
        certificaciones: [],
        licencias: [],
        tieneSeguro: true,
        metodosCobro: [MetodoPago.tarjeta, MetodoPago.efectivo],
        valoracionPromedio: 4.5,
        resenas: [],
        totalServicios: 100,
      ),
    );
  }

  // Generar ID único
  String _generateId() {
    return 'SR-${DateTime.now().millisecondsSinceEpoch}-${_solicitudes.length + 1}';
  }

  // Obtener estadísticas
  Map<String, int> getEstadisticasPorProveedor(String proveedorId) {
    final solicitudesProveedor = getSolicitudesPorProveedor(proveedorId);

    return {
      'total': solicitudesProveedor.length,
      'pendientes': solicitudesProveedor
          .where((s) => s.estado == EstadoSolicitud.pendiente)
          .length,
      'confirmadas': solicitudesProveedor
          .where((s) => s.estado == EstadoSolicitud.confirmada)
          .length,
      'enProgreso': solicitudesProveedor
          .where((s) => s.estado == EstadoSolicitud.enProgreso)
          .length,
      'completadas': solicitudesProveedor
          .where((s) => s.estado == EstadoSolicitud.completada)
          .length,
      'facturadas': solicitudesProveedor
          .where((s) => s.estado == EstadoSolicitud.facturada)
          .length,
      'canceladas': solicitudesProveedor
          .where((s) => s.estado == EstadoSolicitud.cancelada)
          .length,
    };
  }

  // Obtener ingresos totales por proveedor
  double getIngresosTotalesPorProveedor(String proveedorId) {
    final solicitudesProveedor = getSolicitudesPorProveedor(proveedorId);

    return solicitudesProveedor
        .where((s) => s.estado == EstadoSolicitud.facturada)
        .fold(0.0, (sum, s) => sum + (s.costoFinal ?? s.costoEstimado));
  }

  // Limpiar datos antiguos (opcional)
  Future<void> limpiarDatosAntiguos({int diasRetencion = 90}) async {
    final fechaLimite = DateTime.now().subtract(Duration(days: diasRetencion));

    _solicitudes.removeWhere((solicitud) {
      return solicitud.fechaSolicitud.isBefore(fechaLimite) &&
          (solicitud.estado == EstadoSolicitud.cancelada ||
              solicitud.estado == EstadoSolicitud.completada);
    });

    await _saveSolicitudes();
    _logger.i(
      'Datos antiguos limpiados. Solicitudes restantes: ${_solicitudes.length}',
    );
  }
}
