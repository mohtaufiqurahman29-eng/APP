import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _language = 'id'; // id, mad (Madura)
  bool _pushNotifications = true;
  bool _offlineMode = true;
  String _theme = 'light'; // light, dark

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _language = prefs.getString('language') ?? 'id';
      _pushNotifications = prefs.getBool('push_notifications') ?? true;
      _offlineMode = prefs.getBool('offline_mode') ?? true;
      _theme = prefs.getString('theme') ?? 'light';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', _language);
    await prefs.setBool('push_notifications', _pushNotifications);
    await prefs.setBool('offline_mode', _offlineMode);
    await prefs.setString('theme', _theme);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pengaturan disimpan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: Colors.grey.shade600,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language Section
            _buildSectionHeader('Bahasa'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _buildSettingTile(
                      icon: Icons.language,
                      title: 'Bahasa Indonesia',
                      value: 'id',
                      current: _language,
                      onChanged: (value) {
                        setState(() => _language = value);
                      },
                    ),
                    const Divider(),
                    _buildSettingTile(
                      icon: Icons.language,
                      title: 'Bahasa Madura',
                      value: 'mad',
                      current: _language,
                      onChanged: (value) {
                        setState(() => _language = value);
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Theme Section
            _buildSectionHeader('Tema Aplikasi'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _buildRadioTile(
                      title: 'Tema Terang',
                      value: 'light',
                      current: _theme,
                      onChanged: (value) {
                        setState(() => _theme = value);
                      },
                    ),
                    const Divider(),
                    _buildRadioTile(
                      title: 'Tema Gelap',
                      value: 'dark',
                      current: _theme,
                      onChanged: (value) {
                        setState(() => _theme = value);
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Notifications Section
            _buildSectionHeader('Notifikasi'),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Push Notification BMKG',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Terima peringatan dini tsunami dan badai',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    Switch(
                      value: _pushNotifications,
                      onChanged: (value) {
                        setState(() => _pushNotifications = value);
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Offline Mode Section
            _buildSectionHeader('Mode Offline'),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cache Data Lokal',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Simpan data cuaca terbaru untuk akses offline',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    Switch(
                      value: _offlineMode,
                      onChanged: (value) {
                        setState(() => _offlineMode = value);
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Data Management Section
            _buildSectionHeader('Kelola Data'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: Colors.red),
                    title: const Text('Hapus Cache Data'),
                    subtitle:
                        const Text('Hapus data cuaca dan lokasi yang di-cache'),
                    onTap: () => _showClearCacheDialog(),
                  ),
                  const Divider(),
                  ListTile(
                    leading:
                        const Icon(Icons.cloud_download_outlined, color: Colors.blue),
                    title: const Text('Backup Logbook'),
                    subtitle: const Text('Ekspor semua data logbook ke file'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Fitur backup akan segera tersedia di versi mendatang',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // About Section
            _buildSectionHeader('Tentang'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Versi Aplikasi'),
                        Text(
                          '1.0.0',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Developer'),
                        Text(
                          'InfoLaut Team',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Aplikasi Informasi Laut untuk nelayan dan mahasiswa kelautan Indonesia',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                child: const Text('Simpan Pengaturan'),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String value,
    required String current,
    required ValueChanged<String> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title),
            ),
            Radio(
              value: value,
              groupValue: current,
              onChanged: (v) => onChanged(v ?? value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioTile({
    required String title,
    required String value,
    required String current,
    required ValueChanged<String> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(title),
            ),
            Radio(
              value: value,
              groupValue: current,
              onChanged: (v) => onChanged(v ?? value),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Cache Data?'),
          content: const Text(
            'Ini akan menghapus semua data cuaca dan lokasi yang di-cache. Anda perlu koneksi internet untuk mengakses data lagi.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cache data dihapus')),
                );
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}
