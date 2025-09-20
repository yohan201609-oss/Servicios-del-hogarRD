import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../models/user_profile.dart';
import 'payment_methods_screen.dart';

class EditProfileScreen extends StatefulWidget {
  final Usuario usuario;
  final bool isProviderMode;

  const EditProfileScreen({
    super.key,
    required this.usuario,
    this.isProviderMode = false,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _logger = Logger();

  // Controladores para campos comunes
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();

  // Controladores para proveedor
  final _cedulaController = TextEditingController();
  final _experienciaController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _ubicacionBaseController = TextEditingController();
  final _horarioInicioController = TextEditingController();
  final _horarioFinController = TextEditingController();

  // Variables de estado
  final List<MetodoPago> _metodosPagoSeleccionados = <MetodoPago>[];
  final List<TipoServicio> _categoriasServiciosSeleccionadas = <TipoServicio>[];
  final List<String> _diasDisponibles = <String>[];
  bool _serviciosEmergencia = false;
  bool _tieneSeguro = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.isProviderMode ? 2 : 1,
      vsync: this,
    );
    _loadUserData();
  }

  void _loadUserData() {
    // Cargar datos del cliente
    if (widget.usuario.perfilCliente != null) {
      final cliente = widget.usuario.perfilCliente!;
      _nombreController.text = cliente.nombre;
      _apellidoController.text = cliente.apellido;
      _telefonoController.text = cliente.telefono;
      _direccionController.text = cliente.direccionPrincipal;
      _metodosPagoSeleccionados.addAll(cliente.metodosPago);
    }

    // Cargar datos del proveedor
    if (widget.usuario.perfilProveedor != null) {
      final proveedor = widget.usuario.perfilProveedor!;
      _cedulaController.text = proveedor.cedulaRnc;
      _experienciaController.text = proveedor.experiencia;
      _descripcionController.text = proveedor.descripcion;
      _ubicacionBaseController.text = proveedor.ubicacionBase;
      _categoriasServiciosSeleccionadas.addAll(proveedor.categoriasServicios);
      _metodosPagoSeleccionados.addAll(proveedor.metodosCobro);
      _serviciosEmergencia = proveedor.disponibilidad.serviciosEmergencia;
      _tieneSeguro = proveedor.tieneSeguro;
      _diasDisponibles.addAll(proveedor.disponibilidad.diasDisponibles);
      _horarioInicioController.text = proveedor.disponibilidad.horarioInicio;
      _horarioFinController.text = proveedor.disponibilidad.horarioFin;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _cedulaController.dispose();
    _experienciaController.dispose();
    _descripcionController.dispose();
    _ubicacionBaseController.dispose();
    _horarioInicioController.dispose();
    _horarioFinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Guardar',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
          ),
        ],
        bottom: widget.isProviderMode
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Datos Básicos', icon: Icon(Icons.person)),
                  Tab(text: 'Servicios', icon: Icon(Icons.build)),
                ],
              )
            : null,
      ),
      body: widget.isProviderMode
          ? TabBarView(
              controller: _tabController,
              children: [_buildBasicInfoTab(), _buildServicesTab()],
            )
          : _buildBasicInfoTab(),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información básica común
            _buildSectionTitle('Información Básica'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) =>
                  value?.isEmpty == true ? 'Nombre requerido' : null,
            ),
            const SizedBox(height: 16),
            if (widget.usuario.tipoUsuario == TipoUsuario.cliente ||
                widget.usuario.tipoUsuario == TipoUsuario.ambos) ...[
              TextFormField(
                controller: _apellidoController,
                decoration: const InputDecoration(
                  labelText: 'Apellido *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Apellido requerido' : null,
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _telefonoController,
              decoration: const InputDecoration(
                labelText: 'Teléfono *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
                hintText: 'Ej: 809-123-4567',
              ),
              keyboardType: TextInputType.phone,
              validator: (value) =>
                  value?.isEmpty == true ? 'Teléfono requerido' : null,
            ),
            const SizedBox(height: 16),
            if (widget.usuario.tipoUsuario == TipoUsuario.cliente ||
                widget.usuario.tipoUsuario == TipoUsuario.ambos) ...[
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(
                  labelText: 'Dirección Principal *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                  hintText: 'Calle, número, sector, ciudad',
                ),
                maxLines: 2,
                validator: (value) =>
                    value?.isEmpty == true ? 'Dirección requerida' : null,
              ),
              const SizedBox(height: 24),
            ],

            // Información específica de proveedor
            if (widget.usuario.tipoUsuario == TipoUsuario.proveedor ||
                widget.usuario.tipoUsuario == TipoUsuario.ambos) ...[
              _buildSectionTitle('Información de Proveedor'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cedulaController,
                decoration: const InputDecoration(
                  labelText: 'Cédula/RNC *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Cédula/RNC requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ubicacionBaseController,
                decoration: const InputDecoration(
                  labelText: 'Ubicación Base *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),
                  hintText: 'Ciudad o zona donde trabajas principalmente',
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Ubicación requerida' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _experienciaController,
                decoration: const InputDecoration(
                  labelText: 'Experiencia *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work),
                  hintText: 'Ej: 5 años',
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Experiencia requerida' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción de Servicios *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                  hintText:
                      'Describe brevemente tus servicios y especialidades',
                ),
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty == true ? 'Descripción requerida' : null,
              ),
              const SizedBox(height: 24),
            ],

            // Métodos de pago
            _buildSectionTitle('Métodos de Pago'),
            const SizedBox(height: 16),

            // Botón para gestionar métodos de pago detallados
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.payment, color: Colors.blue),
                ),
                title: const Text(
                  'Gestionar Métodos de Pago',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Agrega tarjetas de crédito, débito, PayPal y más',
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _navigateToPaymentMethods,
              ),
            ),

            // Métodos de pago básicos (mantener compatibilidad)
            const Text(
              'Métodos de Pago Básicos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Estos son los métodos de pago básicos que aceptas como proveedor',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ...MetodoPago.values.map(
              (metodo) => _buildMetodoPagoOption(metodo),
            ),
            const SizedBox(height: 24),

            // Disponibilidad (solo para proveedores)
            if (widget.usuario.tipoUsuario == TipoUsuario.proveedor ||
                widget.usuario.tipoUsuario == TipoUsuario.ambos) ...[
              _buildSectionTitle('Disponibilidad'),
              const SizedBox(height: 16),
              _buildDisponibilidadSection(),
            ],
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
          _buildSectionTitle('Categorías de Servicios'),
          const SizedBox(height: 16),
          const Text(
            'Selecciona los servicios que ofreces',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
            ),
            itemCount: TipoServicio.values.length,
            itemBuilder: (context, index) {
              final servicio = TipoServicio.values[index];
              final isSelected = _categoriasServiciosSeleccionadas.contains(
                servicio,
              );

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _categoriasServiciosSeleccionadas.remove(servicio);
                    } else {
                      _categoriasServiciosSeleccionadas.add(servicio);
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? servicio.color.withValues(alpha: 0.2)
                        : Colors.grey[100],
                    border: Border.all(
                      color: isSelected ? servicio.color : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        servicio.icon,
                        color: isSelected ? servicio.color : Colors.grey[600],
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        servicio.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isSelected ? servicio.color : Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Documentación'),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Tengo Seguro'),
            subtitle: const Text(
              'Mi negocio cuenta con seguro de responsabilidad',
            ),
            value: _tieneSeguro,
            onChanged: (value) => setState(() => _tieneSeguro = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }

  Widget _buildMetodoPagoOption(MetodoPago metodo) {
    final isSelected = _metodosPagoSeleccionados.contains(metodo);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        title: Row(
          children: [
            Icon(metodo.icon, color: Colors.blue[600]),
            const SizedBox(width: 12),
            Text(metodo.displayName),
          ],
        ),
        value: isSelected,
        onChanged: (value) {
          setState(() {
            if (value == true) {
              _metodosPagoSeleccionados.add(metodo);
            } else {
              _metodosPagoSeleccionados.remove(metodo);
            }
          });
        },
      ),
    );
  }

  Widget _buildDisponibilidadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Días Disponibles',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ...[
          'Lunes',
          'Martes',
          'Miércoles',
          'Jueves',
          'Viernes',
          'Sábado',
          'Domingo',
        ].map((dia) => _buildDiaOption(dia)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _horarioInicioController,
                decoration: const InputDecoration(
                  labelText: 'Hora Inicio',
                  border: OutlineInputBorder(),
                  hintText: '08:00',
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _horarioFinController,
                decoration: const InputDecoration(
                  labelText: 'Hora Fin',
                  border: OutlineInputBorder(),
                  hintText: '18:00',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Servicios de Emergencia'),
          subtitle: const Text('Disponible 24/7 para emergencias'),
          value: _serviciosEmergencia,
          onChanged: (value) => setState(() => _serviciosEmergencia = value),
        ),
      ],
    );
  }

  Widget _buildDiaOption(String dia) {
    final isSelected = _diasDisponibles.contains(dia);

    return CheckboxListTile(
      title: Text(dia),
      value: isSelected,
      onChanged: (value) {
        setState(() {
          if (value == true) {
            _diasDisponibles.add(dia);
          } else {
            _diasDisponibles.remove(dia);
          }
        });
      },
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Validar campos específicos según el tipo de usuario
      if (widget.usuario.tipoUsuario == TipoUsuario.proveedor ||
          widget.usuario.tipoUsuario == TipoUsuario.ambos) {
        if (_categoriasServiciosSeleccionadas.isEmpty) {
          _showError('Debe seleccionar al menos una categoría de servicio');
          return;
        }
      }

      // Crear perfil de cliente actualizado
      PerfilCliente? perfilCliente;
      if (widget.usuario.tipoUsuario == TipoUsuario.cliente ||
          widget.usuario.tipoUsuario == TipoUsuario.ambos) {
        perfilCliente = PerfilCliente(
          usuarioId: widget.usuario.id,
          nombre: _nombreController.text.trim(),
          apellido: _apellidoController.text.trim(),
          telefono: _telefonoController.text.trim(),
          direccionPrincipal: _direccionController.text.trim(),
          metodosPago: _metodosPagoSeleccionados,
          preferencias:
              widget.usuario.perfilCliente?.preferencias ??
              PreferenciasCliente(),
          direccionesGuardadas:
              widget.usuario.perfilCliente?.direccionesGuardadas ?? [],
          historialServicios:
              widget.usuario.perfilCliente?.historialServicios ?? [],
          valoracionPromedio:
              widget.usuario.perfilCliente?.valoracionPromedio ?? 0.0,
          resenas: widget.usuario.perfilCliente?.resenas ?? [],
        );
      }

      // Crear perfil de proveedor actualizado
      PerfilProveedor? perfilProveedor;
      if (widget.usuario.tipoUsuario == TipoUsuario.proveedor ||
          widget.usuario.tipoUsuario == TipoUsuario.ambos) {
        perfilProveedor = PerfilProveedor(
          usuarioId: widget.usuario.id,
          nombreCompleto: _nombreController.text.trim(),
          cedulaRnc: _cedulaController.text.trim(),
          categoriasServicios: _categoriasServiciosSeleccionadas,
          experiencia: _experienciaController.text.trim(),
          descripcion: _descripcionController.text.trim(),
          portafolioFotos:
              widget.usuario.perfilProveedor?.portafolioFotos ?? [],
          disponibilidad: DisponibilidadProveedor(
            diasDisponibles: _diasDisponibles,
            horarioInicio: _horarioInicioController.text.trim().isNotEmpty
                ? _horarioInicioController.text.trim()
                : '08:00',
            horarioFin: _horarioFinController.text.trim().isNotEmpty
                ? _horarioFinController.text.trim()
                : '18:00',
            serviciosEmergencia: _serviciosEmergencia,
            areasCobertura:
                widget.usuario.perfilProveedor?.disponibilidad.areasCobertura ??
                [],
          ),
          ubicacionBase: _ubicacionBaseController.text.trim(),
          certificaciones:
              widget.usuario.perfilProveedor?.certificaciones ?? [],
          licencias: widget.usuario.perfilProveedor?.licencias ?? [],
          tieneSeguro: _tieneSeguro,
          metodosCobro: _metodosPagoSeleccionados,
          valoracionPromedio:
              widget.usuario.perfilProveedor?.valoracionPromedio ?? 0.0,
          resenas: widget.usuario.perfilProveedor?.resenas ?? [],
          totalServicios: widget.usuario.perfilProveedor?.totalServicios ?? 0,
        );
      }

      // Crear usuario actualizado
      final usuarioActualizado = Usuario(
        id: widget.usuario.id,
        email: widget.usuario.email,
        password: widget.usuario.password,
        tipoUsuario: widget.usuario.tipoUsuario,
        fechaCreacion: widget.usuario.fechaCreacion,
        activo: widget.usuario.activo,
        perfilCliente: perfilCliente,
        perfilProveedor: perfilProveedor,
      );

      // Guardar en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'usuario_actual',
        jsonEncode(usuarioActualizado.toJson()),
      );

      _logger.i('Perfil actualizado exitosamente');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Retornar true para indicar éxito
      }
    } catch (e) {
      _logger.e('Error actualizando perfil: $e');
      _showError('Error al actualizar perfil: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _navigateToPaymentMethods() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentMethodsScreen(usuario: widget.usuario),
      ),
    );

    // Si se agregó o modificó algún método de pago, mostrar mensaje
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Métodos de pago actualizados'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }
}
