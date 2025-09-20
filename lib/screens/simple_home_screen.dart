import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../constants/app_constants.dart';
import '../services/auth_service.dart';
import 'simple_login_screen.dart';
import 'provider_profile_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'provider_list_screen.dart';
import 'invoice_history_screen.dart';
import 'provider_services_screen.dart';
import 'chat_list_screen.dart';
import '../models/user_profile.dart';

class SimpleHomeScreen extends StatefulWidget {
  const SimpleHomeScreen({super.key});

  @override
  State<SimpleHomeScreen> createState() => _SimpleHomeScreenState();
}

class _SimpleHomeScreenState extends State<SimpleHomeScreen> {
  int _selectedIndex = 0;
  Usuario? _usuarioActual;
  final _logger = Logger();
  final AuthService _authService = AuthService();
  bool _isProviderMode = false; // false = cliente, true = proveedor

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadModePreference();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usuarioJson = prefs.getString('usuario_actual');
      if (usuarioJson != null) {
        // Parse the JSON string to get the actual user data
        final Map<String, dynamic> jsonData = jsonDecode(usuarioJson);

        // Create Usuario from the parsed JSON
        setState(() {
          _usuarioActual = Usuario.fromJson(jsonData);
        });
        _logger.i(
          'User loaded successfully: ${_usuarioActual?.tipoUsuario.displayName}',
        );
      } else {
        _logger.w('No user data found in SharedPreferences');
      }
    } catch (e) {
      _logger.e('Error loading user data: $e');
      // Fallback to demo user if there's an error
      setState(() {
        _usuarioActual = Usuario(
          id: '1',
          email: 'usuario@demo.com',
          password: 'demo',
          tipoUsuario: TipoUsuario.cliente,
          fechaCreacion: DateTime.now(),
        );
      });
    }
  }

  Future<void> _loadModePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isProviderMode = prefs.getBool('is_provider_mode') ?? false;
      setState(() {
        _isProviderMode = isProviderMode;
      });
    } catch (e) {
      _logger.e('Error loading mode preference: $e');
    }
  }

  Future<void> _toggleMode() async {
    setState(() {
      _isProviderMode = !_isProviderMode;
    });

    // Guardar preferencia
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_provider_mode', _isProviderMode);
    } catch (e) {
      _logger.e('Error saving mode preference: $e');
    }

    // Si cambió a modo proveedor, navegar directamente al panel de proveedor
    if (_isProviderMode &&
        (_usuarioActual?.tipoUsuario == TipoUsuario.proveedor ||
            _usuarioActual?.tipoUsuario == TipoUsuario.ambos)) {
      // La navegación se manejará automáticamente en el build method
    }
  }

  List<Widget> get pages => [
    HomePage(usuario: _usuarioActual),
    ServicesPage(usuario: _usuarioActual),
    const ChatListScreen(),
    ProfilePage(usuario: _usuarioActual),
  ];

  @override
  Widget build(BuildContext context) {
    // Si el usuario no puede ser proveedor, mostrar solo vista de cliente
    if (_usuarioActual?.tipoUsuario == TipoUsuario.cliente) {
      return _buildClientView();
    }

    // Si el usuario puede ser proveedor, mostrar la pantalla de selección de modo
    if (_usuarioActual?.tipoUsuario == TipoUsuario.proveedor ||
        _usuarioActual?.tipoUsuario == TipoUsuario.ambos) {
      // Si ya se seleccionó un modo, mostrar la vista correspondiente
      if (_isProviderMode) {
        return ProviderProfileScreen(usuario: _usuarioActual!);
      } else {
        return _buildClientView();
      }
    }

    // Fallback a vista de cliente
    return _buildClientView();
  }

  Widget _buildClientView() {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          // Mostrar switch de modo solo si el usuario puede ser proveedor
          if (_usuarioActual?.tipoUsuario == TipoUsuario.proveedor ||
              _usuarioActual?.tipoUsuario == TipoUsuario.ambos)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isProviderMode
                      ? AppLocalizations.of(context)!.provider
                      : AppLocalizations.of(context)!.client,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: _isProviderMode,
                  onChanged: (value) => _toggleMode(),
                  activeThumbColor: Colors.orange,
                ),
              ],
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await _authService.signOut();
                // Clear saved credentials
                await _authService.clearSavedCredentials();
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const SimpleLoginScreen(),
                    ),
                  );
                }
              } catch (e) {
                _logger.e('Error signing out: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al cerrar sesión: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body:
          _isProviderMode &&
              (_usuarioActual?.tipoUsuario == TipoUsuario.proveedor ||
                  _usuarioActual?.tipoUsuario == TipoUsuario.ambos)
          ? _buildModeSelectionScreen()
          : pages[_selectedIndex],
      bottomNavigationBar:
          _isProviderMode &&
              (_usuarioActual?.tipoUsuario == TipoUsuario.proveedor ||
                  _usuarioActual?.tipoUsuario == TipoUsuario.ambos)
          ? null
          : BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home),
                  label: AppLocalizations.of(context)!.home,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.build),
                  label: AppLocalizations.of(context)!.services,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.chat),
                  label: 'Chat',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person),
                  label: AppLocalizations.of(context)!.profile,
                ),
              ],
            ),
    );
  }

  Widget _buildModeSelectionScreen() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.supervisor_account, size: 80, color: Colors.blue),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.whatDoYouWantToDo,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.selectModeDescription,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _buildModeOption(
            title: AppLocalizations.of(context)!.searchService,
            description: AppLocalizations.of(context)!.searchServiceDescription,
            icon: Icons.search,
            color: Colors.blue,
            onTap: () {
              setState(() {
                _isProviderMode = false;
              });
              _toggleMode();
            },
          ),
          const SizedBox(height: 20),
          _buildModeOption(
            title: AppLocalizations.of(context)!.offerService,
            description: AppLocalizations.of(context)!.offerServiceDescription,
            icon: Icons.build,
            color: Colors.orange,
            onTap: () {
              setState(() {
                _isProviderMode = true;
              });
              _toggleMode();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModeOption({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final Usuario? usuario;

  const HomePage({super.key, this.usuario});

  String _getWelcomeMessage(BuildContext context) {
    if (usuario == null) {
      return AppLocalizations.of(context)!.welcomeMessage('');
    }

    String nombre = '';

    // Obtener nombre del perfil correspondiente
    if (usuario!.tipoUsuario == TipoUsuario.cliente &&
        usuario!.perfilCliente != null) {
      nombre = ' ${usuario!.perfilCliente!.nombre}';
    } else if (usuario!.tipoUsuario == TipoUsuario.proveedor &&
        usuario!.perfilProveedor != null) {
      nombre = ' ${usuario!.perfilProveedor!.nombreCompleto}';
    } else if (usuario!.tipoUsuario == TipoUsuario.ambos) {
      // Si es ambos, usar el perfil de cliente si existe, sino el de proveedor
      if (usuario!.perfilCliente != null) {
        nombre = ' ${usuario!.perfilCliente!.nombre}';
      } else if (usuario!.perfilProveedor != null) {
        nombre = ' ${usuario!.perfilProveedor!.nombreCompleto}';
      }
    }

    // Si no hay nombre, usar el email como fallback
    if (nombre.isEmpty) {
      nombre = ' ${usuario!.email.split('@')[0]}';
    }

    return AppLocalizations.of(context)!.welcomeMessage(nombre);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getWelcomeMessage(context),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.welcomeSubtitle,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)!.serviceCategories,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calcular el aspect ratio dinámicamente basado en el espacio disponible
                final availableHeight = constraints.maxHeight;
                final availableWidth = constraints.maxWidth;
                final crossAxisCount = 4;
                final crossAxisSpacing = 4.0;
                final mainAxisSpacing = 4.0;

                // Calcular el ancho de cada item
                final itemWidth =
                    (availableWidth -
                        (crossAxisSpacing * (crossAxisCount - 1))) /
                    crossAxisCount;

                // Calcular la altura necesaria para 3 filas (12 items / 4 columnas = 3 filas)
                final rows = 3;
                final totalMainAxisSpacing = mainAxisSpacing * (rows - 1);
                final availableHeightForItems =
                    availableHeight - totalMainAxisSpacing;
                final itemHeight = availableHeightForItems / rows;

                // Calcular aspect ratio dinámico
                final dynamicAspectRatio = itemWidth / itemHeight;

                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: crossAxisSpacing,
                  mainAxisSpacing: mainAxisSpacing,
                  childAspectRatio: dynamicAspectRatio,
                  padding: const EdgeInsets.only(bottom: 4),
                  children: [
                    _buildServiceCard(
                      AppLocalizations.of(context)!.plumbing,
                      Icons.plumbing,
                      Colors.blue,
                    ),
                    _buildServiceCard(
                      AppLocalizations.of(context)!.electricity,
                      Icons.electrical_services,
                      Colors.orange,
                    ),
                    _buildServiceCard(
                      AppLocalizations.of(context)!.cleaning,
                      Icons.cleaning_services,
                      Colors.green,
                    ),
                    _buildServiceCard(
                      AppLocalizations.of(context)!.gardening,
                      Icons.yard,
                      Colors.brown,
                    ),
                    _buildServiceCard(
                      AppLocalizations.of(context)!.painting,
                      Icons.format_paint,
                      Colors.purple,
                    ),
                    _buildServiceCard(
                      AppLocalizations.of(context)!.carpentry,
                      Icons.build,
                      Colors.amber,
                    ),
                    _buildServiceCard(
                      AppLocalizations.of(context)!.airConditioning,
                      Icons.ac_unit,
                      Colors.cyan,
                    ),
                    _buildServiceCard(
                      AppLocalizations.of(context)!.locksmith,
                      Icons.lock,
                      Colors.grey,
                    ),
                    _buildServiceCard(
                      AppLocalizations.of(context)!.masonry,
                      Icons.construction,
                      Colors.deepOrange,
                    ),
                    _buildServiceCard(
                      AppLocalizations.of(context)!.poolCleaning,
                      Icons.pool,
                      Colors.lightBlue,
                    ),
                    _buildServiceCard(
                      AppLocalizations.of(context)!.security,
                      Icons.security,
                      Colors.red,
                    ),
                    _buildServiceCard(
                      AppLocalizations.of(context)!.moving,
                      Icons.local_shipping,
                      Colors.teal,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(String title, IconData icon, Color color) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(1),
      child: Builder(
        builder: (context) => InkWell(
          onTap: () => _showServiceDetails(context, title, icon, color),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(flex: 2, child: Icon(icon, size: 24, color: color)),
                const SizedBox(height: 1),
                Flexible(
                  flex: 1,
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showServiceDetails(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    // Navegar directamente a la lista de proveedores
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProviderListScreen(
          category: title,
          categoryIcon: icon,
          categoryColor: color,
        ),
      ),
    );
  }
}

class ServicesPage extends StatelessWidget {
  final Usuario? usuario;

  const ServicesPage({super.key, this.usuario});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.myServices,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildServiceItem(
                  'Reparación de grifo',
                  AppLocalizations.of(context)!.plumbing,
                  AppLocalizations.of(context)!.pending,
                ),
                _buildServiceItem(
                  'Instalación eléctrica',
                  AppLocalizations.of(context)!.electricity,
                  AppLocalizations.of(context)!.inProgress,
                ),
                _buildServiceItem(
                  'Limpieza general',
                  AppLocalizations.of(context)!.cleaning,
                  AppLocalizations.of(context)!.completed,
                ),
                _buildServiceItem(
                  'Mantenimiento de aire acondicionado',
                  AppLocalizations.of(context)!.airConditioning,
                  AppLocalizations.of(context)!.pending,
                ),
                _buildServiceItem(
                  'Pintura de fachada',
                  AppLocalizations.of(context)!.painting,
                  AppLocalizations.of(context)!.inProgress,
                ),
                _buildServiceItem(
                  'Limpieza de piscina',
                  AppLocalizations.of(context)!.poolCleaning,
                  AppLocalizations.of(context)!.completed,
                ),
                _buildServiceItem(
                  'Reparación de cerradura',
                  AppLocalizations.of(context)!.locksmith,
                  AppLocalizations.of(context)!.pending,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(String title, String category, String status) {
    Color statusColor;
    switch (status) {
      case 'Completed':
      case 'Completado':
        statusColor = Colors.green;
        break;
      case 'In Progress':
      case 'En progreso':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Icon(Icons.build, color: Colors.blue[600]),
        ),
        title: Text(title),
        subtitle: Text(category),
        trailing: Chip(
          label: Text(
            status,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          backgroundColor: statusColor,
        ),
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  final Usuario? usuario;

  const ProfilePage({super.key, this.usuario});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.myProfile,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.usuario?.email ?? 'Usuario Demo',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.usuario?.tipoUsuario.displayName ?? 'Cliente',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  if (widget.usuario?.tipoUsuario == TipoUsuario.proveedor ||
                      widget.usuario?.tipoUsuario == TipoUsuario.ambos)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ProviderProfileScreen(usuario: widget.usuario!),
                          ),
                        );
                      },
                      icon: const Icon(Icons.build),
                      label: Text(AppLocalizations.of(context)!.providerPanel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildProfileStat(
                        AppLocalizations.of(context)!.servicesLabel,
                        '12',
                      ),
                      _buildProfileStat(
                        AppLocalizations.of(context)!.completedServices,
                        '8',
                      ),
                      _buildProfileStat(
                        AppLocalizations.of(context)!.pendingServices,
                        '4',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildProfileOption(
                  context,
                  Icons.edit,
                  AppLocalizations.of(context)!.editProfileButton,
                ),
                _buildProfileOption(context, Icons.chat, 'Conversaciones'),
                if (widget.usuario?.tipoUsuario == TipoUsuario.proveedor ||
                    widget.usuario?.tipoUsuario == TipoUsuario.ambos)
                  _buildProfileOption(context, Icons.work, 'Mis Servicios'),
                _buildProfileOption(
                  context,
                  Icons.receipt_long,
                  'Historial de Facturas',
                ),
                _buildProfileOption(
                  context,
                  Icons.settings,
                  AppLocalizations.of(context)!.settings,
                ),
                _buildProfileOption(
                  context,
                  Icons.help,
                  AppLocalizations.of(context)!.help,
                ),
                _buildProfileOption(
                  context,
                  Icons.info,
                  AppLocalizations.of(context)!.about,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildProfileOption(
    BuildContext context,
    IconData icon,
    String title,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue[600]),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _handleProfileOptionTap(context, title),
      ),
    );
  }

  void _handleProfileOptionTap(BuildContext context, String title) {
    switch (title) {
      case 'Edit Profile':
      case 'Editar Perfil':
        if (widget.usuario?.tipoUsuario == TipoUsuario.proveedor ||
            widget.usuario?.tipoUsuario == TipoUsuario.ambos) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  ProviderProfileScreen(usuario: widget.usuario!),
            ),
          );
        } else {
          _showEditProfileDialog(context);
        }
        break;
      case 'Conversaciones':
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const ChatListScreen()));
        break;
      case 'Mis Servicios':
        if (widget.usuario != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  ProviderServicesScreen(usuario: widget.usuario!),
            ),
          );
        }
        break;
      case 'Historial de Facturas':
        if (widget.usuario != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  InvoiceHistoryScreen(usuario: widget.usuario!),
            ),
          );
        }
        break;
      case 'Settings':
      case 'Configuración':
        _showSettingsDialog(context);
        break;
      case 'Help':
      case 'Ayuda':
        _showHelpDialog(context);
        break;
      case 'About':
      case 'Acerca de':
        _showAboutDialog(context);
        break;
      default:
        _showComingSoonDialog(context, title);
    }
  }

  void _showEditProfileDialog(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usuarioJson = prefs.getString('usuario_actual');

      if (usuarioJson != null) {
        final usuario = Usuario.fromJson(jsonDecode(usuarioJson));

        if (mounted && context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EditProfileScreen(
                usuario: usuario,
                isProviderMode:
                    usuario.tipoUsuario == TipoUsuario.proveedor ||
                    usuario.tipoUsuario == TipoUsuario.ambos,
              ),
            ),
          );
        }
      } else {
        if (mounted && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.noUserData),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context)!.errorLoadingProfile}: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSettingsDialog(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
  }

  void _showHelpDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.help_outline, color: Colors.blue[600]),
              const SizedBox(width: 8),
              Text(l10n.help),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.helpMessage, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📧 Email de Soporte:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        AppConstants.supportEmail,
                        style: TextStyle(color: Colors.blue[600], fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Clipboard.setData(
                  ClipboardData(text: AppConstants.supportEmail),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Email copiado: ${AppConstants.supportEmail}',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copiar Email'),
            ),
            TextButton.icon(
              onPressed: () async {
                final Uri emailUri = Uri(
                  scheme: 'mailto',
                  path: AppConstants.supportEmail,
                  query: 'subject=Soporte - Servicios Hogar RD',
                );
                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(emailUri);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No se pudo abrir el cliente de email'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.email),
              label: const Text('Enviar Email'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.close),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.about),
          content: Text(l10n.aboutMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.close),
            ),
          ],
        );
      },
    );
  }

  void _showComingSoonDialog(BuildContext context, String title) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(l10n.comingSoon),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.close),
            ),
          ],
        );
      },
    );
  }
}
