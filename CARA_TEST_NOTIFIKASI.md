# 📲 Cara Test Notifikasi Firebase - Panduan Sederhana

## 🎯 **Langkah Test (5 Menit)**

### **STEP 1: Jalankan Aplikasi**

```bash
flutter run
```

**Tunggu hingga aplikasi terbuka di HP/emulator.**

---

### **STEP 2: Cari FCM Token di Console**

Di console/terminal, cari baris ini:
```
FCM Token: dxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

**Contoh:**
```
FCM Token: dZpM5R2oRO6xxxxxxxxxxxxxxxxxxxxxx:APA91bxxxxxxxxxxxxxxxxx
```

**⚠️ PENTING:** Copy seluruh token (sangat panjang, ~150-200 karakter)

**❌ Jika token TIDAK muncul:**
1. Cek internet HP/emulator aktif
2. Tunggu 10-20 detik
3. Jika tetap tidak ada:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

---

### **STEP 3: Buka Firebase Console**

1. Buka: https://console.firebase.google.com
2. Pilih project Anda (warteg_almera)
3. Sidebar kiri: **Engage** → **Cloud Messaging**
4. Klik tombol **Send your first message** (atau **Create campaign** → **Notifications**)

---

### **STEP 4: Isi Form Notifikasi**

#### **Tab 1: Notification**
- **Notification title:** `🎉 Promo Spesial`
- **Notification text:** `Diskon 10rb untuk pembelian hari ini!`
- **Notification image:** (kosongkan)
- Klik **Next**

#### **Tab 2: Target**
- Pilih: **Send test message**
- **Add an FCM registration token:**
  - Paste token yang Anda copy di Step 2
  - Klik tombol **+ (Add)**
  - Token akan muncul di list
- Klik **Test**

---

### **STEP 5: Cek Notifikasi**

**Skenario 1: Aplikasi DIBUKA (Foreground)**
- Notifikasi muncul sebagai **banner** di atas layar
- Bunyi: `hidupjokowi.mp3`
- Console menampilkan: `--- FOREGROUND MESSAGE RECEIVED ---`

**Skenario 2: Aplikasi MINIMIZE (Background)**
- Notifikasi muncul di **notification tray**
- Klik notifikasi → Aplikasi terbuka

**Skenario 3: Aplikasi DITUTUP TOTAL (Terminated)**
- Notifikasi muncul di **notification tray**
- Klik notifikasi → Aplikasi dibuka

---

## ✅ **Expected Result**

Jika berhasil, Anda akan lihat:

### **Di Console:**
```
--- FOREGROUND MESSAGE RECEIVED ---
Notification Data: {title: 🎉 Promo Spesial, body: Diskon 10rb untuk pembelian hari ini!}
Message data: {}
```

### **Di HP:**
- Banner notifikasi muncul (jika app dibuka)
- Atau notifikasi di tray (jika app minimize/closed)

---

## 🔧 **Test dengan Navigasi ke Promo**

Jika ingin test navigasi ke halaman promo:

### **Di Firebase Console:**

1. **Tab 1: Notification**
   - Title: `🔥 Promo Baru!`
   - Text: `Klik untuk lihat promo menarik`
   - Next

2. **Tab 2: Target**
   - Send test message
   - Paste token
   - **JANGAN klik Test dulu**
   - Klik **Next** (bukan Test)

3. **Tab 3: Scheduling**
   - Now (biarkan default)
   - Next

4. **Tab 4: Additional options**
   - **Custom data:**
     - Key: `type` → Value: `promo`
     - Key: `promo_id` → Value: `1`
   - Review
   - Publish

**Hasil:**
- Klik notifikasi → Otomatis buka halaman Promo Detail

---

## 🎯 **Quick Test Command**

Copy-paste command ini untuk test cepat:

```bash
# 1. Run aplikasi
flutter run

# 2. Tunggu sampai console menampilkan:
# "FCM Token: xxxxx..."

# 3. Copy token

# 4. Buka browser:
# https://console.firebase.google.com → Cloud Messaging → Send test message

# 5. Paste token → Test
```

---

## 🐛 **Jika Notifikasi TIDAK Muncul**

### **Cek 1: FCM Token Muncul?**
```bash
flutter logs | grep "FCM Token"
```

**Jika tidak:**
- Pastikan google-services.json ada di android/app/
- Clean project: `flutter clean && flutter pub get`
- Run ulang

### **Cek 2: Permission Allowed?**

**Di HP:**
1. Settings → Apps → Warteg Almera
2. Notifications → **Pastikan ON**

**Jika OFF:**
- Aktifkan
- Restart aplikasi
- Test ulang

### **Cek 3: Format Notifikasi Benar?**

**✅ BENAR:**
```json
{
  "notification": {
    "title": "Test",
    "body": "Pesan test"
  }
}
```

**❌ SALAH (hanya data):**
```json
{
  "data": {
    "message": "Test"
  }
}
```

### **Cek 4: Internet Aktif?**

- Pastikan HP/emulator terhubung internet
- Test: buka browser di emulator

---

## 📸 **Bukti Sukses**

Jika berhasil, Anda akan lihat:

1. **Console Log:**
   ```
   FCM Token: dZpM5R...
   --- FOREGROUND MESSAGE RECEIVED ---
   ```

2. **Notifikasi Banner (jika app dibuka):**
   ```
   🎉 Promo Spesial
   Diskon 10rb untuk pembelian hari ini!
   ```

3. **Notification Tray (jika app minimize):**
   - Icon aplikasi
   - Judul: 🎉 Promo Spesial
   - Pesan: Diskon 10rb...

---

## 🆘 **FAQ**

### **Q: Token tidak muncul di console?**
**A:** 
```bash
flutter clean
rm -rf android/.gradle
flutter pub get
flutter run
```

### **Q: Notifikasi muncul di background tapi tidak di foreground?**
**A:** Ini sudah di-handle dengan Local Notifications. Jika tidak muncul, cek console apakah ada error.

### **Q: Notifikasi muncul tapi tidak ada bunyi?**
**A:** File `hidupjokowi.mp3` harus ada di `android/app/src/main/res/raw/hidupjokowi.mp3`

### **Q: Klik notifikasi tapi tidak navigasi ke promo?**
**A:** Pastikan kirim dengan custom data:
```
type: promo
promo_id: 1
```

---

## 🎉 **Selesai!**

Jika semua langkah diikuti, notifikasi pasti muncul.

**Masih error?** Lihat file [TROUBLESHOOTING_NOTIFIKASI.md](TROUBLESHOOTING_NOTIFIKASI.md) untuk debugging lebih detail.
