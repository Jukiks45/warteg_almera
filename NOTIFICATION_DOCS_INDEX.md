# 🔔 Dokumentasi Push Notification & Promo - Warteg Almera

## 📚 Daftar File Panduan

### 🚀 **Quick Start**
1. **[CARA_TEST_NOTIFIKASI.md](CARA_TEST_NOTIFIKASI.md)**
   - Panduan cepat 5 menit untuk test notifikasi
   - Step-by-step dari run app sampai terima notifikasi
   - **Mulai dari sini jika baru pertama kali test!**

### 🔧 **Troubleshooting**
2. **[SOLUSI_NOTIFIKASI_TIDAK_MASUK.md](SOLUSI_NOTIFIKASI_TIDAK_MASUK.md)**
   - Solusi lengkap untuk semua masalah notifikasi
   - Debug checklist sistematis
   - Common errors & fixes
   - **Baca ini jika notifikasi tidak muncul!**

3. **[TROUBLESHOOTING_NOTIFIKASI.md](TROUBLESHOOTING_NOTIFIKASI.md)**
   - Troubleshooting detail untuk berbagai kasus
   - Debugging step-by-step
   - Tips & tricks
   - **Untuk debugging lebih mendalam**

### 📖 **Setup & Implementation**
4. **[PUSH_NOTIFICATION_PROMO_GUIDE.md](PUSH_NOTIFICATION_PROMO_GUIDE.md)**
   - Setup awal Firebase Cloud Messaging
   - Implementasi NotificationService lengkap
   - Integrasi dengan halaman promo
   - Cara kirim notifikasi dari backend
   - **Panduan lengkap dari nol!**

5. **[PROMO_QUICKSTART.md](PROMO_QUICKSTART.md)**
   - Panduan cepat menggunakan fitur promo
   - Cara apply promo di cart
   - List promo yang tersedia
   - **Untuk pengguna aplikasi**

### 🛠️ **Technical Docs**
6. **[FIX_PROMO_DATABASE.md](FIX_PROMO_DATABASE.md)**
   - Fix database error "promo_code not found"
   - Migration SQL untuk add promo columns
   - **Untuk developer yang handle database**

### 🐍 **Testing Scripts**
7. **[send_test_notification.py](send_test_notification.py)**
   - Script Python untuk kirim notifikasi test
   - Bisa kirim dengan custom data
   - **Gunakan jika ingin test via script**

8. **[send_test_notification.js](send_test_notification.js)**
   - Script Node.js untuk kirim notifikasi test
   - Alternatif dari Python
   - **Untuk yang prefer JavaScript**

---

## 🎯 **Alur Penggunaan**

### **Scenario 1: Baru Pertama Kali Setup**
```
1. Baca PUSH_NOTIFICATION_PROMO_GUIDE.md (setup FCM)
   ↓
2. Run aplikasi: flutter run
   ↓
3. Baca CARA_TEST_NOTIFIKASI.md (test pertama kali)
   ↓
4. Jika gagal → Baca SOLUSI_NOTIFIKASI_TIDAK_MASUK.md
```

### **Scenario 2: Sudah Setup, Notifikasi Tidak Masuk**
```
1. Baca SOLUSI_NOTIFIKASI_TIDAK_MASUK.md
   ↓
2. Ikuti debug checklist
   ↓
3. Jika masih gagal → Baca TROUBLESHOOTING_NOTIFIKASI.md
```

### **Scenario 3: Ingin Test via Script**
```
1. Download serviceAccountKey.json dari Firebase
   ↓
2. Edit send_test_notification.py atau .js
   ↓
3. Ganti FCM_TOKEN dengan token dari console
   ↓
4. Run: python send_test_notification.py
```

### **Scenario 4: Database Error**
```
1. Baca FIX_PROMO_DATABASE.md
   ↓
2. Run SQL migration: supabase_add_promo_columns.sql
   ↓
3. Uncomment code di cart_controller.dart
```

---

## 🔍 **Quick Reference**

### **Cara Dapat FCM Token**
```bash
flutter run
# Lihat console, cari:
# FCM Token: xxxxx...
```

### **Cara Kirim Notifikasi Test (Firebase Console)**
```
1. Firebase Console → Cloud Messaging
2. Send test message
3. Paste FCM token
4. Test
```

### **Cara Apply Promo di App**
```
1. Buka Cart
2. Scroll ke bawah
3. Klik "Punya Kode Promo?"
4. Pilih promo atau masukkan kode
5. Klik "Terapkan"
```

### **List Kode Promo Tersedia**
- `HEMAT5K` - Diskon Rp 5.000 (min. Rp 10.000)
- `SAVE10K` - Diskon Rp 10.000 (min. Rp 20.000)
- `SUPER15` - Diskon Rp 15.000 (min. Rp 30.000)
- `FREEONGKIR` - Diskon Rp 5.000 (min. Rp 15.000)

