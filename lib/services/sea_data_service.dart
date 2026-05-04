import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import '../models/sea_condition_model.dart';
import '../models/tide_model.dart';
import '../models/fish_model.dart';
import '../models/logbook_model.dart';
import '../models/location_model.dart';

class SeaDataService {
  static const String _seaConditionKey = 'sea_condition';
  static const String _cacheTimestampKey = 'cache_timestamp';

  // Generate safety status based on conditions
  static String _generateSafetyStatus(double waveHeight, double windSpeed) {
    if (waveHeight > 400 || windSpeed > 40) {
      return 'BAHAYA';
    } else if (waveHeight > 200 || windSpeed > 25) {
      return 'WASPADA';
    }
    return 'AMAN';
  }

  // Get current sea condition (dummy data with variation)
  static SeaCondition generateCurrentSeaCondition() {
    final now = DateTime.now();
    final hour = now.hour;
    
    // Wave height varies throughout the day (higher in afternoon)
    final baseWaveHeight = 100 + (hour - 6) * 10.0;
    final waveHeight = baseWaveHeight.clamp(80.0, 250.0);
    
    // Wind speed variation
    final windSpeed = 10.0 + (hour % 6) * 2.5;
    
    final windDirections = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final windDirection = windDirections[hour % 8];
    
    final airPressure = 1013.0 + (hour % 12) * 0.5;
    final temperature = 26.0 + (hour - 12) * 0.5;
    final humidity = 70 + (hour % 6) * 2;

    final safetyStatus = _generateSafetyStatus(waveHeight, windSpeed);

    return SeaCondition(
      waveHeight: waveHeight,
      windSpeed: windSpeed,
      windDirection: windDirection,
      airPressure: airPressure,
      safetyStatus: safetyStatus,
      timestamp: now,
      temperature: temperature.clamp(20.0, 32.0),
      humidity: humidity.clamp(60, 95),
    );
  }

  // Get tide schedule
  static TideSchedule generateTideSchedule() {
    final now = DateTime.now();
    final schedule = <TideData>[];

    for (int i = 0; i < 24; i++) {
      final time = now.add(Duration(hours: i));
      
      // Tide follows semi-diurnal pattern (2 high tides, 2 low tides per day)
      final hour = time.hour.toDouble();
      final heightValue = 1.5 + 1.0 * (1 + sin(hour / 6 - (hour ~/ 6).toDouble()));
      
      final type = heightValue > 1.8 ? 'Pasang' : 'Surut';

      schedule.add(TideData(
        time: time,
        height: heightValue.clamp(0.5, 2.5),
        type: type,
      ));
    }

    return TideSchedule(
      schedule: schedule,
      generatedAt: now,
    );
  }

  // Save to cache
  static Future<void> saveToCache(SeaCondition condition) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(condition.toJson());
    await prefs.setString(_seaConditionKey, json);
    await prefs.setInt(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  // Get from cache
  static Future<SeaCondition?> getFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_seaConditionKey);
    if (json != null) {
      try {
        return SeaCondition.fromJson(jsonDecode(json));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Check if cache is still valid (less than 30 minutes old)
  static Future<bool> isCacheValid() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_cacheTimestampKey);
    if (timestamp == null) return false;

    final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
    return cacheAge < (30 * 60 * 1000); // 30 minutes
  }

  // Get sea condition with cache support
  static Future<SeaCondition> getSeaCondition() async {
    // Check cache first
    if (await isCacheValid()) {
      final cached = await getFromCache();
      if (cached != null) return cached;
    }

    // Generate new data
    final condition = generateCurrentSeaCondition();
    await saveToCache(condition);
    return condition;
  }
}
