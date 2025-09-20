import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../models/user_profile.dart';
import 'simple_login_screen.dart';
import 'simple_home_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class ProviderProfileScreen extends StatefulWidget {
  final Usuario usuario;

  const ProviderProfileScreen({super.key, required this.usuario});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final Logger _logger = Logger();

  // Datos del perfil
  late String _nombre;
  late String _descripcion;
  late List<TipoServicio> _categorias;
  late List<String> _fotosPortafolio;
  late List<ServicioOfrecido> _servicios;
  late DisponibilidadProveedor _disponibilidad;
  late List<Pedido> _pedidos;
  late List<ResenaProveedor> _resenas;
  late MetricasProveedor _metricas;
  late List<Certificacion> _certificaciones;
  late List<MetodoPago> _metodosCobro;
  late List<Transaccion> _historialPagos;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _initializeData();
  }

  void _initializeData() {
    _nombre = widget.usuario.perfilProveedor?.nombreCompleto ?? '';
    _descripcion = widget.usuario.perfilProveedor?.descripcion ?? '';
    _categorias = widget.usuario.perfilProveedor?.categoriasServicios ?? [];
    _fotosPortafolio = widget.usuario.perfilProveedor?.portafolioFotos ?? [];
    _servicios = _getDefaultServices();
    _disponibilidad =
        widget.usuario.perfilProveedor?.disponibilidad ??
        DisponibilidadProveedor(horarioInicio: '08:00', horarioFin: '18:00');
    _pedidos = _getSampleOrders();
    _resenas = widget.usuario.perfilProveedor?.resenas ?? _getSampleReviews();
    _metricas = _getSampleMetrics();
    _certificaciones = _getSampleCertifications();
    _metodosCobro = widget.usuario.perfilProveedor?.metodosCobro ?? [];
    _historialPagos = _getSampleTransactions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil de Proveedor'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          // Switch para cambiar a modo cliente
          if (widget.usuario.tipoUsuario == TipoUsuario.ambos)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Cliente',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: true, // Siempre true en esta pantalla (modo proveedor)
                  onChanged: (value) async {
                    // Cambiar a modo cliente
                    try {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('is_provider_mode', false);
                    } catch (e) {
                      _logger.e('Error saving mode preference: $e');
                    }

                    if (mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const SimpleHomeScreen(),
                        ),
                      );
                    }
                  },
                  activeThumbColor: Colors.orange,
                ),
              ],
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const SimpleLoginScreen(),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Perfil', icon: Icon(Icons.person)),
            Tab(text: 'Servicios', icon: Icon(Icons.build)),
            Tab(text: 'Pedidos', icon: Icon(Icons.assignment)),
            Tab(text: 'Reseñas', icon: Icon(Icons.star)),
            Tab(text: 'Finanzas', icon: Icon(Icons.account_balance_wallet)),
            Tab(text: 'Configuración', icon: Icon(Icons.settings)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfileTab(),
          _buildServicesTab(),
          _buildOrdersTab(),
          _buildReviewsTab(),
          _buildFinancesTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildPortfolioSection(),
          const SizedBox(height: 24),
          _buildAvailabilitySection(),
          const SizedBox(height: 24),
          _buildMetricsSection(),
          const SizedBox(height: 24),
          _buildCertificationsSection(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue[100],
                  child: Icon(Icons.person, size: 40, color: Colors.blue[600]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _nombre,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _descripcion,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _categorias
                            .map(
                              (categoria) => Chip(
                                label: Text(categoria.displayName),
                                backgroundColor: categoria.color.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _editProfile,
                  icon: const Icon(Icons.edit),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard('Servicios', '${_servicios.length}'),
                _buildStatCard('Pedidos', '${_pedidos.length}'),
                _buildStatCard(
                  'Valoración',
                  _metricas.valoracionPromedio.toStringAsFixed(1),
                ),
                _buildStatCard('Ingresos', '\$${_metricas.ingresosMensuales}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortfolioSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Portafolio',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _addPortfolioPhoto,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Agregar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_fotosPortafolio.isEmpty)
              Container(
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('No hay fotos en el portafolio'),
                ),
              )
            else
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _fotosPortafolio.length,
                  itemBuilder: (context, index) => Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.image, size: 40),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilitySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Disponibilidad',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _editAvailability,
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTimeField(
                    'Inicio',
                    _disponibilidad.horarioInicio,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimeField('Fin', _disponibilidad.horarioFin),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Días disponibles:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _disponibilidad.diasDisponibles
                  .map(
                    (dia) => Chip(
                      label: Text(dia),
                      backgroundColor: Colors.blue[100],
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Servicios de Emergencia'),
              subtitle: const Text('Disponible 24/7'),
              value: _disponibilidad.serviciosEmergencia,
              onChanged: (value) {
                setState(() {
                  _disponibilidad = DisponibilidadProveedor(
                    diasDisponibles: _disponibilidad.diasDisponibles,
                    horarioInicio: _disponibilidad.horarioInicio,
                    horarioFin: _disponibilidad.horarioFin,
                    serviciosEmergencia: value,
                    areasCobertura: _disponibilidad.areasCobertura,
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Métricas y Estadísticas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Contrataciones',
                    '${_metricas.contratacionesCompletadas}',
                    Icons.assignment_turned_in,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    'Ingresos Mensuales',
                    '\$${_metricas.ingresosMensuales}',
                    Icons.attach_money,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Valoración',
                    _metricas.valoracionPromedio.toStringAsFixed(1),
                    Icons.star,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    'Puntualidad',
                    _metricas.puntualidad.toStringAsFixed(1),
                    Icons.schedule,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificationsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Certificaciones y Seguros',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _addCertification,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_certificaciones.isEmpty)
              const Text('No hay certificaciones registradas')
            else
              ..._certificaciones.map(
                (cert) => ListTile(
                  leading: Icon(
                    cert.tipo == TipoCertificacion.seguro
                        ? Icons.security
                        : Icons.verified,
                  ),
                  title: Text(cert.nombre),
                  subtitle: Text('Vence: ${cert.fechaVencimiento}'),
                  trailing: IconButton(
                    onPressed: () => _removeCertification(cert),
                    icon: const Icon(Icons.delete),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mis Servicios',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _addService,
                icon: const Icon(Icons.add),
                label: const Text('Agregar Servicio'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._servicios.map((servicio) => _buildServiceCard(servicio)),
        ],
      ),
    );
  }

  Widget _buildServiceCard(ServicioOfrecido servicio) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  servicio.tipoServicio.icon,
                  color: servicio.tipoServicio.color,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    servicio.tipoServicio.displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Switch(
                  value: servicio.activo,
                  onChanged: (value) => _toggleService(servicio, value),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(servicio.descripcion),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Precio: \$${servicio.precioBase}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  onPressed: () => _editService(servicio),
                  icon: const Icon(Icons.edit),
                ),
                IconButton(
                  onPressed: () => _deleteService(servicio),
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gestión de Pedidos',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ..._pedidos.map((pedido) => _buildOrderCard(pedido)),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Pedido pedido) {
    Color statusColor = _getOrderStatusColor(pedido.estado);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  pedido.servicio,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(pedido.estado),
                  backgroundColor: statusColor.withValues(alpha: 0.2),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Cliente: ${pedido.clienteNombre}'),
            Text('Fecha: ${pedido.fecha}'),
            Text('Precio: \$${pedido.precio}'),
            const SizedBox(height: 12),
            if (pedido.estado == 'Pendiente')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _acceptOrder(pedido),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Aceptar'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _rejectOrder(pedido),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Rechazar'),
                    ),
                  ),
                ],
              )
            else if (pedido.estado == 'En Progreso')
              ElevatedButton(
                onPressed: () => _completeOrder(pedido),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('Marcar como Completado'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reseñas Recibidas',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_resenas.isEmpty)
            const Center(child: Text('No hay reseñas aún'))
          else
            ..._resenas.map((resena) => _buildReviewCard(resena)),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ResenaProveedor resena) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Text(resena.clienteNombre[0]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resena.clienteNombre,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            index < resena.valoracion
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(resena.fecha.toString().split(' ')[0]),
              ],
            ),
            const SizedBox(height: 8),
            Text(resena.comentario),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Responder comentario...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _respondToReview(resena),
                  child: const Text('Responder'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gestión Financiera',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildPaymentMethodsSection(),
          const SizedBox(height: 24),
          _buildTransactionHistorySection(),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Métodos de Cobro',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._metodosCobro.map(
              (metodo) => ListTile(
                leading: Icon(metodo.icon),
                title: Text(metodo.displayName),
                trailing: Switch(
                  value: true,
                  onChanged: (value) => _togglePaymentMethod(metodo, value),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _addPaymentMethod,
              icon: const Icon(Icons.add),
              label: const Text('Agregar Método'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHistorySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Historial de Pagos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._historialPagos.map(
              (transaccion) => ListTile(
                leading: Icon(
                  transaccion.tipo == TipoTransaccion.ingreso
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
                  color: transaccion.tipo == TipoTransaccion.ingreso
                      ? Colors.green
                      : Colors.red,
                ),
                title: Text(transaccion.descripcion),
                subtitle: Text(transaccion.fecha),
                trailing: Text(
                  '${transaccion.tipo == TipoTransaccion.ingreso ? '+' : '-'}\$${transaccion.monto}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: transaccion.tipo == TipoTransaccion.ingreso
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTab() {
    return const SettingsScreen();
  }

  // Métodos auxiliares
  Widget _buildStatCard(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(title, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildTimeField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(value),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(title, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Color _getOrderStatusColor(String estado) {
    switch (estado) {
      case 'Pendiente':
        return Colors.orange;
      case 'Aceptado':
        return Colors.blue;
      case 'En Progreso':
        return Colors.purple;
      case 'Completado':
        return Colors.green;
      case 'Rechazado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Métodos de datos de ejemplo
  List<ServicioOfrecido> _getDefaultServices() {
    return [
      ServicioOfrecido(
        id: '1',
        tipoServicio: TipoServicio.plomeria,
        descripcion: 'Reparación e instalación de sistemas de plomería',
        precioBase: 150.0,
        activo: true,
      ),
      ServicioOfrecido(
        id: '2',
        tipoServicio: TipoServicio.electricidad,
        descripcion: 'Instalación y reparación eléctrica',
        precioBase: 200.0,
        activo: true,
      ),
    ];
  }

  List<Pedido> _getSampleOrders() {
    return [
      Pedido(
        id: '1',
        clienteNombre: 'Juan Pérez',
        servicio: 'Reparación de grifo',
        fecha: '2024-01-15',
        precio: 150.0,
        estado: 'Pendiente',
      ),
      Pedido(
        id: '2',
        clienteNombre: 'María García',
        servicio: 'Instalación eléctrica',
        fecha: '2024-01-14',
        precio: 200.0,
        estado: 'En Progreso',
      ),
    ];
  }

  MetricasProveedor _getSampleMetrics() {
    return MetricasProveedor(
      contratacionesCompletadas: 25,
      ingresosMensuales: 3500,
      valoracionPromedio: 4.8,
      puntualidad: 4.9,
      calidad: 4.7,
      trato: 4.8,
    );
  }

  List<Certificacion> _getSampleCertifications() {
    return [
      Certificacion(
        id: '1',
        nombre: 'Seguro de Responsabilidad Civil',
        tipo: TipoCertificacion.seguro,
        fechaVencimiento: '2024-12-31',
      ),
    ];
  }

  List<Transaccion> _getSampleTransactions() {
    return [
      Transaccion(
        id: '1',
        descripcion: 'Pago por reparación de grifo',
        monto: 150.0,
        tipo: TipoTransaccion.ingreso,
        fecha: '2024-01-15',
      ),
      Transaccion(
        id: '2',
        descripcion: 'Retiro a cuenta bancaria',
        monto: 1000.0,
        tipo: TipoTransaccion.egreso,
        fecha: '2024-01-10',
      ),
    ];
  }

  List<ResenaProveedor> _getSampleReviews() {
    return [
      ResenaProveedor(
        id: '1',
        clienteId: '1',
        clienteNombre: 'María García',
        comentario: 'Excelente trabajo, muy puntual y profesional.',
        valoracion: 5,
        fecha: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ResenaProveedor(
        id: '2',
        clienteId: '2',
        clienteNombre: 'Carlos López',
        comentario: 'Muy satisfecho con el servicio, lo recomiendo.',
        valoracion: 4,
        fecha: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }

  // Métodos de acción (implementar según necesidades)
  void _editProfile() async {
    try {
      Navigator.of(context)
          .push(
            MaterialPageRoute(
              builder: (context) => EditProfileScreen(
                usuario: widget.usuario,
                isProviderMode: true,
              ),
            ),
          )
          .then((success) {
            if (success == true) {
              // Recargar datos después de editar
              _initializeData();
              setState(() {});
            }
          });
    } catch (e) {
      _logger.e('Error abriendo editor de perfil: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error abriendo editor: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addPortfolioPhoto() {
    // Implementar subida de fotos
  }

  void _editAvailability() {
    // Implementar edición de disponibilidad
  }

  void _addCertification() {
    // Implementar agregar certificación
  }

  void _removeCertification(Certificacion cert) {
    setState(() {
      _certificaciones.remove(cert);
    });
  }

  void _addService() {
    // Implementar agregar servicio
  }

  void _editService(ServicioOfrecido servicio) {
    // Implementar edición de servicio
  }

  void _deleteService(ServicioOfrecido servicio) {
    setState(() {
      _servicios.remove(servicio);
    });
  }

  void _toggleService(ServicioOfrecido servicio, bool value) {
    setState(() {
      servicio.activo = value;
    });
  }

  void _acceptOrder(Pedido pedido) {
    setState(() {
      pedido.estado = 'Aceptado';
    });
  }

  void _rejectOrder(Pedido pedido) {
    setState(() {
      pedido.estado = 'Rechazado';
    });
  }

  void _completeOrder(Pedido pedido) {
    setState(() {
      pedido.estado = 'Completado';
    });
  }

  void _respondToReview(ResenaProveedor resena) {
    // Implementar respuesta a reseña
  }

  void _togglePaymentMethod(MetodoPago metodo, bool value) {
    // Implementar toggle de método de pago
  }

  void _addPaymentMethod() {
    // Implementar agregar método de pago
  }
}

// Clases de datos adicionales
class ServicioOfrecido {
  final String id;
  final TipoServicio tipoServicio;
  final String descripcion;
  final double precioBase;
  bool activo;

  ServicioOfrecido({
    required this.id,
    required this.tipoServicio,
    required this.descripcion,
    required this.precioBase,
    required this.activo,
  });
}

class Pedido {
  final String id;
  final String clienteNombre;
  final String servicio;
  final String fecha;
  final double precio;
  String estado;

  Pedido({
    required this.id,
    required this.clienteNombre,
    required this.servicio,
    required this.fecha,
    required this.precio,
    required this.estado,
  });
}

class MetricasProveedor {
  final int contratacionesCompletadas;
  final int ingresosMensuales;
  final double valoracionPromedio;
  final double puntualidad;
  final double calidad;
  final double trato;

  MetricasProveedor({
    required this.contratacionesCompletadas,
    required this.ingresosMensuales,
    required this.valoracionPromedio,
    required this.puntualidad,
    required this.calidad,
    required this.trato,
  });
}

class Certificacion {
  final String id;
  final String nombre;
  final TipoCertificacion tipo;
  final String fechaVencimiento;

  Certificacion({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.fechaVencimiento,
  });
}

enum TipoCertificacion { certificacion, seguro }

class Transaccion {
  final String id;
  final String descripcion;
  final double monto;
  final TipoTransaccion tipo;
  final String fecha;

  Transaccion({
    required this.id,
    required this.descripcion,
    required this.monto,
    required this.tipo,
    required this.fecha,
  });
}

enum TipoTransaccion { ingreso, egreso }

class Notificacion {
  final String id;
  final String titulo;
  final String mensaje;
  final TipoNotificacion tipo;
  final String fecha;

  Notificacion({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.tipo,
    required this.fecha,
  });
}

enum TipoNotificacion { pedido, resena, pago, general }

extension TipoNotificacionExtension on TipoNotificacion {
  IconData get icon {
    switch (this) {
      case TipoNotificacion.pedido:
        return Icons.assignment;
      case TipoNotificacion.resena:
        return Icons.star;
      case TipoNotificacion.pago:
        return Icons.payment;
      case TipoNotificacion.general:
        return Icons.notifications;
    }
  }
}
