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
  debugPrint("--- Starting Service Initialization ---");

  // Load .env file first, as other services depend on it.
  try {
    await dotenv.load(fileName: ".env");
    debugPrint("✅ .env file loaded.");
  } catch (e) {
    debugPrint("🛑 CRITICAL: FAILED to load .env file. $e");
    // Re-throw because the app is not functional without it.
    throw Exception("Could not load .env file. Please ensure 'warteg_almera/.env' exists and is correctly formatted.");
  }

  // Initialize SupabaseService. Get.putAsync waits for the init() Future to complete.
  try {
    await Get.putAsync(() => SupabaseService().init(), permanent: true);
    debugPrint("✅ SupabaseService initialized and registered.");
  } catch (e) {
     debugPrint("🛑 CRITICAL: FAILED to initialize SupabaseService. $e");
     rethrow;
  }

  // Initialize AuthSessionService for login session management
  try {
    await Get.putAsync(() => AuthSessionService().init(), permanent: true);
    debugPrint("✅ AuthSessionService initialized.");
  } catch(e) {
    debugPrint("⚠️ FAILED AuthSessionService init: $e");
  }

  // Initialize LoginProviders, which depends on the now-available SupabaseService.
  Get.put(LoginProviders(), permanent: true);
  debugPrint("✅ LoginProviders registered.");


  // Initialize other services like LocalStorageService if needed
  try {
    await Get.putAsync(() => LocalStorageService().init());
    debugPrint("✅ LocalStorageService initialized.");
  } catch(e) {
    debugPrint("⚠️ FAILED LocalStorage init: $e");
  }

  debugPrint("--- Service Initialization Complete ---");
}

Future<void> main() async {
  // Ensure Flutter engine and GetX are ready.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize all critical services before running the app.
  try {
    await initServices();
  } catch (e) {
    // If services fail, run a fallback error app to display the issue.
    runApp(ErrorApp(error: e.toString()));
    return; // Stop further execution.
  }

  // All services are loaded, run the main application.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if user is already logged in
    final authSession = Get.find<AuthSessionService>();
    final isLoggedIn = authSession.isLoggedIn();
    
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
