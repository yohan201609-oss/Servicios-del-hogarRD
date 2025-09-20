import '../models/provider.dart';

class ProviderService {
  static final ProviderService _instance = ProviderService._internal();
  factory ProviderService() => _instance;
  ProviderService._internal();

  // Datos de ejemplo de proveedores
  static final List<Provider> _providers = [
    // Plomería
    Provider(
      id: '1',
      name: 'Carlos Mendoza',
      email: 'carlos.mendoza@email.com',
      phone: '809-123-4567',
      description:
          'Plomero con más de 10 años de experiencia en reparaciones domésticas y comerciales.',
      category: 'Plomería',
      rating: 4.8,
      totalReviews: 127,
      pricePerHour: 25.0,
      location: 'Santo Domingo Este',
      services: [
        'Reparación de grifos',
        'Instalación de tuberías',
        'Desatascos',
        'Reparación de inodoros',
      ],
      images: [],
      isAvailable: true,
      isVerified: true,
      joinDate: DateTime(2023, 1, 15),
      schedule: {
        'monday': '8:00-18:00',
        'tuesday': '8:00-18:00',
        'wednesday': '8:00-18:00',
        'thursday': '8:00-18:00',
        'friday': '8:00-18:00',
      },
      certifications: [
        'Certificación en Plomería Residencial',
        'Seguro de Responsabilidad Civil',
      ],
    ),
    Provider(
      id: '2',
      name: 'Miguel Rodríguez',
      email: 'miguel.rodriguez@email.com',
      phone: '809-234-5678',
      description:
          'Especialista en sistemas de agua caliente y reparaciones de emergencia.',
      category: 'Plomería',
      rating: 4.6,
      totalReviews: 89,
      pricePerHour: 30.0,
      location: 'Santo Domingo Oeste',
      services: [
        'Sistemas de agua caliente',
        'Reparaciones de emergencia',
        'Instalación de calentadores',
      ],
      images: [],
      isAvailable: true,
      isVerified: true,
      joinDate: DateTime(2023, 3, 10),
      schedule: {
        'monday': '7:00-19:00',
        'tuesday': '7:00-19:00',
        'wednesday': '7:00-19:00',
        'thursday': '7:00-19:00',
        'friday': '7:00-19:00',
      },
      certifications: ['Certificación en Sistemas de Agua Caliente'],
    ),

    // Electricidad
    Provider(
      id: '3',
      name: 'Ana García',
      email: 'ana.garcia@email.com',
      phone: '809-345-6789',
      description:
          'Electricista certificada especializada en instalaciones residenciales y comerciales.',
      category: 'Electricidad',
      rating: 4.9,
      totalReviews: 156,
      pricePerHour: 35.0,
      location: 'Santo Domingo Norte',
      services: [
        'Instalaciones eléctricas',
        'Reparación de circuitos',
        'Instalación de ventiladores',
        'Sistemas de iluminación',
      ],
      images: [],
      isAvailable: true,
      isVerified: true,
      joinDate: DateTime(2022, 11, 20),
      schedule: {
        'monday': '8:00-17:00',
        'tuesday': '8:00-17:00',
        'wednesday': '8:00-17:00',
        'thursday': '8:00-17:00',
        'friday': '8:00-17:00',
      },
      certifications: [
        'Licencia de Electricista',
        'Certificación en Seguridad Eléctrica',
      ],
    ),
    Provider(
      id: '4',
      name: 'Roberto Silva',
      email: 'roberto.silva@email.com',
      phone: '809-456-7890',
      description:
          'Experto en sistemas eléctricos industriales y domésticos con 15 años de experiencia.',
      category: 'Electricidad',
      rating: 4.7,
      totalReviews: 203,
      pricePerHour: 40.0,
      location: 'Santiago',
      services: [
        'Sistemas industriales',
        'Instalaciones domésticas',
        'Mantenimiento preventivo',
        'Reparaciones de emergencia',
      ],
      images: [],
      isAvailable: false,
      isVerified: true,
      joinDate: DateTime(2021, 6, 5),
      schedule: {
        'monday': '6:00-20:00',
        'tuesday': '6:00-20:00',
        'wednesday': '6:00-20:00',
        'thursday': '6:00-20:00',
        'friday': '6:00-20:00',
      },
      certifications: [
        'Licencia de Electricista Industrial',
        'Certificación en Sistemas de Emergencia',
      ],
    ),

    // Limpieza
    Provider(
      id: '5',
      name: 'María López',
      email: 'maria.lopez@email.com',
      phone: '809-567-8901',
      description:
          'Servicios de limpieza profesional para hogares y oficinas con productos ecológicos.',
      category: 'Limpieza',
      rating: 4.5,
      totalReviews: 94,
      pricePerHour: 20.0,
      location: 'Santo Domingo Este',
      services: [
        'Limpieza doméstica',
        'Limpieza de oficinas',
        'Limpieza post-construcción',
        'Limpieza de alfombras',
      ],
      images: [],
      isAvailable: true,
      isVerified: true,
      joinDate: DateTime(2023, 2, 28),
      schedule: {
        'monday': '7:00-16:00',
        'tuesday': '7:00-16:00',
        'wednesday': '7:00-16:00',
        'thursday': '7:00-16:00',
        'friday': '7:00-16:00',
      },
      certifications: [
        'Certificación en Limpieza Profesional',
        'Manejo de Productos Químicos',
      ],
    ),

    // Jardinería
    Provider(
      id: '6',
      name: 'José Martínez',
      email: 'jose.martinez@email.com',
      phone: '809-678-9012',
      description:
          'Jardinero especializado en diseño y mantenimiento de jardines residenciales.',
      category: 'Jardinería',
      rating: 4.6,
      totalReviews: 78,
      pricePerHour: 22.0,
      location: 'Santo Domingo Oeste',
      services: [
        'Diseño de jardines',
        'Mantenimiento de césped',
        'Poda de árboles',
        'Instalación de riego',
      ],
      images: [],
      isAvailable: true,
      isVerified: false,
      joinDate: DateTime(2023, 4, 12),
      schedule: {
        'monday': '6:00-18:00',
        'tuesday': '6:00-18:00',
        'wednesday': '6:00-18:00',
        'thursday': '6:00-18:00',
        'friday': '6:00-18:00',
      },
      certifications: ['Certificación en Jardinería'],
    ),

    // Pintura
    Provider(
      id: '7',
      name: 'Luis Herrera',
      email: 'luis.herrera@email.com',
      phone: '809-789-0123',
      description:
          'Pintor profesional con experiencia en interiores y exteriores, residencial y comercial.',
      category: 'Pintura',
      rating: 4.8,
      totalReviews: 142,
      pricePerHour: 28.0,
      location: 'Santo Domingo Norte',
      services: [
        'Pintura interior',
        'Pintura exterior',
        'Pintura comercial',
        'Preparación de superficies',
      ],
      images: [],
      isAvailable: true,
      isVerified: true,
      joinDate: DateTime(2022, 9, 8),
      schedule: {
        'monday': '7:00-17:00',
        'tuesday': '7:00-17:00',
        'wednesday': '7:00-17:00',
        'thursday': '7:00-17:00',
        'friday': '7:00-17:00',
      },
      certifications: [
        'Certificación en Técnicas de Pintura',
        'Manejo de Materiales Especializados',
      ],
    ),

    // Carpintería
    Provider(
      id: '8',
      name: 'Pedro Vargas',
      email: 'pedro.vargas@email.com',
      phone: '809-890-1234',
      description:
          'Carpintero especializado en muebles personalizados y reparaciones de madera.',
      category: 'Carpintería',
      rating: 4.7,
      totalReviews: 115,
      pricePerHour: 32.0,
      location: 'Santiago',
      services: [
        'Muebles personalizados',
        'Reparación de muebles',
        'Instalación de gabinetes',
        'Trabajos en madera',
      ],
      images: [],
      isAvailable: true,
      isVerified: true,
      joinDate: DateTime(2022, 12, 3),
      schedule: {
        'monday': '8:00-18:00',
        'tuesday': '8:00-18:00',
        'wednesday': '8:00-18:00',
        'thursday': '8:00-18:00',
        'friday': '8:00-18:00',
      },
      certifications: [
        'Certificación en Carpintería',
        'Manejo de Herramientas Especializadas',
      ],
    ),

    // Aire Acondicionado
    Provider(
      id: '9',
      name: 'Carmen Díaz',
      email: 'carmen.diaz@email.com',
      phone: '809-901-2345',
      description:
          'Técnica especializada en instalación y mantenimiento de sistemas de aire acondicionado.',
      category: 'Aire Acondicionado',
      rating: 4.9,
      totalReviews: 167,
      pricePerHour: 45.0,
      location: 'Santo Domingo Este',
      services: [
        'Instalación de AC',
        'Mantenimiento preventivo',
        'Reparación de equipos',
        'Limpieza de ductos',
      ],
      images: [],
      isAvailable: true,
      isVerified: true,
      joinDate: DateTime(2022, 7, 15),
      schedule: {
        'monday': '7:00-19:00',
        'tuesday': '7:00-19:00',
        'wednesday': '7:00-19:00',
        'thursday': '7:00-19:00',
        'friday': '7:00-19:00',
      },
      certifications: [
        'Certificación en Refrigeración',
        'Manejo de Refrigerantes',
        'Seguridad en Alturas',
      ],
    ),

    // Seguridad
    Provider(
      id: '10',
      name: 'Fernando Ruiz',
      email: 'fernando.ruiz@email.com',
      phone: '809-012-3456',
      description:
          'Especialista en sistemas de seguridad residencial y comercial con tecnología de vanguardia.',
      category: 'Seguridad',
      rating: 4.8,
      totalReviews: 89,
      pricePerHour: 50.0,
      location: 'Santo Domingo Oeste',
      services: [
        'Sistemas de alarma',
        'Cámaras de seguridad',
        'Control de acceso',
        'Monitoreo 24/7',
      ],
      images: [],
      isAvailable: true,
      isVerified: true,
      joinDate: DateTime(2023, 1, 30),
      schedule: {
        'monday': '8:00-20:00',
        'tuesday': '8:00-20:00',
        'wednesday': '8:00-20:00',
        'thursday': '8:00-20:00',
        'friday': '8:00-20:00',
      },
      certifications: [
        'Certificación en Sistemas de Seguridad',
        'Licencia de Instalador',
        'Certificación en Ciberseguridad',
      ],
    ),
  ];

