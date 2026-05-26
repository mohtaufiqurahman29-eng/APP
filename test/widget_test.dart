import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// 1. Mengubah nama package dari nelayanku menjadi tugas
import 'package:tugas/pages/dashboard_page.dart'; 

void main() {
  testWidgets('Dashboard InfoLaut Smoke Test', (WidgetTester tester) async {
    // 2. Mengganti MyApp() menjadi DashboardPage() yang dibungkus MaterialApp
    // Ini adalah cara paling benar jika tidak ada class MyApp
    await tester.pumpWidget(const MaterialApp(
      home: DashboardPage(),
    ));

    // 3. Tunggu sampai semua FutureBuilder selesai memuat data acaknya
    await tester.pumpAndSettle();

    // 4. Memastikan teks judul dasbor berhasil dirender di layar
    expect(find.text('🛟 InfoLaut Dashboard'), findsOneWidget);
  });
}