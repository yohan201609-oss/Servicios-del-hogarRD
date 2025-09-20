class Provider {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String description;
  final String category;
  final double rating;
  final int totalReviews;
  final double pricePerHour;
  final String location;
  final List<String> services;
  final List<String> images;
  final bool isAvailable;
  final bool isVerified;
  final DateTime joinDate;
  final Map<String, dynamic> schedule; // Horarios disponibles
  final List<String> certifications;

  Provider({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.description,
    required this.category,
    required this.rating,
    required this.totalReviews,
    required this.pricePerHour,
    required this.location,
    required this.services,
    required this.images,
    required this.isAvailable,
    required this.isVerified,
    required this.joinDate,
    required this.schedule,
    required this.certifications,
  });

  factory Provider.fromJson(Map<String, dynamic> json) {
    return Provider(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      pricePerHour: (json['pricePerHour'] ?? 0.0).toDouble(),
      location: json['location'] ?? '',
      services: List<String>.from(json['services'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      isAvailable: json['isAvailable'] ?? true,
      isVerified: json['isVerified'] ?? false,
      joinDate: DateTime.parse(
        json['joinDate'] ?? DateTime.now().toIso8601String(),
      ),
      schedule: Map<String, dynamic>.from(json['schedule'] ?? {}),
      certifications: List<String>.from(json['certifications'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'description': description,
      'category': category,
      'rating': rating,
      'totalReviews': totalReviews,
      'pricePerHour': pricePerHour,
      'location': location,
      'services': services,
      'images': images,
      'isAvailable': isAvailable,
      'isVerified': isVerified,
      'joinDate': joinDate.toIso8601String(),
      'schedule': schedule,
      'certifications': certifications,
    };
  }

  String get ratingText {
    if (totalReviews == 0) return 'Sin calificaciones';
    return '${rating.toStringAsFixed(1)} (${totalReviews} reseñas)';
  }

  String get priceText {
    return '\$${pricePerHour.toStringAsFixed(0)}/hora';
  }

  String get availabilityText {
    return isAvailable ? 'Disponible' : 'No disponible';
  }
}
