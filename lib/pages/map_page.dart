import 'package:flutter/material.dart';
import '../services/location_service.dart';
import '../models/location_model.dart';
import 'detail_page.dart';

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
          _filteredLocations =
              LocationService.getLocationsByType(_selectedType);
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
          // SEARCH
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari lokasi...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: _filterLocations,
            ),
          ),

          // FILTER
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

          const SizedBox(height: 10),

          // LIST
          Expanded(
            child: _filteredLocations.isEmpty
                ? const Center(
                    child: Text('Lokasi tidak ditemukan'),
                  )
                : ListView.builder(
                    itemCount: _filteredLocations.length,
                    itemBuilder: (context, index) {
                      final location = _filteredLocations[index];

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailPage(
                                location: location,
                              ),
                            ),
                          );
                        },

                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),

                          child: Padding(
                            padding: const EdgeInsets.all(12),

                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [
                                Row(
                                  children: [
                                    _getLocationIcon(location.type),

                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,

                                        children: [
                                          Text(
                                            location.name,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight:
                                                  FontWeight.bold,
                                            ),
                                          ),

                                          const SizedBox(height: 4),

                                          Text(
                                            location.type,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  location.description,
                                  maxLines: 2,
                                  overflow:
                                      TextOverflow.ellipsis,
                                ),

                                const SizedBox(height: 10),

                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Colors.blue,
                                      size: 18,
                                    ),

                                    const SizedBox(width: 4),

                                    Text(
                                      '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
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
        selectedColor: Colors.green.shade300,
      ),
    );
  }

  Widget _getLocationIcon(String type) {
    switch (type) {
      case 'Pelabuhan':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.anchor,
            color: Colors.blue,
          ),
        );

      case 'Pantai':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.beach_access,
            color: Colors.orange,
          ),
        );

      case 'TPI':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
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