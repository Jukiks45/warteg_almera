import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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
  // TODO: Implement navigation/data handling for Terminated/Background state
}

class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<NotificationService> init() async {
    try {
      print('>>> Starting NotificationService Initialization...');
      // ⏰ INIT TIMEZONE
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
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
        print('Local Notification Tapped with payload: ${response.payload}');
      },
    );

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }


  // --- Handle FCM Foreground (App Terbuka) ---
  void _setupForegroundHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('--- FOREGROUND MESSAGE RECEIVED ---');

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
        payload: message.data.toString(),
      );
    });
  }

  // --- Handle FCM Background to App (Eksperimen 2) ---
  void _handleMessageOpenedApp() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('--- ON MESSAGE OPENED APP ---');
      // TODO: Navigation logic here
    });
  }

  // --- Handle FCM Terminated to App (Eksperimen 3) ---
  void _handleInitialMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print('--- GET INITIAL MESSAGE ---');
      // TODO: Navigation logic here
    }
  }

  // --- Get and Log FCM Token ---
  void _getFCMToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print("FCM Token: $token");
    // TODO: Send token to your backend/Supabase
  }
}
