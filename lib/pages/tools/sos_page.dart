import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class SOSPage extends StatefulWidget {
  const SOSPage({Key? key}) : super(key: key);

  @override
  State<SOSPage> createState() => _SOSPageState();
}

class _SOSPageState extends State<SOSPage> {
  Position? _currentPosition;
  bool _isLoading = false;
  final TextEditingController _phoneController =
      TextEditingController(text: '+62274567890'); // Nomor SAR dummy
  final TextEditingController _messageController =
      TextEditingController(text: 'DARURAT: Kapal Saya Dalam Keadaan Bahaya!');

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  void _sendSOS() {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lokasi GPS belum tersedia'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi SOS'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Apakah Anda yakin ingin mengirim sinyal darurat?'),
              const SizedBox(height: 16),
              Text(
                'Lokasi: ${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Penerima: ${_phoneController.text}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(context);
                _executeSOSMessage();
              },
              child: const Text('Kirim SOS'),
            ),
          ],
        );
      },
    );
  }

  void _executeSOSMessage() {
    // Simulate sending SOS
    final message =
        '${_messageController.text}\nLokasi: ${_currentPosition!.latitude},${_currentPosition!.longitude}\nGMaps: https://maps.google.com/?q=${_currentPosition!.latitude},${_currentPosition!.longitude}';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('✓ SOS Terkirim'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text('Sinyal darurat telah dikirim!'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  message,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tombol SOS - Darurat'),
        backgroundColor: Colors.red.shade600,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '⚠️ Hanya Gunakan Untuk Darurat',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tombol ini hanya untuk kondisi darurat di laut. Pastikan Anda dalam situasi yang benar-benar memerlukan bantuan darurat sebelum mengirim.',
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Current Location
            Text(
              'Lokasi GPS Saat Ini',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _currentPosition == null
                    ? Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_off,
                                color: Colors.grey),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'GPS belum tersedia',
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _getCurrentLocation,
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          border: Border.all(color: Colors.green),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    color: Colors.green),
                                const SizedBox(width: 8),
                                const Text('GPS Tersambung'),
                                const Spacer(),
                                ElevatedButton(
                                  onPressed: _getCurrentLocation,
                                  child: const Text('Perbarui'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Latitude: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                            ),
                            Text(
                              'Longitude: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                            ),
                            Text(
                              'Akurasi: ±${_currentPosition!.accuracy.toStringAsFixed(1)}m',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),

            const SizedBox(height: 24),

            // Recipient Number
            Text(
              'Nomor Penerima (SAR/Dinas Perikanan)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'Nomor telepon',
              ),
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 16),

            // Message
            Text(
              'Pesan SOS',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLines: 4,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'Pesan darurat',
              ),
            ),

            const SizedBox(height: 24),

            // Big SOS Button
            SizedBox(
              width: double.infinity,
              height: 80,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _currentPosition != null ? _sendSOS : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.emergency, size: 40, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      'KIRIM SOS',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ℹ️ Informasi SOS',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Pesan akan dikirim via WhatsApp/SMS dengan lokasi GPS\n'
                    '• Link Google Maps akan disertakan untuk memudahkan pencarian\n'
                    '• Pastikan nomor penerima sudah benar\n'
                    '• Sinyal internet/telkomsel diperlukan untuk pengiriman',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
