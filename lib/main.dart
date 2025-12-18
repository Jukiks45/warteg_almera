import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

// services
import 'services/local_storage_service.dart';
import 'services/supabase_service.dart';
import 'services/auth_session_service.dart';
import 'providers/login_providers.dart';
import 'services/notification_service.dart'; // Menggunakan nama NotificationService Anda

import 'constant/admin_constants.dart';

/// Initializes all services in the correct order before running the app.
/// Fungsi ini tetap sama seperti sebelumnya, karena sudah memiliki print/debugPrint yang baik.
Future<void> initServices() async {
  debugPrint("=".padRight(60, '='));
  debugPrint(">>> Starting Service Initialization");
  debugPrint("=".padRight(60, '='));

  // 1. Load .env file first
  try {
    await dotenv.load(fileName: ".env");
    debugPrint("[1/5] .env file loaded");
  } catch (e) {
    debugPrint("CRITICAL: FAILED to load .env file. $e");
    throw Exception(
        "Could not load .env file. Please ensure 'warteg_almera/.env' exists and is correctly formatted.");
  }

  // 2. Initialize LocalStorageService
  try {
    debugPrint(" [2/5] Initializing LocalStorageService...");
    await Get.putAsync(() => LocalStorageService().init(), permanent: true);
    debugPrint("[2/5] LocalStorageService initialized and registered");
  } on Exception catch (e) {
    debugPrint("CRITICAL: FAILED LocalStorageService init: ${e.toString()}");
    throw Exception("Gagal inisialisasi database lokal: ${e.toString()}");
  } catch (e) {
    debugPrint("CRITICAL: FAILED LocalStorageService init: $e");
    throw Exception("Gagal inisialisasi penyimpanan lokal: $e");
  }

  // 3. Initialize SupabaseService
  try {
    debugPrint(" [3/5] Initializing SupabaseService...");
    await Get.putAsync(() => SupabaseService().init(), permanent: true);
    debugPrint("Γ£à [3/5] SupabaseService initialized and registered");
  } on Exception catch (e) {
    debugPrint(
        "Γ¥î CRITICAL: FAILED to initialize SupabaseService: ${e.toString()}");
    throw Exception("Gagal koneksi ke server: ${e.toString()}");
  } catch (e) {
    debugPrint("Γ¥î CRITICAL: FAILED to initialize SupabaseService: $e");
    throw Exception("Gagal inisialisasi server: $e");
  }

  // 4. Initialize AuthSessionService
  try {
    debugPrint(" [4/5] Initializing AuthSessionService...");
    await Get.putAsync(() => AuthSessionService().init(), permanent: true);
    debugPrint("Γ£à [4/5] AuthSessionService initialized");
  } on Exception catch (e) {
    debugPrint(" FAILED AuthSessionService init: ${e.toString()}");
  } catch (e) {
    debugPrint(" FAILED AuthSessionService init: $e");
  }

  // 5. Initialize LoginProviders
  try {
    debugPrint(" [5/5] Registering LoginProviders...");
    Get.put(LoginProviders(), permanent: true);
    debugPrint("Γ£à [5/5] LoginProviders registered");
  } on Exception catch (e) {
    debugPrint(" FAILED LoginProviders init: ${e.toString()}");
  } catch (e) {
    debugPrint(" FAILED LoginProviders init: $e");
  }

  debugPrint("=".padRight(60, '='));
  debugPrint("Γ£à All Core Services Initialized Successfully");
  debugPrint("=".padRight(60, '='));
}

Future<void> main() async {
  // Ensure Flutter engine and GetX are ready
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialization must be done outside try-catch
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Gunakan try-catch di sini untuk menangkap kegagalan yang berasal dari notifikasi atau initServices
  try {
    // 2. Inisialisasi Global Service (Notifikasi)
    // PENTING: Panggil init() di sini untuk memastikan FCM/LocalNotif setup terjadi
    await Get.putAsync(() => NotificationService().init(), permanent: true);

    // PRINT SUCCESS JIKA init() berhasil
    debugPrint(
        '[MAIN] NotificationService berhasil diinisialisasi dan siap digunakan.');

    // 3. Inisialisasi semua layanan kritis lainnya
    await initServices();

    // 4. Jalankan aplikasi
    runApp(const MyApp());
  } catch (e, stackTrace) {
    // Jika ada CRITICAL ERROR (misal: Firebase/Supabase/Notif gagal)
    debugPrint('CRITICAL ERROR DURING STARTUP:');
    debugPrint(e.toString());
    debugPrint(stackTrace.toString());

    // Tampilkan layar error yang elegan
    runApp(ErrorApp(error: e.toString()));
    return; // Stop further execution
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if user is already logged in
    final authSession = Get.find<AuthSessionService>();
    final isLoggedIn = authSession.isLoggedIn();

    // Check if user is admin
    String initialRoute;

    if (!isLoggedIn) {
      initialRoute = AppRoutes.login;
    } else if (authSession.isAdmin) {
      initialRoute = AppRoutes.adminDashboard;
    } else {
      initialRoute = AppRoutes.menu;
    }

    debugPrint(">>> Building MyApp...");
    debugPrint(">>> User logged in: $isLoggedIn");
    debugPrint(">>> Initial route: $initialRoute");

    return GetMaterialApp(
      title: 'Warung Makan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      getPages: AppPages.routes,
    );
  }
}

/// A simple widget to display a critical startup error.
class ErrorApp extends StatelessWidget {
  final String error;
  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Application failed to start:\n\n$error",
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
