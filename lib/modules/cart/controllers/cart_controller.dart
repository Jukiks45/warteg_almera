import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/cart_item_model.dart';
import '../../menu/models/menu_model.dart';
import '../../../services/local_storage_service.dart';

class CartController extends GetxController {
  final cartItems = <CartItemModel>[].obs;
  final _supabase = Supabase.instance.client;
  late Box _cartBox;

  @override
  void onInit() {
    super.onInit();
    _initHive();
  }

  // Initialize Hive and load cart
  Future<void> _initHive() async {
    try {
      _cartBox = Hive.box(LocalStorageService.cartBoxName);
      _loadCartFromHive();
    } catch (e) {
      print('Error initializing Hive cart: $e');
    }
  }

  // Load cart from Hive
  void _loadCartFromHive() {
    try {
      final savedCart = _cartBox.get('cart_items');
      if (savedCart != null && savedCart is List) {
        cartItems.value = savedCart
            .map((item) => CartItemModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        print('Cart loaded from Hive: ${cartItems.length} items');
      }
    } catch (e) {
      print('Error loading cart from Hive: $e');
    }
  }

  // Save cart to Hive
  Future<void> _saveCartToHive() async {
    try {
      final cartData = cartItems.map((item) => item.toJson()).toList();
      await _cartBox.put('cart_items', cartData);
      print('Cart saved to Hive: ${cartItems.length} items');
    } catch (e) {
      print('Error saving cart to Hive: $e');
    }
  }

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
    
    _saveCartToHive();
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
      _saveCartToHive();
    }
  }

  // Increase quantity
  void increaseQuantity(int menuId) {
    final index = cartItems.indexWhere((item) => item.menu.id == menuId);
    if (index != -1) {
      cartItems[index].quantity++;
      cartItems.refresh();
      _saveCartToHive();
    }
  }

  // Decrease quantity
  void decreaseQuantity(int menuId) {
    final index = cartItems.indexWhere((item) => item.menu.id == menuId);
    if (index != -1) {
      if (cartItems[index].quantity > 1) {
        cartItems[index].quantity--;
        cartItems.refresh();
        _saveCartToHive();
      } else {
        removeFromCart(menuId);
      }
    }
  }

  // Remove item from cart
  void removeFromCart(int menuId) {
    cartItems.removeWhere((item) => item.menu.id == menuId);
    _saveCartToHive();
  }

  // Clear all cart
  void clearCart() {
    cartItems.clear();
    _saveCartToHive();
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

      // Clear cart after successful payment
      clearCart();

      return orderId;
    } catch (e) {
      print('Error saving order to Supabase: $e');
      rethrow;
    }
  }

  @override
  void onClose() {
    _saveCartToHive();
    super.onClose();
  }
}
