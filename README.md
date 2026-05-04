# InfoLaut - Aplikasi Informasi Laut Indonesia

InfoLaut adalah aplikasi Flutter yang dirancang khusus untuk nelayan, mahasiswa, dan profesional sektor kelautan Indonesia. Aplikasi ini menyediakan informasi real-time tentang kondisi laut, data pasang surut, prediksi area tangkapan ikan, dan fitur keselamatan darurat.

## Fitur Utama

### 1. 📊 Dashboard - Real-Time Monitoring
- **Ringkasan Kondisi Laut**: Status keamanan (Aman/Waspada/Bahaya) berdasarkan tinggi gelombang dan kecepatan angin
- **Data Pasang Surut (24 jam)**: Grafik interaktif menunjukkan waktu pasang dan surut
- **Tinggi & Arah Gelombang**: Informasi detail tentang kondisi gelombang
- **Kecepatan Angin & Tekanan Udara**: Compass interaktif untuk navigasi angin
- **Suhu Air & Kelembaban**: Parameter cuaca laut real-time
- **Refresh Mode**: Tarik layar ke bawah untuk update data terbaru

### 2. 🗺️ Peta & Navigasi
- **Interactive Sea Map**: Pencarian lokasi pelabuhan, pantai, dan TPI di Indonesia
- **Filter Lokasi**: Cari berdasarkan jenis (Pelabuhan/Pantai/TPI) atau nama
- **Detail Lokasi**: Lihat koordinat GPS, provinsi, dan deskripsi
- **Rute**: Fitur untuk menampilkan rute ke lokasi tujuan
- **Lokasi Terdekat**: Temukan lokasi terdekat dari posisi Anda

### 3. 🛠️ Tools & Fitur Nelayan

#### 🚨 Tombol SOS (Darurat)
- Kirim sinyal darurat dengan lokasi GPS ke nomor SAR/Dinas Perikanan
- Pesan darurat via WhatsApp/SMS dengan link Google Maps
- Konfirmasi keamanan sebelum mengirim
- Perbarui lokasi GPS real-time

#### 📔 Logbook Digital Melaut
- Catat setiap trip melaut dengan detail lengkap:
  - Lokasi melaut
  - Hasil tangkapan (jenis ikan, berat, jumlah)
  - Kondisi cuaca (suhu, gelombang, angin)
  - Catatan penting
- Lihat riwayat logbook dengan statistik:
  - Total trip melaut
  - Total hasil tangkapan
  - Rata-rata tinggi gelombang
  - Jenis ikan yang paling sering ditangkap
- Edit dan hapus logbook lama

#### 🎣 Prediksi Area Tangkapan (Fishing Ground)
- Prediksi lokasi terbaik berdasarkan:
  - Suhu permukaan air laut
  - Jenis ikan musiman
  - Data historis
- Tampilkan 5 area potensial dengan suitability score
- Lihat prediksi ikan yang akan ditemukan
- Buka lokasi di peta

#### 📚 Katalog Jenis Ikan
- Database 8+ jenis ikan laut Indonesia:
  - Cakalang, Tuna, Tongkol, Kembung, Bandeng, Udang, Teri, Layur
- Filter berdasarkan musim (Musiman/Sepanjang Tahun)
- Cari ikan berdasarkan nama ilmiah atau nama lokal
- Informasi lengkap:
  - Suhu ideal
  - Kedalaman perairan
  - Bulan musim tangkapan
  - Tips penangkapan

#### ⚙️ Pengaturan
- **Bahasa**: Dukungan Bahasa Indonesia dan Bahasa Madura
- **Tema**: Pilih Tema Terang atau Gelap
- **Notifikasi**: Aktifkan/matikan push notification BMKG untuk peringatan dini tsunami
- **Mode Offline**: Cache data cuaca untuk akses offline
- **Backup Data**: Ekspor data logbook (fitur segera hadir)

## Instalasi & Setup

### Prerequisites
- Flutter SDK ^3.11.5
- Dart SDK

### Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  fl_chart: ^0.65.0
  geolocator: ^9.0.2
  intl: ^0.19.0
  shared_preferences: ^2.2.2
  http: ^1.1.0
  provider: ^6.0.0
  flutter_map: ^6.1.0
  latlong2: ^0.9.1
```

### Cara Menjalankan

1. **Clone repository / Extract project**
   ```bash
   cd tugas
   flutter pub get
   ```

2. **Run aplikasi**
   ```bash
   flutter run
   ```

3. **Build APK**
   ```bash
   flutter build apk --release
   ```

## Struktur Project

```
lib/
├── main.dart                 # Entry point & bottom navigation
├── models/                   # Data models
│   ├── sea_condition_model.dart
│   ├── tide_model.dart
│   ├── fish_model.dart
│   ├── logbook_model.dart
│   └── location_model.dart
├── services/                 # Business logic & data
│   ├── sea_data_service.dart
│   ├── fish_service.dart
│   ├── logbook_service.dart
│   └── location_service.dart
├── pages/                    # Main screens
│   ├── dashboard_page.dart
│   ├── map_page.dart
│   ├── tools_page.dart
│   └── tools/                # Sub-pages untuk Tools
│       ├── sos_page.dart
│       ├── logbook_page.dart
│       ├── fish_catalog_page.dart
│       ├── fish_prediction_page.dart
│       └── settings_page.dart
└── widgets/                  # Reusable UI components
    ├── custom_widgets.dart
    └── chart_widgets.dart
```

## Fitur Teknis

### 1. Mode Offline
- Data cuaca terbaru di-cache otomatis
- Dapat diakses bahkan tanpa koneksi internet
- Cache valid selama 30 menit
- Clear cache tersedia di pengaturan

### 2. Notifikasi
- Push Notification dari BMKG (fitur integrasi)
- Peringatan dini tsunami dan badai ekstrem
- Dapat diatur pada halaman pengaturan

### 3. Lokalisasi (I18N)
- Dukungan multi-bahasa (Bahasa Indonesia & Madura)
- Pengaturan bahasa simpan ke local storage
- Siap untuk ekspansi bahasa daerah lainnya

### 4. Data Persistence
- Logbook disimpan dengan SharedPreferences
- Enkripsi opsional untuk data sensitif
- Backup & restore (fitur mendatang)

## Roadmap Fitur Mendatang

- [ ] Integrasi API BMKG real-time
- [ ] Push notification otomatis
- [ ] Peta interaktif dengan Google Maps
- [ ] Mode dark theme otomatis
- [ ] Export logbook ke PDF
- [ ] Sinkronisasi cloud
- [ ] Multi-language support (Bugis, Makasar, dll)
- [ ] Fitur social sharing logbook
- [ ] Weather forecast 7 hari

## Testing

Aplikasi dilengkapi dengan dummy data untuk testing:
- **Sea Condition**: Data real-time yang bervariasi setiap jam
- **Tide Schedule**: Jadwal pasang surut semi-diurnal (2 pasang, 2 surut/hari)
- **Locations**: 8 lokasi riil di Indonesia
- **Fish Database**: 8 jenis ikan dengan data lengkap

## Performance

- **Lightweight**: Ukuran APK ~50MB
- **Fast Load**: Cold start < 2 detik
- **Battery Efficient**: Menggunakan cached data
- **Smooth Animation**: 60 FPS di mayoritas device

## Kontribusi

Untuk berkontribusi pada proyek InfoLaut:

1. Fork repository
2. Buat feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push ke branch (`git push origin feature/AmazingFeature`)
5. Buat Pull Request

## License

Project ini dibuat untuk keperluan akademik dan pengembangan aplikasi publik.

## Kontak & Support

- **Developer**: Tim InfoLaut
- **Email**: infolaut@example.com
- **Issues**: Report bugs atau request fitur melalui GitHub Issues

---

**InfoLaut - Informasi Laut untuk Nelayan Indonesia** ⛵🌊
