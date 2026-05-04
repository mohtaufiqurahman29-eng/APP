class Fish {
  final String id;
  final String name;
  final String scientificName;
  final String description;
  final List<String> season; // bulan musim
  final double minTemp;
  final double maxTemp;
  final String depth; // perairan dalam
  final String imageUrl;

  Fish({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.description,
    required this.season,
    required this.minTemp,
    required this.maxTemp,
    required this.depth,
    required this.imageUrl,
  });

  factory Fish.fromJson(Map<String, dynamic> json) {
    return Fish(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      scientificName: json['scientificName'] ?? '',
      description: json['description'] ?? '',
      season: List<String>.from(json['season'] ?? []),
      minTemp: (json['minTemp'] as num?)?.toDouble() ?? 20.0,
      maxTemp: (json['maxTemp'] as num?)?.toDouble() ?? 30.0,
      depth: json['depth'] ?? 'Sedang',
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'scientificName': scientificName,
      'description': description,
      'season': season,
      'minTemp': minTemp,
      'maxTemp': maxTemp,
      'depth': depth,
      'imageUrl': imageUrl,
    };
  }
}

class FishingGround {
  final double latitude;
  final double longitude;
  final double suitabilityScore; // 0-100
  final double waterTemperature;
  final String predictedFish; // nama ikan yang diprediksi

  FishingGround({
    required this.latitude,
    required this.longitude,
    required this.suitabilityScore,
    required this.waterTemperature,
    required this.predictedFish,
  });

  factory FishingGround.fromJson(Map<String, dynamic> json) {
    return FishingGround(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      suitabilityScore: (json['suitabilityScore'] as num).toDouble(),
      waterTemperature: (json['waterTemperature'] as num).toDouble(),
      predictedFish: json['predictedFish'] ?? 'Tidak diketahui',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'suitabilityScore': suitabilityScore,
      'waterTemperature': waterTemperature,
      'predictedFish': predictedFish,
    };
  }
}
