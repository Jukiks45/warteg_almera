import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

// services
import 'services/local_storage_service.dart';
import 'services/supabase_service.dart';

// --- IMPORT MODEL UNTUK HIVE ---
import 'modules/menu/models/menu_model.dart';
import 'modules/cart/models/cart_item_model.dart';
// --------------------------------

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- LOAD .ENV ---
  try {
    await dotenv.load(fileName: ".env");
    debugPrint(">>> .env loaded");
  } catch (e, st) {
    debugPrint(">>> FAILED to load .env: $e");
    debugPrint(st.toString());
  }

  // --- INIT LOCAL STORAGE & SETUP HIVE MODELS ---
  try {
    // Service Anda sudah menjalankan Hive.initFlutter()
    await LocalStorageService().init();
    debugPrint(">>> LocalStorage initialized");

    // Daftarkan adapter setelah Hive diinisialisasi
    Hive.registerAdapter(MenuModelAdapter());
    Hive.registerAdapter(CartItemModelAdapter()); // <-- Ini sekarang tidak akan error

    // Buka box (database) untuk menyimpan item keranjang
    await Hive.openBox<CartItemModel>('cart_items');
    debugPrint(">>> Hive Adapters registered and Cart Box opened");

  } catch (e, st) {
    debugPrint(">>> FAILED LocalStorage or Hive setup: $e");
    debugPrint(st.toString());
  }

  // --- INIT SUPABASE ---
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
