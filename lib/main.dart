import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'config/firebase_config.dart';
import 'services/app_service.dart';
import 'screens/simple_login_screen.dart';
import 'screens/simple_home_screen.dart';
import 'models/user_profile.dart';

// Service Category Model
class ServiceCategory {
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  ServiceCategory({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with environment-specific configuration
  try {
    await Firebase.initializeApp(options: FirebaseConfig.currentOptions);
    FirebaseConfig.printDebugInfo();
  } catch (e) {
    print('Firebase initialization error: $e');
    // Continue without Firebase for now
  }

  // Initialize App Service
  await AppService.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppService _appService = AppService.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _appService.localization,
      builder: (context, child) {
        return MaterialApp(
          title: 'Servicio del HogarRD',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo[900]!),
            primarySwatch: Colors.indigo,
          ),
          locale: _appService.localization.currentLocale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [
            Locale('es', ''), // Spanish
            Locale('en', ''), // English
          ],
          home: const AuthWrapper(),
          routes: {
            '/login': (context) => const SimpleLoginScreen(),
            '/home': (context) => const SimpleHomeScreen(),
            '/profile': (context) => const SimpleHomeScreen(),
          },
        );
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AppService _appService = AppService.instance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    try {
      // Check Firebase Auth first
      final firebaseUser = _appService.auth.currentUser;
      if (firebaseUser != null) {
        await _appService.initializeUserSession(firebaseUser.uid, 'cliente');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Check local authentication
      final prefs = await SharedPreferences.getInstance();
      final usuarioJson = prefs.getString('usuario_actual');
      if (usuarioJson != null) {
        final Map<String, dynamic> jsonData = jsonDecode(usuarioJson);
        final usuario = Usuario.fromJson(jsonData);

        await _appService.initializeUserSession(
          usuario.id,
          usuario.tipoUsuario.name,
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // No user found
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error checking auth state: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // If user is logged in (Firebase or local), show home screen
    if (_appService.currentUserId != null) {
      return const SimpleHomeScreen();
    }

    // If user is not logged in, show login screen
    return const SimpleLoginScreen();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Sample service categories data
  final List<ServiceCategory> serviceCategories = [
    ServiceCategory(
      name: 'Limpieza',
      description: 'Servicios de limpieza doméstica y comercial',
      icon: Icons.cleaning_services,
      color: Colors.blue,
    ),
    ServiceCategory(
      name: 'Plomería',
      description: 'Reparaciones y mantenimiento de tuberías',
      icon: Icons.plumbing,
      color: Colors.orange,
    ),
    ServiceCategory(
      name: 'Electricidad',
      description: 'Instalaciones y reparaciones eléctricas',
      icon: Icons.electrical_services,
      color: Colors.yellow,
    ),
    ServiceCategory(
      name: 'Jardinería',
      description: 'Mantenimiento de jardines y áreas verdes',
      icon: Icons.local_florist,
      color: Colors.green,
    ),
    ServiceCategory(
      name: 'Pintura',
      description: 'Pintura interior y exterior de viviendas',
      icon: Icons.format_paint,
      color: Colors.purple,
    ),
    ServiceCategory(
      name: 'Carpintería',
      description: 'Trabajos en madera y muebles',
      icon: Icons.build,
      color: Colors.brown,
    ),
    ServiceCategory(
      name: 'Aire Acondicionado',
      description: 'Instalación y mantenimiento de AC',
      icon: Icons.ac_unit,
      color: Colors.cyan,
    ),
    ServiceCategory(
      name: 'Seguridad',
      description: 'Sistemas de seguridad y alarmas',
      icon: Icons.security,
      color: Colors.red,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              l10n.serviceCategoriesTitle,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.selectServiceType,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: serviceCategories.length,
                itemBuilder: (context, index) {
                  final category = serviceCategories[index];
                  return _buildCategoryCard(category);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(ServiceCategory category) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceDetailsPage(category: category),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                category.color.withValues(alpha: 0.1),
                category.color.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(category.icon, size: 24, color: category.color),
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
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
    );
  }
}

class ServiceDetailsPage extends StatelessWidget {
  final ServiceCategory category;

  const ServiceDetailsPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
        backgroundColor: category.color.withValues(alpha: 0.1),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(category.icon, size: 60, color: category.color),
            const SizedBox(height: 20),
            Text(
              l10n.servicesOf(category.name),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.comingSoonProviders,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
