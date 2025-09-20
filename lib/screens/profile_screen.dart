import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import 'complete_profile_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  UserProfile? _userProfile;
  PerfilCliente? _clienteProfile;
  PerfilProveedor? _proveedorProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _authService.currentUser;
    if (user == null) return;

    try {
      final userProfile = await _authService.getUserProfile(user.uid);
      if (userProfile != null) {
        setState(() {
          _userProfile = userProfile;
        });

        if (userProfile.userType == UserType.cliente) {
          final clienteProfile = await _authService.getClienteProfile(user.uid);
          setState(() {
            _clienteProfile = clienteProfile;
          });
        } else {
          final proveedorProfile = await _authService.getProveedorProfile(
            user.uid,
          );
          setState(() {
            _proveedorProfile = proveedorProfile;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando perfil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _switchUserType(UserType newType) async {
    final user = _authService.currentUser;
    if (user == null) return;

    try {
      await _authService.updateUserType(user.uid, newType);

      // Recargar datos
      await _loadUserData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cambiado a modo ${newType.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cambiando modo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _completeProfile() async {
    if (_userProfile == null) return;

    // Convert UserType to TipoUsuario
    TipoUsuario tipoUsuario;
    switch (_userProfile!.userType) {
      case UserType.cliente:
        tipoUsuario = TipoUsuario.cliente;
        break;
      case UserType.proveedor:
        tipoUsuario = TipoUsuario.proveedor;
        break;
    }

    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => CompleteProfileScreen(
              email: _userProfile!.email,
              password: '', // Password is not available in UserProfile
              tipoUsuario: tipoUsuario,
            ),
          ),
        )
        .then((_) => _loadUserData());
  }

  Future<void> _editProfile() async {
    // Cargar usuario actual desde SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final usuarioJson = prefs.getString('usuario_actual');

      if (usuarioJson != null) {
        final usuario = Usuario.fromJson(jsonDecode(usuarioJson));

        // Check if widget is still mounted before using context
        if (!mounted) return;

        Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (context) => EditProfileScreen(
                  usuario: usuario,
                  isProviderMode:
                      usuario.tipoUsuario == TipoUsuario.proveedor ||
                      usuario.tipoUsuario == TipoUsuario.ambos,
                ),
              ),
            )
            .then((success) {
              if (success == true) {
                _loadUserData(); // Recargar datos después de editar
              }
            });
      } else {
        // Check if widget is still mounted before using context
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se encontró información del usuario'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Check if widget is still mounted before using context
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cargando perfil: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_userProfile == null) {
      return const Scaffold(body: Center(child: Text('Error cargando perfil')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _userProfile!.isProfileComplete
                ? _editProfile
                : _completeProfile,
            icon: Icon(
              _userProfile!.isProfileComplete ? Icons.edit : Icons.add,
            ),
            tooltip: _userProfile!.isProfileComplete
                ? 'Editar Perfil'
                : 'Completar Perfil',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con información básica
            _buildProfileHeader(),
            const SizedBox(height: 24),

            // Botón para cambiar modo
            _buildModeSwitch(),
            const SizedBox(height: 24),

            // Información del perfil específico
            if (_userProfile!.userType == UserType.cliente)
              _buildClienteInfo()
            else
              _buildProveedorInfo(),

            const SizedBox(height: 24),

            // Botón de cerrar sesión
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                _userProfile!.name.isNotEmpty
                    ? _userProfile!.name[0].toUpperCase()
                    : 'U',
                style: const TextStyle(fontSize: 32, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _userProfile!.name,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _userProfile!.email,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _userProfile!.userType == UserType.cliente
                    ? Colors.blue.withValues(alpha: 0.1)
                    : Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _userProfile!.userType == UserType.cliente
                    ? 'Cliente'
                    : 'Proveedor',
                style: TextStyle(
                  color: _userProfile!.userType == UserType.cliente
                      ? Colors.blue[700]
                      : Colors.green[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSwitch() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Modo de Usuario',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              'Puedes cambiar entre modo Cliente y Proveedor según necesites.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _userProfile!.userType == UserType.cliente
                        ? null
                        : () => _switchUserType(UserType.cliente),
                    icon: const Icon(Icons.person),
                    label: const Text('Modo Cliente'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          _userProfile!.userType == UserType.cliente
                          ? Colors.blue
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _userProfile!.userType == UserType.proveedor
                        ? null
                        : () => _switchUserType(UserType.proveedor),
                    icon: const Icon(Icons.business),
                    label: const Text('Modo Proveedor'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          _userProfile!.userType == UserType.proveedor
                          ? Colors.green
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClienteInfo() {
    if (_clienteProfile == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Icon(Icons.info_outline, size: 48, color: Colors.orange),
              const SizedBox(height: 16),
              const Text(
                'Perfil de Cliente Incompleto',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Completa tu perfil para una mejor experiencia.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _completeProfile,
                child: const Text('Completar Perfil'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información del Cliente',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Teléfono', _clienteProfile!.telefono),
            _buildInfoRow('Dirección', _clienteProfile!.direccionPrincipal),
            _buildInfoRow(
              'Métodos de Pago',
              _clienteProfile!.metodosPago
                  .map((e) => _getPaymentMethodName(e))
                  .join(', '),
            ),
            _buildInfoRow(
              'Direcciones Guardadas',
              '${_clienteProfile!.direccionesGuardadas.length} direcciones',
            ),
            _buildInfoRow(
              'Horarios Preferidos',
              _clienteProfile!.preferencias.horariosDisponibles.join(', '),
            ),
            _buildInfoRow(
              'Servicios Favoritos',
              _clienteProfile!.preferencias.tiposServiciosFrecuentes
                  .map((e) => _getServiceCategoryName(e))
                  .join(', '),
            ),
            _buildInfoRow(
              'Valoración Promedio',
              '${_clienteProfile!.valoracionPromedio.toStringAsFixed(1)} ⭐',
            ),
            _buildInfoRow(
              'Total Reseñas',
              '${_clienteProfile!.resenas.length}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProveedorInfo() {
    if (_proveedorProfile == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Icon(Icons.info_outline, size: 48, color: Colors.orange),
              const SizedBox(height: 16),
              const Text(
                'Perfil de Proveedor Incompleto',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Completa tu perfil para empezar a ofrecer servicios.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _completeProfile,
                child: const Text('Completar Perfil'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información del Proveedor',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Cédula/RNC', _proveedorProfile!.cedulaRnc),
            _buildInfoRow(
              'Categorías',
              _proveedorProfile!.categoriasServicios
                  .map((e) => _getServiceCategoryName(e))
                  .join(', '),
            ),
            _buildInfoRow('Experiencia', _proveedorProfile!.experiencia),
            _buildInfoRow('Descripción', _proveedorProfile!.descripcion),
            _buildInfoRow('Ubicación Base', _proveedorProfile!.ubicacionBase),
            _buildInfoRow(
              'Días Disponibles',
              _proveedorProfile!.disponibilidad.diasDisponibles.join(', '),
            ),
            _buildInfoRow(
              'Servicios de Emergencia',
              _proveedorProfile!.disponibilidad.serviciosEmergencia
                  ? 'Sí'
                  : 'No',
            ),
            _buildInfoRow(
              'Métodos de Cobro',
              _proveedorProfile!.metodosCobro
                  .map((e) => _getPaymentMethodName(e))
                  .join(', '),
            ),
            _buildInfoRow(
              'Valoración Promedio',
              '${_proveedorProfile!.valoracionPromedio.toStringAsFixed(1)} ⭐',
            ),
            _buildInfoRow(
              'Total Reseñas',
              '${_proveedorProfile!.resenas.length}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'No especificado' : value,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          try {
            await _authService.signOut();
            if (mounted) {
              Navigator.of(context).pushReplacementNamed('/login');
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error cerrando sesión: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        icon: const Icon(Icons.logout),
        label: const Text('Cerrar Sesión'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  String _getPaymentMethodName(MetodoPago method) {
    switch (method) {
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

  String _getServiceCategoryName(TipoServicio category) {
    switch (category) {
      case TipoServicio.limpieza:
        return 'Limpieza';
      case TipoServicio.plomeria:
        return 'Plomería';
      case TipoServicio.electricidad:
        return 'Electricidad';
      case TipoServicio.jardineria:
        return 'Jardinería';
      case TipoServicio.pintura:
        return 'Pintura';
      case TipoServicio.carpinteria:
        return 'Carpintería';
      case TipoServicio.aireAcondicionado:
        return 'Aire Acondicionado';
      case TipoServicio.seguridad:
        return 'Seguridad';
      case TipoServicio.cerrajeria:
        return 'Cerrajería';
      case TipoServicio.albanileria:
        return 'Albañilería';
      case TipoServicio.limpiezaPiscinas:
        return 'Limpieza de Piscinas';
      case TipoServicio.mudanzas:
        return 'Mudanzas';
    }
  }
}
