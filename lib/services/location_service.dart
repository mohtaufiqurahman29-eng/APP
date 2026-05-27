import '../models/location_model.dart';
import 'dart:math' as math;

class LocationService {
  // Sample sea locations across Indonesia
  static final List<SeaLocation> _locations = [
    SeaLocation(
      id: '1',
      name: 'Pelabuhan_Sunda_Kelapa',
      type: 'Pelabuhan',
      latitude: -6.1285,
      longitude: 106.8277,
      province: 'DKI Jakarta',
      description: 'Pelabuhan utama di Jakarta dengan fasilitas lengkap',
      image: 'assets/img/pelabuhan_sunda_kelapa.jpg',
    ),
    SeaLocation(
      id: '2',
      name: 'Pantai_Ancol',
      type: 'Pantai',
      latitude: -6.1180,
      longitude: 106.8292,
      province: 'DKI Jakarta',
      description: 'Pantai populer untuk rekreasi dan olahraga air',
      image: 'assets/img/pantai_ancol.jpg',
    ),
    SeaLocation(
      id: '3',
      name: 'Pelabuhan_Tanjung _Perak',
      type: 'Pelabuhan',
      latitude: -7.2097,
      longitude: 112.7467,
      province: 'Jawa Timur',
      description: 'Pelabuhan terbesar kedua di Indonesia',
      image: 'assets/img/pelabuhan_tanjung_perak.jpg',
    ),
    SeaLocation(
      id: '4',
      name: 'Pantai Sanur',
      type: 'Pantai',
      latitude: -8.6725,
      longitude: 115.2656,
      province: 'Bali',
      description: 'Pantai terkenal dengan ombak yang cocok untuk selancar',
      image: 'assets/img/pantai_sanur.jpg',
    ),
    SeaLocation(
      id: '5',
      name: 'pasar_Muara_Angke',
      type: 'TPI',
      latitude: -6.1120,
      longitude: 106.8180,
      province: 'DKI Jakarta',
      description: 'Tempat pelelangan ikan terbesar di Jakarta',
      image: 'assets/img/pasar_muara_angke.jpg',
    ),
    SeaLocation(
      id: '6',
      name: 'Pelabuhan_Belawan',
      type: 'Pelabuhan',
      latitude: 3.7939,
      longitude: 98.6753,
      province: 'Sumatera Utara',
      description: 'Pelabuhan strategis di Selat Malaka',
      image: 'assets/img/pelabuhan_belawan.jpg',
    ),
    SeaLocation(
      id: '7',
      name: 'Pantai_Parangtritis',
      type: 'Pantai',
      latitude: -7.9633,
      longitude: 110.3447,
      province: 'Daerah Istimewa Yogyakarta',
      description: 'Pantai terkenal dengan pasir hitam dan ombak besar',
      image: 'assets/img/pantai_parangtritis.jpg',
    ),
    SeaLocation(
      id: '8',
      name: 'Pelabuhan_Makassar',
      type: 'Pelabuhan',
      latitude: -5.1340,
      longitude: 119.4080,
      province: 'Sulawesi Selatan',
      description: 'Pelabuhan utama di kawasan timur Indonesia',
      image: 'assets/img/pelabuhan_makassar.jpg',
    ),
  ];

  // Get all locations
  static List<SeaLocation> getAllLocations() {
    return _locations;
  }

  // Get location by ID
  static SeaLocation? getLocationById(String id) {
    try {
      return _locations.firstWhere((loc) => loc.id == id);
    } catch (e) {
      return null;
    }
  }

  // Search locations by name or type
  static List<SeaLocation> searchLocations(String query) {
    final lowerQuery = query.toLowerCase();
    return _locations
        .where((loc) =>
            loc.name.toLowerCase().contains(lowerQuery) ||
            loc.type.toLowerCase().contains(lowerQuery) ||
            loc.province.toLowerCase().contains(lowerQuery))
        .toList();
  }

  // Get locations by type
  static List<SeaLocation> getLocationsByType(String type) {
    return _locations.where((loc) => loc.type == type).toList();
  }

  // Get locations by province
  static List<SeaLocation> getLocationsByProvince(String province) {
    return _locations.where((loc) => loc.province == province).toList();
  }

  // Calculate distance between two coordinates (Haversine formula)
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371; // Radius in km
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRad(double degree) {
    return degree * (math.pi / 180);
  }

  // Get nearest locations
  static List<SeaLocation> getNearestLocations(
    double latitude,
    double longitude, {
    int limit = 5,
    double radiusKm = 50,
  }) {
    final nearby = <(SeaLocation, double)>[];

    for (final location in _locations) {
      final distance = calculateDistance(
        latitude,
        longitude,
        location.latitude,
        location.longitude,
      );

      if (distance <= radiusKm) {
        nearby.add((location, distance));
      }
    }

    nearby.sort((a, b) => a.$2.compareTo(b.$2));
    return nearby.take(limit).map((e) => e.$1).toList();
  }
}
