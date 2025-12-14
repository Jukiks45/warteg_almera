/**
 * 🚀 Script Test FCM - Kirim Notifikasi ke Flutter App (Node.js)
 * ============================================================
 * 
 * SETUP:
 * 1. Install: npm install firebase-admin
 * 2. Download service account key dari Firebase Console
 * 3. Ganti FCM_TOKEN dengan token dari console aplikasi
 * 4. Run: node send_test_notification.js
 */

const admin = require('firebase-admin');
const readline = require('readline');

// ========================================
// KONFIGURASI - GANTI INI!
// ========================================

// 1. FCM Token dari console aplikasi
const FCM_TOKEN = "PASTE_TOKEN_DARI_CONSOLE_DI_SINI";

// 2. Path ke service account key
const serviceAccount = require('./serviceAccountKey.json');

// ========================================
// JANGAN EDIT DI BAWAH INI
// ========================================

// Initialize Firebase Admin
try {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
  console.log("✅ Firebase Admin initialized");
} catch (error) {
  console.error("❌ Error initializing Firebase:", error.message);
  console.log("\n📝 Pastikan file 'serviceAccountKey.json' ada!");
  console.log("   Download dari: Firebase Console → Project Settings → Service Accounts");
  process.exit(1);
}

// Validasi token
if (FCM_TOKEN === "PASTE_TOKEN_DARI_CONSOLE_DI_SINI") {
  console.error("❌ Error: FCM_TOKEN belum diganti!");
  console.log("\n📝 Cara mendapatkan token:");
  console.log("   1. Run aplikasi Flutter: flutter run");
  console.log("   2. Cek console, cari: 'FCM Token: xxxxx'");
  console.log("   3. Copy token dan paste di variable FCM_TOKEN di script ini");
  process.exit(1);
}

/**
 * Kirim notifikasi test sederhana
 */
async function sendTestNotification() {
  const message = {
    notification: {
      title: '🎉 Test dari Node.js',
      body: 'Notifikasi berhasil dikirim menggunakan Firebase Admin SDK!',
    },
    data: {
      type: 'promo',
      promo_id: '1',
    },
    token: FCM_TOKEN,
  };

  try {
    const response = await admin.messaging().send(message);
    console.log("\n✅ Notifikasi berhasil dikirim!");
    console.log("📨 Message ID:", response);
    console.log("\n🎯 Cek aplikasi Anda, notifikasi seharusnya muncul!");
  } catch (error) {
    console.error("\n❌ Error mengirim notifikasi:", error.message);
    console.log("\n📝 Kemungkinan penyebab:");
    console.log("   - Token salah/expired (run ulang aplikasi untuk token baru)");
    console.log("   - Internet tidak aktif");
    console.log("   - Service account key tidak valid");
  }
}

/**
 * Kirim notifikasi promo dengan navigasi
 */
async function sendPromoNotification() {
  const message = {
    notification: {
      title: '🔥 PROMO HEMAT 5K!',
      body: 'Diskon Rp 5.000 untuk pembelian min Rp 10.000. Klik untuk lihat detail!',
    },
    data: {
      type: 'promo',
      promo_id: '1',
    },
    android: {
      priority: 'high',
      notification: {
        sound: 'hidupjokowi',
        channelId: 'high_importance_channel',
      },
    },
    token: FCM_TOKEN,
  };

  try {
    const response = await admin.messaging().send(message);
    console.log("\n✅ Notifikasi PROMO berhasil dikirim!");
    console.log("📨 Message ID:", response);
    console.log("\n🎯 Klik notifikasi untuk langsung ke halaman promo!");
  } catch (error) {
    console.error("\n❌ Error:", error.message);
  }
}

/**
 * Kirim notifikasi menu baru
 */
async function sendMenuNotification() {
  const message = {
    notification: {
      title: '🍽️ Menu Baru!',
      body: 'Ada menu spesial hari ini! Lihat sekarang.',
    },
    data: {
      type: 'menu',
    },
    token: FCM_TOKEN,
  };

  try {
    const response = await admin.messaging().send(message);
    console.log("\n✅ Notifikasi MENU berhasil dikirim!");
    console.log("📨 Message ID:", response);
  } catch (error) {
    console.error("\n❌ Error:", error.message);
  }
}

/**
 * Kirim notifikasi ke multiple devices
 */
async function sendMulticastNotification() {
  // Contoh untuk kirim ke banyak device sekaligus
  const tokens = [
    FCM_TOKEN,
    // Tambahkan token lain di sini jika ada
  ];

  const message = {
    notification: {
      title: '📢 Pengumuman!',
      body: 'Pesan broadcast untuk semua pengguna.',
    },
    tokens: tokens,
  };

  try {
    const response = await admin.messaging().sendEachForMulticast(message);
    console.log("\n✅ Multicast berhasil!");
    console.log(`📨 ${response.successCount} pesan berhasil dikirim`);
    console.log(`❌ ${response.failureCount} pesan gagal`);
  } catch (error) {
    console.error("\n❌ Error:", error.message);
  }
}

// ========================================
// MAIN MENU
// ========================================

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

console.log("\n" + "=".repeat(60));
console.log("🚀 FCM Test - Warteg Almera Notification Sender (Node.js)");
console.log("=".repeat(60));
console.log("\nPilih jenis notifikasi:");
console.log("1. Test Notifikasi Sederhana");
console.log("2. Notifikasi Promo (dengan navigasi)");
console.log("3. Notifikasi Menu Baru");
console.log("4. Broadcast ke Multiple Devices");
console.log("0. Exit");

rl.question('\nPilihan (0-4): ', async (answer) => {
  switch(answer.trim()) {
    case '1':
      await sendTestNotification();
      break;
    case '2':
      await sendPromoNotification();
      break;
    case '3':
      await sendMenuNotification();
      break;
    case '4':
      await sendMulticastNotification();
      break;
    case '0':
      console.log("Bye! 👋");
      break;
    default:
      console.log("❌ Pilihan tidak valid!");
  }
  
  console.log("\n" + "=".repeat(60));
  rl.close();
  process.exit(0);
});
