import 'package:flutter/material.dart';
import '../../services/logbook_service.dart';
import '../../models/logbook_model.dart';

class LogbookPage extends StatefulWidget {
  const LogbookPage({Key? key}) : super(key: key);

  @override
  State<LogbookPage> createState() => _LogbookPageState();
}

class _LogbookPageState extends State<LogbookPage> {
  late Future<List<LogbookEntry>> _entriesFuture;

  @override
  void initState() {
    super.initState();
    _refreshEntries();
  }

  Future<void> _refreshEntries() async {
    setState(() {
      _entriesFuture = LogbookService.getRecent(limit: 100);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logbook Digital Melaut'),
        backgroundColor: Colors.indigo.shade600,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateLogbookPage(),
            ),
          ).then((_) => _refreshEntries());
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<LogbookEntry>>(
        future: _entriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book,
                    size: 48,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text('Tidak ada data logbook'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateLogbookPage(),
                        ),
                      ).then((_) => _refreshEntries());
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Buat Logbook Baru'),
                  ),
                ],
              ),
            );
          }

          final entries = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refreshEntries,
            child: ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(
                      entry.location,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          '${entry.date.day}/${entry.date.month}/${entry.date.year} - ${entry.date.hour.toString().padLeft(2, '0')}:${entry.date.minute.toString().padLeft(2, '0')}',
                        ),
                        Text(
                          'Hasil: ${entry.catches.fold<double>(0, (sum, c) => sum + c.weight).toStringAsFixed(1)} kg',
                          style: TextStyle(color: Colors.green.shade700),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: const Text('Lihat Detail'),
                          onTap: () => _showDetail(entry),
                        ),
                        PopupMenuItem(
                          child: const Text('Hapus'),
                          onTap: () => _deleteEntry(entry.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showDetail(LogbookEntry entry) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(entry.location),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tanggal: ${entry.date.day}/${entry.date.month}/${entry.date.year}',
                ),
                const SizedBox(height: 8),
                Text('Lokasi GPS: ${entry.latitude}, ${entry.longitude}'),
                const SizedBox(height: 8),
                Text('Suhu: ${entry.temperature}°C'),
                const SizedBox(height: 8),
                Text('Tinggi Gelombang: ${entry.waveHeight}cm'),
                const SizedBox(height: 8),
                Text('Arah Angin: ${entry.windDirection}'),
                const SizedBox(height: 8),
                Text('Kecepatan Angin: ${entry.windSpeed} knot'),
                const SizedBox(height: 16),
                const Text(
                  'Hasil Tangkapan:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                for (final catch_ in entry.catches) ...[
                  const SizedBox(height: 8),
                  Text('• ${catch_.fishSpecies}: ${catch_.weight}kg x${catch_.quantity}'),
                  if (catch_.remarks.isNotEmpty)
                    Text('  Catatan: ${catch_.remarks}',
                        style: const TextStyle(fontSize: 12)),
                ],
                const SizedBox(height: 16),
                if (entry.notes.isNotEmpty) ...[
                  const Text(
                    'Catatan:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(entry.notes),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  void _deleteEntry(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Logbook?'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus data ini? Tidak dapat dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(context);
                await LogbookService.deleteEntry(id);
                _refreshEntries();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logbook dihapus')),
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

class CreateLogbookPage extends StatefulWidget {
  const CreateLogbookPage({Key? key}) : super(key: key);

  @override
  State<CreateLogbookPage> createState() => _CreateLogbookPageState();
}

class _CreateLogbookPageState extends State<CreateLogbookPage> {
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final _tempController = TextEditingController(text: '27.5');
  final _waveController = TextEditingController(text: '150');
  final _windSpeedController = TextEditingController(text: '12');

  String _windDirection = 'N';
  List<CatchRecord> _catches = [];
  double _latitude = -6.1285;
  double _longitude = 106.8277;

  void _addCatch() {
    showDialog(
      context: context,
      builder: (context) {
        String species = '';
        double weight = 0;
        int quantity = 0;
        String remarks = '';

        return AlertDialog(
          title: const Text('Tambah Hasil Tangkapan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Jenis Ikan'),
                  onChanged: (value) => species = value,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Berat (kg)'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                      weight = double.tryParse(value) ?? 0,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Jumlah'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                      quantity = int.tryParse(value) ?? 0,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Catatan'),
                  onChanged: (value) => remarks = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (species.isNotEmpty && weight > 0) {
                  setState(() {
                    _catches.add(CatchRecord(
                      fishSpecies: species,
                      weight: weight,
                      quantity: quantity,
                      remarks: remarks,
                    ));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  void _saveLogbook() async {
    if (_locationController.text.isEmpty || _catches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Isi lokasi dan minimal 1 hasil tangkapan'),
        ),
      );
      return;
    }

    final entry = LogbookService.createEntry(
      date: DateTime.now(),
      latitude: _latitude,
      longitude: _longitude,
      location: _locationController.text,
      catches: _catches,
      temperature: double.tryParse(_tempController.text) ?? 27.5,
      waveHeight: double.tryParse(_waveController.text) ?? 150,
      windDirection: _windDirection,
      windSpeed: double.tryParse(_windSpeedController.text) ?? 12,
      notes: _notesController.text,
    );

    await LogbookService.saveEntry(entry);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logbook disimpan')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Logbook Baru'),
        backgroundColor: Colors.indigo.shade600,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location
            Text(
              'Lokasi Melaut',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: 'Nama lokasi (misal: Perairan Muara Angke)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Conditions
            Text(
              'Kondisi Cuaca & Laut',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tempController,
                    decoration: InputDecoration(
                      labelText: 'Suhu (°C)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _waveController,
                    decoration: InputDecoration(
                      labelText: 'Gelombang (cm)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField(
                    initialValue: _windDirection,
                    decoration: InputDecoration(
                      labelText: 'Arah Angin',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'N', child: Text('Utara (N)')),
                      DropdownMenuItem(value: 'NE', child: Text('Barat Laut (NE)')),
                      DropdownMenuItem(value: 'E', child: Text('Timur (E)')),
                      DropdownMenuItem(value: 'SE', child: Text('Tenggara (SE)')),
                      DropdownMenuItem(value: 'S', child: Text('Selatan (S)')),
                      DropdownMenuItem(value: 'SW', child: Text('Barat Daya (SW)')),
                      DropdownMenuItem(value: 'W', child: Text('Barat (W)')),
                      DropdownMenuItem(value: 'NW', child: Text('Barat Laut (NW)')),
                    ],
                    onChanged: (value) {
                      setState(() => _windDirection = value ?? 'N');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _windSpeedController,
                    decoration: InputDecoration(
                      labelText: 'Kec. Angin (knot)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Catches
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hasil Tangkapan',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                ElevatedButton.icon(
                  onPressed: _addCatch,
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _catches.isEmpty
                ? const Text('Belum ada hasil tangkapan')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _catches.length,
                    itemBuilder: (context, index) {
                      final catch_ = _catches[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      catch_.fishSpecies,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${catch_.weight}kg x${catch_.quantity}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() => _catches.removeAt(index));
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

            const SizedBox(height: 16),

            // Notes
            Text(
              'Catatan Tambahan',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Catatan kondisi, kejadian khusus, dll',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveLogbook,
                child: const Text('Simpan Logbook'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    _notesController.dispose();
    _tempController.dispose();
    _waveController.dispose();
    _windSpeedController.dispose();
    super.dispose();
  }
}
