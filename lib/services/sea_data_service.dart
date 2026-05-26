import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sea_condition_model.dart';
import '../models/tide_model.dart'; // Mengarah ke file model pasang surutmu

class SeaDataService {
  static const String _storageKey = 'laporan_laut_db';

  // Fungsi untuk mengambil data dari memori HP
  static Future<List<SeaCondition>> getSavedReports() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_storageKey);
    
    if (jsonString == null) return []; 

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((data) => SeaCondition.fromJson(data)).toList();
  }

  // Fungsi untuk menyimpan data baru ke memori HP
  static Future<void> addCustomReport(SeaCondition newReport) async {
    final prefs = await SharedPreferences.getInstance();
    List<SeaCondition> currentList = await getSavedReports();
    currentList.insert(0, newReport);
    
    final String encodedData = jsonEncode(currentList.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encodedData);
  }

  // Fungsi acak cuaca otomatis
  static Future<SeaCondition> getSeaCondition() async {
    final random = Random();
    double wave = 50 + random.nextDouble() * 300; 
    double speed = 2 + random.nextDouble() * 25;   
    double temp = 26 + random.nextDouble() * 5;
    int hum = 70 + random.nextInt(25);
    
    List<String> directions = ['UTARA', 'TIMUR LAUT', 'TIMUR', 'TENGGARA', 'SELATAN', 'BARAT DAYA', 'BARAT', 'BARAT LAUT'];
    String direction = directions[random.nextInt(directions.length)];
    String status = (wave > 250 || speed > 20) ? 'BAHAYA' : (wave > 125 || speed > 10) ? 'WASPADA' : 'AMAN';

    return SeaCondition.fromJson({
      'waveHeight': wave,
      'windSpeed': speed,
      'windDirection': direction,
      'temperature': temp,
      'humidity': hum,
      'safetyStatus': status,
    });
  }

  // 🔄 Fungsi pasang surut yang sudah diselaraskan dengan TideSchedule
  static TideSchedule generateTideSchedule() {
    DateTime now = DateTime.now();
    return TideSchedule.fromJson({
      'location': "Pesisir Pantai talang siring",
      'lastUpdated': now.toIso8601String(),
      'dataPoints': [
        {'time': now.toIso8601String(), 'height': 1.0},
        {'time': now.add(const Duration(hours: 6)).toIso8601String(), 'height': 1.2},
        {'time': now.add(const Duration(hours: 12)).toIso8601String(), 'height': 0.8},
        {'time': now.add(const Duration(hours: 18)).toIso8601String(), 'height': 0.5},
        {'time': now.add(const Duration(hours: 24)).toIso8601String(), 'height': 1.1},
      ],
    });
  }
}