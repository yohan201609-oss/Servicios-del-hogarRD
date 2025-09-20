import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import 'complete_profile_screen.dart';

class UserTypeSelectionScreen extends StatefulWidget {
  final String email;
  final String password;

  const UserTypeSelectionScreen({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<UserTypeSelectionScreen> createState() =>
      _UserTypeSelectionScreenState();
}

class _UserTypeSelectionScreenState extends State<UserTypeSelectionScreen> {
  TipoUsuario? _selectedType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servicios Hogar RD'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              '¿Cómo quieres usar la aplicación?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Selecciona el tipo de usuario que mejor se adapte a ti. Puedes cambiar esta configuración más tarde.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: Column(
                children: [
                  _buildUserTypeOption(
                    tipo: TipoUsuario.cliente,
                    title: 'Solo Contratar Servicios',
                    description:
                        'Busco profesionales para servicios en mi hogar',
                    icon: Icons.person,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 20),
                  _buildUserTypeOption(
                    tipo: TipoUsuario.proveedor,
                    title: 'Ofrecer Servicios',
                    description: 'Soy un profesional que ofrece servicios',
                    icon: Icons.build,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 20),
                  _buildUserTypeOption(
                    tipo: TipoUsuario.ambos,
                    title: 'Contratar y Ofrecer',
                    description:
                        'Quiero tanto contratar como ofrecer servicios',
                    icon: Icons.supervisor_account,
                    color: Colors.green,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _selectedType != null ? _continueToProfile : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTypeOption({
    required TipoUsuario tipo,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedType == tipo;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = tipo;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected
                          ? color.withValues(alpha: 0.8)
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: color, size: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _continueToProfile() async {
    if (_selectedType == null) return;

    // Guardar el tipo de usuario seleccionado
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_type', _selectedType.toString());
    await prefs.setString('user_email', widget.email);
    await prefs.setString('user_password', widget.password);

    // Navegar a la pantalla de completar perfil
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => CompleteProfileScreen(
            email: widget.email,
            password: widget.password,
            tipoUsuario: _selectedType!,
          ),
        ),
      );
    }
  }
}

// Widget para mostrar información adicional sobre cada tipo
class UserTypeInfoCard extends StatelessWidget {
  final TipoUsuario tipo;
  final List<String> features;
  final Color color;

  const UserTypeInfoCard({
    super.key,
    required this.tipo,
    required this.features,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(tipo.icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                'Incluye:',
                style: TextStyle(fontWeight: FontWeight.w600, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(Icons.check, color: color, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature,
                      style: TextStyle(
                        fontSize: 14,
                        color: color.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
