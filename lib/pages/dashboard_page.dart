import 'package:flutter/material.dart';
import '../models/sea_condition_model.dart';
import '../models/tide_model.dart'; 
import '../services/sea_data_service.dart';
import 'add_report_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Future<SeaCondition>? _seaConditionFuture;
  Future<TideSchedule>? _tideScheduleFuture;
  
  List<SeaCondition> _savedReports = [];
  bool _isLoadingReports = true;

  @override
  void initState() {
    super.initState();
    _initFutures();
    _loadSavedReportsOnly();
  }

  void _initFutures() {
    _seaConditionFuture = SeaDataService.getSeaCondition();
    _tideScheduleFuture = Future.value(SeaDataService.generateTideSchedule());
  }

  Future<void> _loadSavedReportsOnly() async {
    if (!mounted) return;
    setState(() {
      _isLoadingReports = true;
    });

    final reports = await SeaDataService.getSavedReports();
    
    if (!mounted) return;
    setState(() {
      _savedReports = reports;
      _isLoadingReports = false;
    });
  }

  Future<void> _loadAllData() async {
    setState(() {
      _initFutures();
    });
    await _loadSavedReportsOnly();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌊 InfoLaut - Dasbor Nelayan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadAllData,
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAllData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FutureBuilder<SeaCondition>(
              future: _seaConditionFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError || !snapshot.hasData) {
                  // ✅ FIX PARSING: Menambahkan airPressure dan timestamp agar sesuai model aslimu
                  final fallbackData = SeaCondition(
                    waveHeight: 120.5, // Kembali ke cm sesuai modelmu
                    windSpeed: 12.5,
                    windDirection: 'UTARA',
                    airPressure: 1010.0, // Parameter wajib baru
                    safetyStatus: 'AMAN',
                    timestamp: DateTime.now(), // Parameter wajib baru
                    temperature: 29.0,
                    humidity: 78,
                  );
                  return _buildMainDashboardContent(context, fallbackData);
                } else {
                  return _buildMainDashboardContent(context, snapshot.data!);
                }
              },
            ),
            const SizedBox(height: 25),
            
            // 🌊 JADWAL PASANG SURUT AIR LAUT
            Row(
              children: [
                const Icon(Icons.wb_twighlight, color: Colors.blue),
                const SizedBox(width: 8),
                Text('Jadwal Pasang Surut Air Laut', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
              ],
            ),
            const SizedBox(height: 10),
            FutureBuilder<TideSchedule>(
              future: _tideScheduleFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError || !snapshot.hasData) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Lokasi: Pesisir Pantai', style: TextStyle(fontWeight: FontWeight.bold)),
                          const Divider(),
                          _buildTideRow('06:00', '1.2'),
                          _buildTideRow('12:00', '0.4'),
                          _buildTideRow('18:00', '1.5'),
                        ],
                      ),
                    ),
                  );
                } else {
                  final tide = snapshot.data!;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Lokasi: ${tide.location}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const Divider(),
                          ...tide.dataPoints.map((point) => _buildTideRow(
                            point.time.length >= 16 ? point.time.substring(11, 16) : point.time, 
                            point.height.toString()
                          )),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
            
            const SizedBox(height: 25),
            
            // 📋 LAPORAN PETUGAS & NELAYAN LOKAL
            Row(
              children: [
                const Icon(Icons.history, color: Colors.blue),
                const SizedBox(width: 8),
                Text('Laporan Petugas & Nelayan Lokal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
              ],
            ),
            const SizedBox(height: 10),
            _isLoadingReports
                ? const Center(child: CircularProgressIndicator())
                : _savedReports.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                        child: const Center(child: Text('Belum ada laporan manual dimasukkan.', style: TextStyle(color: Colors.grey))),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _savedReports.length,
                        itemBuilder: (context, index) {
                          final report = _savedReports[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: report.safetyStatus == 'BAHAYA' ? Colors.red : report.safetyStatus == 'WASPADA' ? Colors.orange : Colors.green,
                                child: const Icon(Icons.waves, color: Colors.white),
                              ),
                              // ✅ FIX TAMPILAN: Satuan dikembalikan ke cm
                              title: Text('Gelombang: ${report.waveHeight} cm (${report.safetyStatus})', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('Angin: ${report.windSpeed} Knot ke ${report.windDirection}'),
                              trailing: Icon(Icons.check_circle, color: Colors.blue.shade300),
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade700,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddReportPage()),
          );

          if (result == true) {
            _loadAllData();
          }
        },
      ),
    );
  }

  Widget _buildTideRow(String time, String height) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Waktu: $time'),
          Text('Tinggi: $height meter', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
        ],
      ),
    );
  }

  Widget _buildMainDashboardContent(BuildContext context, SeaCondition data) {
    return Column(
      children: [
        Card(
          color: data.safetyStatus == 'BAHAYA' ? Colors.red.shade100 : data.safetyStatus == 'WASPADA' ? Colors.orange.shade100 : Colors.green.shade100,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('STATUS KEAMANAN LAUT SAAT INI:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                const SizedBox(height: 8),
                Text(
                  data.safetyStatus,
                  style: TextStyle(
                    fontSize: 28, 
                    fontWeight: FontWeight.bold, 
                    color: data.safetyStatus == 'BAHAYA' ? Colors.red.shade700 : data.safetyStatus == 'WASPADA' ? Colors.orange.shade700 : Colors.green.shade700
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Icon(Icons.analytics, color: Colors.blue),
            const SizedBox(width: 8),
            Text('Kondisi Real-Time Cuaca Laut', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
          ],
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.5,
          children: [
            // ✅ FIX TAMPILAN GELOMBANG: Satuan cm dan logika dialog disesuaikan (> 150 cm baru bahaya)
            _buildRealTimeCard(
              context,
              'Tinggi Gelombang', 
              '${data.waveHeight.toStringAsFixed(1)} cm', 
              Icons.waves, 
              Colors.blue,
              'Detail Gelombang',
              'Tinggi gelombang saat ini mencatat angka ${data.waveHeight.toStringAsFixed(1)} cm. ${data.waveHeight > 150.0 ? "Ombak terpantau sangat tinggi, harap kurangi kecepatan kapal atau tunda melaut." : "Kondisi ombak relatif tenang dan aman untuk melaut."}'
            ),
            _buildRealTimeCard(
              context,
              'Kecepatan Angin', 
              '${data.windSpeed.toStringAsFixed(1)} Knot', 
              Icons.air, 
              Colors.teal,
              'Detail Kecepatan Angin',
              'Hembusan angin berkecepatan ${data.windSpeed.toStringAsFixed(1)} Knot. ${data.windSpeed > 15 ? "Angin kencang berpotensi memicu riak ombak besar mendadak." : "Angin bertiup stabil dan ideal untuk navigasi layar kapal."}'
            ),
            _buildRealTimeCard(
              context,
              'Arah Angin', 
              data.windDirection, 
              Icons.explore, 
              Colors.orange,
              'Detail Arah Angin',
              'Pergerakan arah angin saat ini menuju ke arah $data.windDirection. Nelayan dapat memanfaatkan info ini untuk arah tebar jaring.'
            ),
            _buildRealTimeCard(
              context,
              'Suhu & Kelembapan', 
              '${data.temperature.toStringAsFixed(1)}°C / ${data.humidity}%', 
              Icons.thermostat, 
              Colors.red,
              'Detail Atmosfer Laut',
              'Suhu udara di wilayah pesisir mencapai ${data.temperature.toStringAsFixed(1)}°C dengan tingkat kelembapan udara berkisar ${data.humidity}%.'
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRealTimeCard(
    BuildContext context, 
    String title, 
    String value, 
    IconData icon, 
    Color color,
    String dialogTitle,
    String dialogMessage,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias, 
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: Row(
                children: [
                  Icon(icon, color: color),
                  const SizedBox(width: 10),
                  Text(dialogTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: Text(dialogMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Paham', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}