import '../models/fish_model.dart';

class FishService {
  // List of common fish in Indonesian waters
  static final List<Fish> _fishes = [
    Fish(
      id: '1',
      name: 'Cakalang',
      scientificName: 'Rastrelliger kanagurta',
      description: 'Ikan pelagis kecil yang bernilai ekonomis tinggi',
      season: ['5', '6', '7', '8', '9', '10'],
      minTemp: 24.0,
      maxTemp: 30.0,
      depth: 'Perairan dalam (50-100m)',
      imageUrl: 'assets/fish/cakalang.png',
    ),
    Fish(
      id: '2',
      name: 'Tuna',
      scientificName: 'Thunnus albacares',
      description: 'Ikan pelagis besar, bernilai ekspor tinggi',
      season: ['6', '7', '8', '9'],
      minTemp: 18.0,
      maxTemp: 28.0,
      depth: 'Perairan dalam (200-500m)',
      imageUrl: 'assets/fish/tuna.png',
    ),
    Fish(
      id: '3',
      name: 'Tongkol',
      scientificName: 'Auxis thazard',
      description: 'Ikan pelagis kecil, musim sepanjang tahun',
      season: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'],
      minTemp: 20.0,
      maxTemp: 32.0,
      depth: 'Perairan sedang (20-100m)',
      imageUrl: 'assets/fish/tongkol.png',
    ),
    Fish(
      id: '4',
      name: 'Kembung',
      scientificName: 'Rastrelliger brachysoma',
      description: 'Ikan dasar, populer di pasaran lokal',
      season: ['4', '5', '6', '7', '8'],
      minTemp: 22.0,
      maxTemp: 28.0,
      depth: 'Perairan sedang (10-50m)',
      imageUrl: 'assets/fish/kembung.png',
    ),
    Fish(
      id: '5',
      name: 'Bandeng',
      scientificName: 'Chanos chanos',
      description: 'Ikan estuary, biasa diternakkan di tambak',
      season: ['3', '4', '5', '6', '7', '8'],
      minTemp: 25.0,
      maxTemp: 32.0,
      depth: 'Perairan dangkal (1-5m)',
      imageUrl: 'assets/fish/bandeng.png',
    ),
    Fish(
      id: '6',
      name: 'Udang Vaname',
      scientificName: 'Litopenaeus vannamei',
      description: 'Udang laut yang populer untuk tambak',
      season: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'],
      minTemp: 26.0,
      maxTemp: 32.0,
      depth: 'Perairan dangkal (1-10m)',
      imageUrl: 'assets/fish/udang.png',
    ),
    Fish(
      id: '7',
      name: 'Teri',
      scientificName: 'Stolephorus sp.',
      description: 'Ikan pelagis sangat kecil, untuk pakan ternak',
      season: ['5', '6', '7', '8', '9', '10', '11'],
      minTemp: 26.0,
      maxTemp: 30.0,
      depth: 'Perairan permukaan (0-20m)',
      imageUrl: 'assets/fish/teri.png',
    ),
    Fish(
      id: '8',
      name: 'Layur',
      scientificName: 'Trichiurus savala',
      description: 'Ikan dasar dengan bentuk panjang memanjang',
      season: ['6', '7', '8', '9', '10'],
      minTemp: 20.0,
      maxTemp: 28.0,
      depth: 'Perairan sedang (50-150m)',
      imageUrl: 'assets/fish/layur.png',
    ),
  ];

  // Get all fish
  static List<Fish> getAllFish() {
    return _fishes;
  }

  // Get fish by ID
  static Fish? getFishById(String id) {
    try {
      return _fishes.firstWhere((fish) => fish.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get fish by current month
  static List<Fish> getFishByCurrentSeason() {
    final now = DateTime.now();
    final month = now.month.toString();

    return _fishes.where((fish) => fish.season.contains(month)).toList();
  }

  // Predict fishing grounds based on conditions
  static List<FishingGround> predictFishingGrounds(
    double waterTemp,
    double latitude,
    double longitude,
  ) {
    final grounds = <FishingGround>[];
    final now = DateTime.now();
    final month = now.month.toString();

    // Get available fish for current season
    final availableFish = _fishes.where((fish) => fish.season.contains(month)).toList();

    // Generate 5 potential fishing grounds
    for (int i = 0; i < 5; i++) {
      final offsetLat = (i - 2) * 0.05;
      final offsetLon = (i - 2) * 0.05;

      // Calculate suitability score
      var score = 50.0;

      // Find best matching fish for this ground
      String predictedFish = 'Tidak diketahui';
      for (final fish in availableFish) {
        if (waterTemp >= fish.minTemp && waterTemp <= fish.maxTemp) {
          score = 85.0 + (i * 2.0).clamp(0, 10);
          predictedFish = fish.name;
          break;
        }
      }

      grounds.add(FishingGround(
        latitude: latitude + offsetLat,
        longitude: longitude + offsetLon,
        suitabilityScore: score.clamp(0, 100),
        waterTemperature: waterTemp + (i - 2) * 0.5,
        predictedFish: predictedFish,
      ));
    }

    return grounds;
  }

  // Search fish by name
  static List<Fish> searchFish(String query) {
    final lowerQuery = query.toLowerCase();
    return _fishes
        .where((fish) =>
            fish.name.toLowerCase().contains(lowerQuery) ||
            fish.scientificName.toLowerCase().contains(lowerQuery))
        .toList();
  }
}
