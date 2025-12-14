# 📱 Quick Start - Push Notification & Promo

## ✅ Yang Sudah Dibuat

### 1. **Modul Promo** (`lib/modules/promo/`)
- ✅ `models/promo_model.dart` - Model data promo
- ✅ `controllers/promo_controller.dart` - Logic & state management
- ✅ `bindings/promo_binding.dart` - Dependency injection
- ✅ `views/promo_view.dart` - Halaman list promo
- ✅ `views/promo_detail_view.dart` - Halaman detail promo

### 2. **Routing**
- ✅ Route `/promo` sudah terdaftar di `AppRoutes`
- ✅ Binding sudah dikonfigurasi di `AppPages`

### 3. **Notification Service**
- ✅ Integrasi FCM (foreground, background, terminated)
- ✅ Navigasi otomatis ke halaman promo saat notifikasi diklik
- ✅ Support multiple tipe notifikasi (promo, order, menu)

### 4. **Backend Scripts**
- ✅ `send_fcm_notification.py` - Python script untuk kirim notifikasi
- ✅ `send_fcm_notification.js` - Node.js script untuk kirim notifikasi

### 5. **Dokumentasi**
- ✅ `PUSH_NOTIFICATION_PROMO_GUIDE.md` - Panduan lengkap

---

## 🚀 Cara Cepat Testing

### 1. **Jalankan Aplikasi**
```bash
flutter run
```

### 2. **Dapatkan FCM Token**
Lihat di console/terminal, cari baris:
```
FCM Token: dxxxxxxxxxxxxxxxxxxxx...
```
Copy token tersebut.

### 3. **Buka Halaman Promo Manual**
Tambahkan button di menu atau navigasi langsung:
```dart
Get.toNamed('/promo');
```

### 4. **Test Push Notification**

#### Via Firebase Console:
1. Buka https://console.firebase.google.com
2. Pilih project → Cloud Messaging → New campaign
3. Isi:
   - Title: "Promo Spesial!"
   - Text: "Diskon 50% hari ini"
   - Target: Single device → Paste FCM token
   - Additional options → Custom data:
     - `type` = `promo`
     - `promo_id` = `1`
4. Send!

#### Via Script Python:
```bash
# Edit file send_fcm_notification.py
# Ganti FCM_SERVER_KEY dan DEVICE_TOKEN

python send_fcm_notification.py
```

#### Via Script Node.js:
```bash
# Edit file send_fcm_notification.js
# Ganti FCM_SERVER_KEY dan DEVICE_TOKEN

npm install axios
node send_fcm_notification.js
```

---

## 📋 Struktur Data Notifikasi

### Promo Umum → List Promo
```json
{
  "notification": {
    "title": "Lihat Promo!",
    "body": "Ada promo menarik"
  },
  "data": {
    "type": "promo"
  }
}
```

### Promo Spesifik → Detail Promo
```json
{
  "notification": {
    "title": "Diskon 50%!",
    "body": "Kode: SPESIAL50"
  },
  "data": {
    "type": "promo",
    "promo_id": "1"
  }
}
```

---

## 🎯 Navigasi dari Kode

```dart
// Ke list promo
Get.toNamed('/promo');

// Ke detail promo spesifik
Get.toNamed('/promo', arguments: {'promoId': '1'});

// Dari menu view (contoh)
ElevatedButton(
  onPressed: () => Get.toNamed('/promo'),
  child: Text('Lihat Promo'),
)
```

---

## 📦 File Utama

```
lib/
├── modules/promo/               # ← Modul promo lengkap
├── services/
│   └── notification_service.dart  # ← FCM handler
└── routes/
    ├── app_routes.dart          # ← Route /promo
    └── app_pages.dart           # ← Binding promo

Dokumentasi:
├── PUSH_NOTIFICATION_PROMO_GUIDE.md  # Panduan lengkap
├── send_fcm_notification.py          # Python script
└── send_fcm_notification.js          # Node.js script
```

---

## 🔧 Next Steps

### Jika Ingin Pakai Database Supabase:
1. Buat tabel `promos` (lihat PUSH_NOTIFICATION_PROMO_GUIDE.md)
2. Uncomment code di `PromoController.loadPromos()`
3. Insert sample data promo

### Jika Ingin Custom:
- Ubah warna di `PromoView` / `PromoDetailView`
- Tambah promo dummy di `PromoController._getDummyPromos()`
- Custom sound notification (lihat guide)

---

## ✅ Done!

Sistem sudah siap pakai! 🎉

**Untuk detail lengkap, baca:** [PUSH_NOTIFICATION_PROMO_GUIDE.md](PUSH_NOTIFICATION_PROMO_GUIDE.md)
