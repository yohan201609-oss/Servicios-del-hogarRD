import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/provider.dart';
import 'start_chat_screen.dart';

class ProviderDetailScreen extends StatelessWidget {
  final Provider provider;

  const ProviderDetailScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(provider.name),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareProvider(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildInfoSection(context),
            _buildServicesSection(context),
            _buildScheduleSection(context),
            _buildCertificationsSection(context),
            _buildContactSection(context),
            const SizedBox(height: 100), // Espacio para el botón flotante
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showActionDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Acciones'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue[600]!, Colors.blue[400]!],
        ),
      ),
      child: Column(
        children: [
          // Avatar del proveedor
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          // Nombre y verificación
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                provider.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (provider.isVerified) ...[
                const SizedBox(width: 8),
                Icon(Icons.verified, color: Colors.white, size: 24),
              ],
            ],
          ),
          const SizedBox(height: 8),
          // Ubicación
          Text(
            provider.location,
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          // Rating y precio
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                Icons.star,
                provider.ratingText,
                'Calificación',
                Colors.white,
              ),
              _buildStatItem(
                Icons.attach_money,
                provider.priceText,
                'Precio por hora',
                Colors.white,
              ),
              _buildStatItem(
                Icons.rate_review,
                '${provider.totalReviews}',
                'Reseñas',
                Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Información',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(provider.description, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              // Estado de disponibilidad
              Row(
                children: [
                  Icon(
                    provider.isAvailable ? Icons.check_circle : Icons.cancel,
                    color: provider.isAvailable ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    provider.availabilityText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: provider.isAvailable ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServicesSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Servicios Ofrecidos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: provider.services.map((service) {
                  return Chip(
                    label: Text(service),
                    backgroundColor: Colors.blue[50],
                    labelStyle: TextStyle(color: Colors.blue[700]),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Horarios de Atención',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...provider.schedule.entries.map((entry) {
                final day = _getDayName(entry.key);
                final time = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          day,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text(time),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCertificationsSection(BuildContext context) {
    if (provider.certifications.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Certificaciones',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...provider.certifications.map((cert) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(Icons.verified, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(cert)),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Información de Contacto',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildContactItem(
                Icons.email,
                provider.email,
                'Email',
                () => _launchEmail(provider.email),
              ),
              _buildContactItem(
                Icons.phone,
                provider.phone,
                'Teléfono',
                () => _launchPhone(provider.phone),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem(
    IconData icon,
    String value,
    String label,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: Colors.blue[600], size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  String _getDayName(String dayKey) {
    switch (dayKey) {
      case 'monday':
        return 'Lunes';
      case 'tuesday':
        return 'Martes';
      case 'wednesday':
        return 'Miércoles';
      case 'thursday':
        return 'Jueves';
      case 'friday':
        return 'Viernes';
      case 'saturday':
        return 'Sábado';
      case 'sunday':
        return 'Domingo';
      default:
        return dayKey;
    }
  }

  void _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Consulta sobre servicios - Servicios Hogar RD',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  void _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _shareProvider(BuildContext context) {
    // Implementar funcionalidad de compartir
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidad de compartir próximamente')),
    );
  }

  void _showActionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Acciones para ${provider.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.work, color: Colors.blue),
              title: const Text('Solicitar Servicio'),
              subtitle: const Text('Crear una nueva solicitud de servicio'),
              onTap: () {
                Navigator.pop(context);
                _requestService(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.green),
              title: const Text('Iniciar Chat'),
              subtitle: const Text('Comunicarse directamente'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => StartChatScreen(provider: provider),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.message, color: Colors.blue),
              title: const Text('Contactar'),
              subtitle: const Text('Enviar mensaje o llamar'),
              onTap: () {
                Navigator.pop(context);
                _contactProvider(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _requestService(BuildContext context) {
    // Por ahora mostramos un diálogo simple
    // En una implementación real, navegarías a la pantalla de solicitud
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Solicitar Servicio'),
        content: const Text(
          'Esta funcionalidad permitirá crear una solicitud de servicio. El sistema generará automáticamente una factura cuando el proveedor complete el servicio.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Aquí navegarías a CreateServiceRequestScreen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Funcionalidad de solicitud de servicio implementada',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _contactProvider(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contactar a ${provider.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Llamar'),
              subtitle: Text(provider.phone),
              onTap: () {
                Navigator.pop(context);
                _launchPhone(provider.phone);
              },
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Enviar Email'),
              subtitle: Text(provider.email),
              onTap: () {
                Navigator.pop(context);
                _launchEmail(provider.email);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }
}
