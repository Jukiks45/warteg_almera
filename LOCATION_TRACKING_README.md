# 📍 Fitur Location Tracking dengan OpenStreetMap

## 🎯 Overview

Fitur ini mengimplementasikan **real-time location tracking** dengan:
- ✅ GPS + Network positioning menggunakan **Geolocator**
- ✅ Peta interaktif dengan **flutter_map** dan **OpenStreetMap**
- ✅ Auto-center map mengikuti pergerakan user
- ✅ Update koordinat ke **Supabase** setiap lokasi berubah
- ✅ Reverse geocoding untuk mendapat alamat lengkap
- ✅ UI modern dengan marker dan info cards

---

## 📦 Dependencies yang Digunakan

```yaml
dependencies:
  geolocator: ^10.1.0          # GPS dan Network positioning
  geocoding: ^3.0.0            # Reverse geocoding (koordinat → alamat)
  flutter_map: ^7.0.2          # Map widget dengan OpenStreetMap
  latlong2: ^0.9.1             # LatLng untuk flutter_map
  supabase_flutter: ^2.10.3    # Backend untuk simpan lokasi
  permission_handler: ^11.0.0  # Handle permission request
```

**Sudah terinstall?** ✅ Ya, semua dependency sudah dijalankan dengan `flutter pub get`

---

## 🗄️ Database Structure (Supabase)

### Tabel: `profiles`

Struktur tabel di Supabase untuk menyimpan lokasi user:

```sql
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT,
    full_name TEXT,
    avatar_url TEXT,
    latitude DOUBLE PRECISION,      -- ✅ Lokasi latitude user
    longitude DOUBLE PRECISION,     -- ✅ Lokasi longitude user
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()  -- Auto-update saat lokasi berubah
);
```

### Index untuk Performa

```sql
-- Index untuk query lokasi
CREATE INDEX idx_profiles_location ON public.profiles(latitude, longitude);

-- Index untuk updated_at (lokasi terbaru)
CREATE INDEX idx_profiles_updated_at ON public.profiles(updated_at DESC);
```

### RLS (Row Level Security) Policies

```sql
-- User hanya bisa lihat/update profil mereka sendiri
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own profile"
ON public.profiles FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
ON public.profiles FOR UPDATE USING (auth.uid() = id);
```

### Cara Install Database

1. **Buka Supabase Dashboard** → SQL Editor
2. **Copy-paste file** `supabase_migration_location.sql` 
3. **Klik "Run"** untuk execute migration
4. **Verifikasi** dengan query:
   ```sql
   \d public.profiles  -- Lihat struktur tabel
   ```

---

## 🏗️ Arsitektur Kode (GetX Pattern)

### 1. **LocationController** (`lib/modules/location/controllers/location_controller.dart`)

**Responsibilities:**
- Manage GPS location tracking
- Update marker dan auto-center map
- Reverse geocoding (koordinat → alamat)
- Update location ke Supabase setiap lokasi berubah

**Key Methods:**

```dart
startLocationTracking()          // Real-time tracking dengan getPositionStream()
getCurrentLocation()             // Get lokasi sekali (saat init/refresh)
updateLocationToSupabase()       // Save lat/lon ke Supabase profiles
getAddressFromCoordinates()      // Reverse geocoding untuk alamat
_updateMarker()                  // Update marker di peta
_centerMapToCurrentPosition()    // Auto-center map ke lokasi user
```

**Observables:**

```dart
currentPosition: Rxn<Position>   // Posisi GPS terkini
currentLatLng: Rxn<LatLng>       // Koordinat untuk flutter_map
currentAddress: String           // Alamat hasil reverse geocoding
markers: List<Marker>            // Marker untuk ditampilkan di map
isLoading: bool                  // Loading state
hasError: bool                   // Error state
```

**Location Settings:**

```dart
LocationSettings(
  accuracy: LocationAccuracy.high,  // GPS akurasi tinggi
  distanceFilter: 10,               // Update setiap 10 meter
)
```

### 2. **LocationView** (`lib/modules/location/views/location_view.dart`)

**UI Components:**

1. **FlutterMap dengan OpenStreetMap**
   ```dart
   TileLayer(
     urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
   )
   ```

2. **Marker Layer**
   - Red pin icon di lokasi user
   - Auto-update saat lokasi berubah

3. **Info Cards Overlay (Bottom Sheet)**
   - Koordinat: Latitude, Longitude, Accuracy
   - Alamat lengkap dari reverse geocoding
   - Action buttons: Refresh, Buka Maps

4. **Real-time Tracking Indicator**
   - Badge hijau "Tracking Aktif" di top-right

**States:**
- **Loading:** CircularProgressIndicator
- **Error:** Error message + retry button
- **Empty:** Waiting for GPS
- **Success:** Map + marker + info cards

### 3. **LocationBinding** (`lib/modules/location/bindings/location_binding.dart`)

```dart
Get.lazyPut<LocationController>(() => LocationController());
```

---

## 🔄 Alur Kerja (Flow)

