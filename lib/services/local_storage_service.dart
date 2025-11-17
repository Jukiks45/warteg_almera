import 'package:hive_flutter/hive_flutter.dart';
import '../modules/cart/models/cart_item_adapter.dart';

class LocalStorageService {
  static const String cartBoxName = 'cartBox';
  
  Future<LocalStorageService> init() async {
    await Hive.initFlutter();
    
    // Register adapter untuk CartItemModel
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CartItemAdapter());
    }
    
    // Open boxes
    await Hive.openBox('appBox');
    await Hive.openBox(cartBoxName);
    
    return this;
  }
}