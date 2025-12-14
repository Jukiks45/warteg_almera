import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

// --- 1. Custom Sound Channel Definition (Android) ---
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important order status updates.',
  importance: Importance.max,
  sound: RawResourceAndroidNotificationSound('hidupjokowi'),
);

// --- 2. Background Message Handler (Top-level function) ---
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
  print('Data: ${message.data}');
  // TODO: Implement navigation/data handling for Terminated/Background state
}

class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<NotificationService> init() async {
    try {
      print('>>> Starting NotificationService Initialization...');
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      await _setupLocalNotifications();
      _setupForegroundHandler();
      _handleInitialMessage();
      _handleMessageOpenedApp();
      _getFCMToken();
      print('✅ [SERVICE] Notification and FCM setup complete.');
      return this;
    } catch (e, stacktrace) {
      print('❌ CRITICAL: Failed to initialize NotificationService: $e');
      print('STACK: $stacktrace');
      return this;
    }
  }

  // --- FUNGSI BARU: Uji Suara Kustom (Instan) ---
  Future<void> showCustomSoundTest() async {
    // ID 99 adalah ID notifikasi
    await flutterLocalNotificationsPlugin.show(
      99,
      '✅ UJI SUARA KUSTOM BERHASIL',
      'Ini adalah notifikasi dengan audio "hidupjokowi.mp3" Anda.',
      NotificationDetails(
        android: AndroidNotificationDetails(
          // PENTING: Menggunakan CHANNEL ID yang sudah kita definisikan di atas
          channel.id,
          channel.name,
          importance: Importance.max,
        ),
      ),
      payload: 'custom_sound_test',
    );
    print('✅ [TEST] Notifikasi Uji Suara Kustom dipicu.');
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

    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('--- NOTIFICATION TAPPED ---');
        if (response.payload != null) {
          // Parse payload (dari FCM data)
          try {
            // Payload berisi data dalam format string
            final data = _parsePayload(response.payload!);
            _handleNotificationNavigation(data);
          } catch (e) {
            print('Error parsing payload: $e');
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
      print("\n" + "🔔" * 30);
      print('📩 FOREGROUND MESSAGE RECEIVED!');
      print("🔔" * 30);

      if (message.notification != null) {
        print('📌 Title: ${message.notification!.title}');
        print('📝 Body: ${message.notification!.body}');
      }

      if (message.data.isNotEmpty) {
        print('📦 Data: ${message.data}');
      }

      print("🔔" * 30 + "\n");

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
      print('--- ON MESSAGE OPENED APP (Eksperimen 2) ---');
      print('Message data: ${message.data}');

      // Navigasi berdasarkan tipe notifikasi
      _handleNotificationNavigation(message.data);
    });
  }

  // Metode untuk Eksperimen 3 (Navigasi dari Terminated)
  void _handleInitialMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print('--- GET INITIAL MESSAGE (Eksperimen 3) ---');
      print('Message data: ${initialMessage.data}');

      // Delay untuk memastikan aplikasi sudah siap
      Future.delayed(const Duration(seconds: 1), () {
        _handleNotificationNavigation(initialMessage.data);
      });
    }
  }

  // --- Get and Log FCM Token ---
  void _getFCMToken() async {
    String? token = await FirebaseMessaging.instance.getToken();

    print("\n" + "=" * 60);
    print("📱 FCM TOKEN - COPY TOKEN INI!");
    print("=" * 60);
    print("FCM Token: $token");
    print("=" * 60);
    print("📝 Cara test:");
    print("1. Copy token di atas");
    print("2. Firebase Console → Cloud Messaging → Send test message");
    print("3. Paste token → Test");
    print("=" * 60 + "\n");

    // TODO: Simpan token ini ke Supabase di tabel profiles jika perlu
  }

  /// Helper untuk navigasi berdasarkan data notifikasi
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    print('Handling navigation with data: $data');

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

      case 'menu':
        // Navigasi ke menu
        Get.toNamed('/menu');
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
