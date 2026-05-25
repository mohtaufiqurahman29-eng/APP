import 'package:flutter/material.dart';
import 'package:tugas/widgets/smooth_compass_widget.dart'; // Import kompas baru
import '../services/sea_data_service.dart';
import '../models/sea_condition_model.dart';
import '../models/tide_model.dart';
import '../widgets/custom_widgets.dart';
import '../widgets/chart_widgets.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<SeaCondition> _seaConditionFuture;
  late Future<TideSchedule> _tideScheduleFuture;

  @override
  void initState() {
    super.initState();
    _seaConditionFuture = SeaDataService.getSeaCondition();
    _tideScheduleFuture = Future.value(SeaDataService.generateTideSchedule());
  }

  String _getSafetyDescription(String status) {
    switch (status) {
      case 'AMAN':
        return 'Kondisi laut aman untuk berlayar. Gelombang rendah dan angin terukur.';
      case 'WASPADA':
        return 'Kondisi laut perlu diwaspadai. Gelombang mulai tinggi, hati-hati saat berlayar.';
      case 'BAHAYA':
        return 'Kondisi laut berbahaya. Tidak disarankan untuk berlayar hari ini.';
      default:
        return 'Kondisi tidak diketahui';
    }
  }

  double _getWindDegree(String direction) {
    switch (direction.toUpperCase()) {
      case 'UTARA': case 'N': return 0.0;
      case 'TIMUR LAUT': case 'NE': return 45.0;
      case 'TIMUR': case 'E': return 90.0;
      case 'TENGGARA': case 'SE': return 135.0;
      case 'SELATAN': case 'S': return 180.0;
      case 'BARAT DAYA': case 'SW': return 225.0;
      case 'BARAT': case 'W': return 270.0;
      case 'BARAT LAUT': case 'NW': return 315.0;
      default: return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('InfoLaut - Dashboard'),
        elevation: 0,
        backgroundColor: Colors.blue.shade600,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _seaConditionFuture = SeaDataService.getSeaCondition();
            _tideScheduleFuture = Future.value(SeaDataService.generateTideSchedule());
          });
        },
        child: ListView(
          children: [
            FutureBuilder<SeaCondition>(
              future: _seaConditionFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final condition = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: SafetyStatusCard(
                      status: condition.safetyStatus,
                      description: _getSafetyDescription(condition.safetyStatus),
                    ),
                  );
                }
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              },
            ),

            FutureBuilder<SeaCondition>(
              future: _seaConditionFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final condition = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.2,
                      children: [
                        WeatherInfoCard(
                          icon: '🌊',
                          label: 'Tinggi Gelombang',
                          value: condition.waveHeight.toStringAsFixed(0),
                          unit: 'cm',
                        ),
                        WeatherInfoCard(
                          icon: '💨',
                          label: 'Kecepatan Angin',
                          value: condition.windSpeed.toStringAsFixed(1),
                          unit: 'knot',
                        ),
                        WeatherInfoCard(
                          icon: '🌡️',
                          label: 'Suhu Air',
                          value: condition.temperature.toStringAsFixed(1),
                          unit: '°C',
                        ),
                        WeatherInfoCard(
                          icon: '💧',
                          label: 'Kelembaban',
                          value: condition.humidity.toString(),
                          unit: '%',
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: 16),

            // --- BAGIAN UTAMA KOMPAS BARU YANG SUDAH TERHUBUNG DATA---
            FutureBuilder<SeaCondition>(
              future: _seaConditionFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final condition = snapshot.data!;
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SmoothCompassWidget(
                        // Mengonversi string arah angin (misal 'UTARA') menjadi derajat pasang surut target
                        targetTideDirection: _getWindDegree(condition.windDirection),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: 16),

            SectionHeader(
              title: 'Jadwal Pasang Surut (24 jam)',
              onMorePressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lihat jadwal lengkap pasang surut di halaman detail'),
                  ),
                );
              },
            ),
            FutureBuilder<TideSchedule>(
              future: _tideScheduleFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return const TideChart(
                    heights: [1.0, 1.2, 0.8, 0.5, 1.1],
                    labels: ["00:00", "06:00", "12:00", "18:00", "24:00"],
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}