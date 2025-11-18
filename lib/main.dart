import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

// services
import 'services/local_storage_service.dart';
import 'services/supabase_service.dart';
import 'services/auth_session_service.dart';
import 'providers/login_providers.dart';

/// Initializes all services in the correct order before running the app.
Future<void> initServices() async {
  debugPrint("=".padRight(60, '='));
  debugPrint("🚀 Starting Service Initialization");
  debugPrint("=".padRight(60, '='));

  // 1. Load .env file first
  try {
    await dotenv.load(fileName: ".env");
    debugPrint("✅ [1/5] .env file loaded");
  } catch (e) {
    debugPrint("🛑 CRITICAL: FAILED to load .env file. $e");
    throw Exception("Could not load .env file. Please ensure 'warteg_almera/.env' exists and is correctly formatted.");
  }

  // 2. Initialize LocalStorageService PERTAMA (ini yang penting!)
  try {
    debugPrint("🔧 [2/5] Initializing LocalStorageService...");
    await Get.putAsync(() => LocalStorageService().init(), permanent: true);
    debugPrint("✅ [2/5] LocalStorageService initialized and registered");
  } catch(e) {
    debugPrint("🛑 CRITICAL: FAILED LocalStorageService init: $e");
    rethrow;
  }

  // 3. Initialize SupabaseService
  try {
    debugPrint("🔧 [3/5] Initializing SupabaseService...");
    await Get.putAsync(() => SupabaseService().init(), permanent: true);
    debugPrint("✅ [3/5] SupabaseService initialized and registered");
  } catch (e) {
    debugPrint("🛑 CRITICAL: FAILED to initialize SupabaseService. $e");
    rethrow;
  }

  // 4. Initialize AuthSessionService
  try {
    debugPrint("🔧 [4/5] Initializing AuthSessionService...");
    await Get.putAsync(() => AuthSessionService().init(), permanent: true);
    debugPrint("✅ [4/5] AuthSessionService initialized");
  } catch(e) {
    debugPrint("⚠️ FAILED AuthSessionService init: $e");
  }

  // 5. Initialize LoginProviders
  try {
    debugPrint("🔧 [5/5] Registering LoginProviders...");
    Get.put(LoginProviders(), permanent: true);
    debugPrint("✅ [5/5] LoginProviders registered");
  } catch(e) {
    debugPrint("⚠️ FAILED LoginProviders init: $e");
  }

  debugPrint("=".padRight(60, '='));
  debugPrint("✅ All Services Initialized Successfully");
  debugPrint("=".padRight(60, '='));
}

Future<void> main() async {
  // Ensure Flutter engine and GetX are ready
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize all critical services before running the app
  try {
    await initServices();
  } catch (e) {
    // If services fail, run a fallback error app to display the issue
    runApp(ErrorApp(error: e.toString()));
    return; // Stop further execution
  }

  // All services are loaded, run the main application
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if user is already logged in
    final authSession = Get.find<AuthSessionService>();
    final isLoggedIn = authSession.isLoggedIn();
    
    debugPrint("📱 Building MyApp...");
    debugPrint("🔐 User logged in: $isLoggedIn");
    debugPrint("🏠 Initial route: ${isLoggedIn ? AppRoutes.menu : AppRoutes.login}");
    
    return GetMaterialApp(
      title: 'Warung Makan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: isLoggedIn ? AppRoutes.menu : AppRoutes.login,
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