---

## ✅ **Checklist Setup**

### **Backend (Firebase)**
- [ ] Project Firebase sudah dibuat
- [ ] google-services.json sudah di-download
- [ ] google-services.json sudah di-copy ke `android/app/`
- [ ] gradle plugin sudah diterapkan
- [ ] serviceAccountKey.json sudah di-download (jika pakai script)

### **Code**
- [ ] NotificationService sudah di-init di main.dart
- [ ] Permission sudah di-request
- [ ] Handler sudah di-setup (foreground, background, terminated)
- [ ] Navigation handler sudah dibuat
- [ ] Promo module sudah dibuat
- [ ] Cart integration sudah selesai

### **Testing**
- [ ] Aplikasi bisa di-run tanpa error
- [ ] FCM Token muncul di console
- [ ] Permission notifikasi di-allow
- [ ] Test notifikasi dari Firebase Console berhasil
- [ ] Notifikasi muncul di foreground (app dibuka)
- [ ] Notifikasi muncul di background (app minimize)
- [ ] Notifikasi muncul di terminated (app ditutup)
- [ ] Klik notifikasi navigasi ke halaman yang benar
- [ ] Apply promo di cart berhasil

---

## 🐛 **Common Issues**

| Issue | Solusi |
|-------|--------|
| Token tidak muncul | `flutter clean && flutter pub get` |
| Permission denied | Settings → Apps → Notifications → ON |
| Notifikasi tidak muncul di foreground | Sudah di-handle dengan Local Notifications |
| Database error promo_code | Baca FIX_PROMO_DATABASE.md |
| Emulator tidak bisa terima notif | Gunakan emulator dengan Play Store |

---

## 📞 **Need Help?**

1. **Cek dokumentasi terlebih dahulu:**
   - Masalah umum → SOLUSI_NOTIFIKASI_TIDAK_MASUK.md
   - Setup awal → PUSH_NOTIFICATION_PROMO_GUIDE.md
   - Test cepat → CARA_TEST_NOTIFIKASI.md

2. **Kumpulkan info:**
   - Screenshot console (FCM Token)
   - Screenshot error (jika ada)
   - Device/emulator yang dipakai

3. **Debug sistematis:**
   - Ikuti checklist di SOLUSI_NOTIFIKASI_TIDAK_MASUK.md
   - Cek satu per satu

---

## 📊 **Architecture Overview**

```
main.dart
  └─ Firebase.initializeApp()
  └─ NotificationService.init()
      ├─ Setup Local Notifications
      ├─ Setup Foreground Handler
      ├─ Setup Background Handler
      ├─ Setup Message Opened Handler
      └─ Get FCM Token

NotificationService
  ├─ Foreground → Show banner via Local Notifications
  ├─ Background → Auto-show by Firebase
  ├─ Terminated → Auto-show by Firebase
  └─ On Click → Navigate to promo/menu/etc

PromoModule
  ├─ PromoModel (data)
  ├─ PromoController (business logic)
  ├─ PromoView (list promo)
  └─ PromoDetailView (detail promo)

CartController
  ├─ applyPromo() → Validate & apply discount
  └─ removePromo() → Remove discount

CartView
  └─ PromoSection → Input kode/pilih promo
```

---

## 🎉 **Feature List**

### **✅ Implemented**
- [x] Firebase Cloud Messaging setup
- [x] Foreground notification handler
- [x] Background notification handler
- [x] Terminated notification handler
- [x] Navigation dari notifikasi
- [x] Promo module (models, controllers, views)
- [x] Promo integration dengan cart
- [x] Price-based discount (bukan percentage)
- [x] Minimum purchase validation
- [x] Promo banner di menu
- [x] Promo icon di AppBar
- [x] Database migration untuk promo columns

### **🔄 Optional/Future**
- [ ] Simpan FCM token ke Supabase
- [ ] Schedule notification
- [ ] Topic-based notification (broadcast)
- [ ] Notification history
- [ ] Analytics untuk notifikasi
- [ ] A/B testing untuk notifikasi

---

## 📝 **Notes**

- **Custom Sound:** File `hidupjokowi.mp3` harus ada di `android/app/src/main/res/raw/`
- **Notification Channel:** ID = `high_importance_channel`
- **Min SDK:** Android 21 (Lollipop)
- **Target SDK:** Android 34

---

## 🔗 **External Resources**

- [Firebase Console](https://console.firebase.google.com)
- [Flutter Firebase Messaging Docs](https://firebase.flutter.dev/docs/messaging/overview)
- [FCM HTTP v1 API](https://firebase.google.com/docs/reference/fcm/rest/v1/projects.messages)
- [Local Notifications Plugin](https://pub.dev/packages/flutter_local_notifications)

---

**Last Updated:** 2024-01-XX  
**Version:** 1.0.0  
**Author:** GitHub Copilot
