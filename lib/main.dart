import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

// services
import 'services/local_storage_service.dart';
import 'services/supabase_service.dart';

// models
import 'modules/menu/models/menu_model.dart';
import 'modules/cart/models/cart_item_model.dart';

// FUNGSI BARU UNTUK INISIALISASI SEMUA SERVICE
Future<void> initServices() async {
  debugPrint("--- Memulai inisialisasi service ---");

  // Load .env
  try {
    await dotenv.load(fileName: ".env");
    debugPrint(">>> .env berhasil dimuat");
  } catch (e) {
    debugPrint(">>> GAGAL memuat .env: $e");
  }

  // Init Local Storage (Hive)
  try {
    // 1. Inisialisasi Hive-nya dulu
    await LocalStorageService().init(); // Ini menjalankan Hive.initFlutter()
    debugPrint(">>> Hive berhasil diinisialisasi");

    // 2. Daftarkan semua adapter
    Hive.registerAdapter(MenuModelAdapter());
    Hive.registerAdapter(CartItemModelAdapter());
    debugPrint(">>> Adapter Hive berhasil didaftarkan");

    // 3. BUKA BOX-NYA DAN DAFTARKAN KE GetX (LANGKAH KUNCI)
    final cartBox = await Hive.openBox<CartItemModel>('cart_items');
    Get.put(cartBox, permanent: true); // Daftarkan 'cartBox' sebagai dependensi global
    debugPrint(">>> Box Keranjang ('cart_items') berhasil dibuka dan di-inject ke GetX");

  } catch (e, st) {
    debugPrint(">>> GAGAL setup LocalStorage atau Hive: $e");
    debugPrint(st.toString());
  }

  // Init Supabase
  try {
    await SupabaseService().init();
    debugPrint(">>> Supabase berhasil diinisialisasi");
  } catch (e) {
    debugPrint(">>> GAGAL inisialisasi Supabase: $e");
  }
  
  debugPrint("--- Inisialisasi service selesai ---");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Tunggu semua service selesai SEBELUM menjalankan UI
  await initServices();

  // Jalankan UI
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
