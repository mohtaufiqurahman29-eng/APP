class TideData {
  final DateTime time;
  final double height; // dalam meter
  final String type; // "Pasang" atau "Surut"

  TideData({
    required this.time,
    required this.height,
    required this.type,
  });

  factory TideData.fromJson(Map<String, dynamic> json) {
    return TideData(
      time: DateTime.parse(json['time'] ?? DateTime.now().toIso8601String()),
      height: (json['height'] as num).toDouble(),
      type: json['type'] ?? 'Pasang',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time.toIso8601String(),
      'height': height,
      'type': type,
    };
  }
}

class TideSchedule {
  final List<TideData> schedule;
  final DateTime generatedAt;

  TideSchedule({
    required this.schedule,
    required this.generatedAt,
  });

  factory TideSchedule.fromJson(Map<String, dynamic> json) {
    return TideSchedule(
      schedule: (json['schedule'] as List<dynamic>?)
              ?.map((e) => TideData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      generatedAt: DateTime.parse(json['generatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schedule': schedule.map((e) => e.toJson()).toList(),
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
}
