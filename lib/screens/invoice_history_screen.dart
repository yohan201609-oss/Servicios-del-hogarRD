import 'package:flutter/material.dart';
import '../models/invoice.dart';
import '../models/user_profile.dart';
import '../services/invoice_service.dart';
import 'invoice_detail_screen.dart';
import 'generate_invoice_demo_screen.dart';

class InvoiceHistoryScreen extends StatefulWidget {
  final Usuario usuario;

  const InvoiceHistoryScreen({super.key, required this.usuario});

  @override
  State<InvoiceHistoryScreen> createState() => _InvoiceHistoryScreenState();
}

class _InvoiceHistoryScreenState extends State<InvoiceHistoryScreen>
    with TickerProviderStateMixin {
  List<Factura> _facturas = [];
  Map<String, dynamic> _estadisticas = {};
  bool _isLoading = true;
  String _filtroEstado = 'Todas';
  String _busqueda = '';

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _cargarFacturas();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarFacturas() async {
    setState(() => _isLoading = true);

    try {
      final facturas = await InvoiceService.obtenerFacturasUsuario(
        widget.usuario.id,
      );
      final estadisticas = await InvoiceService.obtenerEstadisticasFacturas(
        widget.usuario.id,
      );

      setState(() {
        _facturas = facturas;
        _estadisticas = estadisticas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _mostrarError('Error cargando facturas: $e');
    }
  }

  List<Factura> _filtrarFacturas() {
    var facturasFiltradas = _facturas;

    // Filtrar por estado
    if (_filtroEstado != 'Todas') {
      final estado = EstadoFactura.values.firstWhere(
        (e) => e.displayName == _filtroEstado,
        orElse: () => EstadoFactura.pendiente,
      );
      facturasFiltradas = facturasFiltradas
          .where((f) => f.estado == estado)
          .toList();
    }

    // Filtrar por búsqueda
    if (_busqueda.isNotEmpty) {
      facturasFiltradas = facturasFiltradas
          .where(
            (f) =>
                f.numeroFactura.toLowerCase().contains(
                  _busqueda.toLowerCase(),
                ) ||
                f.items.any(
                  (item) => item.descripcion.toLowerCase().contains(
                    _busqueda.toLowerCase(),
                  ),
                ),
          )
          .toList();
    }

    return facturasFiltradas;
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }

  void _mostrarExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Facturas'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _cargarFacturas,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
          IconButton(
            onPressed: _mostrarDemoGeneracion,
            icon: const Icon(Icons.add),
            tooltip: 'Generar Factura Demo',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              icon: const Icon(Icons.list),
              text: 'Todas (${_facturas.length})',
            ),
            Tab(
              icon: const Icon(Icons.pending),
              text: 'Pendientes (${_estadisticas['facturasPendientes'] ?? 0})',
            ),
            Tab(
              icon: const Icon(Icons.check_circle),
              text: 'Pagadas (${_estadisticas['facturasPagadas'] ?? 0})',
            ),
            Tab(icon: const Icon(Icons.analytics), text: 'Estadísticas'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFacturasTab(),
                _buildFacturasPorEstado(EstadoFactura.pendiente),
                _buildFacturasPorEstado(EstadoFactura.pagada),
                _buildEstadisticasTab(),
              ],
            ),
    );
  }

  Widget _buildFacturasTab() {
    final facturasFiltradas = _filtrarFacturas();

    return Column(
      children: [
        _buildFiltrosYBusqueda(),
        Expanded(
          child: facturasFiltradas.isEmpty
              ? _buildEstadoVacio()
              : _buildListaFacturas(facturasFiltradas),
        ),
      ],
    );
  }

  Widget _buildFacturasPorEstado(EstadoFactura estado) {
    final facturasPorEstado = _facturas
        .where((f) => f.estado == estado)
        .toList();

    return Column(
      children: [
        _buildFiltrosYBusqueda(),
        Expanded(
          child: facturasPorEstado.isEmpty
              ? _buildEstadoVacioPorEstado(estado)
              : _buildListaFacturas(facturasPorEstado),
        ),
      ],
    );
  }

  Widget _buildFiltrosYBusqueda() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        children: [
          // Barra de búsqueda
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar por número de factura o descripción...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              setState(() {
                _busqueda = value;
              });
            },
          ),
          const SizedBox(height: 12),
          // Filtro por estado
          DropdownButtonFormField<String>(
            value: _filtroEstado,
            decoration: InputDecoration(
              labelText: 'Filtrar por estado',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            items: ['Todas', ...EstadoFactura.values.map((e) => e.displayName)]
                .map((String estado) {
                  return DropdownMenuItem<String>(
                    value: estado,
                    child: Text(estado),
                  );
                })
                .toList(),
            onChanged: (String? nuevoEstado) {
              setState(() {
                _filtroEstado = nuevoEstado ?? 'Todas';
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListaFacturas(List<Factura> facturas) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: facturas.length,
      itemBuilder: (context, index) {
        final factura = facturas[index];
        return _buildTarjetaFactura(factura);
      },
    );
  }

  Widget _buildTarjetaFactura(Factura factura) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _verDetalleFactura(factura),
        borderRadius: BorderRadius.circular(8),
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
                      color: factura.estado.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      factura.estado.icon,
                      color: factura.estado.color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          factura.numeroFactura,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          factura.resumenItems,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        if (factura.isVencida)
                          Text(
                            'VENCIDA (${factura.diasVencimiento} días)',
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${factura.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: factura.estado.color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          factura.estado.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    'Emitida: ${_formatearFecha(factura.fechaEmision)}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.schedule, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    'Vence: ${_formatearFecha(factura.fechaVencimiento)}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.usuario.tipoUsuario == TipoUsuario.cliente
                        ? 'Proveedor: ${_obtenerNombreUsuario(factura.proveedor)}'
                        : 'Cliente: ${_obtenerNombreUsuario(factura.cliente)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Row(
                    children: [
                      if (factura.estado == EstadoFactura.pendiente &&
                          widget.usuario.tipoUsuario == TipoUsuario.cliente)
                        TextButton.icon(
                          onPressed: () => _marcarComoPagada(factura),
                          icon: const Icon(Icons.payment, size: 16),
                          label: const Text('Pagar'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                          ),
                        ),
                      IconButton(
                        onPressed: () => _verDetalleFactura(factura),
                        icon: const Icon(Icons.visibility, size: 20),
                        tooltip: 'Ver detalles',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstadisticasTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTarjetaEstadistica(
            'Resumen General',
            [
              'Total de Facturas: ${_estadisticas['totalFacturas'] ?? 0}',
              'Facturas Pendientes: ${_estadisticas['facturasPendientes'] ?? 0}',
              'Facturas Pagadas: ${_estadisticas['facturasPagadas'] ?? 0}',
              'Facturas Canceladas: ${_estadisticas['facturasCanceladas'] ?? 0}',
              'Facturas Vencidas: ${_estadisticas['facturasVencidas'] ?? 0}',
            ],
            Icons.analytics,
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildTarjetaEstadistica(
            'Financiero',
            [
              'Total Ingresos: \$${(_estadisticas['totalIngresos'] ?? 0.0).toStringAsFixed(2)}',
              'Total Pendiente: \$${(_estadisticas['totalPendiente'] ?? 0.0).toStringAsFixed(2)}',
            ],
            Icons.attach_money,
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildTarjetaEstadistica(
            'Acciones',
            [
              'Enviar Recordatorios',
              'Exportar Historial',
              'Limpiar Facturas Antiguas',
            ],
            Icons.settings,
            Colors.orange,
            esAcciones: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTarjetaEstadistica(
    String titulo,
    List<String> items,
    IconData icono,
    Color color, {
    bool esAcciones = false,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icono, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: esAcciones
                    ? ListTile(
                        title: Text(item),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => _ejecutarAccion(item),
                      )
                    : Text(
                        item,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No hay facturas',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Las facturas aparecerán aquí cuando se generen',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoVacioPorEstado(EstadoFactura estado) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            estado.icon,
            size: 80,
            color: estado.color.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay facturas ${estado.displayName.toLowerCase()}',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // Métodos de utilidad
  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  String _obtenerNombreUsuario(Usuario usuario) {
    if (usuario.perfilCliente != null) {
      return '${usuario.perfilCliente!.nombre} ${usuario.perfilCliente!.apellido}';
    } else if (usuario.perfilProveedor != null) {
      return usuario.perfilProveedor!.nombreCompleto;
    }
    return usuario.email;
  }

  // Métodos de acción
  void _verDetalleFactura(Factura factura) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            InvoiceDetailScreen(factura: factura, usuario: widget.usuario),
      ),
    );
  }

  Future<void> _marcarComoPagada(Factura factura) async {
    final confirmado = await _mostrarConfirmacion(
      'Marcar como Pagada',
      '¿Estás seguro de que quieres marcar esta factura como pagada?',
    );

    if (confirmado == true) {
      final exitoso = await InvoiceService.marcarFacturaComoPagada(factura.id);
      if (exitoso) {
        _mostrarExito('Factura marcada como pagada');
        _cargarFacturas();
      } else {
        _mostrarError('Error marcando factura como pagada');
      }
    }
  }

  void _ejecutarAccion(String accion) {
    switch (accion) {
      case 'Enviar Recordatorios':
        _enviarRecordatorios();
        break;
      case 'Exportar Historial':
        _exportarHistorial();
        break;
      case 'Limpiar Facturas Antiguas':
        _limpiarFacturasAntiguas();
        break;
    }
  }

  Future<void> _enviarRecordatorios() async {
    final recordatoriosEnviados =
        await InvoiceService.enviarRecordatoriosPago();
    _mostrarExito('$recordatoriosEnviados recordatorios enviados');
  }

  void _exportarHistorial() {
    _mostrarExito('Función de exportación en desarrollo');
  }

  Future<void> _limpiarFacturasAntiguas() async {
    final confirmado = await _mostrarConfirmacion(
      'Limpiar Facturas Antiguas',
      '¿Estás seguro de que quieres eliminar facturas de más de 1 año? Esta acción no se puede deshacer.',
    );

    if (confirmado == true) {
      await InvoiceService.limpiarFacturasAntiguas();
      _mostrarExito('Facturas antiguas eliminadas');
      _cargarFacturas();
    }
  }

  void _mostrarDemoGeneracion() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) =>
                GenerateInvoiceDemoScreen(usuario: widget.usuario),
          ),
        )
        .then((_) {
          // Recargar facturas después de generar una nueva
          _cargarFacturas();
        });
  }

  Future<bool?> _mostrarConfirmacion(String titulo, String mensaje) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}
