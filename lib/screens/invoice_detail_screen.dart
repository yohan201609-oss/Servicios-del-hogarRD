import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/invoice.dart';
import '../models/user_profile.dart';
import '../services/invoice_service.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final Factura factura;
  final Usuario usuario;

  const InvoiceDetailScreen({
    super.key,
    required this.factura,
    required this.usuario,
  });

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Factura ${widget.factura.numeroFactura}'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _compartirFactura,
            icon: const Icon(Icons.share),
            tooltip: 'Compartir',
          ),
          PopupMenuButton<String>(
            onSelected: _ejecutarAccion,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reenviar',
                child: Row(
                  children: [
                    Icon(Icons.email, size: 20),
                    SizedBox(width: 8),
                    Text('Reenviar por email'),
                  ],
                ),
              ),
              if (widget.factura.estado == EstadoFactura.pendiente &&
                  widget.usuario.tipoUsuario == TipoUsuario.cliente)
                const PopupMenuItem(
                  value: 'pagar',
                  child: Row(
                    children: [
                      Icon(Icons.payment, size: 20),
                      SizedBox(width: 8),
                      Text('Marcar como Pagada'),
                    ],
                  ),
                ),
              if (widget.factura.estado == EstadoFactura.pendiente)
                const PopupMenuItem(
                  value: 'cancelar',
                  child: Row(
                    children: [
                      Icon(Icons.cancel, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Cancelar', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 16),
                  _buildClientProviderCard(),
                  const SizedBox(height: 16),
                  _buildItemsCard(),
                  const SizedBox(height: 16),
                  _buildTotalsCard(),
                  const SizedBox(height: 16),
                  _buildStatusCard(),
                  if (widget.factura.notas != null) ...[
                    const SizedBox(height: 16),
                    _buildNotesCard(),
                  ],
                  const SizedBox(height: 16),
                  _buildActionsCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 3,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [Colors.blue[50]!, Colors.blue[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FACTURA',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.factura.numeroFactura,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: widget.factura.estado.color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.factura.estado.icon,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.factura.estado.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Fecha de Emisión',
                    _formatearFecha(widget.factura.fechaEmision),
                    Icons.calendar_today,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Fecha de Vencimiento',
                    _formatearFecha(widget.factura.fechaVencimiento),
                    Icons.schedule,
                  ),
                ),
              ],
            ),
            if (widget.factura.fechaPago != null) ...[
              const SizedBox(height: 12),
              _buildInfoItem(
                'Fecha de Pago',
                _formatearFecha(widget.factura.fechaPago!),
                Icons.payment,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildClientProviderCard() {
    return Card(
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildPartyInfo(
                    'Cliente',
                    widget.factura.cliente,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPartyInfo(
                    'Proveedor',
                    widget.factura.proveedor,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
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
          if (_obtenerTelefonoUsuario(usuario) != null) ...[
            const SizedBox(height: 4),
            Text(
              _obtenerTelefonoUsuario(usuario)!,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalle de Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            ...widget.factura.items.map((item) => _buildItemRow(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(ItemFactura item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.descripcion,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                '\$${item.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Cantidad: ${item.cantidad}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(width: 16),
              Text(
                'Precio Unit.: \$${item.precioUnitario.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              if (item.descuento > 0) ...[
                const SizedBox(width: 16),
                Text(
                  'Desc.: ${item.descuento.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: Colors.green[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          if (item.notas != null) ...[
            const SizedBox(height: 8),
            Text(
              'Notas: ${item.notas}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTotalsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen de Totales',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            _buildTotalRow('Subtotal', widget.factura.subtotal, false),
            _buildTotalRow('Descuentos', -widget.factura.descuentos, false),
            _buildTotalRow('ITBIS (18%)', widget.factura.impuestos, false),
            const Divider(),
            _buildTotalRow('TOTAL', widget.factura.total, true),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, bool isTotal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: FontWeight.bold,
              color: isTotal ? Colors.blue[800] : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estado de la Factura',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.factura.estado.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    widget.factura.estado.icon,
                    color: widget.factura.estado.color,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.factura.estado.displayName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: widget.factura.estado.color,
                        ),
                      ),
                      if (widget.factura.isVencida)
                        Text(
                          'Esta factura está vencida (${widget.factura.diasVencimiento} días)',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      else if (widget.factura.estado == EstadoFactura.pendiente)
                        Text(
                          'Vence en ${widget.factura.fechaVencimiento.difference(DateTime.now()).inDays} días',
                          style: TextStyle(
                            color: Colors.orange[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.factura.metodoPago != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.payment, color: Colors.grey[600], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Método de Pago: ${widget.factura.metodoPago!.nombre}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notas Adicionales',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                widget.factura.notas!,
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acciones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: _compartirFactura,
                  icon: const Icon(Icons.share),
                  label: const Text('Compartir'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _reenviarPorEmail,
                  icon: const Icon(Icons.email),
                  label: const Text('Reenviar Email'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                  ),
                ),
                if (widget.factura.estado == EstadoFactura.pendiente &&
                    widget.usuario.tipoUsuario == TipoUsuario.cliente)
                  ElevatedButton.icon(
                    onPressed: _marcarComoPagada,
                    icon: const Icon(Icons.payment),
                    label: const Text('Marcar como Pagada'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                    ),
                  ),
                if (widget.factura.estado == EstadoFactura.pendiente)
                  ElevatedButton.icon(
                    onPressed: _cancelarFactura,
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancelar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // Métodos de utilidad
  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  String _obtenerNombreUsuario(Usuario usuario) {
    if (usuario.perfilCliente != null) {
      return '${usuario.perfilCliente!.nombre} ${usuario.perfilCliente!.apellido}';
    } else if (usuario.perfilProveedor != null) {
      return usuario.perfilProveedor!.nombreCompleto;
    }
    return usuario.email;
  }

  String? _obtenerTelefonoUsuario(Usuario usuario) {
    if (usuario.perfilCliente != null) {
      return usuario.perfilCliente!.telefono;
    } else if (usuario.perfilProveedor != null) {
      return 'No disponible';
    }
    return null;
  }

  // Métodos de acción
  void _compartirFactura() {
    final texto =
        '''
Factura ${widget.factura.numeroFactura}
Cliente: ${_obtenerNombreUsuario(widget.factura.cliente)}
Proveedor: ${_obtenerNombreUsuario(widget.factura.proveedor)}
Total: \$${widget.factura.total.toStringAsFixed(2)}
Estado: ${widget.factura.estado.displayName}
''';

    Clipboard.setData(ClipboardData(text: texto));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Información de la factura copiada al portapapeles'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _ejecutarAccion(String accion) {
    switch (accion) {
      case 'reenviar':
        _reenviarPorEmail();
        break;
      case 'pagar':
        _marcarComoPagada();
        break;
      case 'cancelar':
        _cancelarFactura();
        break;
    }
  }

  Future<void> _reenviarPorEmail() async {
    setState(() => _isLoading = true);

    try {
      final exitoso = await InvoiceService.reenviarFactura(
        widget.factura.id,
        null,
      );
      if (exitoso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Factura reenviada por email exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error reenviando la factura'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _marcarComoPagada() async {
    final confirmado = await _mostrarConfirmacion(
      'Marcar como Pagada',
      '¿Estás seguro de que quieres marcar esta factura como pagada?',
    );

    if (confirmado == true) {
      setState(() => _isLoading = true);

      try {
        final exitoso = await InvoiceService.marcarFacturaComoPagada(
          widget.factura.id,
        );
        if (exitoso) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Factura marcada como pagada'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true); // Regresar con actualización
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error marcando factura como pagada'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _cancelarFactura() async {
    final confirmado = await _mostrarConfirmacion(
      'Cancelar Factura',
      '¿Estás seguro de que quieres cancelar esta factura? Esta acción no se puede deshacer.',
    );

    if (confirmado == true) {
      setState(() => _isLoading = true);

      try {
        final exitoso = await InvoiceService.cancelarFactura(widget.factura.id);
        if (exitoso) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Factura cancelada'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true); // Regresar con actualización
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error cancelando factura'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool?> _mostrarConfirmacion(String titulo, String mensaje) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}
