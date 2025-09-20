import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../models/service_request.dart';
import '../models/user_profile.dart';
import '../services/service_request_service.dart';
import 'service_detail_screen.dart';

class ProviderServicesScreen extends StatefulWidget {
  final Usuario usuario;

  const ProviderServicesScreen({super.key, required this.usuario});

  @override
  State<ProviderServicesScreen> createState() => _ProviderServicesScreenState();
}

class _ProviderServicesScreenState extends State<ProviderServicesScreen>
    with SingleTickerProviderStateMixin {
  final Logger _logger = Logger();
  final ServiceRequestService _serviceRequestService =
      ServiceRequestService.instance;

  late TabController _tabController;
  List<SolicitudServicio> _solicitudes = [];
  Map<String, int> _estadisticas = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadSolicitudes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSolicitudes() async {
    setState(() => _isLoading = true);

    try {
      _solicitudes = _serviceRequestService.getSolicitudesPorProveedor(
        widget.usuario.id,
      );
      _estadisticas = _serviceRequestService.getEstadisticasPorProveedor(
        widget.usuario.id,
      );

      _logger.i(
        'Cargadas ${_solicitudes.length} solicitudes para proveedor ${widget.usuario.id}',
      );
    } catch (e) {
      _logger.e('Error cargando solicitudes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al cargar las solicitudes'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Servicios'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Activos', icon: Icon(Icons.work)),
            Tab(text: 'Pendientes', icon: Icon(Icons.pending)),
            Tab(text: 'Completados', icon: Icon(Icons.check_circle)),
            Tab(text: 'Estadísticas', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildActiveServicesTab(),
                _buildPendingServicesTab(),
                _buildCompletedServicesTab(),
                _buildStatisticsTab(),
              ],
            ),
    );
  }

  Widget _buildActiveServicesTab() {
    final serviciosActivos = _solicitudes
        .where(
          (s) =>
              s.estado == EstadoSolicitud.confirmada ||
              s.estado == EstadoSolicitud.enProgreso,
        )
        .toList();

    if (serviciosActivos.isEmpty) {
      return _buildEmptyState(
        icon: Icons.work_outline,
        title: 'No hay servicios activos',
        subtitle: 'Los servicios confirmados y en progreso aparecerán aquí',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSolicitudes,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: serviciosActivos.length,
        itemBuilder: (context, index) {
          final solicitud = serviciosActivos[index];
          return _buildServiceCard(solicitud);
        },
      ),
    );
  }

  Widget _buildPendingServicesTab() {
    final serviciosPendientes = _solicitudes
        .where((s) => s.estado == EstadoSolicitud.pendiente)
        .toList();

    if (serviciosPendientes.isEmpty) {
      return _buildEmptyState(
        icon: Icons.pending_outlined,
        title: 'No hay solicitudes pendientes',
        subtitle: 'Las nuevas solicitudes aparecerán aquí',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSolicitudes,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: serviciosPendientes.length,
        itemBuilder: (context, index) {
          final solicitud = serviciosPendientes[index];
          return _buildServiceCard(solicitud);
        },
      ),
    );
  }

  Widget _buildCompletedServicesTab() {
    final serviciosCompletados = _solicitudes
        .where(
          (s) =>
              s.estado == EstadoSolicitud.completada ||
              s.estado == EstadoSolicitud.facturada,
        )
        .toList();

    if (serviciosCompletados.isEmpty) {
      return _buildEmptyState(
        icon: Icons.check_circle_outline,
        title: 'No hay servicios completados',
        subtitle: 'Los servicios terminados aparecerán aquí',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSolicitudes,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: serviciosCompletados.length,
        itemBuilder: (context, index) {
          final solicitud = serviciosCompletados[index];
          return _buildServiceCard(solicitud);
        },
      ),
    );
  }

  Widget _buildStatisticsTab() {
    final ingresosTotales = _serviceRequestService
        .getIngresosTotalesPorProveedor(widget.usuario.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCard(
            'Ingresos Totales',
            '\$${ingresosTotales.toStringAsFixed(2)}',
            Icons.attach_money,
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            'Servicios Totales',
            '${_estadisticas['total'] ?? 0}',
            Icons.work,
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            'Servicios Completados',
            '${_estadisticas['completadas'] ?? 0}',
            Icons.check_circle,
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            'Servicios Facturados',
            '${_estadisticas['facturadas'] ?? 0}',
            Icons.receipt,
            Colors.orange,
          ),
          const SizedBox(height: 24),
          Text(
            'Resumen por Estado',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ..._estadisticas.entries.map((entry) {
            if (entry.key == 'total') return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_getEstadoDisplayName(entry.key)),
                  Text(
                    '${entry.value}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildServiceCard(SolicitudServicio solicitud) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: InkWell(
        onTap: () => _navigateToServiceDetail(solicitud),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getEstadoColor(
                        solicitud.estado,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      solicitud.tipoServicio.icon,
                      color: _getEstadoColor(solicitud.estado),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          solicitud.tipoServicio.displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          solicitud.descripcion,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _buildEstadoChip(solicitud.estado),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      solicitud.direccion,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(solicitud.fechaSolicitud),
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const Spacer(),
                  Text(
                    solicitud.costoFinalText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              if (solicitud.estado == EstadoSolicitud.pendiente) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _confirmarSolicitud(solicitud),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Confirmar'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _cancelarSolicitud(solicitud),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                  ],
                ),
              ] else if (solicitud.estado == EstadoSolicitud.confirmada) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _iniciarServicio(solicitud),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Iniciar Servicio'),
                  ),
                ),
              ] else if (solicitud.estado == EstadoSolicitud.enProgreso) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _completarServicio(solicitud),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Completar Servicio'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstadoChip(EstadoSolicitud estado) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getEstadoColor(estado).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getEstadoColor(estado)),
      ),
      child: Text(
        estado.displayName,
        style: TextStyle(
          color: _getEstadoColor(estado),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Acciones
  Future<void> _confirmarSolicitud(SolicitudServicio solicitud) async {
    try {
      await _serviceRequestService.confirmarSolicitud(solicitud.id);
      await _loadSolicitudes();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitud confirmada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _logger.e('Error confirmando solicitud: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al confirmar la solicitud'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cancelarSolicitud(SolicitudServicio solicitud) async {
    final motivo = await _showCancelDialog();
    if (motivo != null) {
      try {
        await _serviceRequestService.cancelarSolicitud(
          solicitud.id,
          motivo: motivo,
        );
        await _loadSolicitudes();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitud cancelada'),
            backgroundColor: Colors.orange,
          ),
        );
      } catch (e) {
        _logger.e('Error cancelando solicitud: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cancelar la solicitud'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _iniciarServicio(SolicitudServicio solicitud) async {
    try {
      await _serviceRequestService.iniciarServicio(solicitud.id);
      await _loadSolicitudes();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Servicio iniciado'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      _logger.e('Error iniciando servicio: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al iniciar el servicio'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _completarServicio(SolicitudServicio solicitud) async {
    final resultado = await _showCompleteDialog(solicitud);
    if (resultado != null) {
      try {
        await _serviceRequestService.completarServicio(
          solicitudId: solicitud.id,
          costoFinal: resultado['costoFinal'],
          observacionesProveedor: resultado['observaciones'],
        );
        await _loadSolicitudes();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Servicio completado y factura generada automáticamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        _logger.e('Error completando servicio: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al completar el servicio'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToServiceDetail(SolicitudServicio solicitud) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ServiceDetailScreen(solicitud: solicitud, usuario: widget.usuario),
      ),
    ).then((_) => _loadSolicitudes());
  }

  // Diálogos
  Future<String?> _showCancelDialog() async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Solicitud'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¿Estás seguro de que deseas cancelar esta solicitud?'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Motivo de cancelación (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>?> _showCompleteDialog(
    SolicitudServicio solicitud,
  ) async {
    final costoController = TextEditingController(
      text: (solicitud.costoFinal ?? solicitud.costoEstimado).toString(),
    );
    final observacionesController = TextEditingController();

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Completar Servicio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Completando servicio: ${solicitud.tipoServicio.displayName}'),
            const SizedBox(height: 16),
            TextField(
              controller: costoController,
              decoration: const InputDecoration(
                labelText: 'Costo Final',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: observacionesController,
              decoration: const InputDecoration(
                labelText: 'Observaciones (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Se generará automáticamente una factura al completar el servicio',
                      style: TextStyle(color: Colors.blue[700], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final costoFinal = double.tryParse(costoController.text);
              if (costoFinal != null && costoFinal > 0) {
                Navigator.pop(context, {
                  'costoFinal': costoFinal,
                  'observaciones': observacionesController.text,
                });
              }
            },
            child: const Text('Completar'),
          ),
        ],
      ),
    );
  }

  // Utilidades
  Color _getEstadoColor(EstadoSolicitud estado) {
    switch (estado) {
      case EstadoSolicitud.pendiente:
        return Colors.orange;
      case EstadoSolicitud.confirmada:
        return Colors.blue;
      case EstadoSolicitud.enProgreso:
        return Colors.purple;
      case EstadoSolicitud.completada:
        return Colors.green;
      case EstadoSolicitud.facturada:
        return Colors.teal;
      case EstadoSolicitud.cancelada:
        return Colors.red;
    }
  }

  String _getEstadoDisplayName(String key) {
    switch (key) {
      case 'pendientes':
        return 'Pendientes';
      case 'confirmadas':
        return 'Confirmadas';
      case 'enProgreso':
        return 'En Progreso';
      case 'completadas':
        return 'Completadas';
      case 'facturadas':
        return 'Facturadas';
      case 'canceladas':
        return 'Canceladas';
      default:
        return key;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
