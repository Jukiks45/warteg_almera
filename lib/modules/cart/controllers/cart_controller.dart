import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cart_item_model.dart';
import '../../menu/models/menu_model.dart';

class CartController extends GetxController {
  // === BAGIAN YANG DIMODIFIKASI ===
  late Box<CartItemModel> cartBox; // Deklarasi tetap sama

  final cartItems = <CartItemModel>[].obs;
  final _supabase = Supabase.instance.client;

  @override
  void onInit() {
    super.onInit();
    // PERUBAHAN UTAMA: Ambil Box yang sudah disiapkan di main.dart
    cartBox = Get.find<Box<CartItemModel>>(); 
    
    // Logika selanjutnya tetap sama
    loadCartItemsFromDb();
  }
  // ==============================

  void loadCartItemsFromDb() {
    cartItems.assignAll(cartBox.values.toList());
  }

  // == TIDAK ADA PERUBAHAN DARI SINI KE BAWAH, SEMUA KODE ASLI ANDA AMAN ==

  int get totalItems => cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => cartItems.fold(0.0, (sum, item) => sum + item.subtotal);

  void addToCart(MenuModel menu, {int quantity = 1}) {
    final existingItem = cartItems.firstWhereOrNull((item) => item.menu.id == menu.id);
    
    if (existingItem != null) {
      increaseQuantity(menu.id, count: quantity);
    } else {
      final newItem = CartItemModel(menu: menu, quantity: quantity);
      cartBox.add(newItem);
      loadCartItemsFromDb();
    }
  }

  void increaseQuantity(int menuId, {int count = 1}) {
    final item = cartItems.firstWhere((item) => item.menu.id == menuId);
    item.quantity += count;
    item.save();
    cartItems.refresh();
  }

  void decreaseQuantity(int menuId) {
    final item = cartItems.firstWhere((item) => item.menu.id == menuId);
    if (item.quantity > 1) {
      item.quantity--;
      item.save();
      cartItems.refresh();
    } else {
      removeFromCart(menuId);
    }
  }

  void removeFromCart(int menuId) {
    final itemToRemove = cartItems.firstWhere((item) => item.menu.id == menuId);
    itemToRemove.delete();
    loadCartItemsFromDb();
  }

  void clearCart() {
    cartBox.clear();
    loadCartItemsFromDb();
  }

  int getItemQuantity(int menuId) {
    final index = cartItems.indexWhere((item) => item.menu.id == menuId);
    return index != -1 ? cartItems[index].quantity : 0;
  }

  bool isInCart(int menuId) {
    return cartItems.any((item) => item.menu.id == menuId);
  }

  Future<String?> saveOrderToSupabase({String paymentMethod = 'cash', String? note}) async {
    try {
      if (cartItems.isEmpty) throw Exception('Keranjang kosong');
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('Anda harus login terlebih dahulu untuk melakukan pemesanan');
      
      final orderData = {
        'user_id': user.id, 'total_items': totalItems, 'total_price': totalPrice,
        'status': 'paid', 'payment_method': paymentMethod, 'note': note,
      };

      final orderResponse = await _supabase.from('orders').insert(orderData).select('id').single();
      final orderId = orderResponse['id'] as String;

      final orderItemsData = cartItems.map((item) => {
        'order_id': orderId, 'menu_id': item.menu.id, 'menu_nama': item.menu.nama,
        'menu_kategori': item.menu.kategori, 'menu_harga': item.menu.harga,
        'quantity': item.quantity, 'subtotal': item.subtotal,
      }).toList();

      await _supabase.from('order_items').insert(orderItemsData);
      clearCart();
      return orderId;
    } catch (e) {
      print('Error saving order to Supabase: $e');
      rethrow;
    }
  }
}
