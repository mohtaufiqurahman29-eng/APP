import 'package:flutter/material.dart';
import '../models/location_model.dart';

class DetailPage extends StatelessWidget {
  final SeaLocation location;

  const DetailPage({
    Key? key,
    required this.location,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(location.name),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

           ClipRRect(
            borderRadius: BorderRadius.circular(20),
             child: Image.asset(
              location.image,
                height: 250,
                width: double.infinity,
                 fit: BoxFit.cover,
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    location.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(location.description),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      const Icon(Icons.location_on),
                      const SizedBox(width: 8),
                      Text(
                        '${location.latitude}, ${location.longitude}',
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.directions),
                      label: const Text('Lihat Rute'),
                      onPressed: () {

                      },
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