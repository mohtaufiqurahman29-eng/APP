import 'dart:math' as math;
import 'package:flutter/foundation.dart'; // Untuk cek kIsWeb
import 'package:flutter/material.dart';

// KODE INI BEBAS DARI PACKAGES LUAR - PASTI BEBAS EROR MERAH
class SmoothCompassWidget extends StatefulWidget {
  final double? targetTideDirection;

  const SmoothCompassWidget({Key? key, this.targetTideDirection}) : super(key: key);

  @override
  State<SmoothCompassWidget> createState() => _SmoothCompassWidgetState();
}

class _SmoothCompassWidgetState extends State<SmoothCompassWidget> {
  double _currentHeading = 0.0; // Nilai default derajat kompas

  @override
  Widget build(BuildContext context) {
    double headingInRadian = _currentHeading * (math.pi / 180);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Kotak Informasi Derajat
        _buildHeadingCard(_currentHeading),
        const SizedBox(height: 12),
        
        Text(
          kIsWeb ? "(Mode Chrome: Gunakan Slider di Bawah)" : "(Mode Device: Kompas Siap)",
          style: const TextStyle(fontSize: 12, color: Colors.amber, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        // 2. Visualisasi Kompas Berputar (Menggunakan Animasi Halus)
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: headingInRadian),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          builder: (context, radian, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Piringan kompas yang berputar
                Transform.rotate(
                  angle: -radian,
                  child: _buildCompassPlate(),
                ),
                
                // Jarum Penunjuk Utara Statis (Warna Merah)
                _buildStaticNorthPointer(),

                // Jarum Indikator Arus Pasang Surut (Warna Cyan) jika ada datanya
                if (widget.targetTideDirection != null)
                  Transform.rotate(
                    angle: (widget.targetTideDirection! * (math.pi / 180)) - radian,
                    child: _buildTideDirectionPointer(),
                  ),
              ],
            );
          },
        ),
        
        const SizedBox(height: 20),

        // Slider Pengendali Simulasi (Sangat berguna saat kamu running di Chrome/Web)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Slider(
            value: _currentHeading,
            min: 0,
            max: 360,
            activeColor: Colors.blue,
            inactiveColor: Colors.grey[700],
            onChanged: (value) {
              setState(() {
                _currentHeading = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeadingCard(double heading) {
    String cardinal = _getCardinalDirection(heading);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "${heading.toStringAsFixed(0)}°",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(width: 8),
          Text(
            cardinal,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCompassPlate() {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[900],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 8,
          )
        ],
        border: Border.all(color: Colors.grey[700]!, width: 4),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(top: 10, child: _buildDirectionText('N', Colors.red, true)),
          Positioned(bottom: 10, child: _buildDirectionText('S', Colors.white, false)),
          Positioned(right: 10, child: _buildDirectionText('E', Colors.white, false)),
          Positioned(left: 10, child: _buildDirectionText('W', Colors.white, false)),
          
          // Lingkaran dekorasi dalam
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue.withOpacity(0.15), width: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticNorthPointer() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.arrow_drop_up, size: 45, color: Colors.red[700]),
        const SizedBox(height: 95), 
      ],
    );
  }

  Widget _buildTideDirectionPointer() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.navigation, size: 28, color: Colors.cyan[400]),
        const SizedBox(height: 125), 
      ],
    );
  }

  Widget _buildDirectionText(String text, Color color, bool isBold) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        color: color,
      ),
    );
  }

  String _getCardinalDirection(double heading) {
    if (heading >= 337.5 || heading < 22.5) return 'Utara (N)';
    if (heading >= 22.5 && heading < 67.5) return 'Timur Laut (NE)';
    if (heading >= 67.5 && heading < 112.5) return 'Timur (E)';
    if (heading >= 112.5 && heading < 157.5) return 'Tenggara (SE)';
    if (heading >= 157.5 && heading < 202.5) return 'Selatan (S)';
    if (heading >= 202.5 && heading < 247.5) return 'Barat Daya (SW)';
    if (heading >= 247.5 && heading < 292.5) return 'Barat (W)';
    if (heading >= 292.5 && heading < 337.5) return 'Barat Laut (NW)';
    return '';
  }
}