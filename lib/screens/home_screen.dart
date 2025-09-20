import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_profile.dart';
import '../main.dart';
import 'profile_screen.dart';
import 'complete_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = _authService.currentUser;
    if (user == null) return;

    try {
      final profile = await _authService.getUserProfile(user.uid);
      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      // Clear saved credentials when signing out
      await _authService.clearSavedCredentials();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Si el perfil no está completo, mostrar pantalla de completar perfil
    if (_userProfile != null && !_userProfile!.isProfileComplete) {
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

      return CompleteProfileScreen(
        email: _userProfile!.email,
        password: '', // Password is not available in UserProfile
        tipoUsuario: tipoUsuario,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Servicio del HogarRD'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  )
                  .then((_) => _loadUserProfile());
            },
            icon: const Icon(Icons.person),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _signOut();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Cerrar Sesión'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: const MyHomePage(title: 'Servicio del HogarRD'),
    );
  }
}
