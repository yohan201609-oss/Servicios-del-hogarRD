import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/payment_method.dart';
import '../models/user_profile.dart';
import 'add_payment_method_screen.dart';

class PaymentMethodsScreen extends StatefulWidget {
  final Usuario usuario;

  const PaymentMethodsScreen({super.key, required this.usuario});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  List<MetodoPagoDetallado> _metodosPago = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metodosJson =
          prefs.getStringList('metodos_pago_${widget.usuario.id}') ?? [];

      setState(() {
        _metodosPago = metodosJson
            .map((json) => MetodoPagoDetallado.fromJson(jsonDecode(json)))
            .where((metodo) => metodo.activo)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Error cargando métodos de pago: $e');
    }
  }

  Future<void> _savePaymentMethods() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metodosJson = _metodosPago
          .map((metodo) => jsonEncode(metodo.toJson()))
          .toList();
      await prefs.setStringList(
        'metodos_pago_${widget.usuario.id}',
        metodosJson,
      );
    } catch (e) {
      _showError('Error guardando métodos de pago: $e');
    }
  }

  Future<void> _addPaymentMethod() async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => AddPaymentMethodScreen()));

    if (result != null && result is MetodoPagoDetallado) {
      setState(() {
        _metodosPago.add(result);
      });
      await _savePaymentMethods();
      _showSuccess('Método de pago agregado exitosamente');
    }
  }

  Future<void> _setDefaultMethod(MetodoPagoDetallado metodo) async {
    setState(() {
      _metodosPago = _metodosPago
          .map((m) => m.copyWith(esDefault: m.id == metodo.id))
          .toList();
    });
    await _savePaymentMethods();
    _showSuccess('Método de pago por defecto actualizado');
  }

  Future<void> _deleteMethod(MetodoPagoDetallado metodo) async {
    final confirm = await _showDeleteConfirmation(metodo);
    if (confirm == true) {
      setState(() {
        _metodosPago.removeWhere((m) => m.id == metodo.id);
      });
      await _savePaymentMethods();
      _showSuccess('Método de pago eliminado');
    }
  }

  Future<bool?> _showDeleteConfirmation(MetodoPagoDetallado metodo) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Método de Pago'),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${metodo.nombre}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(true);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Métodos de Pago'),
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: _addPaymentMethod,
              icon: const Icon(Icons.add),
              tooltip: 'Agregar Método de Pago',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _metodosPago.isEmpty
            ? _buildEmptyState()
            : _buildPaymentMethodsList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.payment, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No tienes métodos de pago',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega un método de pago para facilitar tus transacciones',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addPaymentMethod,
            icon: const Icon(Icons.add),
            label: const Text('Agregar Método de Pago'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsList() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue[50],
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Los métodos de pago te permiten realizar pagos rápidos y seguros a los proveedores de servicios.',
                  style: TextStyle(color: Colors.blue[700], fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _metodosPago.length,
            itemBuilder: (context, index) {
              final metodo = _metodosPago[index];
              return _buildPaymentMethodCard(metodo);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard(MetodoPagoDetallado metodo) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: metodo.tipo.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    metodo.tipo.icon,
                    color: metodo.tipo.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            metodo.nombre,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (metodo.esDefault) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Por defecto',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        metodo.tipo.displayName,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      if (metodo.numeroTarjeta != null)
                        Text(
                          '**** **** **** ${metodo.numeroTarjeta}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      if (metodo.bancoInfo != null || metodo.banco != null)
                        Text(
                          metodo.bancoInfo?.nombre ?? metodo.banco!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      if (metodo.bancoInfo != null)
                        Text(
                          metodo.bancoInfo!.pais == 'RD'
                              ? 'República Dominicana'
                              : metodo.bancoInfo!.pais,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'set_default':
                        _setDefaultMethod(metodo);
                        break;
                      case 'delete':
                        _deleteMethod(metodo);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    if (!metodo.esDefault)
                      const PopupMenuItem(
                        value: 'set_default',
                        child: Row(
                          children: [
                            Icon(Icons.star, size: 20),
                            SizedBox(width: 8),
                            Text('Establecer como por defecto'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Eliminar', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  'Agregado el ${_formatDate(metodo.fechaAgregado)}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
