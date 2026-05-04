import 'package:flutter/material.dart';
import '../../services/fish_service.dart';
import '../../models/fish_model.dart';

class FishPredictionPage extends StatefulWidget {
  const FishPredictionPage({Key? key}) : super(key: key);

  @override
  State<FishPredictionPage> createState() => _FishPredictionPageState();
}

class _FishPredictionPageState extends State<FishPredictionPage> {
  final _latController = TextEditingController(text: '-6.1285');
  final _lonController = TextEditingController(text: '106.8277');
  final _tempController = TextEditingController(text: '27.5');

  List<FishingGround> _predictions = [];
  bool _isLoading = false;

  void _predictFishingGrounds() {
    setState(() => _isLoading = true);

    final latitude = double.tryParse(_latController.text) ?? -6.1285;
    final longitude = double.tryParse(_lonController.text) ?? 106.8277;
    final temperature = double.tryParse(_tempController.text) ?? 27.5;

    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _predictions = FishService.predictFishingGrounds(
          temperature,
          latitude,
          longitude,
        );
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prediksi Area Tangkapan Ikan'),
        backgroundColor: Colors.amber.shade600,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                border: Border.all(color: Colors.amber),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📍 Cara Kerja Prediksi',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sistem ini memprediksi lokasi terbaik berdasarkan:\n'
                    '• Suhu permukaan air laut\n'
                    '• Jenis ikan musiman\n'
                    '• Zona perairan\n\n'
                    'Masukkan koordinat dan suhu air untuk mendapat prediksi.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Input Section
            Text(
              'Input Data',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            // Latitude
            TextField(
              controller: _latController,
              decoration: InputDecoration(
                labelText: 'Latitude (°)',
                hintText: '-6.1285',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 12),

            // Longitude
            TextField(
              controller: _lonController,
              decoration: InputDecoration(
                labelText: 'Longitude (°)',
                hintText: '106.8277',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 12),

            // Temperature
            TextField(
              controller: _tempController,
              decoration: InputDecoration(
                labelText: 'Suhu Air (°C)',
                hintText: '27.5',
                prefixIcon: const Icon(Icons.thermostat),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 24),

            // Predict Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.location_searching),
                label: const Text('Prediksi Area Tangkapan'),
                onPressed: _isLoading ? null : _predictFishingGrounds,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade600,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Results
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_predictions.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.location_off,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text('Tekan tombol untuk memulai prediksi'),
                  ],
                ),
              )
            else ...[
              Text(
                'Hasil Prediksi Area Terbaik',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _predictions.length,
                itemBuilder: (context, index) {
                  final ground = _predictions[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Lokasi ${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getSuitabilityColor(
                                    ground.suitabilityScore,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${ground.suitabilityScore.toStringAsFixed(0)}% Cocok',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Koordinat GPS',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      '${ground.latitude.toStringAsFixed(4)}, ${ground.longitude.toStringAsFixed(4)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Suhu Air',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      '${ground.waterTemperature.toStringAsFixed(1)}°C',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.school,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Ikan Diprediksi',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        ground.predictedFish,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Rute ke Lokasi ${index + 1} ditampilkan di peta',
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Buka di Peta'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Color _getSuitabilityColor(double score) {
    if (score >= 85) {
      return Colors.green;
    } else if (score >= 70) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  void dispose() {
    _latController.dispose();
    _lonController.dispose();
    _tempController.dispose();
    super.dispose();
  }
}
