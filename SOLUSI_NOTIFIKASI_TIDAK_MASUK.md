# ✅ SOLUSI: Notifikasi Firebase Tidak Masuk

## 📌 **Penyebab Umum & Solusinya**

### **1. FCM Token Tidak Muncul**

**Gejala:**
- Console tidak menampilkan "FCM Token: xxxxx"
- Aplikasi jalan tapi tidak ada log token

**Penyebab:**
- Firebase belum ter-initialize
- google-services.json tidak ada/salah
- Internet tidak aktif

**Solusi:**
```bash
# Clean project
flutter clean
flutter pub get

# Pastikan google-services.json ada
ls android/app/google-services.json

# Run ulang
flutter run
```

**Verifikasi:**
Harus ada output seperti ini:
```
============================================================
📱 FCM TOKEN - COPY TOKEN INI!
============================================================
FCM Token: dZpM5R2oRO6xxxxxxxxxxxxxxxxxxxxxxxxx
============================================================
```

---

### **2. Permission Notifikasi Tidak Di-Allow**

**Gejala:**
- Token muncul tapi notifikasi tidak masuk
- Tidak ada popup permission saat pertama buka app

**Penyebab:**
- User klik "Deny" saat popup permission
- Permission tidak diminta sama sekali
- Android 13+ (API 33+) butuh permission runtime

**Solusi:**

**Manual di HP:**
1. Settings → Apps → Warteg Almera
2. Notifications → **Aktifkan (ON)**
3. Pastikan semua kategori notifikasi aktif

**Di Code:**
Sudah di-handle di `NotificationService.init()`:
```dart
await FirebaseMessaging.instance.requestPermission(
  alert: true,
  badge: true,
  sound: true,
);
```

**Test:**
1. Uninstall aplikasi
2. Install ulang: `flutter run`
3. Saat popup muncul → Klik **Allow**

---

### **3. Notifikasi Tidak Muncul di Foreground**

**Gejala:**
- Notifikasi muncul saat app minimize/closed
- Tidak muncul saat app dibuka (foreground)

**Penyebab:**
- Ini **NORMAL** di Firebase!
- Firebase tidak auto-show notification saat foreground
- Butuh Local Notification untuk display

**Solusi:**
Sudah di-handle dengan `flutter_local_notifications`.

**Verifikasi:**
Saat test kirim notifikasi dengan app dibuka, harus ada log:
```
🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔
📩 FOREGROUND MESSAGE RECEIVED!
🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔
📌 Title: Test Notifikasi
📝 Body: Ini test
📦 Data: {type: promo}
🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔
```

Dan banner notifikasi muncul di atas layar!

---

### **4. Format Notifikasi dari Firebase Console Salah**

**Gejala:**
- Token sudah benar
- Permission sudah allow
- Tapi notifikasi tidak muncul sama sekali

**Penyebab:**
- Kirim hanya `data` tanpa `notification`
- Firebase butuh field `notification` untuk show banner

**Format SALAH ❌:**
```json
{
  "data": {
    "message": "Test"
  }
}
```

**Format BENAR ✅:**
```json
{
  "notification": {
    "title": "Judul Notifikasi",
    "body": "Isi pesan"
  },
  "data": {
    "type": "promo",
    "promo_id": "1"
  }
}
```

**Cara Kirim yang Benar di Firebase Console:**

1. **Cloud Messaging** → **Send your first message**
2. **Notification title:** `Test Promo`
3. **Notification text:** `Ini adalah test`
4. **Next**
5. **Target:** Send test message
6. **FCM registration token:** Paste token
7. **Add** → **Test**

**JANGAN:**
- Jangan gunakan Messaging API langsung (kecuali paham format)
- Jangan skip field notification
- Jangan hanya kirim data payload

---

### **5. google-services.json Tidak Ada/Salah**

**Gejala:**
- Error saat build: "File google-services.json is missing"
- Token tidak pernah muncul
- App crash saat di-run

**Penyebab:**
- File tidak ada di `android/app/`
- File dari project Firebase yang berbeda
- File corrupt

**Solusi:**

