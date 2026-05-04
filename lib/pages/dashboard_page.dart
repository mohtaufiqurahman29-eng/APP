import 'package:flutter/material.dart';
import '../services/sea_data_service.dart';
import '../models/sea_condition_model.dart';
import '../models/tide_model.dart';
import '../widgets/custom_widgets.dart';
import '../widgets/chart_widgets.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

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
            // Safety Status Card
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
                  child: CircularProgressIndicator(),
                );
              },
            ),

            // Weather Info Grid
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

            // Arah Angin (Compass)
            FutureBuilder<SeaCondition>(
              future: _seaConditionFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final condition = snapshot.data!;
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: CompassWidget(
                        windDirection: condition.windDirection,
                        windSpeed: condition.windSpeed,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: 16),

            // Tide Schedule
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
                  return TideChart(tideSchedule: snapshot.data!);
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
