import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../models/user_profile.dart';
import 'simple_home_screen.dart';

class CompleteProfileScreen extends StatefulWidget {
  final String email;
  final String password;
  final TipoUsuario tipoUsuario;

  const CompleteProfileScreen({
    super.key,
    required this.email,
    required this.password,
    required this.tipoUsuario,
  });

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _clienteFormKey = GlobalKey<FormState>();
  final _proveedorFormKey = GlobalKey<FormState>();
  final _pageController = PageController();
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
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.tipoUsuario == TipoUsuario.ambos ? 2 : 1,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
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
        title: const Text('Completar Perfil'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        bottom: widget.tipoUsuario == TipoUsuario.ambos
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Cliente', icon: Icon(Icons.person)),
                  Tab(text: 'Proveedor', icon: Icon(Icons.build)),
                ],
              )
            : null,
      ),
      body: widget.tipoUsuario == TipoUsuario.ambos
          ? TabBarView(
              controller: _tabController,
              children: [_buildClienteForm(), _buildProveedorForm()],
            )
          : widget.tipoUsuario == TipoUsuario.cliente
          ? _buildClienteForm()
          : _buildProveedorForm(),
      bottomNavigationBar: widget.tipoUsuario == TipoUsuario.ambos
          ? Container(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _completeProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Finalizar Registro'),
              ),
            )
          : Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousPage,
                        child: const Text('Anterior'),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        _currentPage == _getTotalPages() - 1
                            ? 'Finalizar'
                            : 'Siguiente',
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildClienteForm() {
    if (widget.tipoUsuario == TipoUsuario.ambos) {
      return Form(
        key: _clienteFormKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Información de Cliente',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildClienteDatosBasicosContent(),
              const SizedBox(height: 24),
              _buildClienteMetodosPagoContent(),
              const SizedBox(height: 24),
              _buildClienteDireccionesContent(),
              const SizedBox(height: 24),
              _buildClientePreferenciasContent(),
            ],
          ),
        ),
      );
    }

    return Form(
      key: _clienteFormKey,
      child: PageView(
        controller: _pageController,
        onPageChanged: (page) => setState(() => _currentPage = page),
        children: [
          _buildClienteDatosBasicos(),
          _buildClienteMetodosPago(),
          _buildClienteDirecciones(),
          _buildClientePreferencias(),
        ],
      ),
    );
  }

  Widget _buildProveedorForm() {
    if (widget.tipoUsuario == TipoUsuario.ambos) {
      return Form(
        key: _proveedorFormKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Información de Proveedor',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildProveedorDatosBasicosContent(),
              const SizedBox(height: 24),
              _buildProveedorServiciosContent(),
              const SizedBox(height: 24),
              _buildProveedorExperienciaContent(),
              const SizedBox(height: 24),
              _buildProveedorDisponibilidadContent(),
              const SizedBox(height: 24),
              _buildProveedorDocumentacionContent(),
            ],
          ),
        ),
      );
    }

    return Form(
      key: _proveedorFormKey,
      child: PageView(
        controller: _pageController,
        onPageChanged: (page) => setState(() => _currentPage = page),
        children: [
          _buildProveedorDatosBasicos(),
          _buildProveedorServicios(),
          _buildProveedorExperiencia(),
          _buildProveedorDisponibilidad(),
          _buildProveedorDocumentacion(),
        ],
      ),
    );
  }

  Widget _buildClienteDatosBasicos() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Datos Básicos',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Proporciona tu información personal básica',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _nombreController,
            decoration: const InputDecoration(
              labelText: 'Nombre *',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value?.isEmpty == true ? 'Nombre requerido' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _apellidoController,
            decoration: const InputDecoration(
              labelText: 'Apellido *',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value?.isEmpty == true ? 'Apellido requerido' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _telefonoController,
            decoration: const InputDecoration(
              labelText: 'Teléfono *',
              border: OutlineInputBorder(),
              hintText: 'Ej: 809-123-4567',
            ),
            keyboardType: TextInputType.phone,
            validator: (value) =>
                value?.isEmpty == true ? 'Teléfono requerido' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _direccionController,
            decoration: const InputDecoration(
              labelText: 'Dirección Principal *',
              border: OutlineInputBorder(),
              hintText: 'Calle, número, sector, ciudad',
            ),
            maxLines: 2,
            validator: (value) =>
                value?.isEmpty == true ? 'Dirección requerida' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildClienteMetodosPago() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Métodos de Pago',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Selecciona tus métodos de pago preferidos',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ...MetodoPago.values.map((metodo) => _buildMetodoPagoOption(metodo)),
        ],
      ),
    );
  }

  Widget _buildMetodoPagoOption(MetodoPago metodo) {
    final isSelected = _metodosPagoSeleccionados.contains(metodo);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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

  Widget _buildClienteDirecciones() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Direcciones Guardadas',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Agrega direcciones adicionales para servicios',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          const Text(
            'Tu dirección principal ya está guardada. Puedes agregar más direcciones después de completar tu perfil.',
            style: TextStyle(color: Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildClientePreferencias() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preferencias',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Configura tus preferencias de servicio',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          const Text(
            'Puedes configurar tus preferencias detalladas después de completar tu perfil.',
            style: TextStyle(color: Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildProveedorDatosBasicos() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Datos Básicos',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Información personal y legal',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _nombreController,
            decoration: const InputDecoration(
              labelText: 'Nombre Completo o Nombre del Negocio *',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value?.isEmpty == true ? 'Nombre requerido' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _cedulaController,
            decoration: const InputDecoration(
              labelText: 'Cédula o RNC *',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value?.isEmpty == true ? 'Cédula/RNC requerido' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _telefonoController,
            decoration: const InputDecoration(
              labelText: 'Teléfono *',
              border: OutlineInputBorder(),
              hintText: 'Ej: 809-123-4567',
            ),
            keyboardType: TextInputType.phone,
            validator: (value) =>
                value?.isEmpty == true ? 'Teléfono requerido' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _ubicacionBaseController,
            decoration: const InputDecoration(
              labelText: 'Ubicación Base *',
              border: OutlineInputBorder(),
              hintText: 'Ciudad o zona donde trabajas principalmente',
            ),
            validator: (value) =>
                value?.isEmpty == true ? 'Ubicación requerida' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildProveedorServicios() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Categorías de Servicios',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Selecciona los servicios que ofreces',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
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
                            color: isSelected
                                ? servicio.color
                                : Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProveedorExperiencia() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Experiencia y Descripción',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Cuéntanos sobre tu experiencia profesional',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _experienciaController,
            decoration: const InputDecoration(
              labelText: 'Años de Experiencia *',
              border: OutlineInputBorder(),
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
              hintText: 'Describe brevemente tus servicios y especialidades',
            ),
            maxLines: 4,
            validator: (value) =>
                value?.isEmpty == true ? 'Descripción requerida' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildProveedorDisponibilidad() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Disponibilidad',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Configura tu disponibilidad de trabajo',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          const Text(
            'Días Disponibles',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
          const SizedBox(height: 24),
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
          const SizedBox(height: 24), // Espacio adicional al final
        ],
      ),
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

  Widget _buildProveedorDocumentacion() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Documentación',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Información adicional (opcional)',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text('Tengo Seguro'),
            subtitle: const Text(
              'Mi negocio cuenta con seguro de responsabilidad',
            ),
            value: _tieneSeguro,
            onChanged: (value) => setState(() => _tieneSeguro = value),
          ),
          const SizedBox(height: 16),
          const Text(
            'Métodos de Cobro Preferidos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ...MetodoPago.values.map((metodo) => _buildMetodoPagoOption(metodo)),
          const SizedBox(height: 24),
          const Text(
            'Puedes agregar certificaciones y licencias después de completar tu perfil.',
            style: TextStyle(color: Colors.blue),
          ),
        ],
      ),
    );
  }

  int _getTotalPages() {
    if (widget.tipoUsuario == TipoUsuario.cliente) {
      return 4;
    } else if (widget.tipoUsuario == TipoUsuario.proveedor) {
      return 5;
    } else {
      return 9; // Cliente + Proveedor
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextPage() {
    if (_currentPage < _getTotalPages() - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeProfile();
    }
  }

  Future<void> _completeProfile() async {
    _logger.i('Iniciando completar perfil...');
    _logger.i('Tipo de usuario: ${widget.tipoUsuario}');

    // Validar campos requeridos según el tipo de usuario
    bool isValid = true;
    String errorMessage = '';

    // Validar campos básicos
    if (_nombreController.text.trim().isEmpty) {
      isValid = false;
      errorMessage = 'El nombre es requerido';
      _logger.w('Error: Nombre vacío');
    } else if (_telefonoController.text.trim().isEmpty) {
      isValid = false;
      errorMessage = 'El teléfono es requerido';
      _logger.w('Error: Teléfono vacío');
    }

    // Validar campos específicos de cliente
    if (widget.tipoUsuario == TipoUsuario.cliente ||
        widget.tipoUsuario == TipoUsuario.ambos) {
      if (_apellidoController.text.trim().isEmpty) {
        isValid = false;
        errorMessage = 'El apellido es requerido';
      } else if (_direccionController.text.trim().isEmpty) {
        isValid = false;
        errorMessage = 'La dirección es requerida';
      }
    }

    // Validar campos específicos de proveedor
    if (widget.tipoUsuario == TipoUsuario.proveedor ||
        widget.tipoUsuario == TipoUsuario.ambos) {
      if (_cedulaController.text.trim().isEmpty) {
        isValid = false;
        errorMessage = 'La cédula/RNC es requerida';
      } else if (_experienciaController.text.trim().isEmpty) {
        isValid = false;
        errorMessage = 'La experiencia es requerida';
      } else if (_descripcionController.text.trim().isEmpty) {
        isValid = false;
        errorMessage = 'La descripción es requerida';
      } else if (_ubicacionBaseController.text.trim().isEmpty) {
        isValid = false;
        errorMessage = 'La ubicación base es requerida';
      } else if (_categoriasServiciosSeleccionadas.isEmpty) {
        isValid = false;
        errorMessage = 'Debe seleccionar al menos una categoría de servicio';
      }
    }

    if (!isValid) {
      _logger.e('Validación falló: $errorMessage');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
      return;
    }

    _logger.i('Validación exitosa, creando usuario...');

    try {
      // Crear el usuario con los datos proporcionados
      final usuario = Usuario(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: widget.email,
        password: widget.password,
        tipoUsuario: widget.tipoUsuario,
        fechaCreacion: DateTime.now(),
        perfilCliente:
            widget.tipoUsuario == TipoUsuario.cliente ||
                widget.tipoUsuario == TipoUsuario.ambos
            ? PerfilCliente(
                usuarioId: DateTime.now().millisecondsSinceEpoch.toString(),
                nombre: _nombreController.text.trim(),
                apellido: _apellidoController.text.trim(),
                telefono: _telefonoController.text.trim(),
                direccionPrincipal: _direccionController.text.trim(),
                metodosPago: _metodosPagoSeleccionados,
                preferencias: PreferenciasCliente(),
              )
            : null,
        perfilProveedor:
            widget.tipoUsuario == TipoUsuario.proveedor ||
                widget.tipoUsuario == TipoUsuario.ambos
            ? PerfilProveedor(
                usuarioId: DateTime.now().millisecondsSinceEpoch.toString(),
                nombreCompleto: _nombreController.text.trim(),
                cedulaRnc: _cedulaController.text.trim(),
                categoriasServicios: _categoriasServiciosSeleccionadas,
                experiencia: _experienciaController.text.trim(),
                descripcion: _descripcionController.text.trim(),
                disponibilidad: DisponibilidadProveedor(
                  diasDisponibles: _diasDisponibles,
                  horarioInicio: _horarioInicioController.text.trim().isNotEmpty
                      ? _horarioInicioController.text.trim()
                      : '08:00',
                  horarioFin: _horarioFinController.text.trim().isNotEmpty
                      ? _horarioFinController.text.trim()
                      : '18:00',
                  serviciosEmergencia: _serviciosEmergencia,
                ),
                ubicacionBase: _ubicacionBaseController.text.trim(),
                metodosCobro: _metodosPagoSeleccionados,
                tieneSeguro: _tieneSeguro,
              )
            : null,
      );

      // Guardar en SharedPreferences (simulación de base de datos)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('usuario_actual', jsonEncode(usuario.toJson()));
      await prefs.setBool('perfil_completado', true);

      // Mostrar mensaje de éxito
      _logger.i('Usuario creado exitosamente, navegando a home...');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil completado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );

        // Navegar a la pantalla principal
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SimpleHomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al completar perfil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Métodos de contenido para formularios de usuarios "ambos"
  Widget _buildClienteDatosBasicosContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Datos Básicos',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nombreController,
          decoration: const InputDecoration(
            labelText: 'Nombre *',
            border: OutlineInputBorder(),
          ),
          validator: (value) =>
              value?.isEmpty == true ? 'Nombre requerido' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _apellidoController,
          decoration: const InputDecoration(
            labelText: 'Apellido *',
            border: OutlineInputBorder(),
          ),
          validator: (value) =>
              value?.isEmpty == true ? 'Apellido requerido' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _telefonoController,
          decoration: const InputDecoration(
            labelText: 'Teléfono *',
            border: OutlineInputBorder(),
            hintText: 'Ej: 809-123-4567',
          ),
          keyboardType: TextInputType.phone,
          validator: (value) =>
              value?.isEmpty == true ? 'Teléfono requerido' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _direccionController,
          decoration: const InputDecoration(
            labelText: 'Dirección Principal *',
            border: OutlineInputBorder(),
            hintText: 'Calle, número, sector, ciudad',
          ),
          maxLines: 2,
          validator: (value) =>
              value?.isEmpty == true ? 'Dirección requerida' : null,
        ),
      ],
    );
  }

  Widget _buildClienteMetodosPagoContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Métodos de Pago',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...MetodoPago.values.map((metodo) => _buildMetodoPagoOption(metodo)),
      ],
    );
  }

  Widget _buildClienteDireccionesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Direcciones Guardadas',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          'Tu dirección principal ya está guardada. Puedes agregar más direcciones después de completar tu perfil.',
          style: TextStyle(color: Colors.blue),
        ),
      ],
    );
  }

  Widget _buildClientePreferenciasContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preferencias',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          'Puedes configurar tus preferencias detalladas después de completar tu perfil.',
          style: TextStyle(color: Colors.blue),
        ),
      ],
    );
  }

  Widget _buildProveedorDatosBasicosContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Datos Básicos',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nombreController,
          decoration: const InputDecoration(
            labelText: 'Nombre Completo o Nombre del Negocio *',
            border: OutlineInputBorder(),
          ),
          validator: (value) =>
              value?.isEmpty == true ? 'Nombre requerido' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _cedulaController,
          decoration: const InputDecoration(
            labelText: 'Cédula o RNC *',
            border: OutlineInputBorder(),
          ),
          validator: (value) =>
              value?.isEmpty == true ? 'Cédula/RNC requerido' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _telefonoController,
          decoration: const InputDecoration(
            labelText: 'Teléfono *',
            border: OutlineInputBorder(),
            hintText: 'Ej: 809-123-4567',
          ),
          keyboardType: TextInputType.phone,
          validator: (value) =>
              value?.isEmpty == true ? 'Teléfono requerido' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _ubicacionBaseController,
          decoration: const InputDecoration(
            labelText: 'Ubicación Base *',
            border: OutlineInputBorder(),
            hintText: 'Ciudad o zona donde trabajas principalmente',
          ),
          validator: (value) =>
              value?.isEmpty == true ? 'Ubicación requerida' : null,
        ),
      ],
    );
  }

  Widget _buildProveedorServiciosContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categorías de Servicios',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
      ],
    );
  }

  Widget _buildProveedorExperienciaContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Experiencia y Descripción',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _experienciaController,
          decoration: const InputDecoration(
            labelText: 'Años de Experiencia *',
            border: OutlineInputBorder(),
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
            hintText: 'Describe brevemente tus servicios y especialidades',
          ),
          maxLines: 4,
          validator: (value) =>
              value?.isEmpty == true ? 'Descripción requerida' : null,
        ),
      ],
    );
  }

  Widget _buildProveedorDisponibilidadContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Disponibilidad',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
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

  Widget _buildProveedorDocumentacionContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Documentación',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Tengo Seguro'),
          subtitle: const Text(
            'Mi negocio cuenta con seguro de responsabilidad',
          ),
          value: _tieneSeguro,
          onChanged: (value) => setState(() => _tieneSeguro = value),
        ),
        const SizedBox(height: 16),
        const Text(
          'Métodos de Cobro Preferidos',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ...MetodoPago.values.map((metodo) => _buildMetodoPagoOption(metodo)),
        const SizedBox(height: 16),
        const Text(
          'Puedes agregar certificaciones y licencias después de completar tu perfil.',
          style: TextStyle(color: Colors.blue),
        ),
      ],
    );
  }
}