1. **Download ulang dari Firebase:**
   - Buka [Firebase Console](https://console.firebase.google.com)
   - Pilih project Anda
   - ⚙️ Project Settings → General
   - Scroll ke "Your apps"
   - Klik Android app
   - Download `google-services.json`

2. **Copy ke lokasi yang benar:**
   ```bash
   # Windows
   copy google-services.json android\app\google-services.json
   
   # Linux/Mac
   cp google-services.json android/app/google-services.json
   ```

3. **Verifikasi:**
   ```bash
   # File harus ada di sini
   ls android/app/google-services.json
   ```

4. **Clean & rebuild:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

---

### **6. gradle Plugin Tidak Diterapkan**

**Gejala:**
- google-services.json ada tapi tidak diload
- Token tidak muncul
- Tidak ada error build

**Penyebab:**
- Plugin `com.google.gms.google-services` tidak ada di gradle

**Solusi:**

**File: `android/build.gradle.kts`**
```kotlin
dependencies {
    classpath("com.google.gms:google-services:4.4.0")  // ← Pastikan ada
}
```

**File: `android/app/build.gradle.kts`**
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // ← Pastikan ada
}
```

**Test:**
```bash
flutter clean
flutter run
```

---

### **7. Emulator/Device Tidak Ada Google Play Services**

**Gejala:**
- Token = null
- Error: "MISSING_INSTANCEID_SERVICE"
- Hanya terjadi di emulator

**Penyebab:**
- Emulator tidak punya Google Play Services
- FCM butuh Play Services untuk jalan

**Solusi:**

**Opsi 1: Gunakan Emulator dengan Play Store**
1. Android Studio → AVD Manager
2. Create New Virtual Device
3. Pilih device dengan **Play Store** icon ✅
4. Download system image (pilih yang ada Play Store)
5. Run emulator

**Opsi 2: Test di HP Real**
```bash
# Enable USB Debugging di HP
# Colok USB
flutter run
```

**Verifikasi Emulator Punya Play Services:**
- Buka emulator
- Cari app **Play Store**
- Jika ada → ✅ OK
- Jika tidak ada → ❌ Ganti emulator

---

### **8. Internet Tidak Aktif**

**Gejala:**
- Token tidak muncul
- Notifikasi tidak masuk
- Timeout error

**Penyebab:**
- HP/emulator tidak connect internet
- WiFi mati
- Data seluler mati

**Solusi:**

**Di Emulator:**
1. Swipe down → Cek WiFi icon
2. Atau buka browser, coba akses google.com
3. Jika tidak bisa → Restart emulator

**Di HP Real:**
1. Settings → WiFi/Data → Aktifkan
2. Test dengan buka browser

**Test Koneksi:**
```bash
# Di terminal emulator/device
adb shell ping google.com
```

---

## 🎯 **Langkah Troubleshooting Sistematis**

Ikuti langkah ini secara berurutan:

### **Step 1: Verifikasi Setup Dasar**

```bash
# 1. Cek google-services.json ada
ls android/app/google-services.json

# 2. Clean project
flutter clean

# 3. Get dependencies
flutter pub get

# 4. Run aplikasi
flutter run
```

**Expected Output:**
```
============================================================
📱 FCM TOKEN - COPY TOKEN INI!
============================================================
FCM Token: dZpM5R2oRO6...
============================================================
```

**❌ Jika token TIDAK muncul → Masalah di setup dasar:**
- Cek google-services.json
- Cek internet aktif
- Cek emulator punya Play Services

**✅ Jika token MUNCUL → Lanjut Step 2**

---

### **Step 2: Test Kirim Notifikasi**

1. **Copy FCM Token** dari console
2. **Buka Firebase Console:**
   - Cloud Messaging → Send test message
3. **Paste token** → Test

**Expected: Notifikasi muncul**

**❌ Jika TIDAK muncul → Lanjut Step 3**

---

### **Step 3: Cek Permission**

**Di HP:**
```
Settings → Apps → Warteg Almera → Notifications → ON
```

**Atau uninstall & reinstall:**
```bash
flutter run
# Saat popup "Allow notifications?" → Klik Allow
```

**Test kirim ulang dari Firebase Console**

**✅ Jika muncul → SELESAI!**

**❌ Jika tetap tidak muncul → Lanjut Step 4**

---

### **Step 4: Cek Console Log**

Saat kirim notifikasi, cek console. Harus ada:

**Foreground (app dibuka):**
```
🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔
📩 FOREGROUND MESSAGE RECEIVED!
🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔
📌 Title: Test
📝 Body: Pesan test
📦 Data: {}
🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔🔔
```

**Background (app minimize):**
- Tidak ada log (normal)
- Notifikasi langsung muncul di tray

**❌ Jika LOG muncul tapi NOTIFIKASI tidak:**
- Problem di Local Notifications
- Cek permission
- Restart HP

**❌ Jika LOG tidak muncul sama sekali:**
- Notifikasi tidak sampai ke device
- Cek token yang di-paste benar
- Cek internet aktif
- Test dengan token baru (run ulang app)

---

### **Step 5: Test dengan Script**

Gunakan script Python/Node.js untuk test lebih detail:

```bash
# Python
pip install firebase-admin
python send_test_notification.py

