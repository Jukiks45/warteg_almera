import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart'; // Import GetX


// --- 1. Definisi Custom Sound Channel (Android) ---
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // ID Channel
  'High Importance Notifications', // Nama Channel (terlihat di setting HP)
  description: 'This channel is used for important order status updates.',
  importance: Importance.max,
  sound: RawResourceAndroidNotificationSound('hidupjokowi'), // NAMA FILE AUDIO (TANPA EKSTENSI)
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

    return this;
  }

  // Metode untuk inisialisasi FLNP
  Future<void> _setupLocalNotifications() async {
    // Setup Android
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    
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
        // TODO: Sama seperti logic navigasi FCM (Eksperimen 2/3)
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
      print('--- FOREGROUND MESSAGE RECEIVED ---');
      print('Message data: ${message.data}');
      
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
        payload: message.data.toString(), // Kirim payload data
      );
    });
  }

  // TODO: Metode untuk Eksperimen 2 (Navigasi dari Background/Closed)
  void _handleMessageOpenedApp() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('--- ON MESSAGE OPENED APP (Eksperimen 2) ---');
      // Panggil Get.toNamed untuk navigasi ke halaman detail
      // Contoh: Get.toNamed(AppRoutes.ORDER_DETAIL, arguments: message.data['order_id']);
    });
  }
  
  // TODO: Metode untuk Eksperimen 3 (Navigasi dari Terminated)
  void _handleInitialMessage() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print('--- GET INITIAL MESSAGE (Eksperimen 3) ---');
      // Panggil Get.toNamed untuk navigasi saat aplikasi baru dibuka
    }
  }

  // Metode untuk mendapatkan token (Wajib untuk pengujian FCM Console)
  void _getFCMToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print("FCM Token: $token");
    // TODO: Simpan token ini ke Supabase di tabel profiles jika perlu
  }
}