### Saat Pertama Kali Buka Halaman

```
1. User tap tombol Maps di menu
   ↓
2. Navigate ke LocationView (Get.toNamed(AppRoutes.lokasi))
   ↓
3. LocationController.onInit() dipanggil:
   - getCurrentLocation() → Minta permission, get posisi pertama
   - startLocationTracking() → Mulai listen getPositionStream()
   ↓
4. LocationView menampilkan:
   - Loading indicator (saat mendapat lokasi pertama)
   - Map dengan marker di lokasi user
   - Info card dengan koordinat + alamat
   ↓
5. Real-time tracking aktif!
```

### Saat Lokasi Berubah (Real-time)

```
User bergerak (berjalan/berkendara)
   ↓
Geolocator.getPositionStream() mendeteksi perubahan (>10m)
   ↓
LocationController menerima Position baru:
   1. Update currentPosition dan currentLatLng
   2. Update marker di map (_updateMarker)
   3. Auto-center map ke posisi baru (_centerMapToCurrentPosition)
   4. Reverse geocoding untuk alamat baru (getAddressFromCoordinates)
   5. Update ke Supabase (updateLocationToSupabase)
   ↓
UI otomatis update karena menggunakan Obx (reactive)
```

### Update ke Supabase

```dart
// Setiap lokasi berubah, otomatis save ke Supabase
await supabase.from('profiles').upsert({
  'id': userId,              // User ID dari auth
  'latitude': latitude,      // GPS latitude
  'longitude': longitude,    // GPS longitude
  'updated_at': DateTime.now().toIso8601String(),
});
```

**Trigger otomatis** di Supabase:
- `updated_at` akan auto-update setiap kali ada perubahan
- Tidak perlu manual set di Flutter

---

## 🎨 Features yang Diimplementasikan

### ✅ Fitur Utama

| Fitur | Status | Deskripsi |
|-------|--------|-----------|
| GPS + Network Location | ✅ | Gabungan GPS dan network untuk akurasi tinggi |
| OpenStreetMap | ✅ | Peta gratis tanpa API key |
| Real-time Tracking | ✅ | Update lokasi setiap 10 meter |
| Auto-center Map | ✅ | Peta otomatis ikuti pergerakan user |
| Update ke Supabase | ✅ | Save koordinat ke database setiap lokasi berubah |
| Reverse Geocoding | ✅ | Konversi koordinat → alamat lengkap |
| Permission Handling | ✅ | Auto request permission dengan error handling |
| Marker di Peta | ✅ | Red pin icon di lokasi user |
| Loading States | ✅ | Loading, error, empty, success states |

### ✅ Fitur Tambahan

- 🎯 Tracking indicator badge (hijau di top-right)
- 🔄 Refresh button untuk manual update
- 📍 Info cards dengan koordinat detail
- 🏠 Alamat lengkap dari geocoding
- ⚙️ Link ke settings jika permission ditolak
- 📍 Button "Buka Maps" (dapat dikembangkan dengan url_launcher)

---

## 🚀 Cara Menggunakan

### 1. Setup Database

```bash
# Buka Supabase Dashboard → SQL Editor
# Copy-paste dan run: supabase_migration_location.sql
```

### 2. Jalankan Aplikasi

```bash
flutter clean
flutter pub get
flutter run
```

⚠️ **PENTING:** Lakukan **full restart** (bukan hot reload) karena ada:
- Perubahan dependencies
- Permission baru di AndroidManifest.xml dan Info.plist

### 3. Test Fitur

1. Login ke aplikasi
2. Tap tombol **Maps** di halaman menu
3. **Allow permission** saat diminta
4. Lihat **lokasi Anda muncul di peta**
5. **Bergerak** (jalan kaki/mobil) → Peta otomatis ikuti
6. Check **Supabase Dashboard** → Tabel profiles → Lihat `latitude` dan `longitude` ter-update

---

## 🔐 Permissions yang Diperlukan

### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

✅ **Sudah ditambahkan!**

### iOS (`ios/Runner/Info.plist`)

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Aplikasi memerlukan akses lokasi untuk menampilkan posisi Anda</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>Aplikasi memerlukan akses lokasi untuk menampilkan posisi Anda</string>
```

✅ **Sudah ditambahkan!**

---

## 📊 Query SQL yang Berguna

### 1. Lihat Semua Lokasi User

```sql
SELECT 
    email, 
    full_name, 
    latitude, 
    longitude, 
    updated_at 
FROM public.profiles 
WHERE latitude IS NOT NULL 
ORDER BY updated_at DESC;
```

### 2. Hitung Jarak User dari Titik Tertentu

Contoh: User dalam radius 5km dari Jakarta (-6.2088, 106.8456)

```sql
SELECT 
    email,
    latitude,
    longitude,
    (
        6371 * acos(
            cos(radians(-6.2088)) * cos(radians(latitude)) * 
            cos(radians(longitude) - radians(106.8456)) + 
            sin(radians(-6.2088)) * sin(radians(latitude))
        )
    ) AS distance_km