# Node.js
npm install firebase-admin
node send_test_notification.js
```

**Keuntungan:**
- Lebih flexible
- Bisa debug payload
- Bisa test berbagai format

**File yang dibutuhkan:**
- `serviceAccountKey.json` dari Firebase Console
- Script `send_test_notification.py` atau `.js`

---

## 🔍 **Debug Checklist**

Centang satu per satu:

- [ ] ✅ FCM Token muncul di console
- [ ] ✅ google-services.json ada di `android/app/`
- [ ] ✅ gradle plugin `com.google.gms.google-services` diterapkan
- [ ] ✅ Internet aktif (HP/emulator)
- [ ] ✅ Permission notifikasi di-allow
- [ ] ✅ Emulator punya Google Play Services (jika pakai emulator)
- [ ] ✅ Format notifikasi benar (ada field `notification`)
- [ ] ✅ Token yang di-paste di Firebase Console benar (tidak expired)

**Jika semua ✅ tapi tetap tidak muncul:**
1. Restart HP/emulator
2. Uninstall → Reinstall app
3. Test dengan HP real (jika pakai emulator)
4. Cek Firebase project settings (pastikan package name sama)

---

## 📋 **Common Errors & Fixes**

### **Error: "MISSING_INSTANCEID_SERVICE"**
**Penyebab:** Emulator tidak punya Play Services  
**Solusi:** Gunakan emulator dengan Play Store

### **Error: "MissingPluginException"**
**Penyebab:** Plugin tidak ter-register  
**Solusi:**
```bash
flutter clean
flutter pub get
flutter run
```

### **Error: "File google-services.json is missing"**
**Penyebab:** File tidak ada di `android/app/`  
**Solusi:** Download dari Firebase Console → Copy ke `android/app/`

### **Token = null**
**Penyebab:** Internet mati atau Play Services tidak ada  
**Solusi:** Cek internet + gunakan emulator dengan Play Store

### **Notifikasi muncul di background, tidak di foreground**
**Penyebab:** Ini NORMAL (sudah di-handle dengan Local Notifications)  
**Solusi:** Tidak perlu fix, sudah benar

---

## 📞 **Langkah Jika Masih Gagal**

Jika sudah ikuti semua step tapi tetap gagal:

1. **Kumpulkan Info:**
   - Screenshot console output (terutama bagian FCM Token)
   - Screenshot Firebase Console saat kirim notif
   - Log error (jika ada)
   - Spesifikasi device/emulator

2. **Cek Package Name:**
   - File: `android/app/build.gradle.kts`
   - Cari: `applicationId`
   - Contoh: `com.example.warteg_almera`
   - **Harus sama** dengan package name di Firebase Console

3. **Rebuild Project:**
   ```bash
   flutter clean
   rm -rf android/.gradle
   flutter pub get
   flutter run
   ```

4. **Test di Device Lain:**
   - Coba di HP real (jika pakai emulator)
   - Coba di emulator (jika pakai HP)

5. **Verifikasi SHA Certificate (jika pakai real device):**
   ```bash
   cd android
   ./gradlew signingReport
   ```
   - Copy SHA-1 dan SHA-256
   - Paste di Firebase Console → Project Settings → Add fingerprint

---

## ✅ **Kesimpulan**

**Masalah paling umum:**
1. ❌ Token tidak muncul → google-services.json salah/tidak ada
2. ❌ Permission tidak di-allow → User klik Deny
3. ❌ Format notifikasi salah → Hanya kirim `data` tanpa `notification`
4. ❌ Emulator tidak punya Play Services → Ganti emulator

**Solusi tercepat:**
```bash
# 1. Clean
flutter clean && flutter pub get

# 2. Run
flutter run

# 3. Copy token dari console

# 4. Firebase Console → Send test message → Paste token → Test

# 5. Allow permission saat popup muncul
```

**Jika sudah ikuti semua tapi tetap gagal:**
- 99% masalahnya di permission atau token expired
- Solusi: Uninstall → Reinstall → Allow permission → Copy token baru → Test ulang

---

## 📚 **Referensi**

- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [Flutter Firebase Messaging](https://firebase.flutter.dev/docs/messaging/overview)
- [Local Notifications](https://pub.dev/packages/flutter_local_notifications)

**File Panduan:**
- `CARA_TEST_NOTIFIKASI.md` - Panduan test notifikasi
- `PUSH_NOTIFICATION_PROMO_GUIDE.md` - Setup FCM lengkap
- `send_test_notification.py` - Script Python untuk test
- `send_test_notification.js` - Script Node.js untuk test
