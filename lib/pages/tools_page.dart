import 'package:flutter/material.dart';
import '../services/logbook_service.dart';
import 'tools/sos_page.dart';
import 'tools/logbook_page.dart';
import 'tools/fish_catalog_page.dart';
import 'tools/fish_prediction_page.dart';
import 'tools/settings_page.dart';

class ToolsPage extends StatefulWidget {
  const ToolsPage({Key? key}) : super(key: key);

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  late Future<LogbookStatistics> _statisticsFuture;

  @override
  void initState() {
    super.initState();
    _statisticsFuture = LogbookService.getStatistics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('InfoLaut - Tools & Fitur'),
        elevation: 0,
        backgroundColor: Colors.purple.shade600,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Emergency Section
          _buildSectionHeader('🚨 Darurat'),
          _buildToolCard(
            title: 'Tombol SOS',
            description: 'Kirim lokasi darurat via WhatsApp/SMS',
            icon: Icons.emergency,
            color: Colors.red,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SOSPage()),
              );
            },
          ),

          const SizedBox(height: 16),

          // Fishing Tools Section
          _buildSectionHeader('🎣 Tools Nelayan'),
          Row(
            children: [
              Expanded(
                child: _buildToolCard(
                  title: 'Prediksi Ikan',
                  description: 'Lokasi tangkapan terbaik',
                  icon: Icons.location_on,
                  color: Colors.amber,
                  compact: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FishPredictionPage(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildToolCard(
                  title: 'Katalog Ikan',
                  description: 'Jenis ikan & musim',
                  icon: Icons.menu_book,
                  color: Colors.cyan,
                  compact: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FishCatalogPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Logbook Section
          _buildSectionHeader('📔 Logbook Digital'),
          FutureBuilder<LogbookStatistics>(
            future: _statisticsFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final stats = snapshot.data!;
                return Column(
                  children: [
                    _buildStatCard(
                      'Total Trips',
                      stats.totalTrips.toString(),
                      Icons.directions_boat,
                      Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    _buildStatCard(
                      'Total Tangkapan',
                      '${stats.totalCaught.toStringAsFixed(1)} kg',
                      Icons.scale,
                      Colors.green,
                    ),
                    const SizedBox(height: 12),
                    _buildToolCard(
                      title: 'Buka Logbook',
                      description: 'Catat hasil melaut Anda',
                      icon: Icons.book,
                      color: Colors.indigo,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LogbookPage(),
                          ),
                        );
                      },
                    ),
                  ],
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),

          const SizedBox(height: 16),

          // Settings Section
          _buildSectionHeader('⚙️ Pengaturan'),
          _buildToolCard(
            title: 'Pengaturan Bahasa & Notifikasi',
            description: 'Atur preferensi aplikasi',
            icon: Icons.settings,
            color: Colors.grey,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildToolCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool compact = false,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: compact
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: color, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: color, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.grey),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
