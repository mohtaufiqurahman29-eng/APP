class TideSchedule {
  final String location;
  final String lastUpdated;
  final List<TideDataPoint> dataPoints;

  TideSchedule({
    required this.location,
    required this.lastUpdated,
    required this.dataPoints,
  });

  factory TideSchedule.fromJson(Map<String, dynamic> json) {
    var list = json['dataPoints'] as List;
    List<TideDataPoint> dataList = list.map((i) => TideDataPoint.fromJson(i)).toList();

    return TideSchedule(
      location: json['location'] ?? '',
      lastUpdated: json['lastUpdated'] ?? '',
      dataPoints: dataList,
    );
  }
}

class TideDataPoint {
  final String time;
  final double height;

  TideDataPoint({required this.time, required this.height});

  factory TideDataPoint.fromJson(Map<String, dynamic> json) {
    return TideDataPoint(
      time: json['time'] ?? '',
      height: (json['height'] as num).toDouble(),
    );
  }
}