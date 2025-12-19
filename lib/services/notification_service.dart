import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';


// --- 1. Definisi Custom Sound Channel (Android) ---
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important order status updates.',
  importance: Importance.max,
  sound: RawResourceAndroidNotificationSound('hidupjokowi'), // NAMA FILE AUDIO (TANPA EKSTENSI)
);

// --- 2. Background Message Handler (Top-level function) ---
@pragma('vm:entry-point')

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.messageId}');
  debugPrint('Data: ${message.data}');
}

class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<NotificationService> init() async {
    try {
      debugPrint('>>> Starting NotificationService Initialization...');
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      await _setupLocalNotifications();
      _setupForegroundHandler();
      _handleInitialMessage();
      _handleMessageOpenedApp();
      _getFCMToken();
      debugPrint('✅ [SERVICE] Notification and FCM setup complete.');
      return this;
    } catch (e, stacktrace) {
      debugPrint('❌ CRITICAL: Failed to initialize NotificationService: $e');
      debugPrint('STACK: $stacktrace');
      return this;
    }
  }

  // --- FUNGSI BARU: Uji Suara Kustom (Instan) ---
  Future<void> showCustomSoundTest() async {
    await flutterLocalNotificationsPlugin.show(
      99,
      '🧪 TEST LOCAL NOTIFICATION',
      'Ini notifikasi lokal untuk pengujian Modul 6',
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      payload: 'type=location&target=maps',
    );
  }

  // --- Setup Local Notifications Plugin ---
  Future<void> _setupLocalNotifications() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('--- NOTIFICATION TAPPED ---');
        if (response.payload != null) {
          // Parse payload (dari FCM data)
          try {
            // Payload berisi data dalam format string
            final data = _parsePayload(response.payload!);
            _handleNotificationNavigation(data);
          } catch (e) {
            debugPrint('Error parsing payload: $e');
          }
        }
      },
    );

    // Meminta Izin
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  // --- Handle FCM Foreground (App Terbuka) ---
  void _setupForegroundHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("\n${"🔔" * 30}");
      debugPrint('📩 FOREGROUND MESSAGE RECEIVED!');
      debugPrint("🔔" * 30);

      if (message.notification != null) {
        debugPrint('📌 Title: ${message.notification!.title}');
        debugPrint('📝 Body: ${message.notification!.body}');
      }

      if (message.data.isNotEmpty) {
        debugPrint('📦 Data: ${message.data}');
      }

      debugPrint("🔔" * 30 + "\n");

      flutterLocalNotificationsPlugin.show(
        message.hashCode,
        message.notification!.title,
        message.notification!.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.high,
            priority: Priority.high,
            ticker: 'ticker',
          ),
        ),
        payload: _encodePayload(message.data), // Kirim payload data
      );
    });
  }

  // Metode untuk Eksperimen 2 (Navigasi dari Background/Closed)
  void _handleMessageOpenedApp() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('--- ON MESSAGE OPENED APP (Eksperimen 2) ---');
      debugPrint('Message data: ${message.data}');

      // Navigasi berdasarkan tipe notifikasi
      _handleNotificationNavigation(message.data);
    });
  }

  // Metode untuk Eksperimen 3 (Navigasi dari Terminated)
  void _handleInitialMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('--- GET INITIAL MESSAGE (Eksperimen 3) ---');
      debugPrint('Message data: ${initialMessage.data}');

      // Delay untuk memastikan aplikasi sudah siap
      Future.delayed(const Duration(seconds: 1), () {
        _handleNotificationNavigation(initialMessage.data);
      });
    }
  }

  // --- Get and Log FCM Token ---
  void _getFCMToken() async {
    String? token = await FirebaseMessaging.instance.getToken();

    debugPrint("\n${"=" * 60}");
    debugPrint("📱 FCM TOKEN - COPY TOKEN INI!");
    debugPrint("=" * 60);
    debugPrint("FCM Token: $token");
    debugPrint("=" * 60);
    debugPrint("📝 Cara test:");
    debugPrint("1. Copy token di atas");
    debugPrint("2. Firebase Console → Cloud Messaging → Send test message");
    debugPrint("3. Paste token → Test");
    debugPrint("=" * 60 + "\n");

    // TODO: Simpan token ini ke Supabase di tabel profiles jika perlu
  }

  /// Helper untuk navigasi berdasarkan data notifikasi
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    debugPrint('Handling navigation with data: $data');

    final type = data['type']?.toString() ?? '';

    switch (type) {
      case 'promo':
        // Navigasi ke halaman promo
        final promoId = data['promo_id']?.toString();
        if (promoId != null && promoId.isNotEmpty) {
          // Navigasi ke detail promo spesifik
          Get.toNamed('/promo', arguments: {'promoId': promoId});
        } else {
          // Navigasi ke list promo
          Get.toNamed('/promo');
        }
        break;

      case 'order':
        // Navigasi ke order history
        final orderId = data['order_id']?.toString();
        Get.toNamed('/order-history', arguments: {'orderId': orderId});
        break;

      case 'location':
        Get.toNamed('/location');
        break;

      default:
        // Default navigasi ke halaman promo jika tidak ada type
        Get.toNamed('/promo');
        break;
    }
  }

  /// Helper untuk encode payload ke string
  String _encodePayload(Map<String, dynamic> data) {
    try {
      // Simple encoding: key1=value1&key2=value2
      return data.entries.map((e) => '${e.key}=${e.value}').join('&');
    } catch (e) {
      return '';
    }
  }

  /// Helper untuk parse payload dari string
  Map<String, dynamic> _parsePayload(String payload) {
    try {
      final Map<String, dynamic> result = {};
      final parts = payload.split('&');
      for (var part in parts) {
        final keyValue = part.split('=');
        if (keyValue.length == 2) {
          result[keyValue[0]] = keyValue[1];
        }
      }
      return result;
    } catch (e) {
      return {};
    }
  }
}