  /// Obtener todos los proveedores
  List<Provider> getAllProviders() {
    return List.from(_providers);
  }

  /// Obtener proveedores por categoría
  List<Provider> getProvidersByCategory(String category) {
    return _providers
        .where((provider) => provider.category == category)
        .toList();
  }

  /// Obtener proveedores disponibles
  List<Provider> getAvailableProviders() {
    return _providers.where((provider) => provider.isAvailable).toList();
  }

  /// Obtener proveedores por categoría y disponibilidad
  List<Provider> getAvailableProvidersByCategory(String category) {
    return _providers
        .where(
          (provider) => provider.category == category && provider.isAvailable,
        )
        .toList();
  }

  /// Obtener un proveedor por ID
  Provider? getProviderById(String id) {
    try {
      return _providers.firstWhere((provider) => provider.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Buscar proveedores por nombre
  List<Provider> searchProviders(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _providers
        .where(
          (provider) =>
              provider.name.toLowerCase().contains(lowercaseQuery) ||
              provider.description.toLowerCase().contains(lowercaseQuery) ||
              provider.services.any(
                (service) => service.toLowerCase().contains(lowercaseQuery),
              ),
        )
        .toList();
  }

  /// Obtener proveedores verificados
  List<Provider> getVerifiedProviders() {
    return _providers.where((provider) => provider.isVerified).toList();
  }

  /// Obtener proveedores por rango de precio
  List<Provider> getProvidersByPriceRange(double minPrice, double maxPrice) {
    return _providers
        .where(
          (provider) =>
              provider.pricePerHour >= minPrice &&
              provider.pricePerHour <= maxPrice,
        )
        .toList();
  }

  /// Obtener proveedores por calificación mínima
  List<Provider> getProvidersByMinRating(double minRating) {
    return _providers
        .where((provider) => provider.rating >= minRating)
        .toList();
  }
}
