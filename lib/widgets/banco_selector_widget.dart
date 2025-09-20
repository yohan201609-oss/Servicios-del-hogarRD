import 'package:flutter/material.dart';
import '../models/payment_method.dart';

class BancoSelectorWidget extends StatefulWidget {
  final BancoInfo? bancoSeleccionado;
  final ValueChanged<BancoInfo?> onBancoChanged;
  final String? hintText;

  const BancoSelectorWidget({
    super.key,
    this.bancoSeleccionado,
    required this.onBancoChanged,
    this.hintText,
  });

  @override
  State<BancoSelectorWidget> createState() => _BancoSelectorWidgetState();
}

class _BancoSelectorWidgetState extends State<BancoSelectorWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<BancoInfo> _bancosFiltrados = BancosRepository.todosLosBancos;
  bool _mostrarBancos = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filtrarBancos);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filtrarBancos() {
    setState(() {
      _bancosFiltrados = BancosRepository.buscarBancos(_searchController.text);
    });
  }

  void _seleccionarBanco(BancoInfo banco) {
    widget.onBancoChanged(banco);
    setState(() {
      _mostrarBancos = false;
      _searchController.clear();
    });
  }

  void _limpiarSeleccion() {
    widget.onBancoChanged(null);
    setState(() {
      _mostrarBancos = false;
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _mostrarBancos = !_mostrarBancos;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.bancoSeleccionado?.nombre ??
                        widget.hintText ??
                        'Seleccionar banco',
                    style: TextStyle(
                      color: widget.bancoSeleccionado != null
                          ? Colors.black
                          : Colors.grey[600],
                    ),
                  ),
                ),
                if (widget.bancoSeleccionado != null)
                  IconButton(
                    onPressed: _limpiarSeleccion,
                    icon: const Icon(Icons.clear, size: 20),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                Icon(
                  _mostrarBancos
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
        if (_mostrarBancos) ...[
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Barra de búsqueda
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar banco...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                // Lista de bancos
                Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _bancosFiltrados.length,
                    itemBuilder: (context, index) {
                      final banco = _bancosFiltrados[index];
                      final isSelected =
                          widget.bancoSeleccionado?.codigo == banco.codigo;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: banco.pais == 'RD'
                              ? Colors.blue.withValues(alpha: 0.1)
                              : Colors.green.withValues(alpha: 0.1),
                          child: Text(
                            banco.codigo.substring(0, 2).toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: banco.pais == 'RD'
                                  ? Colors.blue
                                  : Colors.green,
                            ),
                          ),
                        ),
                        title: Text(
                          banco.nombre,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          banco.pais == 'RD'
                              ? 'República Dominicana'
                              : banco.pais,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: Colors.blue)
                            : null,
                        selected: isSelected,
                        selectedTileColor: Colors.blue.withValues(alpha: 0.1),
                        onTap: () => _seleccionarBanco(banco),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