FROM public.profiles
WHERE latitude IS NOT NULL 
HAVING distance_km <= 5
ORDER BY distance_km;
```

### 3. User yang Update Lokasi dalam 10 Menit Terakhir

```sql
SELECT 
    email, 
    latitude, 
    longitude, 
    updated_at 
FROM public.profiles 
WHERE updated_at > NOW() - INTERVAL '10 minutes'
ORDER BY updated_at DESC;
```

---

## 🐛 Troubleshooting

### Error: Permission Denied

**Solusi:**
1. Pastikan GPS device aktif
2. Check AndroidManifest.xml dan Info.plist sudah ada permission
3. Full restart aplikasi (bukan hot reload)
4. Uninstall → Install ulang aplikasi

### Error: Location Service Disabled

**Solusi:**
- Aktifkan GPS di settings device
- Tap tombol "Buka Pengaturan" di error screen

### Error: Supabase Update Failed

**Solusi:**
1. Check user sudah login
2. Verifikasi RLS policies di Supabase
3. Check network connection
4. Lihat log di console: `print('❌ Error updating location to Supabase: $e')`

### Map Tidak Muncul

**Solusi:**
1. Check internet connection (OpenStreetMap perlu internet)
2. Tunggu beberapa detik untuk tiles loading
3. Check console log untuk error dari flutter_map

### Lokasi Tidak Update Real-time

**Solusi:**
1. Pastikan `distanceFilter: 10` di LocationSettings
2. User harus bergerak minimal 10 meter untuk trigger update
3. Check console log: `📍 Location updated: ...`
4. Untuk test di emulator, ubah lokasi manual via emulator settings

---

## 📈 Pengembangan Selanjutnya

### Fitur yang Bisa Ditambahkan:

1. **Show Nearby Users**
   - Query user lain dalam radius tertentu
   - Tampilkan multiple markers di peta

2. **Geofencing**
   - Alert jika user masuk/keluar area tertentu
   - Contoh: Promo khusus jika dekat warteg

3. **Location History**
   - Simpan riwayat perjalanan user
   - Tampilkan path/route yang dilalui

4. **Offline Maps**
   - Download tiles untuk offline usage
   - Gunakan package `flutter_map_tile_caching`

5. **Delivery Tracking**
   - Track kurir real-time
   - ETA calculation

6. **Heatmap**
   - Visualisasi area dengan banyak user
   - Popular locations analytics

---

## 📝 Checklist Implementasi

- ✅ Install dependencies (geolocator, geocoding, flutter_map, latlong2)
- ✅ Update pubspec.yaml dan jalankan `flutter pub get`
- ✅ Tambah permissions di AndroidManifest.xml dan Info.plist
- ✅ Buat LocationController dengan real-time tracking
- ✅ Implementasi getPositionStream() dengan distanceFilter: 10
- ✅ Implementasi updateLocationToSupabase() untuk save ke database
- ✅ Buat LocationView dengan FlutterMap + OpenStreetMap
- ✅ Tambah marker layer dengan icon lokasi
- ✅ Implementasi auto-center map (_centerMapToCurrentPosition)
- ✅ Tambah info cards dengan koordinat dan alamat
- ✅ Tambah real-time tracking indicator badge
- ✅ Buat SQL migration untuk tabel profiles
- ✅ Setup RLS policies dan trigger auto-update updated_at
- ✅ Hubungkan routing di app_pages.dart
- ✅ Fix tombol maps di menu_view.dart
- ✅ Remove import google_maps_flutter yang tidak terpakai
- ✅ Test error handling dan permissions

---

## 🎉 Hasil Akhir

**Fitur Location Tracking sudah 100% siap digunakan!**

### Yang Sudah Dibuat:

1. ✅ **LocationController** - Real-time tracking dengan GPS + Network
2. ✅ **LocationView** - UI dengan flutter_map dan OpenStreetMap
3. ✅ **LocationBinding** - GetX dependency injection
4. ✅ **SQL Migration** - Database structure untuk Supabase
5. ✅ **Routing** - Terhubung dengan menu button
6. ✅ **Permissions** - Android dan iOS permissions configured

### Testing Steps:

```bash
# 1. Setup database
# Buka Supabase → SQL Editor → Run supabase_migration_location.sql

# 2. Full restart aplikasi
flutter clean
flutter pub get
flutter run

# 3. Test flow
# - Login → Tap Maps button → Allow permission
# - Lihat lokasi muncul di peta dengan marker merah
# - Bergerak (jalan kaki) → Peta otomatis ikuti
# - Check Supabase profiles → latitude/longitude ter-update

# 4. Verifikasi di Supabase
# Dashboard → Table Editor → profiles
# Lihat kolom latitude, longitude, updated_at
```

---

## 📞 Support

Jika ada pertanyaan atau error:
1. Check console log untuk error details
2. Verifikasi semua checklist di atas
3. Test dengan full restart (bukan hot reload)
4. Check Supabase Dashboard untuk RLS policies

**Happy Coding! 🚀**
