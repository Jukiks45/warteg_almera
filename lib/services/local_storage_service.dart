import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../modules/cart/models/cart_item_model.dart';

class LocalStorageService extends GetxService {
  static const String cartBoxName = 'cart_box';
  
  late final Box<CartItemModel> _cartBox;
  
  Box<CartItemModel> get cartBox => _cartBox;

  Future<LocalStorageService> init() async {
    try {
      print('🔧 Initializing Hive...');
      
      // Initialize Hive Flutter
      await Hive.initFlutter();
      print('✅ Hive.initFlutter() completed');
      
      // Register CartItemModel adapter SAJA
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(CartItemModelAdapter());
        print('✅ CartItemModelAdapter registered (typeId: 2)');
      }
      
      // Open cart box
      _cartBox = await Hive.openBox<CartItemModel>(cartBoxName);
      print('✅ $cartBoxName opened (${_cartBox.length} items found)');
      
      // Debug: Show items in box
      if (_cartBox.isNotEmpty) {
        print('📦 Items in box:');
        for (var item in _cartBox.values) {
          print('   - ${item.menuNama} x${item.quantity}');
        }
      }
      
      print('✅ LocalStorageService initialized successfully');
      return this;
    } catch (e) {
      print('❌ Error initializing LocalStorageService: $e');
      rethrow;
    }
  }

  Future<void> close() async {
    await _cartBox.close();
  }
}