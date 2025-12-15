# Push Notification & Promo Setup Guide

## 📱 Fitur yang Sudah Diimplementasikan

### 1. **Halaman Promo**
- ✅ List semua promo yang tersedia
- ✅ Detail promo dengan informasi lengkap
- ✅ **Diskon dalam bentuk harga (Rupiah), bukan persentase**
- ✅ **Minimal pembelian untuk setiap promo**
- ✅ Badge untuk status promo (AKTIF/TIDAK AKTIF)
- ✅ Kode promo yang bisa disalin
- ✅ Navigasi dari notifikasi ke halaman promo
- ✅ **Integrasi dengan keranjang belanja (Cart)**

### 2. **Fitur Cart dengan Promo**
- ✅ Input/pilih kode promo langsung di cart
- ✅ Tampilan diskon yang diterapkan
- ✅ Validasi minimal pembelian otomatis
- ✅ Subtotal, diskon, dan total yang jelas
- ✅ Hapus promo yang sudah diterapkan

### 3. **Push Notification FCM**
- ✅ Notifikasi foreground (saat aplikasi dibuka)
- ✅ Notifikasi background (saat aplikasi di background)
- ✅ Notifikasi terminated (saat aplikasi ditutup)
- ✅ Navigasi otomatis ke halaman yang sesuai saat notifikasi diklik
- ✅ Custom sound support (hidupjokowi.mp3)

---

## 🎯 Konsep Promo

Promo sekarang menggunakan **diskon harga nominal (Rupiah)**, bukan persentase:

```dart
PromoModel(
  id: '1',
  title: 'Diskon Rp 15.000',
  discountAmount: 15000,      // Diskon dalam rupiah
  minPurchase: 50000,          // Minimal belanja
  promoCode: 'HEMAT15',
)
```

### Contoh Promo:
1. **HEMAT5K** - Diskon Rp 5.000 (min. belanja Rp 10.000)
2. **SAVE10K** - Diskon Rp 10.000 (min. belanja Rp 20.000)
3. **SUPER15** - Diskon Rp 15.000 (min. belanja Rp 50.000)
4. **FREEONGKIR** - Gratis ongkir Rp 8.000 (min. belanja Rp 15.000)

---

## 🚀 Cara Menggunakan

### **Navigasi Manual ke Halaman Promo**

Dari kode mana pun, gunakan:
```dart
// Ke list promo
Get.toNamed(AppRoutes.promo);

// Atau
Get.toNamed('/promo');
```

### **Menambahkan Tombol Promo di Menu**

Tambahkan button di halaman menu Anda:
```dart
ElevatedButton.icon(
  onPressed: () => Get.toNamed('/promo'),
  icon: Icon(Icons.local_offer),
  label: Text('Lihat Promo'),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.orange,
    foregroundColor: Colors.white,
  ),
)
```

---

## 📤 Cara Mengirim Push Notification

### **Metode 1: Firebase Console (Untuk Testing)**

1. **Dapatkan FCM Token:**
   - Jalankan aplikasi
   - Lihat console/log, cari baris: `FCM Token: xxxxx...`
   - Copy token tersebut

