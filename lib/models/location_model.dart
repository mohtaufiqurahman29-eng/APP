class SeaLocation {
  final String id;
  final String name;
  final String type; // "Pelabuhan", "Pantai", "TPI"
  final double latitude;
  final double longitude;
  final String province;
  final String description;
  final bool isFavorite;

  SeaLocation({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.province,
    required this.description,
    this.isFavorite = false,
  });

  factory SeaLocation.fromJson(Map<String, dynamic> json) {
    return SeaLocation(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'Pantai',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      province: json['province'] ?? '',
      description: json['description'] ?? '',
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
      'province': province,
      'description': description,
      'isFavorite': isFavorite,
    };
  }

  SeaLocation copyWith({bool? isFavorite}) {
    return SeaLocation(
      id: id,
      name: name,
      type: type,
      latitude: latitude,
      longitude: longitude,
      province: province,
      description: description,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
