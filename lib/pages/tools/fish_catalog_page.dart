import 'package:flutter/material.dart';
import '../../services/fish_service.dart';
import '../../models/fish_model.dart';

class FishCatalogPage extends StatefulWidget {
  const FishCatalogPage({Key? key}) : super(key: key);

  @override
  State<FishCatalogPage> createState() => _FishCatalogPageState();
}

class _FishCatalogPageState extends State<FishCatalogPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Fish> _fishes = [];
  List<Fish> _filteredFishes = [];
  String _filter = 'semua'; // semua, musiman, sepanjang_tahun

  @override
  void initState() {
    super.initState();
    _fishes = FishService.getAllFish();
    _filteredFishes = _fishes;
  }

  void _filterFishes(String query) {
    setState(() {
      if (query.isEmpty) {
        if (_filter == 'semua') {
          _filteredFishes = _fishes;
        } else if (_filter == 'musiman') {
          _filteredFishes = _fishes.where((f) => f.season.length < 12).toList();
        } else {
          _filteredFishes =
              _fishes.where((f) => f.season.length == 12).toList();
        }
      } else {
        _filteredFishes = FishService.searchFish(query);
      }
    });
  }

  void _setFilter(String filter) {
    setState(() {
      _filter = filter;
      _filterFishes(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Jenis Ikan'),
        backgroundColor: Colors.cyan.shade600,
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari jenis ikan...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: _filterFishes,
            ),
          ),

          // Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('Semua Ikan', 'semua'),
                _buildFilterChip('Musiman', 'musiman'),
                _buildFilterChip('Sepanjang Tahun', 'sepanjang_tahun'),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Fish List
          Expanded(
            child: _filteredFishes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.school,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text('Ikan tidak ditemukan'),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredFishes.length,
                    itemBuilder: (context, index) {
                      final fish = _filteredFishes[index];
                      return _buildFishCard(fish);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: _filter == value,
        onSelected: (_) => _setFilter(value),
        backgroundColor: Colors.grey.shade200,
        selectedColor: Colors.cyan.shade300,
      ),
    );
  }

  Widget _buildFishCard(Fish fish) {
    final seasonText = _getSeasonText(fish.season);
    final isMusicSeason = fish.season.contains(DateTime.now().month.toString());

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.cyan.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.school, color: Colors.cyan),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              fish.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (isMusicSeason)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'MUSIM SEKARANG',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fish.scientificName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              fish.description,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: [
                _buildInfoChip(
                  Icons.thermostat,
                  'Suhu: ${fish.minTemp}-${fish.maxTemp}°C',
                ),
                _buildInfoChip(
                  Icons.water,
                  fish.depth,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Musim: $seasonText',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _showFishDetail(fish),
              child: const Text('Lihat Detail'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _getSeasonText(List<String> seasons) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    final sorted = seasons.map((m) => int.parse(m)).toList();
    sorted.sort();

    if (sorted.length == 12) {
      return 'Sepanjang Tahun';
    }

    return sorted.map((m) => monthNames[m - 1]).join(', ');
  }

  void _showFishDetail(Fish fish) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(fish.name),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Nama Ilmiah:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(fish.scientificName),
                const SizedBox(height: 12),
                const Text(
                  'Deskripsi:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(fish.description),
                const SizedBox(height: 12),
                const Text(
                  'Kondisi Lingkungan:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Suhu: ${fish.minTemp}-${fish.maxTemp}°C'),
                Text('Kedalaman: ${fish.depth}'),
                const SizedBox(height: 12),
                const Text(
                  'Musim Tangkapan:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(_getSeasonText(fish.season)),
                const SizedBox(height: 12),
                const Text(
                  'Tips Penangkapan:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Ikan ini paling melimpah pada musimnya. '
                  'Perhatikan suhu air dan kedalaman yang sesuai untuk hasil maksimal.',
                ),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
