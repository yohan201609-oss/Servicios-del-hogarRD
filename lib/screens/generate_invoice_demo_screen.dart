import 'package:flutter/material.dart';
import '../models/invoice.dart';
import '../models/user_profile.dart';
import '../services/invoice_service.dart';
import 'invoice_history_screen.dart';

class GenerateInvoiceDemoScreen extends StatefulWidget {
  final Usuario usuario;

  const GenerateInvoiceDemoScreen({super.key, required this.usuario});

  @override
  State<GenerateInvoiceDemoScreen> createState() =>
      _GenerateInvoiceDemoScreenState();
}

class _GenerateInvoiceDemoScreenState extends State<GenerateInvoiceDemoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _notasController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _descripcionController.dispose();
    _precioController.dispose();
    _cantidadController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generar Factura de Ejemplo'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Crear Factura de Ejemplo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Esta pantalla demuestra la generación de facturas. En una implementación real, esta funcionalidad se integraría en el flujo de cierre de servicios.',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detalles del Servicio',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descripcionController,
                        decoration: const InputDecoration(
                          labelText: 'Descripción del Servicio *',
                          hintText:
                              'Ej: Limpieza de casa, Reparación eléctrica',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        validator: (value) => value?.isEmpty == true
                            ? 'Descripción requerida'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _cantidadController,
                              decoration: const InputDecoration(
                                labelText: 'Cantidad *',
                                hintText: '1',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.numbers),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty == true) {
                                  return 'Cantidad requerida';
                                }
                                if (int.tryParse(value!) == null) {
                                  return 'Número inválido';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _precioController,
                              decoration: const InputDecoration(
                                labelText: 'Precio por Unidad *',
                                hintText: '100.00',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.attach_money),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty == true) {
                                  return 'Precio requerido';
                                }
                                if (double.tryParse(value!) == null) {
                                  return 'Precio inválido';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notasController,
                        decoration: const InputDecoration(
                          labelText: 'Notas Adicionales',
                          hintText: 'Información adicional sobre el servicio',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.note),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información de las Partes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPartyInfo('Cliente', widget.usuario, Colors.green),
                      const SizedBox(height: 12),
                      _buildPartyInfo(
                        'Proveedor',
                        _createDemoProvider(),
                        Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _generarFactura,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.receipt_long),
                  label: Text(_isLoading ? 'Generando...' : 'Generar Factura'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'La factura se generará como PDF, se enviará por email y se guardará en el historial.',
                        style: TextStyle(color: Colors.blue[700], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPartyInfo(String titulo, Usuario usuario, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _obtenerNombreUsuario(usuario),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            usuario.email,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _obtenerNombreUsuario(Usuario usuario) {
    if (usuario.perfilCliente != null) {
      return '${usuario.perfilCliente!.nombre} ${usuario.perfilCliente!.apellido}';
    } else if (usuario.perfilProveedor != null) {
      return usuario.perfilProveedor!.nombreCompleto;
    }
    return usuario.email;
  }

  Usuario _createDemoProvider() {
    // Crear un proveedor de ejemplo
    return Usuario(
      id: 'demo_provider_123',
      email: 'proveedor@ejemplo.com',
      password: 'password123',
      tipoUsuario: TipoUsuario.proveedor,
      fechaCreacion: DateTime.now(),
      perfilProveedor: PerfilProveedor(
        usuarioId: 'demo_provider_123',
        nombreCompleto: 'Juan Pérez',
        cedulaRnc: '123-4567890-1',
        categoriasServicios: [TipoServicio.limpieza, TipoServicio.electricidad],
        experiencia: '5 años de experiencia',
        descripcion: 'Proveedor de servicios de limpieza y electricidad.',
        portafolioFotos: [],
        disponibilidad: DisponibilidadProveedor(
          diasDisponibles: [
            'Lunes',
            'Martes',
            'Miércoles',
            'Jueves',
            'Viernes',
          ],
          horarioInicio: '08:00',
          horarioFin: '18:00',
          serviciosEmergencia: false,
          areasCobertura: ['Santo Domingo', 'Distrito Nacional'],
        ),
        ubicacionBase: 'Santo Domingo',
        certificaciones: ['Certificado de Limpieza', 'Certificado Eléctrico'],
        licencias: ['Licencia A'],
        tieneSeguro: true,
        metodosCobro: [MetodoPago.tarjeta, MetodoPago.efectivo],
        valoracionPromedio: 4.8,
        resenas: [],
        totalServicios: 150,
      ),
    );
  }

  Future<void> _generarFactura() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Crear items de la factura
      final items = [
        ItemFactura(
          id: 'item_1',
          descripcion: _descripcionController.text.trim(),
          cantidad: int.parse(_cantidadController.text),
          precioUnitario: double.parse(_precioController.text),
          notas: _notasController.text.trim().isNotEmpty
              ? _notasController.text.trim()
              : null,
        ),
      ];

      // Generar la factura
      final factura = await InvoiceService.generarFactura(
        cliente: widget.usuario,
        proveedor: _createDemoProvider(),
        items: items,
        notas: 'Factura generada desde la demo de la aplicación.',
      );

      if (factura != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Factura generada exitosamente! Revisa tu email.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );

          // Mostrar diálogo con detalles
          _mostrarDetallesFactura(factura);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error generando la factura'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _mostrarDetallesFactura(Factura factura) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Factura Generada'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Número: ${factura.numeroFactura}'),
            Text('Total: \$${factura.total.toStringAsFixed(2)}'),
            Text('Estado: ${factura.estado.displayName}'),
            const SizedBox(height: 8),
            const Text(
              'La factura ha sido enviada por email y guardada en tu historial.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navegar al historial de facturas
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      InvoiceHistoryScreen(usuario: widget.usuario),
                ),
              );
            },
            child: const Text('Ver Historial'),
          ),
        ],
      ),
    );
  }
}