2. **Kirim Notifikasi via Firebase Console:**
   - Buka [Firebase Console](https://console.firebase.google.com)
   - Pilih project Anda
   - Klik **Cloud Messaging** di menu kiri
   - Klik **Send your first message** atau **New campaign**
   - Isi form:
     - **Notification title:** Contoh: "Promo Spesial Hari Ini!"
     - **Notification text:** Contoh: "Diskon 50% untuk menu pilihan"
     - **Target:** Pilih "Single device" → Paste FCM Token
     - **Additional options:**
       - Klik **Advanced options**
       - Tambahkan **Custom data:**
         ```
         Key: type       Value: promo
         Key: promo_id   Value: 1
         ```

3. **Send** → Aplikasi akan menerima notifikasi dan otomatis navigasi ke halaman promo saat diklik!

### **Metode 2: Via Backend/API (Production)**

Gunakan HTTP request ke FCM API:

```http
POST https://fcm.googleapis.com/fcm/send
Content-Type: application/json
Authorization: key=YOUR_SERVER_KEY

{
  "to": "FCM_TOKEN_DEVICE",
  "notification": {
    "title": "Promo Spesial Hari Ini!",
    "body": "Diskon 50% untuk menu pilihan",
    "sound": "hidupjokowi"
  },
  "data": {
    "type": "promo",
    "promo_id": "1"
  }
}
```

**Server Key:** Dapatkan dari Firebase Console → Project Settings → Cloud Messaging → Server Key

---

## 🎯 Tipe-Tipe Notifikasi

### **1. Notifikasi Promo (Umum)**
```json
{
  "notification": {
    "title": "Lihat Promo Terbaru!",
    "body": "Banyak promo menarik menanti Anda"
  },
  "data": {
    "type": "promo"
  }
}
```
→ Navigasi ke: **List Promo**

### **2. Notifikasi Promo Spesifik**
```json
{
  "notification": {
    "title": "Diskon 50% Menu Spesial",
    "body": "Gunakan kode SPESIAL50"
  },
  "data": {
    "type": "promo",
    "promo_id": "1"
  }
}
```
→ Navigasi ke: **Detail Promo dengan ID tersebut**

### **3. Notifikasi Order**
```json
{
  "notification": {
    "title": "Pesanan Selesai Diproses",
    "body": "Pesanan #12345 sedang diantar"
  },
  "data": {
    "type": "order",
    "order_id": "12345"
  }
}
```
→ Navigasi ke: **Order History**

### **4. Notifikasi Menu**
```json
{
  "notification": {
    "title": "Menu Baru Tersedia!",
    "body": "Coba menu spesial kami"
  },
  "data": {
    "type": "menu"
  }
}
```
→ Navigasi ke: **Menu**

---

## 🗄️ Database Setup (Opsional)

### Tabel Promo di Supabase

```sql
CREATE TABLE promos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  image_url TEXT,
  start_date TIMESTAMP NOT NULL,
  end_date TIMESTAMP NOT NULL,
  discount_amount NUMERIC(10,2) NOT NULL,  -- Diskon dalam rupiah
  min_purchase NUMERIC(10,2) DEFAULT 0,    -- Minimal pembelian
  is_active BOOLEAN DEFAULT true,
  promo_code TEXT UNIQUE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Sample data
INSERT INTO promos (title, description, image_url, start_date, end_date, discount_amount, min_purchase, is_active, promo_code)
VALUES 
  ('Diskon Rp 5.000', 'Hemat Rp 5.000 untuk pembelian minimal Rp 10.000', 
   'https://via.placeholder.com/400x200', NOW(), NOW() + INTERVAL '7 days', 5000, 10000, true, 'HEMAT5K'),
  ('Potongan Rp 10.000', 'Dapatkan potongan harga Rp 10.000 untuk pembelian minimal Rp 20.000', 
   'https://via.placeholder.com/400x200', NOW(), NOW() + INTERVAL '14 days', 10000, 20000, true, 'SAVE10K'),
  ('Diskon Rp 15.000', 'Diskon Rp 15.000 untuk pembelian minimal Rp 50.000', 
   'https://via.placeholder.com/400x200', NOW(), NOW() + INTERVAL '30 days', 15000, 50000, true, 'SUPER15'),
  ('Gratis Ongkir', 'Gratis ongkir setara Rp 8.000 untuk pesanan minimal Rp 15.000', 
   'https://via.placeholder.com/400x200', NOW(), NOW() + INTERVAL '5 days', 8000, 15000, true, 'FREEONGKIR');
```

### Update Tabel Orders untuk Menyimpan Promo

```sql
ALTER TABLE orders 
ADD COLUMN promo_code TEXT,
ADD COLUMN promo_discount NUMERIC(10,2) DEFAULT 0;

-- Atau jika buat tabel baru:
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id),
  total_items INTEGER NOT NULL,
  total_price NUMERIC(10,2) NOT NULL,
  promo_code TEXT,
  promo_discount NUMERIC(10,2) DEFAULT 0,
  status TEXT DEFAULT 'pending',
  payment_method TEXT,
  note TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
```

Kemudian update `PromoController.loadPromos()`:
```dart
final response = await _supabaseService.client
    .from('promos')
    .select()
    .eq('is_active', true)
    .order('created_at', ascending: false);

promos.value = (response as List)
    .map((json) => PromoModel.fromJson(json))
    .toList();
```

---

## 📱 Testing Checklist

- [ ] **Foreground:** Buka aplikasi → Kirim notifikasi → Muncul banner → Klik → Navigasi ke promo
- [ ] **Background:** Minimize aplikasi → Kirim notifikasi → Klik → Navigasi ke promo
- [ ] **Terminated:** Tutup aplikasi sepenuhnya → Kirim notifikasi → Klik → Aplikasi buka & navigasi ke promo
- [ ] **Kode Promo:** Buka detail promo → Klik "Salin" → Kode ter-copy
- [ ] **Promo List:** Scroll, refresh, lihat semua promo

---

## 🎨 Kustomisasi

### **Mengubah Warna Tema**
Edit di `PromoView` atau `PromoDetailView`:
```dart
backgroundColor: Colors.orange,  // Ganti dengan warna pilihan
```

### **Menambahkan Promo Dummy**
Edit `_getDummyPromos()` di `PromoController`:
```dart
PromoModel(
  id: '5',
  title: 'Promo Baru Anda',
  description: 'Deskripsi promo',
  imageUrl: 'URL_GAMBAR',
  startDate: DateTime.now(),
  endDate: DateTime.now().add(Duration(days: 10)),
  discountPercentage: 30,
  isActive: true,
  promoCode: 'KODE30',
),
```

### **Custom Sound Notification**
1. Tambahkan file audio `.mp3` ke `android/app/src/main/res/raw/`
2. Edit `notification_service.dart`:
```dart
sound: RawResourceAndroidNotificationSound('nama_file_tanpa_ekstensi')
```

---

## 🐛 Troubleshooting

### **Token tidak muncul di console**
- Pastikan `google-services.json` sudah ada di `android/app/`
- Run `flutter clean` kemudian `flutter run`

### **Notifikasi tidak muncul di foreground**
- Periksa apakah `NotificationService` sudah di-init di `main.dart`
- Cek permission notification sudah diizinkan

### **Navigasi tidak bekerja saat klik notifikasi**
- Pastikan menggunakan `Get.toNamed` bukan `Navigator.push`
- Periksa route sudah terdaftar di `AppPages`

### **Gambar promo tidak muncul**
- Gunakan URL gambar yang valid
- Atau ganti dengan asset lokal

---

## 📚 File-File Penting

```
lib/
├── modules/promo/
│   ├── models/promo_model.dart          # Model data promo
│   ├── controllers/promo_controller.dart # Logic promo
│   ├── bindings/promo_binding.dart      # Dependency injection
│   └── views/
│       ├── promo_view.dart              # List promo
│       └── promo_detail_view.dart       # Detail promo
├── services/
│   └── notification_service.dart        # FCM & navigasi
└── routes/
    ├── app_routes.dart                  # Route constants
    └── app_pages.dart                   # Route mapping
```

---

## ✅ Selesai!

Sistem notifikasi push dan halaman promo sudah siap digunakan. Silakan test menggunakan Firebase Console atau integrate dengan backend Anda.

Jika ada pertanyaan atau butuh kustomisasi lebih lanjut, silakan tanyakan! 🚀
