import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../models/payment_method.dart';
import '../widgets/banco_selector_widget.dart';

class AddPaymentMethodScreen extends StatefulWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  State<AddPaymentMethodScreen> createState() => _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _numeroTarjetaController = TextEditingController();
  final _titularController = TextEditingController();
  final _bancoController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();

  TipoMetodoPago _tipoSeleccionado = TipoMetodoPago.tarjetaCredito;
  bool _esDefault = false;
  bool _isLoading = false;
  BancoInfo? _bancoSeleccionado;

  @override
  void dispose() {
    _nombreController.dispose();
    _numeroTarjetaController.dispose();
    _titularController.dispose();
    _bancoController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Método de Pago'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _savePaymentMethod,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Guardar',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPaymentTypeSelection(),
              const SizedBox(height: 24),
              _buildPaymentMethodForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentTypeSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tipo de Método de Pago',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.5,
              ),
              itemCount: TipoMetodoPago.values.length,
              itemBuilder: (context, index) {
                final tipo = TipoMetodoPago.values[index];
                final isSelected = _tipoSeleccionado == tipo;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _tipoSeleccionado = tipo;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? tipo.color.withValues(alpha: 0.2)
                          : Colors.grey[100],
                      border: Border.all(
                        color: isSelected ? tipo.color : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          tipo.icon,
                          color: isSelected ? tipo.color : Colors.grey[600],
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tipo.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected ? tipo.color : Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _tipoSeleccionado.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _tipoSeleccionado.icon,
                    color: _tipoSeleccionado.color,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _tipoSeleccionado.description,
                      style: TextStyle(
                        color: _tipoSeleccionado.color,
                        fontSize: 14,
                      ),
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

  Widget _buildPaymentMethodForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información del Método de Pago',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del método *',
                hintText: 'Ej: Mi Tarjeta Principal',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
              ),
              validator: (value) =>
                  value?.isEmpty == true ? 'Nombre requerido' : null,
            ),
            const SizedBox(height: 16),
            if (_tipoSeleccionado == TipoMetodoPago.tarjetaCredito ||
                _tipoSeleccionado == TipoMetodoPago.tarjetaDebito) ...[
              TextFormField(
                controller: _numeroTarjetaController,
                decoration: const InputDecoration(
                  labelText: 'Número de tarjeta *',
                  hintText: '1234 5678 9012 3456',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.credit_card),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                  CardNumberInputFormatter(),
                ],
                validator: (value) {
                  if (value?.isEmpty == true) {
                    return 'Número de tarjeta requerido';
                  }
                  if (value!.length < 16) {
                    return 'Número de tarjeta inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titularController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del titular *',
                  hintText: 'Como aparece en la tarjeta',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) => value?.isEmpty == true
                    ? 'Nombre del titular requerido'
                    : null,
              ),
              const SizedBox(height: 16),
              BancoSelectorWidget(
                bancoSeleccionado: _bancoSeleccionado,
                onBancoChanged: (banco) {
                  setState(() {
                    _bancoSeleccionado = banco;
                  });
                },
                hintText: 'Seleccionar banco (opcional)',
              ),
            ],
            if (_tipoSeleccionado == TipoMetodoPago.paypal ||
                _tipoSeleccionado == TipoMetodoPago.mercadoPago ||
                _tipoSeleccionado == TipoMetodoPago.billeteraDigital) ...[
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email de la cuenta *',
                  hintText: 'usuario@ejemplo.com',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.isEmpty == true) return 'Email requerido';
                  if (!value!.contains('@')) return 'Email inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  hintText: '809-123-4567',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
            if (_tipoSeleccionado == TipoMetodoPago.transferenciaBancaria) ...[
              BancoSelectorWidget(
                bancoSeleccionado: _bancoSeleccionado,
                onBancoChanged: (banco) {
                  setState(() {
                    _bancoSeleccionado = banco;
                  });
                },
                hintText: 'Seleccionar banco *',
              ),
              if (_bancoSeleccionado == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Banco requerido',
                    style: TextStyle(color: Colors.red[600], fontSize: 12),
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titularController,
                decoration: const InputDecoration(
                  labelText: 'Titular de la cuenta *',
                  hintText: 'Nombre completo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Titular requerido' : null,
              ),
            ],
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Establecer como método por defecto'),
              subtitle: const Text(
                'Este método se usará por defecto para nuevos pagos',
              ),
              value: _esDefault,
              onChanged: (value) => setState(() => _esDefault = value),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePaymentMethod() async {
    if (!_formKey.currentState!.validate()) return;

    // Validación adicional para transferencias bancarias
    if (_tipoSeleccionado == TipoMetodoPago.transferenciaBancaria &&
        _bancoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona un banco'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final metodo = MetodoPagoDetallado(
        id: _generateId(),
        tipo: _tipoSeleccionado,
        nombre: _nombreController.text.trim(),
        numeroTarjeta: _numeroTarjetaController.text.isNotEmpty
            ? _numeroTarjetaController.text.substring(
                _numeroTarjetaController.text.length - 4,
              )
            : null,
        banco: _bancoSeleccionado?.nombre,
        bancoInfo: _bancoSeleccionado,
        titular: _titularController.text.trim().isNotEmpty
            ? _titularController.text.trim()
            : null,
        fechaAgregado: DateTime.now(),
        esDefault: _esDefault,
        activo: true,
        datosAdicionales: {
          if (_emailController.text.isNotEmpty)
            'email': _emailController.text.trim(),
          if (_telefonoController.text.isNotEmpty)
            'telefono': _telefonoController.text.trim(),
        },
      );

      if (mounted) {
        Navigator.of(context).pop(metodo);
      }
    } catch (e) {
      _showError('Error guardando método de pago: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _generateId() {
    return 'pm_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}

// Formatter para números de tarjeta
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.length <= 4) {
      return newValue;
    }

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      final nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }

    final string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
