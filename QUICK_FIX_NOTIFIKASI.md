# ⚡ QUICK FIX: Notifikasi Firebase Tidak Masuk

## 🎯 Solusi Tercepat (5 Menit)

### **Step 1: Run Aplikasi & Cek Token**

```bash
flutter run
```

**Cari di console:**
```
============================================================
📱 FCM TOKEN - COPY TOKEN INI!
============================================================
FCM Token: dZpM5R...
============================================================
```

**❌ Token TIDAK muncul?**
```bash
flutter clean
flutter pub get
flutter run
```

**✅ Token MUNCUL? → Lanjut Step 2**

---

### **Step 2: Allow Permission**

**Saat popup "Allow notifications?" muncul:**
- Klik **Allow** / **Izinkan**

**Atau manual di HP:**
```
Settings → Apps → Warteg Almera → Notifications → ON
```

---

### **Step 3: Test Kirim Notifikasi**

1. **Copy FCM Token** dari Step 1
2. **Buka:** https://console.firebase.google.com
3. **Pilih project** warteg_almera
4. **Sidebar:** Engage → Cloud Messaging
5. **Klik:** Send test message
6. **Paste token** di "FCM registration token"
7. **Klik:** Test

**✅ Notifikasi MUNCUL? → SELESAI!**

**❌ Notifikasi TIDAK MUNCUL? → Lanjut ke Fix**

---

## 🔧 Fix Jika Masih Tidak Muncul

### **Fix 1: Format Notifikasi**

**Di Firebase Console, pastikan:**
- **Title:** Diisi (contoh: "Test")
- **Text:** Diisi (contoh: "Pesan test")
- **JANGAN** kosongkan keduanya

**Format yang BENAR:**
```
Title: 🎉 Promo Hari Ini
Text: Diskon 10rb untuk semua menu
```

---

### **Fix 2: Permission**

**Uninstall & Reinstall:**
```bash
# Uninstall dulu di HP
# Lalu:
flutter run
```

**Saat popup muncul → Klik ALLOW**

---

### **Fix 3: Token Expired**

**Saat test notifikasi, pastikan:**
- Token yang di-paste = Token terbaru dari console
- Jika sudah lama (>1 jam), run ulang app untuk token baru

**Cara cek token masih valid:**
```bash
flutter run
# Bandingkan token baru dengan yang di-paste
# Jika beda → Paste yang baru
```

---

### **Fix 4: Emulator**

**Jika pakai emulator:**
- Pastikan ada icon **Play Store** ✅
- Jika tidak ada → Buat emulator baru dengan Play Store

**Cara buat emulator dengan Play Store:**
```
Android Studio → AVD Manager → Create Virtual Device
→ Pilih Pixel (ada Play Store icon)
→ Download system image
→ Finish
```

**Atau test di HP real:**
```bash
# Colok USB
# Enable USB Debugging
flutter run
```

---

### **Fix 5: Internet**

**Pastikan HP/Emulator connect internet:**
- Buka browser, coba google.com
- Jika tidak bisa → Aktifkan WiFi/Data

---

## ✅ Expected Result

**Jika berhasil, Anda akan lihat:**

### **1. Di Console Aplikasi:**
```
🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔
📩 FOREGROUND MESSAGE RECEIVED!
🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔
📌 Title: Test
📝 Body: Pesan test
📦 Data: {}
🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔
```

### **2. Di HP/Emulator:**

**App Dibuka (Foreground):**
- Banner notifikasi muncul di atas layar
- Bunyi notifikasi

**App Minimize (Background):**
- Notifikasi di notification tray
- Badge di icon app

**App Ditutup (Terminated):**
- Notifikasi di notification tray
- Klik notifikasi → App dibuka

---

## 🎯 Test Navigasi ke Promo

**Jika ingin test klik notifikasi → Langsung ke promo:**

### **Di Firebase Console:**

**Tab Additional Options:**
- Klik **Custom data**
- Add row 1:
  - Key: `type`
  - Value: `promo`
- Add row 2:
  - Key: `promo_id`
  - Value: `1`

**Lalu kirim notifikasi**

**Hasil:**
- Klik notifikasi → Langsung buka halaman Promo Detail

---

## 📋 Quick Checklist

Centang semua:

- [ ] FCM Token muncul di console
- [ ] Permission di-allow (Settings → Notifications → ON)
- [ ] google-services.json ada di `android/app/`
- [ ] Internet aktif
- [ ] Emulator punya Play Store (jika pakai emulator)
- [ ] Title & Text di Firebase Console diisi
- [ ] Token yang di-paste adalah token terbaru

**Jika semua ✅ tapi tetap tidak muncul:**

```bash
# Last resort
flutter clean
rm -rf android/.gradle
flutter pub get
flutter run --no-sound-null-safety
```

---

## 🆘 Masih Gagal?

**Baca dokumentasi lengkap:**
1. **SOLUSI_NOTIFIKASI_TIDAK_MASUK.md** - Troubleshooting detail
2. **CARA_TEST_NOTIFIKASI.md** - Panduan step-by-step
3. **PUSH_NOTIFICATION_PROMO_GUIDE.md** - Setup lengkap

**Atau test dengan script:**
```bash
# Python
pip install firebase-admin
python send_test_notification.py

# Node.js
npm install firebase-admin
node send_test_notification.js
```

---

## 💡 Tips

### **Tip 1: Test Bertahap**
```
1. Test app dibuka (foreground) → Harus ada banner
2. Test app minimize (background) → Harus di tray
3. Test app ditutup (terminated) → Harus di tray
```

### **Tip 2: Restart Everything**
```bash
# Restart adb
adb kill-server
adb start-server

# Restart emulator
# Restart HP
# Restart Android Studio
```

### **Tip 3: Check Logs**
```bash
flutter logs | grep "FCM"
flutter logs | grep "FOREGROUND"
```

### **Tip 4: Test di HP Real**
Jika pakai emulator dan gagal terus, test di HP real.
Seringkali emulator punya issue dengan FCM.

---

## 🎉 Selesai!

**Jika masih belum berhasil setelah semua ini:**
- Screenshot console output
- Screenshot Firebase Console setup
- Screenshot error (jika ada)
- Cek file SOLUSI_NOTIFIKASI_TIDAK_MASUK.md untuk debugging lebih detail

**Good luck! 🚀**
