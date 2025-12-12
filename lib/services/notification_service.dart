import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart'; // Import GetX

// --- 1. Definisi Custom Sound Channel (Android) ---
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // ID Channel
  'High Importance Notifications', // Nama Channel (terlihat di setting HP)
  description: 'This channel is used for important order status updates.',
  importance: Importance.max,
  sound: RawResourceAndroidNotificationSound(
      'hidupjokowi'), // NAMA FILE AUDIO (TANPA EKSTENSI)
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// --- 2. Background Handler (Wajib untuk Eksperimen 3) ---
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Lakukan inisialisasi Firebase lagi di sini jika diperlukan,
  // tetapi biasanya sudah ditangani oleh GetX/main.dart

  print('Handling a background message: ${message.messageId}');
  print('Data: ${message.data}');

  // TODO: Implementasi navigasi untuk Terminated/Background di sini
}

class NotificationService extends GetxService {
  Future<NotificationService> init() async {
    try {
      print('🔔 STARTING NotificationService Initialization...');

      // 1. Setup Background Handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 2. Setup Local Notification Plugin (Android/iOS Settings)
      await _setupLocalNotifications();

      // 3. Setup Foreground Handler (Untuk Eksperimen 1)
      _setupForegroundHandler();

      // 4. Handle Notifikasi Saat Aplikasi Dibuka dari Terminated (Eksperimen 3)
      _handleInitialMessage();

      // 5. Handle Notifikasi Saat Aplikasi Dibuka dari Background (Eksperimen 2)
      _handleMessageOpenedApp();

      // 6. Dapatkan FCM Token
      _getFCMToken();

      print('✅ [SERVICE] Setup Notifikasi dan FCM Token diminta.');
      return this;
    } catch (e, stacktrace) {
      // Tangkap error jika terjadi di dalam inisialisasi
      print('❌ KRITIS: Gagal inisialisasi NotificationService: $e');
      print('STACK: $stacktrace');
      return this; // Return this agar aplikasi tidak crash total
    }
  }

  // Metode untuk inisialisasi FLNP
  Future<void> _setupLocalNotifications() async {
    // Setup Android
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Setup iOS
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
      // Handler saat notifikasi lokal diklik
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

  // Metode untuk Eksperimen 1
  void _setupForegroundHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("\n" + "🔔"*30);
      print('📩 FOREGROUND MESSAGE RECEIVED!');
      print("🔔"*30);
      
      if (message.notification != null) {
        print('📌 Title: ${message.notification!.title}');
        print('📝 Body: ${message.notification!.body}');
      }
      
      if (message.data.isNotEmpty) {
        print('📦 Data: ${message.data}');
      }
      
      print("🔔"*30 + "\n");

      // Menggunakan local notifications untuk menampilkan Heads-up banner
      flutterLocalNotificationsPlugin.show(
        message.hashCode, // ID Notifikasi
        message.notification!.title,
        message.notification!.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.high,
            priority: Priority.high,
            // Custom sound sudah otomatis dipakai karena channel-nya sudah didefinisikan di atas
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

  // Metode untuk mendapatkan token (Wajib untuk pengujian FCM Console)
  void _getFCMToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    
    print("\n" + "="*60);
    print("📱 FCM TOKEN - COPY TOKEN INI!");
    print("="*60);
    print("FCM Token: $token");
    print("="*60);
    print("📝 Cara test:");
    print("1. Copy token di atas");
    print("2. Firebase Console → Cloud Messaging → Send test message");
    print("3. Paste token → Test");
    print("="*60 + "\n");
    
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
