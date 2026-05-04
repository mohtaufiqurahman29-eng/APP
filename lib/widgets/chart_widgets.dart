import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../models/tide_model.dart';
import '../models/sea_condition_model.dart';

class TideChart extends StatelessWidget {
  final TideSchedule tideSchedule;

  const TideChart({
    Key? key,
    required this.tideSchedule,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (tideSchedule.schedule.isEmpty) {
      return const Center(
        child: Text('Tidak ada data pasang surut'),
      );
    }

    final spots = tideSchedule.schedule.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.height);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 250,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 3,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < tideSchedule.schedule.length) {
                      final time = tideSchedule.schedule[index].time;
                      return Text(
                        '${time.hour}:00',
                        style: const TextStyle(fontSize: 10),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${value.toStringAsFixed(1)}m',
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: true),
            minX: 0,
            maxX: (tideSchedule.schedule.length - 1).toDouble(),
            minY: 0,
            maxY: 3,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: Colors.blue,
                barWidth: 2,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.blue.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WaveHeightChart extends StatelessWidget {
  final List<double> heights; // Wave heights for last 12 hours
  final List<String> labels;

  const WaveHeightChart({
    Key? key,
    required this.heights,
    required this.labels,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (heights.isEmpty) {
      return const Center(
        child: Text('Tidak ada data gelombang'),
      );
    }

    final spots = heights.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 250,
        child: BarChart(
          BarChartData(
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < labels.length) {
                      return Text(
                        labels[index],
                        style: const TextStyle(fontSize: 10),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${value.toStringAsFixed(0)}cm',
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: true),
            barGroups: spots.map((spot) {
              return BarChartGroupData(
                x: spot.x.toInt(),
                barRods: [
                  BarChartRodData(
                    toY: spot.y,
                    color: spot.y > 200 ? Colors.red : Colors.blue,
                    width: 15,
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class CompassWidget extends StatelessWidget {
  final String windDirection; // N, NE, E, SE, S, SW, W, NW
  final double windSpeed; // dalam knot

  const CompassWidget({
    Key? key,
    required this.windDirection,
    required this.windSpeed,
  }) : super(key: key);

  double _getRotation() {
    switch (windDirection) {
      case 'N':
        return 0;
      case 'NE':
        return 45;
      case 'E':
        return 90;
      case 'SE':
        return 135;
      case 'S':
        return 180;
      case 'SW':
        return 225;
      case 'W':
        return 270;
      case 'NW':
        return 315;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue, width: 2),
                color: Colors.blue.withOpacity(0.1),
              ),
              child: CustomPaint(
                painter: CompassPainter(),
              ),
            ),
            Transform.rotate(
              angle: _getRotation() * math.pi / 180,
              child: Column(
                children: [
                  Container(
                    width: 4,
                    height: 30,
                    color: Colors.red,
                  ),
                ],
              ),
            ),
            Text(
              windDirection,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Kecepatan Angin: $windSpeed knot',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 1;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Draw cardinal directions
    const directions = ['N', 'E', 'S', 'W'];
    const angles = [0, 90, 180, 270];

    for (int i = 0; i < directions.length; i++) {
      final angle = angles[i] * math.pi / 180;
      final x = center.dx + radius * math.sin(angle);
      final y = center.dy - radius * math.cos(angle);

      canvas.drawCircle(Offset(x, y), 3, paint);
    }

    // Draw intercardinal directions
    const interDirections = ['NE', 'SE', 'SW', 'NW'];
    const interAngles = [45, 135, 225, 315];

    paint.color = Colors.blue.withOpacity(0.5);
    for (int i = 0; i < interDirections.length; i++) {
      final angle = interAngles[i] * math.pi / 180;
      final x = center.dx + radius * math.sin(angle);
      final y = center.dy - radius * math.cos(angle);

      canvas.drawCircle(Offset(x, y), 2, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
