import 'package:flutter/material.dart';
import '../models/sea_condition_model.dart';
import '../services/sea_data_service.dart';

class AddReportPage extends StatefulWidget {
  const AddReportPage({super.key});

  @override
  State<AddReportPage> createState() => _AddReportPageState();
}

class _AddReportPageState extends State<AddReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _waveController = TextEditingController();
  final _windSpeedController = TextEditingController();
  
  String _selectedDirection = 'UTARA';
  String _selectedStatus = 'AMAN';

  final List<String> _directions = ['UTARA', 'TIMUR LAUT', 'TIMUR', 'TENGGARA', 'SELATAN', 'BARAT DAYA', 'BARAT', 'BARAT LAUT'];
  final List<String> _statuses = ['AMAN', 'WASPADA', 'BAHAYA'];

  @override
  void dispose() {
    _waveController.dispose();
    _windSpeedController.dispose();
    super.dispose();
  }

  void _simpanData() async {
    if (_formKey.currentState!.validate()) {
      final laporanBaru = SeaCondition.fromJson({
        'waveHeight': double.parse(_waveController.text),
        'windSpeed': double.parse(_windSpeedController.text),
        'windDirection': _selectedDirection,
        'temperature': 28.0,
        'humidity': 80,
        'safetyStatus': _selectedStatus,
      });

      await SeaDataService.addCustomReport(laporanBaru);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 Laporan cuaca berhasil disimpan ke Database HP!')),
        );
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📝 Tambah Laporan Laut', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _waveController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Tinggi Gelombang (cm)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.waves),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Tinggi gelombang wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _windSpeedController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Kecepatan Angin (knot)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.air),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Kecepatan angin wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedDirection,
              decoration: const InputDecoration(labelText: 'Arah Angin', border: OutlineInputBorder(), prefixIcon: Icon(Icons.explore)),
              items: _directions.map((dir) => DropdownMenuItem(value: dir, child: Text(dir))).toList(),
              onChanged: (value) => setState(() => _selectedDirection = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(labelText: 'Status Keamanan', border: OutlineInputBorder(), prefixIcon: Icon(Icons.gpp_good)),
              items: _statuses.map((stat) => DropdownMenuItem(value: stat, child: Text(stat))).toList(),
              onChanged: (value) => setState(() => _selectedStatus = value!),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _simpanData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Simpan Laporan', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}