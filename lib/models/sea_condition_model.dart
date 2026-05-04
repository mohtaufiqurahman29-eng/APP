class SeaCondition {
  final double waveHeight; // dalam cm
  final double windSpeed; // dalam knot
  final String windDirection; // N, S, E, W, NE, NW, SE, SW
  final double airPressure; // dalam mb
  final String safetyStatus; // AMAN, WASPADA, BAHAYA
  final DateTime timestamp;
  final double temperature; // dalam celsius
  final int humidity; // dalam persen

  SeaCondition({
    required this.waveHeight,
    required this.windSpeed,
    required this.windDirection,
    required this.airPressure,
    required this.safetyStatus,
    required this.timestamp,
    required this.temperature,
    required this.humidity,
  });

  factory SeaCondition.fromJson(Map<String, dynamic> json) {
    return SeaCondition(
      waveHeight: (json['waveHeight'] as num).toDouble(),
      windSpeed: (json['windSpeed'] as num).toDouble(),
      windDirection: json['windDirection'] ?? 'N',
      airPressure: (json['airPressure'] as num).toDouble(),
      safetyStatus: json['safetyStatus'] ?? 'AMAN',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      temperature: (json['temperature'] as num).toDouble(),
      humidity: json['humidity'] ?? 70,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'waveHeight': waveHeight,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'airPressure': airPressure,
      'safetyStatus': safetyStatus,
      'timestamp': timestamp.toIso8601String(),
      'temperature': temperature,
      'humidity': humidity,
    };
  }
}
