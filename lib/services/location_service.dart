import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService extends ChangeNotifier {
  final _logger = Logger();
  static const String _locationKey = 'user_location';
  static const String _locationPermissionKey = 'location_permission_granted';

  // Singleton pattern
  static LocationService? _instance;
  static LocationService get instance {
    _instance ??= LocationService._internal();
    return _instance!;
  }

  LocationService._internal();

  String? _currentLocation;
  bool _locationPermissionGranted = false;
  bool _isLoading = false;

  // Getters
  String? get currentLocation => _currentLocation;
  bool get locationPermissionGranted => _locationPermissionGranted;
  bool get isLoading => _isLoading;

  // Load location settings
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentLocation = prefs.getString(_locationKey);
      _locationPermissionGranted =
          prefs.getBool(_locationPermissionKey) ?? false;

      _logger.i('Location settings loaded');
      notifyListeners();
    } catch (e) {
      _logger.e('Error loading location settings: $e');
    }
  }

  // Save location
  Future<bool> saveLocation(String location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_locationKey, location);
      _currentLocation = location;

      _logger.i('Location saved: $location');
      notifyListeners();
      return true;
    } catch (e) {
      _logger.e('Error saving location: $e');
      return false;
    }
  }

  // Save location permission status
  Future<bool> saveLocationPermission(bool granted) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_locationPermissionKey, granted);
      _locationPermissionGranted = granted;

      _logger.i('Location permission saved: $granted');
      notifyListeners();
      return true;
    } catch (e) {
      _logger.e('Error saving location permission: $e');
      return false;
    }
  }

  // Get current location (simulated)
  Future<String?> getCurrentLocation() async {
    if (!_locationPermissionGranted) {
      _logger.w('Location permission not granted');
      return null;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Simulate location fetching delay
      await Future.delayed(const Duration(seconds: 2));

      // In a real app, this would use geolocator package
      // For now, return a simulated location
      const simulatedLocation = 'Santo Domingo, República Dominicana';

      await saveLocation(simulatedLocation);
      _logger.i('Current location obtained: $simulatedLocation');

      return simulatedLocation;
    } catch (e) {
      _logger.e('Error getting current location: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Request location permission (simulated)
  Future<bool> requestLocationPermission() async {
    try {
      // In a real app, this would use permission_handler package
      // For now, simulate permission request
      await Future.delayed(const Duration(seconds: 1));

      const granted = true; // Simulate permission granted
      await saveLocationPermission(granted);

      _logger.i('Location permission requested: $granted');
      return granted;
    } catch (e) {
      _logger.e('Error requesting location permission: $e');
      return false;
    }
  }

  // Get nearby providers (simulated)
  Future<List<String>> getNearbyProviders(String category) async {
    if (_currentLocation == null) {
      _logger.w('No location available for nearby providers');
      return [];
    }

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // In a real app, this would query a geospatial database
      // For now, return simulated nearby providers
      final nearbyProviders = [
        'Proveedor A - 0.5 km',
        'Proveedor B - 1.2 km',
        'Proveedor C - 2.1 km',
        'Proveedor D - 3.5 km',
      ];

      _logger.i(
        'Found ${nearbyProviders.length} nearby providers for $category',
      );
      return nearbyProviders;
    } catch (e) {
      _logger.e('Error getting nearby providers: $e');
      return [];
    }
  }

  // Calculate distance between two locations (simulated)
  double calculateDistance(String location1, String location2) {
    // In a real app, this would use geolocator package
    // For now, return a simulated distance
    return 2.5; // km
  }

  // Get popular locations in Dominican Republic
  List<String> getPopularLocations() {
    return [
      'Santo Domingo',
      'Santiago de los Caballeros',
      'La Romana',
      'San Pedro de Macorís',
      'San Cristóbal',
      'Puerto Plata',
      'Higüey',
      'San Francisco de Macorís',
      'Moca',
      'Bonao',
      'Azua',
      'Barahona',
      'Bávaro',
      'Punta Cana',
      'Sosúa',
      'Cabarete',
      'Constanza',
      'Jarabacoa',
      'Villa Altagracia',
      'Hato Mayor',
    ];
  }

  // Search locations
  List<String> searchLocations(String query) {
    if (query.isEmpty) return getPopularLocations();

    final popularLocations = getPopularLocations();
    return popularLocations
        .where(
          (location) => location.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  // Clear location data
  Future<void> clearLocationData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_locationKey);
      await prefs.remove(_locationPermissionKey);

      _currentLocation = null;
      _locationPermissionGranted = false;

      _logger.i('Location data cleared');
      notifyListeners();
    } catch (e) {
      _logger.e('Error clearing location data: $e');
    }
  }

  // Check if location is available
  bool get hasLocation => _currentLocation != null;

  // Get location display name
  String get locationDisplayName =>
      _currentLocation ?? 'Ubicación no disponible';

  // Validate location format
  bool isValidLocation(String location) {
    return location.isNotEmpty && location.length >= 3;
  }
}
