import 'package:flutter/material.dart';
import '../models/provider.dart';
import '../services/provider_service.dart';
import 'provider_detail_screen.dart';

class ProviderListScreen extends StatefulWidget {
  final String category;
  final IconData categoryIcon;
  final Color categoryColor;

  const ProviderListScreen({
    super.key,
    required this.category,
    required this.categoryIcon,
    required this.categoryColor,
  });

  @override
  State<ProviderListScreen> createState() => _ProviderListScreenState();
}

class _ProviderListScreenState extends State<ProviderListScreen> {
  final ProviderService _providerService = ProviderService();
  List<Provider> _providers = [];
  List<Provider> _filteredProviders = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _sortBy = 'rating'; // rating, price, name, reviews
  bool _showOnlyAvailable = true;
  bool _showOnlyVerified = false;

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  void _loadProviders() {
    setState(() {
      _isLoading = true;
    });

    // Simular carga de datos
    Future.delayed(const Duration(milliseconds: 500), () {
      final providers = _providerService.getAvailableProvidersByCategory(
        widget.category,
      );
      setState(() {
        _providers = providers;
        _filteredProviders = providers;
        _isLoading = false;
      });
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Provider> filtered = List.from(_providers);

    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (provider) =>
                provider.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                provider.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                provider.services.any(
                  (service) => service.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ),
                ),
          )
          .toList();
    }

    // Filtrar por disponibilidad
    if (_showOnlyAvailable) {
      filtered = filtered.where((provider) => provider.isAvailable).toList();
    }

    // Filtrar por verificación
    if (_showOnlyVerified) {
      filtered = filtered.where((provider) => provider.isVerified).toList();
    }

    // Ordenar
    switch (_sortBy) {
      case 'rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'price':
        filtered.sort((a, b) => a.pricePerHour.compareTo(b.pricePerHour));
        break;
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'reviews':
        filtered.sort((a, b) => b.totalReviews.compareTo(a.totalReviews));
        break;
    }

    setState(() {
      _filteredProviders = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Proveedores de ${widget.category}'),
        backgroundColor: widget.categoryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProviders.isEmpty
                ? _buildEmptyState()
                : _buildProviderList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Barra de búsqueda
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar proveedores...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                        _applyFilters();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
              _applyFilters();
            },
          ),
          const SizedBox(height: 12),
          // Filtros rápidos
          Row(
            children: [
              Expanded(
                child: FilterChip(
                  label: Text(
                    'Disponibles (${_providers.where((p) => p.isAvailable).length})',
                  ),
                  selected: _showOnlyAvailable,
                  onSelected: (selected) {
                    setState(() {
                      _showOnlyAvailable = selected;
                    });
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilterChip(
                  label: Text(
                    'Verificados (${_providers.where((p) => p.isVerified).length})',
                  ),
                  selected: _showOnlyVerified,
                  onSelected: (selected) {
                    setState(() {
                      _showOnlyVerified = selected;
                    });
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProviderList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredProviders.length,
      itemBuilder: (context, index) {
        final provider = _filteredProviders[index];
        return _buildProviderCard(provider);
      },
    );
  }

  Widget _buildProviderCard(Provider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProviderDetailScreen(provider: provider),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar del proveedor
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: widget.categoryColor.withOpacity(0.1),
                    child: Icon(
                      widget.categoryIcon,
                      color: widget.categoryColor,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Información del proveedor
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                provider.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (provider.isVerified)
                              Icon(
                                Icons.verified,
                                color: Colors.blue,
                                size: 20,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          provider.location,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              provider.ratingText,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.attach_money,
                              color: Colors.green,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              provider.priceText,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Descripción
              Text(
                provider.description,
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Servicios
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: provider.services.take(3).map((service) {
                  return Chip(
                    label: Text(service, style: const TextStyle(fontSize: 12)),
                    backgroundColor: widget.categoryColor.withOpacity(0.1),
                    labelStyle: TextStyle(color: widget.categoryColor),
                  );
                }).toList(),
              ),
              if (provider.services.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '+${provider.services.length - 3} servicios más',
                    style: TextStyle(
                      color: widget.categoryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              // Estado de disponibilidad
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: provider.isAvailable ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      provider.availabilityText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Ver detalles',
                    style: TextStyle(
                      color: widget.categoryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: widget.categoryColor,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.categoryIcon, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No hay proveedores disponibles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No se encontraron proveedores para ${widget.category}',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar y Ordenar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ordenar por:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            RadioListTile<String>(
              title: const Text('Calificación'),
              value: 'rating',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
                _applyFilters();
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Precio'),
              value: 'price',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
                _applyFilters();
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Nombre'),
              value: 'name',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
                _applyFilters();
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Número de reseñas'),
              value: 'reviews',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
                _applyFilters();
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
