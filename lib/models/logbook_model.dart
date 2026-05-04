class LogbookEntry {
  final String id;
  final DateTime date;
  final double latitude;
  final double longitude;
  final String location;
  final List<CatchRecord> catches;
  final double temperature;
  final double waveHeight;
  final String windDirection;
  final double windSpeed;
  final String notes;

  LogbookEntry({
    required this.id,
    required this.date,
    required this.latitude,
    required this.longitude,
    required this.location,
    required this.catches,
    required this.temperature,
    required this.waveHeight,
    required this.windDirection,
    required this.windSpeed,
    required this.notes,
  });

  factory LogbookEntry.fromJson(Map<String, dynamic> json) {
    return LogbookEntry(
      id: json['id'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      location: json['location'] ?? '',
      catches: (json['catches'] as List<dynamic>?)
              ?.map((e) => CatchRecord.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      temperature: (json['temperature'] as num).toDouble(),
      waveHeight: (json['waveHeight'] as num).toDouble(),
      windDirection: json['windDirection'] ?? 'N',
      windSpeed: (json['windSpeed'] as num).toDouble(),
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'location': location,
      'catches': catches.map((e) => e.toJson()).toList(),
      'temperature': temperature,
      'waveHeight': waveHeight,
      'windDirection': windDirection,
      'windSpeed': windSpeed,
      'notes': notes,
    };
  }
}

class CatchRecord {
  final String fishSpecies;
  final double weight; // dalam kg
  final int quantity;
  final String remarks;

  CatchRecord({
    required this.fishSpecies,
    required this.weight,
    required this.quantity,
    required this.remarks,
  });

  factory CatchRecord.fromJson(Map<String, dynamic> json) {
    return CatchRecord(
      fishSpecies: json['fishSpecies'] ?? '',
      weight: (json['weight'] as num).toDouble(),
      quantity: json['quantity'] ?? 0,
      remarks: json['remarks'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fishSpecies': fishSpecies,
      'weight': weight,
      'quantity': quantity,
      'remarks': remarks,
    };
  }
}
