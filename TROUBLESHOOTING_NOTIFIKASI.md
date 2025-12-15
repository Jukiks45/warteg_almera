# 🔧 Troubleshooting: Notifikasi Firebase Tidak Masuk

## 📋 Checklist Pemeriksaan

### ✅ **1. Cek FCM Token di Console**

Jalankan aplikasi dan cek console/terminal, cari baris:
```
FCM Token: xxxxxxxxxxxxxxxxxxxxx...
```

**Masalah & Solusi:**

❌ **Token tidak muncul?**
```dart
// Pastikan NotificationService sudah di-init di main.dart
// Cek baris ini ada di main.dart:
await Get.putAsync(() => NotificationService().init(), permanent: true);
```

❌ **Token = null?**
- Pastikan internet aktif
- Cek google-services.json ada di android/app/
- Run `flutter clean` → `flutter pub get` → `flutter run`

---

### ✅ **2. Cek Permission Notifikasi**

**Android 13+ (API 33+):**
Perlu request permission runtime!

**Solusi:** Tambahkan di AndroidManifest.xml:
```xml
<!-- File: android/app/src/main/AndroidManifest.xml -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- Tambahkan permission ini -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.INTERNET"/>
    
    <application ...>
```

**Test Permission:**
1. Buka aplikasi
2. Muncul popup "Allow notifications?" → Klik **Allow**
3. Atau manual: Settings HP → Apps → Warteg Almera → Notifications → **ON**

---

### ✅ **3. Cek Aplikasi di Foreground vs Background**

**Notifikasi tidak muncul saat app DIBUKA (foreground)?**

**Alasan:** Firebase tidak auto-show notification saat foreground.

**Solusi:** Sudah dihandle di `_setupForegroundHandler()` dengan Local Notifications.

**Cek apakah ini yang jalan:**
```dart
// Di notification_service.dart
void _setupForegroundHandler() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('--- FOREGROUND MESSAGE RECEIVED ---');  // ← Cek ini muncul?
    // ... show local notification
  });
}
```

**Jika tidak muncul di console:**
- NotificationService mungkin belum di-init
- Cek ulang main.dart

---

### ✅ **4. Cek Format Notifikasi dari Firebase Console**

**WAJIB:**
```json
{
  "notification": {
    "title": "Test Notifikasi",    // ← WAJIB
    "body": "Ini adalah test"      // ← WAJIB
  },
  "data": {
    "type": "promo",               // ← Opsional (untuk navigasi)
    "promo_id": "1"
  }
}
```

**SALAH (hanya data, tanpa notification):**
```json
{
  "data": {
    "message": "Test"  // ← Tidak akan muncul banner!
  }
}
```

**Cara Kirim yang Benar di Firebase Console:**

1. **Compose notification** (bukan Messaging API)
2. **Notification title:** Isi judul
3. **Notification text:** Isi pesan
4. **Target:** Single device → Paste FCM token
5. **(Optional) Additional options:**
   - Custom data → Add:
     - Key: `type` Value: `promo`
     - Key: `promo_id` Value: `1`
6. **Review** → **Publish**

---

### ✅ **5. Cek google-services.json**

File harus ada di: `android/app/google-services.json`

**Verifikasi:**
```bash
ls android/app/google-services.json
```

