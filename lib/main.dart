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

// controllers
import 'modules/cart/controllers/cart_controller.dart'; 

Future<void> initServices() async {
  debugPrint("--- Memulai inisialisasi service ---");

  // Kode ori Anda untuk .env dan Supabase
  await dotenv.load(fileName: ".env");
  await SupabaseService().init();

  // Inisialisasi Hive dengan penanganan error
  try {
    await LocalStorageService().init();
    Hive.registerAdapter(MenuModelAdapter());
    Hive.registerAdapter(CartItemModelAdapter());
    
    final cartBox = await Hive.openBox<CartItemModel>('cart_items');
    Get.put(cartBox, permanent: true); 
    debugPrint(">>> Box Keranjang ('cart_items') berhasil dibuka.");

    Get.put(CartController(), permanent: true);
    debugPrint(">>> CartController berhasil dibuat dan siap digunakan.");

  } catch (e, st) {
    debugPrint(">>> GAGAL setup LocalStorage atau Hive: $e");
    debugPrint(st.toString());
  }
  
  debugPrint("--- Inisialisasi service selesai ---");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServices();
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
