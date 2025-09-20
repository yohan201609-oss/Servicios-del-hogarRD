import 'package:flutter/material.dart';
import '../models/service_request.dart';
import '../models/user_profile.dart';

class ServiceDetailScreen extends StatelessWidget {
  final SolicitudServicio solicitud;
  final Usuario usuario;

  const ServiceDetailScreen({
    super.key,
    required this.solicitud,
    required this.usuario,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(solicitud.tipoServicio.displayName),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(context),
            const SizedBox(height: 16),
            _buildServiceInfoCard(context),
            const SizedBox(height: 16),
            _buildClientInfoCard(context),
            const SizedBox(height: 16),
            _buildCostCard(context),
            const SizedBox(height: 16),
            _buildTimelineCard(context),
            if (solicitud.observacionesProveedor != null) ...[
              const SizedBox(height: 16),
              _buildObservationsCard(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getEstadoColor(solicitud.estado).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getEstadoIcon(solicitud.estado),
                color: _getEstadoColor(solicitud.estado),
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              solicitud.estado.displayName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _getEstadoColor(solicitud.estado),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getEstadoDescription(solicitud.estado),
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceInfoCard(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.build, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Información del Servicio',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Tipo de Servicio',
              solicitud.tipoServicio.displayName,
            ),
            _buildInfoRow('Descripción', solicitud.descripcion),
            _buildInfoRow('Dirección', solicitud.direccion),
            if (solicitud.fechaProgramada != null)
              _buildInfoRow(
                'Fecha Programada',
                _formatDateTime(solicitud.fechaProgramada!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientInfoCard(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Información del Cliente',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('ID Cliente', solicitud.clienteId),
            // En una app real, aquí mostrarías el nombre real del cliente
            _buildInfoRow('Nombre', 'Cliente Ejemplo'),
            _buildInfoRow('Email', 'cliente@ejemplo.com'),
          ],
        ),
      ),
    );
  }

  Widget _buildCostCard(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.attach_money,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Información de Costos',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Costo Estimado',
              '\$${solicitud.costoEstimado.toStringAsFixed(2)}',
            ),
            if (solicitud.costoFinal != null)
              _buildInfoRow(
                'Costo Final',
                '\$${solicitud.costoFinal!.toStringAsFixed(2)}',
              ),
            if (solicitud.duracionServicio != null)
              _buildInfoRow('Duración', solicitud.duracionText),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timeline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Cronología',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTimelineItem(
              'Solicitud Creada',
              solicitud.fechaSolicitud,
              Icons.add_circle,
              Colors.blue,
            ),
            if (solicitud.fechaInicio != null)
              _buildTimelineItem(
                'Servicio Iniciado',
                solicitud.fechaInicio!,
                Icons.play_circle,
                Colors.green,
              ),
            if (solicitud.fechaCompletado != null)
              _buildTimelineItem(
                'Servicio Completado',
                solicitud.fechaCompletado!,
                Icons.check_circle,
                Colors.green,
              ),
            if (solicitud.facturaId != null)
              _buildTimelineItem(
                'Factura Generada',
                solicitud.fechaCompletado ?? DateTime.now(),
                Icons.receipt,
                Colors.orange,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildObservationsCard(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notes, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Observaciones del Proveedor',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                solicitud.observacionesProveedor!,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    DateTime date,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  _formatDateTime(date),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getEstadoColor(EstadoSolicitud estado) {
    switch (estado) {
      case EstadoSolicitud.pendiente:
        return Colors.orange;
      case EstadoSolicitud.confirmada:
        return Colors.blue;
      case EstadoSolicitud.enProgreso:
        return Colors.purple;
      case EstadoSolicitud.completada:
        return Colors.green;
      case EstadoSolicitud.facturada:
        return Colors.teal;
      case EstadoSolicitud.cancelada:
        return Colors.red;
    }
  }

  IconData _getEstadoIcon(EstadoSolicitud estado) {
    switch (estado) {
      case EstadoSolicitud.pendiente:
        return Icons.pending;
      case EstadoSolicitud.confirmada:
        return Icons.check_circle_outline;
      case EstadoSolicitud.enProgreso:
        return Icons.work;
      case EstadoSolicitud.completada:
        return Icons.check_circle;
      case EstadoSolicitud.facturada:
        return Icons.receipt;
      case EstadoSolicitud.cancelada:
        return Icons.cancel;
    }
  }

  String _getEstadoDescription(EstadoSolicitud estado) {
    switch (estado) {
      case EstadoSolicitud.pendiente:
        return 'Esperando confirmación del proveedor';
      case EstadoSolicitud.confirmada:
        return 'Servicio confirmado, listo para iniciar';
      case EstadoSolicitud.enProgreso:
        return 'Servicio en progreso';
      case EstadoSolicitud.completada:
        return 'Servicio completado exitosamente';
      case EstadoSolicitud.facturada:
        return 'Servicio completado y facturado';
      case EstadoSolicitud.cancelada:
        return 'Servicio cancelado';
    }
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