**Jika tidak ada:**
1. Buka [Firebase Console](https://console.firebase.google.com)
2. Pilih project
3. Project Settings → General
4. Scroll ke "Your apps"
5. Android app → Download `google-services.json`
6. Copy ke `android/app/`

---

### ✅ **6. Cek gradle plugin**

**File:** `android/build.gradle.kts`

Harus ada:
```kotlin
dependencies {
    classpath("com.google.gms:google-services:4.4.0")  // ← Ini
}
```

**File:** `android/app/build.gradle.kts`

Harus ada:
```kotlin
plugins {
    id("com.google.gms.google-services")  // ← Ini
}
```

---

### ✅ **7. Test Bertahap**

**Test 1: Cek FCM Token**
```bash
flutter run
# Lihat console, cari:
# "FCM Token: xxxxx..."
# Copy token ini
```

**Test 2: Kirim Notifikasi Test**
1. Buka Firebase Console → Cloud Messaging
2. Send test message
3. Paste token yang di-copy
4. Send

**Test 3: Cek Console Aplikasi**
Saat notifikasi dikirim, harus muncul:
```
--- FOREGROUND MESSAGE RECEIVED ---
Message data: {type: promo, promo_id: 1}
```

**Test 4: Lihat Notifikasi**
- Jika app dibuka (foreground): Muncul banner notification
- Jika app minimize (background): Muncul di notification tray
- Jika app ditutup (terminated): Muncul di notification tray

---

## 🔍 **Debugging Step-by-Step**

### **Langkah 1: Pastikan FCM Token Muncul**

Run aplikasi dan cek output console. Harus ada:
```
🔔 STARTING NotificationService Initialization...
✅ [SERVICE] Setup Notifikasi dan FCM Token diminta.
FCM Token: dxxxxxxxxxxxxxxxxxxxxx...
```

**Jika TIDAK muncul:**
```bash
# Clean project
flutter clean
flutter pub get

# Rebuild
flutter run
```

---

### **Langkah 2: Test dengan Token yang Sudah Ada**

Jika token sudah muncul, test kirim notifikasi:

**Via Firebase Console:**
1. Cloud Messaging → Send your first message
2. Notification title: `Test Promo`
3. Notification text: `Diskon 50% hari ini!`
4. Target: Single device
5. FCM registration token: `<paste token>`
6. Send test message

**Via cURL (alternatif):**
```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "FCM_TOKEN_DEVICE",
    "notification": {
      "title": "Test Notifikasi",
      "body": "Ini test dari cURL"
    },
    "data": {
      "type": "promo"
    }
  }'
```

---

### **Langkah 3: Cek Permission**

**Di HP:**
1. Settings → Apps → Warteg Almera
2. Notifications → **Pastikan ON**
3. Jika OFF, aktifkan

**Di Code:**
Pastikan permission diminta (sudah ada di NotificationService):
```dart
await FirebaseMessaging.instance.requestPermission(
  alert: true,
  badge: true,
  sound: true,
);
```

---

### **Langkah 4: Cek Apakah Notif Masuk tapi Tidak Terlihat**

**Test dengan app MINIMIZE:**
1. Minimize aplikasi (tekan tombol home)
2. Kirim notifikasi dari Firebase
3. Cek notification tray HP
4. Harus muncul notifikasi

**Jika muncul di background tapi TIDAK di foreground:**
- Ini normal! Local notification harus di-setup
- Sudah di-handle di `_setupForegroundHandler()`

---

## 🎯 **Kemungkinan Penyebab & Solusi**

### **1. Token Tidak Muncul**
**Penyebab:** Firebase belum ter-init atau google-services.json salah  
**Solusi:**
```bash
flutter clean
flutter pub get
# Cek google-services.json ada di android/app/
flutter run
```

### **2. Notifikasi Tidak Muncul di Foreground**
**Penyebab:** Local notification belum di-setup  
**Solusi:** Sudah di-handle, cek console apakah ada error

### **3. Notifikasi Tidak Muncul di Background**
**Penyebab:** Permission ditolak atau format salah  
**Solusi:**
- Cek permission di Settings HP
- Pastikan kirim dengan `notification` field, bukan hanya `data`

### **4. Notifikasi Muncul tapi Tidak Bisa Diklik**
**Penyebab:** Handler onClick belum di-setup  
**Solusi:** Sudah di-handle di `_handleMessageOpenedApp()`

### **5. App Crash saat Terima Notifikasi**
**Penyebab:** Error di handler  
**Solusi:** Cek console untuk stack trace

---

## 📱 **Quick Test Command**

```bash
# 1. Clean & Run
flutter clean && flutter pub get && flutter run

# 2. Lihat console, copy FCM Token

# 3. Kirim test dari Firebase Console

# 4. Cek apakah muncul notifikasi
```

---

## 🆘 **Masih Tidak Bisa?**

**Cek hal berikut:**

1. **Internet aktif?** ✅
2. **Google-services.json ada?** ✅
3. **Permission allowed?** ✅
4. **FCM token muncul di console?** ✅
5. **Format notifikasi sudah benar?** ✅
6. **Kirim dari Firebase Console, bukan API?** ✅

**Debug Output yang Harus Muncul:**
```
🔔 STARTING NotificationService Initialization...
FCM Token: dxxxxxxxxxx...
✅ [SERVICE] Setup Notifikasi dan FCM Token diminta.
✅ [MAIN] NotificationService berhasil diinisialisasi
```

**Jika tetap tidak bisa:**
- Screenshot console output
- Screenshot Firebase Console saat kirim notif
- Cek error di logcat: `flutter logs`

---

## ✅ **Checklist Final**

- [ ] FCM Token muncul di console
- [ ] google-services.json ada di android/app/
- [ ] Permission notifikasi di-allow
- [ ] Kirim notifikasi dengan format yang benar (ada `notification` field)
- [ ] Test kirim dari Firebase Console
- [ ] Cek notification tray HP (jika app minimize)
- [ ] Cek local notification (jika app dibuka)

**Jika semua ✅ tapi tetap tidak muncul:**
- Restart HP
- Uninstall app → Reinstall
- Cek Firebase project settings
