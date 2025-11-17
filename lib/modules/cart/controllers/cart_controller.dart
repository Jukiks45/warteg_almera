import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cart_item_model.dart';
import '../../menu/models/menu_model.dart';

class CartController extends GetxController {
  final cartItems = <CartItemModel>[].obs;
  final _supabase = Supabase.instance.client;

  // Computed properties
  int get totalItems => cartItems.fold(0, (sum, item) => sum + item.quantity);
  
  double get totalPrice => cartItems.fold(0.0, (sum, item) => sum + item.subtotal);

  // Add item to cart
  void addToCart(MenuModel menu, {int quantity = 1}) {
    final index = cartItems.indexWhere((item) => item.menu.id == menu.id);
    
    if (index != -1) {
      // Item already exists, update quantity
      cartItems[index].quantity += quantity;
      cartItems.refresh();
    } else {
      // Add new item
      cartItems.add(CartItemModel(menu: menu, quantity: quantity));
    }
  }

  // Update quantity
  void updateQuantity(int menuId, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(menuId);
      return;
    }
    
    final index = cartItems.indexWhere((item) => item.menu.id == menuId);
    if (index != -1) {
      cartItems[index].quantity = newQuantity;
      cartItems.refresh();
    }
  }

  // Increase quantity
  void increaseQuantity(int menuId) {
    final index = cartItems.indexWhere((item) => item.menu.id == menuId);
    if (index != -1) {
      cartItems[index].quantity++;
      cartItems.refresh();
    }
  }

  // Decrease quantity
  void decreaseQuantity(int menuId) {
    final index = cartItems.indexWhere((item) => item.menu.id == menuId);
    if (index != -1) {
      if (cartItems[index].quantity > 1) {
        cartItems[index].quantity--;
        cartItems.refresh();
      } else {
        removeFromCart(menuId);
      }
    }
  }

  // Remove item from cart
  void removeFromCart(int menuId) {
    cartItems.removeWhere((item) => item.menu.id == menuId);
  }

  // Clear all cart
  void clearCart() {
    cartItems.clear();
  }

  // Get quantity of specific item
  int getItemQuantity(int menuId) {
    final index = cartItems.indexWhere((item) => item.menu.id == menuId);
    return index != -1 ? cartItems[index].quantity : 0;
  }

  // Check if item exists in cart
  bool isInCart(int menuId) {
    return cartItems.any((item) => item.menu.id == menuId);
  }

  // Save order to Supabase (requires login)
  Future<String?> saveOrderToSupabase({String paymentMethod = 'cash', String? note}) async {
    try {
      if (cartItems.isEmpty) {
        throw Exception('Keranjang kosong');
      }

      // Get current user - WAJIB LOGIN
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Anda harus login terlebih dahulu untuk melakukan pemesanan');
      }

      // 1. Insert order header
      final orderData = {
        'user_id': user.id, // WAJIB ada user_id
        'total_items': totalItems,
        'total_price': totalPrice,
        'status': 'paid',
        'payment_method': paymentMethod,
        'note': note,
      };

      final orderResponse = await _supabase
          .from('orders')
          .insert(orderData)
          .select('id')
          .single();

      final orderId = orderResponse['id'] as String;

      // 2. Insert order items
      final orderItemsData = cartItems.map((item) {
        return {
          'order_id': orderId,
          'menu_id': item.menu.id,
          'menu_nama': item.menu.nama,
          'menu_kategori': item.menu.kategori,
          'menu_harga': item.menu.harga,
          'quantity': item.quantity,
          'subtotal': item.subtotal,
        };
      }).toList();

      await _supabase.from('order_items').insert(orderItemsData);

      return orderId;
    } catch (e) {
      print('Error saving order to Supabase: $e');
      rethrow;
    }
  }
}
