import 'package:flutter/material.dart';

class TideChart extends StatelessWidget {
  final List<double> heights;
  final List<String> labels;

  const TideChart({
    super.key,
    required this.heights,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Grafik Pergerakan Air (Meter)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(heights.length, (index) {
                final barHeight = (heights[index] / 2.0) * 100; 
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${heights[index]}m',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 25,
                      height: barHeight.clamp(10.0, 100.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.blue.shade700],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      labels[index],
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class WaveHeightChart extends StatelessWidget {
  final List<double> heights;
  final List<String> labels;

  const WaveHeightChart({
    super.key,
    required this.heights,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: Text('Grafik Tinggi Gelombang'),
      ),
    );
  }
}

class CompassWidget extends StatelessWidget {
  final double windDirection;
  final double windSpeed;

  const CompassWidget({
    super.key,
    required this.windDirection,
    required this.windSpeed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue.shade100, width: 2),
            ),
          ),
          Transform.rotate(
            angle: (windDirection * 3.141592653589793) / 180, 
            child: Icon(Icons.navigation, size: 40, color: Colors.blue.shade700),
          ),
          Positioned(
            bottom: 30,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${windSpeed.toStringAsFixed(1)} knot',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.blue.shade800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}