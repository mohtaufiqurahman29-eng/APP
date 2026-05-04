import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/logbook_model.dart';

class LogbookService {
  static const String _logbookKey = 'logbook_entries';

  // Generate unique ID
  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Create new entry
  static LogbookEntry createEntry({
    required DateTime date,
    required double latitude,
    required double longitude,
    required String location,
    required List<CatchRecord> catches,
    required double temperature,
    required double waveHeight,
    required String windDirection,
    required double windSpeed,
    required String notes,
  }) {
    return LogbookEntry(
      id: _generateId(),
      date: date,
      latitude: latitude,
      longitude: longitude,
      location: location,
      catches: catches,
      temperature: temperature,
      waveHeight: waveHeight,
      windDirection: windDirection,
      windSpeed: windSpeed,
      notes: notes,
    );
  }

  // Save entry to local storage
  static Future<void> saveEntry(LogbookEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getAll();
    entries.add(entry);

    final jsonList = entries.map((e) => e.toJson()).toList();
    await prefs.setString(_logbookKey, jsonEncode(jsonList));
  }

  // Get all entries
  static Future<List<LogbookEntry>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_logbookKey);

    if (json == null) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(json);
      return decoded
          .map((e) => LogbookEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Get entry by ID
  static Future<LogbookEntry?> getById(String id) async {
    final entries = await getAll();
    try {
      return entries.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  // Update entry
  static Future<void> updateEntry(LogbookEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getAll();

    final index = entries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      entries[index] = entry;
      final jsonList = entries.map((e) => e.toJson()).toList();
      await prefs.setString(_logbookKey, jsonEncode(jsonList));
    }
  }

  // Delete entry
  static Future<void> deleteEntry(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getAll();

    entries.removeWhere((e) => e.id == id);
    final jsonList = entries.map((e) => e.toJson()).toList();
    await prefs.setString(_logbookKey, jsonEncode(jsonList));
  }

  // Get entries by date range
  static Future<List<LogbookEntry>> getByDateRange(DateTime start, DateTime end) async {
    final entries = await getAll();
    return entries
        .where((e) => e.date.isAfter(start) && e.date.isBefore(end))
        .toList();
  }

  // Get recent entries
  static Future<List<LogbookEntry>> getRecent({int limit = 10}) async {
    final entries = await getAll();
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries.take(limit).toList();
  }

  // Get statistics
  static Future<LogbookStatistics> getStatistics() async {
    final entries = await getAll();

    double totalCaught = 0;
    int totalTrips = entries.length;
    double avgWaveHeight = 0;
    List<String> topSpecies = [];

    if (entries.isNotEmpty) {
      for (final entry in entries) {
        for (final catch_ in entry.catches) {
          totalCaught += catch_.weight;
        }
        avgWaveHeight += entry.waveHeight;
      }

      avgWaveHeight = avgWaveHeight / entries.length;

      // Count species frequency
      final speciesMap = <String, int>{};
      for (final entry in entries) {
        for (final catch_ in entry.catches) {
          speciesMap[catch_.fishSpecies] = (speciesMap[catch_.fishSpecies] ?? 0) + 1;
        }
      }

      final sortedEntries = speciesMap.entries.toList();
      sortedEntries.sort((a, b) => b.value.compareTo(a.value));
      topSpecies = sortedEntries.take(3).map((e) => e.key).toList();
    }

    return LogbookStatistics(
      totalTrips: totalTrips,
      totalCaught: totalCaught,
      averageWaveHeight: avgWaveHeight,
      topSpecies: topSpecies,
    );
  }
}

class LogbookStatistics {
  final int totalTrips;
  final double totalCaught; // kg
  final double averageWaveHeight; // cm
  final List<String> topSpecies;

  LogbookStatistics({
    required this.totalTrips,
    required this.totalCaught,
    required this.averageWaveHeight,
    required this.topSpecies,
  });
}
