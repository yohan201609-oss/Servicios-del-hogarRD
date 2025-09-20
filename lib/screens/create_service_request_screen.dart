import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../models/user_profile.dart';
import '../services/service_request_service.dart';

class CreateServiceRequestScreen extends StatefulWidget {
  final Usuario usuario;
  final Usuario proveedor;

  const CreateServiceRequestScreen({
    super.key,
    required this.usuario,
    required this.proveedor,
  });

  @override
  State<CreateServiceRequestScreen> createState() =>
      _CreateServiceRequestScreenState();
}

class _CreateServiceRequestScreenState
    extends State<CreateServiceRequestScreen> {
  final Logger _logger = Logger();
  final ServiceRequestService _serviceRequestService =
      ServiceRequestService.instance;
  final _formKey = GlobalKey<FormState>();

  final _descripcionController = TextEditingController();
  final _direccionController = TextEditingController();
  final _costoEstimadoController = TextEditingController();
  final _observacionesController = TextEditingController();

  TipoServicio _tipoServicioSeleccionado = TipoServicio.limpieza;
  DateTime? _fechaProgramada;
  bool _isLoading = false;

  @override
  void dispose() {
    _descripcionController.dispose();
    _direccionController.dispose();
    _costoEstimadoController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitar Servicio'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProviderInfoCard(),
              const SizedBox(height: 16),
              _buildServiceTypeCard(),
              const SizedBox(height: 16),
              _buildServiceDetailsCard(),
              const SizedBox(height: 16),
              _buildLocationCard(),
              const SizedBox(height: 16),
              _buildCostCard(),
              const SizedBox(height: 16),
              _buildScheduleCard(),
              const SizedBox(height: 16),
              _buildObservationsCard(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProviderInfoCard() {
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
                  'Proveedor Seleccionado',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    widget
                                .proveedor
                                .perfilProveedor
                                ?.nombreCompleto
                                .isNotEmpty ==
                            true
                        ? widget.proveedor.perfilProveedor!.nombreCompleto
                              .substring(0, 1)
                        : 'P',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.proveedor.perfilProveedor?.nombreCompleto ??
                            'Proveedor',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.proveedor.perfilProveedor?.descripcion ??
                            'Sin descripción',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceTypeCard() {
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
                  'Tipo de Servicio',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TipoServicio>(
              initialValue: _tipoServicioSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Selecciona el tipo de servicio',
                border: OutlineInputBorder(),
              ),
              items: TipoServicio.values.map((tipo) {
                return DropdownMenuItem(
                  value: tipo,
                  child: Row(
                    children: [
                      Icon(tipo.icon, size: 20),
                      const SizedBox(width: 8),
                      Text(tipo.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _tipoServicioSeleccionado = value);
                }
              },
              validator: (value) {
                if (value == null) {
                  return 'Por favor selecciona un tipo de servicio';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceDetailsCard() {
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
                  Icons.description,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Detalles del Servicio',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción del servicio *',
                hintText: 'Describe detalladamente el servicio que necesitas',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor describe el servicio que necesitas';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
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
                  Icons.location_on,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Ubicación',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _direccionController,
              decoration: const InputDecoration(
                labelText: 'Dirección completa *',
                hintText: 'Ingresa la dirección donde se realizará el servicio',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa la dirección del servicio';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostCard() {
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
                  'Costo Estimado',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _costoEstimadoController,
              decoration: const InputDecoration(
                labelText: 'Costo estimado (RD\$) *',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa un costo estimado';
                }
                final costo = double.tryParse(value);
                if (costo == null || costo <= 0) {
                  return 'Por favor ingresa un costo válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue[700], size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Este es un costo estimado. El costo final puede variar según el trabajo realizado.',
                      style: TextStyle(color: Colors.blue[700], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard() {
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
                  Icons.schedule,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Programación',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.grey[600]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _fechaProgramada != null
                            ? 'Fecha programada: ${_formatDate(_fechaProgramada!)}'
                            : 'Seleccionar fecha (opcional)',
                        style: TextStyle(
                          color: _fechaProgramada != null
                              ? Colors.black
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Si no seleccionas una fecha, el proveedor te contactará para coordinar.',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObservationsCard() {
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
                  'Observaciones Adicionales',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _observacionesController,
              decoration: const InputDecoration(
                labelText: 'Observaciones adicionales (opcional)',
                hintText:
                    'Cualquier información adicional que consideres importante',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitRequest,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Enviar Solicitud',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (fecha != null) {
      setState(() => _fechaProgramada = fecha);
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final solicitud = await _serviceRequestService.crearSolicitud(
        clienteId: widget.usuario.id,
        proveedorId: widget.proveedor.id,
        tipoServicio: _tipoServicioSeleccionado,
        descripcion: _descripcionController.text.trim(),
        direccion: _direccionController.text.trim(),
        costoEstimado: double.parse(_costoEstimadoController.text),
        fechaProgramada: _fechaProgramada,
      );

      _logger.i('Solicitud creada exitosamente: ${solicitud.id}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitud enviada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _logger.e('Error creando solicitud: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al enviar la solicitud'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
