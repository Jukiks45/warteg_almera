/**
 * FCM Push Notification Sender - Node.js Example
 * ===============================================
 * 
 * Script untuk mengirim push notification FCM ke Flutter app.
 * Cocok untuk backend Node.js/Express implementation.
 * 
 * Installation:
 *   npm install axios
 * 
 * Usage:
 *   node send_fcm_notification.js
 */

const axios = require('axios');

// ==================== CONFIGURATION ====================
// Dapatkan dari Firebase Console → Project Settings → Cloud Messaging
const FCM_SERVER_KEY = 'YOUR_FCM_SERVER_KEY_HERE';

// FCM Token dari device (lihat di console Flutter app)
const DEVICE_TOKEN = 'DEVICE_FCM_TOKEN_HERE';

const FCM_URL = 'https://fcm.googleapis.com/fcm/send';
// =======================================================


/**
 * Kirim notifikasi promo ke device
 */
async function sendPromoNotification({
  token,
  title,
  body,
  promoId = null,
  promoType = 'promo'
}) {
  const headers = {
    'Content-Type': 'application/json',
    'Authorization': `key=${FCM_SERVER_KEY}`
  };

  const data = { type: promoType };
  if (promoId) {
    data.promo_id = promoId;
  }

  const payload = {
    to: token,
    notification: {
      title: title,
      body: body,
      sound: 'hidupjokowi',
      click_action: 'FLUTTER_NOTIFICATION_CLICK',
      priority: 'high'
    },
    data: data,
    priority: 'high'
  };

  try {
    const response = await axios.post(FCM_URL, payload, { headers });
    console.log('✅ Notifikasi berhasil dikirim!');
    console.log('Response:', JSON.stringify(response.data, null, 2));
    return response.data;
  } catch (error) {
    console.error('❌ Error mengirim notifikasi:', error.message);
    if (error.response) {
      console.error('Response:', error.response.data);
    }
    return null;
  }
}


/**
 * Kirim notifikasi update order
 */
async function sendOrderNotification(token, orderId, status) {
  const statusMessages = {
    'processing': 'Pesanan Anda sedang diproses',
    'cooking': 'Pesanan Anda sedang dimasak',
    'delivery': 'Pesanan Anda sedang diantar',
    'completed': 'Pesanan Anda telah selesai'
  };

  const headers = {
    'Content-Type': 'application/json',
    'Authorization': `key=${FCM_SERVER_KEY}`
  };

  const payload = {
    to: token,
    notification: {
      title: 'Update Pesanan',
      body: statusMessages[status] || 'Status pesanan berubah',
      sound: 'hidupjokowi'
    },
    data: {
      type: 'order',
      order_id: orderId,
      status: status
    },
    priority: 'high'
  };

  try {
    const response = await axios.post(FCM_URL, payload, { headers });
    console.log('✅ Notifikasi order berhasil dikirim!');
    return response.data;
  } catch (error) {
    console.error('❌ Error:', error.message);
    return null;
  }
}


/**
 * Kirim notifikasi ke multiple devices
 */
async function sendBulkNotification(tokens, title, body, data = null) {
  const headers = {
    'Content-Type': 'application/json',
    'Authorization': `key=${FCM_SERVER_KEY}`
  };

  const payload = {
    registration_ids: tokens,
    notification: {
      title: title,
      body: body,
      sound: 'hidupjokowi'
    },
    data: data || { type: 'promo' },
    priority: 'high'
  };

  try {
    const response = await axios.post(FCM_URL, payload, { headers });
    const { success = 0, failure = 0 } = response.data;
    
    console.log('✅ Notifikasi bulk berhasil!');
    console.log(`   Success: ${success}`);
    console.log(`   Failed: ${failure}`);
    
    return response.data;
  } catch (error) {
    console.error('❌ Error:', error.message);
    return null;
  }
}


/**
 * Express.js Route Example
 */
function setupExpressRoutes(app) {
  // POST /api/send-promo-notification
  app.post('/api/send-promo-notification', async (req, res) => {
    const { token, title, body, promoId } = req.body;
    
    if (!token || !title || !body) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields'
      });
    }

    const result = await sendPromoNotification({
      token,
      title,
      body,
      promoId
    });

    if (result) {
      res.json({ success: true, data: result });
    } else {
      res.status(500).json({ success: false, message: 'Failed to send notification' });
    }
  });

  // POST /api/send-order-notification
  app.post('/api/send-order-notification', async (req, res) => {
    const { token, orderId, status } = req.body;
    
    if (!token || !orderId || !status) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields'
      });
    }

    const result = await sendOrderNotification(token, orderId, status);

    if (result) {
      res.json({ success: true, data: result });
    } else {
      res.status(500).json({ success: false, message: 'Failed to send notification' });
    }
  });
}


// ==================== CONTOH PENGGUNAAN ====================

async function main() {
  console.log('='.repeat(60));
  console.log('FCM Push Notification Sender');
  console.log('='.repeat(60));

  // Contoh 1: Kirim notifikasi promo umum
  console.log('\n1. Mengirim notifikasi promo umum...');
  await sendPromoNotification({
    token: DEVICE_TOKEN,
    title: '🎉 Promo Spesial Hari Ini!',
    body: 'Lihat semua promo menarik yang tersedia untuk Anda'
  });

  // Contoh 2: Kirim notifikasi promo spesifik
  console.log('\n2. Mengirim notifikasi promo spesifik...');
  await sendPromoNotification({
    token: DEVICE_TOKEN,
    title: '🔥 Diskon 50% Menu Spesial!',
    body: 'Gunakan kode SPESIAL50 untuk diskon hingga 50%',
    promoId: '1'
  });

  // Contoh 3: Kirim notifikasi order
  console.log('\n3. Mengirim notifikasi update order...');
  await sendOrderNotification(
    DEVICE_TOKEN,
    '12345',
    'delivery'
  );

  // Contoh 4: Kirim ke multiple devices
  console.log('\n4. Mengirim ke multiple devices...');
  // await sendBulkNotification(
  //   [DEVICE_TOKEN, 'token2', 'token3'],
  //   'Promo Weekend!',
  //   'Nikmati promo weekend spesial',
  //   { type: 'promo' }
  // );

  console.log('\n' + '='.repeat(60));
  console.log('Selesai!');
  console.log('='.repeat(60));
}

// Run if called directly
if (require.main === module) {
  main();
}

// Export untuk digunakan di aplikasi Express
module.exports = {
  sendPromoNotification,
  sendOrderNotification,
  sendBulkNotification,
  setupExpressRoutes
};
