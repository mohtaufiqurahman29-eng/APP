import 'package:flutter/material.dart';
import '../services/location_service.dart';
import '../models/location_model.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final TextEditingController _searchController = TextEditingController();
  List<SeaLocation> _locations = [];
  List<SeaLocation> _filteredLocations = [];
  String _selectedType = 'Semua';

  @override
  void initState() {
    super.initState();
    _locations = LocationService.getAllLocations();
    _filteredLocations = _locations;
  }

  void _filterLocations(String query) {
    setState(() {
      if (query.isEmpty) {
        if (_selectedType == 'Semua') {
          _filteredLocations = _locations;
        } else {
          _filteredLocations = LocationService.getLocationsByType(_selectedType);
        }
      } else {
        _filteredLocations = LocationService.searchLocations(query);
        if (_selectedType != 'Semua') {
          _filteredLocations = _filteredLocations
              .where((loc) => loc.type == _selectedType)
              .toList();
        }
      }
    });
  }

  void _filterByType(String type) {
    setState(() {
      _selectedType = type;
      _filterLocations(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('InfoLaut - Peta & Lokasi'),
        elevation: 0,
        backgroundColor: Colors.green.shade600,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari lokasi (pelabuhan, pantai, TPI)...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterLocations('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: _filterLocations,
            ),
          ),

          // Type Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTypeChip('Semua'),
                  _buildTypeChip('Pelabuhan'),
                  _buildTypeChip('Pantai'),
                  _buildTypeChip('TPI'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Locations List
          Expanded(
            child: _filteredLocations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_off,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text('Lokasi tidak ditemukan'),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredLocations.length,
                    itemBuilder: (context, index) {
                      final location = _filteredLocations[index];
                      return _buildLocationCard(location);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String type) {
    final isSelected = _selectedType == type;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(type),
        selected: isSelected,
        onSelected: (_) => _filterByType(type),
        backgroundColor: Colors.grey.shade200,
        selectedColor: Colors.green.shade300,
      ),
    );
  }

  Widget _buildLocationCard(SeaLocation location) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _getLocationIcon(location.type),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        location.type,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              location.description,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: Colors.blue,
                ),
                const SizedBox(width: 4),
                Text(
                  '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.location_city,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  location.province,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.directions),
                    label: const Text('Rute'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Rute ke ${location.name} ditampilkan di peta'),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.info),
                    label: const Text('Detail'),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(location.name),
                            content: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Tipe: ${location.type}'),
                                  const SizedBox(height: 8),
                                  Text('Provinsi: ${location.province}'),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Koordinat: ${location.latitude}, ${location.longitude}',
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Deskripsi: ${location.description}',
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
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _getLocationIcon(String type) {
    switch (type) {
      case 'Pelabuhan':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.anchor,
            color: Colors.blue,
          ),
        );
      case 'Pantai':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.beach_access,
            color: Colors.orange,
          ),
        );
      case 'TPI':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.storefront,
            color: Colors.green,
          ),
        );
      default:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.place),
        );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
