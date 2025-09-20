import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../l10n/app_localizations.dart';
import '../models/user_profile.dart';
import '../services/settings_service.dart';
import '../services/localization_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _logger = Logger();
  final _settingsService = SettingsService();
  final _localizationService = LocalizationService.instance;
  Usuario? _usuario;
  bool _isLoading = true;

  // Configuraciones de notificaciones
  bool _notificacionesPush = true;
  bool _notificacionesEmail = true;
  bool _notificacionesSMS = false;
  bool _notificacionesPedidos = true;
  bool _notificacionesResenas = true;
  bool _notificacionesPromociones = false;

  // Configuraciones de privacidad
  bool _perfilPublico = true;
  bool _mostrarTelefono = true;
  bool _mostrarUbicacion = false;
  bool _permitirMensajes = true;

  // Configuraciones de idioma y región
  String get _idioma => _localizationService.currentLanguageCode;
  String _region = 'DO';
  String _moneda = 'DOP';

  // Configuraciones de tema
  String _tema = 'sistema';
  bool _modoOscuro = false;

  // Configuraciones de cuenta
  bool _cuentaActiva = true;
  bool _verificacionDosFactores = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSettings();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usuarioJson = prefs.getString('usuario_actual');

      if (usuarioJson != null) {
        setState(() {
          _usuario = Usuario.fromJson(jsonDecode(usuarioJson));
        });
      }
    } catch (e) {
      _logger.e('Error cargando datos del usuario: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _settingsService.loadSettings();

      setState(() {
        _notificacionesPush = settings['notificaciones_push'] ?? true;
        _notificacionesEmail = settings['notificaciones_email'] ?? true;
        _notificacionesSMS = settings['notificaciones_sms'] ?? false;
        _notificacionesPedidos = settings['notificaciones_pedidos'] ?? true;
        _notificacionesResenas = settings['notificaciones_resenas'] ?? true;
        _notificacionesPromociones =
            settings['notificaciones_promociones'] ?? false;

        _perfilPublico = settings['perfil_publico'] ?? true;
        _mostrarTelefono = settings['mostrar_telefono'] ?? true;
        _mostrarUbicacion = settings['mostrar_ubicacion'] ?? false;
        _permitirMensajes = settings['permitir_mensajes'] ?? true;

        // _idioma is now a getter, no need to assign
        _region = settings['region'] ?? 'DO';
        _moneda = settings['moneda'] ?? 'DOP';

        _tema = settings['tema'] ?? 'sistema';
        _modoOscuro = settings['modo_oscuro'] ?? false;

        _cuentaActiva = settings['cuenta_activa'] ?? true;
        _verificacionDosFactores =
            settings['verificacion_dos_factores'] ?? false;
      });
    } catch (e) {
      _logger.e('Error cargando configuraciones: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final settings = {
        'notificaciones_push': _notificacionesPush,
        'notificaciones_email': _notificacionesEmail,
        'notificaciones_sms': _notificacionesSMS,
        'notificaciones_pedidos': _notificacionesPedidos,
        'notificaciones_resenas': _notificacionesResenas,
        'notificaciones_promociones': _notificacionesPromociones,
        'perfil_publico': _perfilPublico,
        'mostrar_telefono': _mostrarTelefono,
        'mostrar_ubicacion': _mostrarUbicacion,
        'permitir_mensajes': _permitirMensajes,
        'idioma': _idioma,
        'region': _region,
        'moneda': _moneda,
        'tema': _tema,
        'modo_oscuro': _modoOscuro,
        'cuenta_activa': _cuentaActiva,
        'verificacion_dos_factores': _verificacionDosFactores,
      };

      final success = await _settingsService.saveSettings(settings);

      if (success) {
        _logger.i(AppLocalizations.of(context)!.settingsSavedSuccessfully);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.settingsSavedSuccessfully,
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Error guardando configuraciones');
      }
    } catch (e) {
      _logger.e('Error guardando configuraciones: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.settingsError}: $e'),
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

    return ListenableBuilder(
      listenable: _localizationService,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.settings),
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
            actions: [
              TextButton(
                onPressed: _saveSettings,
                child: Text(
                  AppLocalizations.of(context)!.save,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAccountSection(),
                const SizedBox(height: 24),
                _buildNotificationsSection(),
                const SizedBox(height: 24),
                _buildPrivacySection(),
                const SizedBox(height: 24),
                _buildLanguageSection(),
                const SizedBox(height: 24),
                _buildThemeSection(),
                const SizedBox(height: 24),
                _buildSecuritySection(),
                const SizedBox(height: 24),
                _buildSupportSection(),
                const SizedBox(height: 24),
                _buildAboutSection(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccountSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.account,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_usuario != null) ...[
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    _usuario!.email[0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(_usuario!.email),
                subtitle: Text(_usuario!.tipoUsuario.displayName),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Navegar a editar perfil
                },
              ),
              const Divider(),
            ],
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.accountActive),
              subtitle: Text(
                AppLocalizations.of(context)!.accountActiveDescription,
              ),
              value: _cuentaActiva,
              onChanged: (value) => setState(() => _cuentaActiva = value),
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(AppLocalizations.of(context)!.editProfile),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navegar a editar perfil
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(
                AppLocalizations.of(context)!.logout,
                style: const TextStyle(color: Colors.red),
              ),
              onTap: _showLogoutDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.notifications,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.pushNotifications),
              subtitle: Text(
                AppLocalizations.of(context)!.pushNotificationsDescription,
              ),
              value: _notificacionesPush,
              onChanged: (value) => setState(() => _notificacionesPush = value),
            ),
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.emailNotifications),
              subtitle: Text(
                AppLocalizations.of(context)!.emailNotificationsDescription,
              ),
              value: _notificacionesEmail,
              onChanged: (value) =>
                  setState(() => _notificacionesEmail = value),
            ),
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.smsNotifications),
              subtitle: Text(
                AppLocalizations.of(context)!.smsNotificationsDescription,
              ),
              value: _notificacionesSMS,
              onChanged: (value) => setState(() => _notificacionesSMS = value),
            ),
            const Divider(),
            Text(
              AppLocalizations.of(context)!.notificationTypes,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.ordersAndServices),
              subtitle: Text(
                AppLocalizations.of(context)!.ordersAndServicesDescription,
              ),
              value: _notificacionesPedidos,
              onChanged: (value) =>
                  setState(() => _notificacionesPedidos = value),
            ),
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.reviewsAndRatings),
              subtitle: Text(
                AppLocalizations.of(context)!.reviewsAndRatingsDescription,
              ),
              value: _notificacionesResenas,
              onChanged: (value) =>
                  setState(() => _notificacionesResenas = value),
            ),
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.promotions),
              subtitle: Text(
                AppLocalizations.of(context)!.promotionsDescription,
              ),
              value: _notificacionesPromociones,
              onChanged: (value) =>
                  setState(() => _notificacionesPromociones = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.privacy,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.publicProfile),
              subtitle: Text(
                AppLocalizations.of(context)!.publicProfileDescription,
              ),
              value: _perfilPublico,
              onChanged: (value) => setState(() => _perfilPublico = value),
            ),
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.showPhone),
              subtitle: Text(
                AppLocalizations.of(context)!.showPhoneDescription,
              ),
              value: _mostrarTelefono,
              onChanged: (value) => setState(() => _mostrarTelefono = value),
            ),
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.showLocation),
              subtitle: Text(
                AppLocalizations.of(context)!.showLocationDescription,
              ),
              value: _mostrarUbicacion,
              onChanged: (value) => setState(() => _mostrarUbicacion = value),
            ),
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.allowMessages),
              subtitle: Text(
                AppLocalizations.of(context)!.allowMessagesDescription,
              ),
              value: _permitirMensajes,
              onChanged: (value) => setState(() => _permitirMensajes = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.languageAndRegion,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(AppLocalizations.of(context)!.language),
              subtitle: Text(_getLanguageName(_idioma)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _showLanguageDialog,
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.region),
              subtitle: Text(_getRegionName(_region)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _showRegionDialog,
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.currency),
              subtitle: Text(_getCurrencyName(_moneda)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _showCurrencyDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.appearance,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(AppLocalizations.of(context)!.theme),
              subtitle: Text(_getThemeName(_tema)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _showThemeDialog,
            ),
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.darkMode),
              subtitle: Text(AppLocalizations.of(context)!.darkModeDescription),
              value: _modoOscuro,
              onChanged: (value) => setState(() => _modoOscuro = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.security,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.twoFactorAuth),
              subtitle: Text(
                AppLocalizations.of(context)!.twoFactorAuthDescription,
              ),
              value: _verificacionDosFactores,
              onChanged: (value) =>
                  setState(() => _verificacionDosFactores = value),
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: Text(AppLocalizations.of(context)!.changePassword),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _showChangePasswordDialog,
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: Text(AppLocalizations.of(context)!.activeSessions),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _showActiveSessionsDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.support,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.help),
              title: Text(AppLocalizations.of(context)!.helpCenter),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _openHelpCenter,
            ),
            ListTile(
              leading: const Icon(Icons.contact_support),
              title: Text(AppLocalizations.of(context)!.contactSupport),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _contactSupport,
            ),
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: Text(AppLocalizations.of(context)!.reportProblem),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _reportBug,
            ),
            ListTile(
              leading: const Icon(Icons.feedback),
              title: Text(AppLocalizations.of(context)!.sendFeedback),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _sendFeedback,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.about,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(AppLocalizations.of(context)!.appVersion),
              subtitle: const Text('1.0.0'),
              trailing: const Icon(Icons.info_outline),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.termsAndConditions),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _showTermsAndConditions,
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.privacyPolicy),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _showPrivacyPolicy,
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.licenses),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _showLicenses,
            ),
          ],
        ),
      ),
    );
  }

  // Métodos auxiliares
  String _getLanguageName(String code) {
    switch (code) {
      case 'es':
        return AppLocalizations.of(context)!.spanish;
      case 'en':
        return AppLocalizations.of(context)!.english;
      default:
        return AppLocalizations.of(context)!.spanish;
    }
  }

  String _getRegionName(String code) {
    switch (code) {
      case 'DO':
        return AppLocalizations.of(context)!.dominicanRepublic;
      case 'US':
        return AppLocalizations.of(context)!.unitedStates;
      case 'MX':
        return AppLocalizations.of(context)!.mexico;
      case 'ES':
        return AppLocalizations.of(context)!.spain;
      case 'FR':
        return AppLocalizations.of(context)!.france;
      case 'BR':
        return AppLocalizations.of(context)!.brazil;
      case 'IT':
        return AppLocalizations.of(context)!.italy;
      case 'DE':
        return AppLocalizations.of(context)!.germany;
      case 'CN':
        return AppLocalizations.of(context)!.china;
      case 'JP':
        return AppLocalizations.of(context)!.japan;
      case 'KR':
        return AppLocalizations.of(context)!.southKorea;
      case 'AE':
        return AppLocalizations.of(context)!.uae;
      case 'RU':
        return AppLocalizations.of(context)!.russia;
      case 'IN':
        return AppLocalizations.of(context)!.india;
      default:
        return AppLocalizations.of(context)!.dominicanRepublic;
    }
  }

  String _getCurrencyName(String code) {
    switch (code) {
      case 'DOP':
        return AppLocalizations.of(context)!.dominicanPeso;
      case 'USD':
        return AppLocalizations.of(context)!.usDollar;
      case 'MXN':
        return AppLocalizations.of(context)!.mexicanPeso;
      case 'EUR':
        return AppLocalizations.of(context)!.euro;
      case 'BRL':
        return AppLocalizations.of(context)!.brazilianReal;
      case 'CNY':
        return AppLocalizations.of(context)!.chineseYuan;
      case 'JPY':
        return AppLocalizations.of(context)!.japaneseYen;
      case 'KRW':
        return AppLocalizations.of(context)!.koreanWon;
      case 'AED':
        return AppLocalizations.of(context)!.uaeDirham;
      case 'RUB':
        return AppLocalizations.of(context)!.russianRuble;
      case 'INR':
        return AppLocalizations.of(context)!.indianRupee;
      default:
        return AppLocalizations.of(context)!.dominicanPeso;
    }
  }

  String _getThemeName(String theme) {
    switch (theme) {
      case 'sistema':
        return AppLocalizations.of(context)!.system;
      case 'claro':
        return AppLocalizations.of(context)!.light;
      case 'oscuro':
        return AppLocalizations.of(context)!.dark;
      default:
        return AppLocalizations.of(context)!.system;
    }
  }

  // Métodos de diálogos
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.confirmLogout),
        content: Text(AppLocalizations.of(context)!.confirmLogoutMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Implementar cierre de sesión
            },
            child: Text(AppLocalizations.of(context)!.confirmLogout),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    final languages = [
      {'code': 'es', 'name': AppLocalizations.of(context)!.spanish},
      {'code': 'en', 'name': AppLocalizations.of(context)!.english},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.selectLanguage),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: RadioGroup<String>(
            groupValue: _idioma,
            onChanged: (value) {
              LocalizationService.instance.changeLanguage(value!);
              Navigator.of(context).pop();
            },
            child: ListView.builder(
              itemCount: languages.length,
              itemBuilder: (context, index) {
                final language = languages[index];
                return RadioListTile(
                  title: Text(language['name']!),
                  value: language['code']!,
                );
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
        ],
      ),
    );
  }

  void _showRegionDialog() {
    final regions = [
      {'code': 'DO', 'name': AppLocalizations.of(context)!.dominicanRepublic},
      {'code': 'US', 'name': AppLocalizations.of(context)!.unitedStates},
      {'code': 'MX', 'name': AppLocalizations.of(context)!.mexico},
      {'code': 'ES', 'name': AppLocalizations.of(context)!.spain},
      {'code': 'FR', 'name': AppLocalizations.of(context)!.france},
      {'code': 'BR', 'name': AppLocalizations.of(context)!.brazil},
      {'code': 'IT', 'name': AppLocalizations.of(context)!.italy},
      {'code': 'DE', 'name': AppLocalizations.of(context)!.germany},
      {'code': 'CN', 'name': AppLocalizations.of(context)!.china},
      {'code': 'JP', 'name': AppLocalizations.of(context)!.japan},
      {'code': 'KR', 'name': AppLocalizations.of(context)!.southKorea},
      {'code': 'AE', 'name': AppLocalizations.of(context)!.uae},
      {'code': 'RU', 'name': AppLocalizations.of(context)!.russia},
      {'code': 'IN', 'name': AppLocalizations.of(context)!.india},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.selectRegion),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: RadioGroup<String>(
            groupValue: _region,
            onChanged: (value) {
              setState(() => _region = value!);
              Navigator.of(context).pop();
            },
            child: ListView.builder(
              itemCount: regions.length,
              itemBuilder: (context, index) {
                final region = regions[index];
                return RadioListTile(
                  title: Text(region['name']!),
                  value: region['code']!,
                );
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _showCurrencyDialog() {
    final currencies = [
      {'code': 'DOP', 'name': AppLocalizations.of(context)!.dominicanPeso},
      {'code': 'USD', 'name': AppLocalizations.of(context)!.usDollar},
      {'code': 'MXN', 'name': AppLocalizations.of(context)!.mexicanPeso},
      {'code': 'EUR', 'name': AppLocalizations.of(context)!.euro},
      {'code': 'BRL', 'name': AppLocalizations.of(context)!.brazilianReal},
      {'code': 'CNY', 'name': AppLocalizations.of(context)!.chineseYuan},
      {'code': 'JPY', 'name': AppLocalizations.of(context)!.japaneseYen},
      {'code': 'KRW', 'name': AppLocalizations.of(context)!.koreanWon},
      {'code': 'AED', 'name': AppLocalizations.of(context)!.uaeDirham},
      {'code': 'RUB', 'name': AppLocalizations.of(context)!.russianRuble},
      {'code': 'INR', 'name': AppLocalizations.of(context)!.indianRupee},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.selectCurrency),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: RadioGroup<String>(
            groupValue: _moneda,
            onChanged: (value) {
              setState(() => _moneda = value!);
              Navigator.of(context).pop();
            },
            child: ListView.builder(
              itemCount: currencies.length,
              itemBuilder: (context, index) {
                final currency = currencies[index];
                return RadioListTile(
                  title: Text(currency['name']!),
                  value: currency['code']!,
                );
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.selectTheme),
        content: RadioGroup<String>(
          groupValue: _tema,
          onChanged: (value) {
            setState(() => _tema = value!);
            Navigator.of(context).pop();
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile(
                title: Text(AppLocalizations.of(context)!.system),
                value: 'sistema',
              ),
              RadioListTile(
                title: Text(AppLocalizations.of(context)!.light),
                value: 'claro',
              ),
              RadioListTile(
                title: Text(AppLocalizations.of(context)!.dark),
                value: 'oscuro',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.changePassword),
        content: Text(AppLocalizations.of(context)!.comingSoonFeature),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  void _showActiveSessionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.activeSessions),
        content: Text(AppLocalizations.of(context)!.comingSoonFeature),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  // Métodos de soporte
  void _openHelpCenter() {
    // Implementar centro de ayuda
  }

  void _contactSupport() {
    // Implementar contacto con soporte
  }

  void _reportBug() {
    // Implementar reporte de bug
  }

  void _sendFeedback() {
    // Implementar envío de comentarios
  }

  void _showTermsAndConditions() {
    // Implementar términos y condiciones
  }

  void _showPrivacyPolicy() {
    // Implementar política de privacidad
  }

  void _showLicenses() {
    // Implementar licencias
  }
}
