import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

// services
import 'services/local_storage_service.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- LOAD .ENV (root .env) ---
  try {
    await dotenv.load(fileName: ".env");
    debugPrint(">>> .env loaded");
  } catch (e, st) {
    debugPrint(">>> FAILED to load .env: $e");
    debugPrint(st.toString());
    // Tidak throw — biarkan UI tetap muncul
  }

  // --- INIT Local Storage (Hive) ---
  try {
    await LocalStorageService().init();
    debugPrint(">>> LocalStorage initialized");
  } catch (e, st) {
    debugPrint(">>> FAILED LocalStorage init: $e");
    debugPrint(st.toString());
  }

  // --- INIT Supabase ---
  try {
    await SupabaseService().init();
    debugPrint(">>> Supabase initialized");
  } catch (e, st) {
    debugPrint(">>> FAILED Supabase init: $e");
    debugPrint(st.toString());
  }

  // --- RUN UI (TIDAK DIUBAH) ---
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Warung Makan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.login,
      getPages: AppPages.routes,
    );
  }
}
