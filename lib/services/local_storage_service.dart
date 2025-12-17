import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../modules/cart/models/cart_item_model.dart';

class LocalStorageService extends GetxService {
  static const String cartBoxName = 'cart_box';
  
  late final Box<CartItemModel> _cartBox;
  
  Box<CartItemModel> get cartBox => _cartBox;

  Future<LocalStorageService> init() async {
    try {
      debugPrint('🔧 Initializing Hive...');
      
      // Initialize Hive Flutter
      await Hive.initFlutter();
      debugPrint('✅ Hive.initFlutter() completed');
      
      // Register CartItemModel adapter SAJA
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(CartItemModelAdapter());
        debugPrint('✅ CartItemModelAdapter registered (typeId: 2)');
      }
      
      // Open cart box
      _cartBox = await Hive.openBox<CartItemModel>(cartBoxName);
      debugPrint('✅ $cartBoxName opened (${_cartBox.length} items found)');
      
      // Debug: Show items in box
      if (_cartBox.isNotEmpty) {
        debugPrint('📦 Items in box:');
        for (var item in _cartBox.values) {
          debugPrint('   - ${item.menuNama} x${item.quantity}');
        }
      }
      
      debugPrint('✅ LocalStorageService initialized successfully');
      return this;
    } catch (e) {
      debugPrint('❌ Error initializing LocalStorageService: $e');
      rethrow;
    }
  }

  Future<void> close() async {
    await _cartBox.close();
  }
}
