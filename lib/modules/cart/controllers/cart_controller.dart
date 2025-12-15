import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/cart_item_model.dart';
import '../../menu/models/menu_model.dart';
import '../../../services/local_storage_service.dart';

class CartController extends GetxController {
  final LocalStorageService _localStorage = Get.find();
  final _supabase = Supabase.instance.client;
  
  final cartItems = <CartItemModel>[].obs;
  final Rx<String?> appliedPromoCode = Rx<String?>(null);
  final Rx<double> promoDiscount = 0.0.obs;

  Box<CartItemModel> get _cartBox => _localStorage.cartBox;

  @override
  void onInit() {
    super.onInit();
    print('🛒 CartController onInit() called');
    _loadCart();
  }

  // Load cart from Hive
  void _loadCart() {
    try {
      print('📂 Loading cart from Hive...');
      
      final items = _cartBox.values.toList();
      cartItems.assignAll(items);
      
      print('✅ Cart loaded: ${cartItems.length} items');
      
      // Debug log
      for (var item in cartItems) {
        print('   📦 ${item.menuNama} x${item.quantity} = Rp${item.subtotal}');
      }
      
    } catch (e) {
      print('❌ Error loading cart: $e');
    }
  }

  // Save cart to Hive
  Future<void> _saveCart() async {
    try {
      print('💾 Saving cart to Hive...');
      
      // Clear box first
      await _cartBox.clear();
      
      // Save all items with menuId as key
      for (var item in cartItems) {
        await _cartBox.put(item.menuId, item);
      }
      
      print('✅ Cart saved: ${cartItems.length} items');
      
    } catch (e) {
      print('❌ Error saving cart: $e');
    }
  }

  // Computed properties
  int get totalItems => cartItems.fold(0, (sum, item) => sum + item.quantity);
  
  double get subtotalPrice => cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
  
  double get totalPrice {
    final subtotal = subtotalPrice;
    final total = subtotal - promoDiscount.value;
    return total < 0 ? 0 : total;
  }

  // Add item to cart
  void addToCart(MenuModel menu, {int quantity = 1}) {
    print('➕ Adding to cart: ${menu.nama} x$quantity');
    
    final index = cartItems.indexWhere((item) => item.menuId == menu.id);
    
    if (index != -1) {
      cartItems[index].quantity += quantity;
      print('   Updated quantity: ${cartItems[index].quantity}');
      cartItems.refresh();
    } else {
      cartItems.add(CartItemModel.fromMenu(menu, quantity: quantity));
      print('   Added new item');
    }
    
    _saveCart();
  }

  // Update quantity
  void updateQuantity(int menuId, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(menuId);
      return;
    }
    
    final index = cartItems.indexWhere((item) => item.menuId == menuId);
    if (index != -1) {
      cartItems[index].quantity = newQuantity;
      cartItems.refresh();
      _saveCart();
    }
  }

  // Increase quantity
  void increaseQuantity(int menuId) {
    final index = cartItems.indexWhere((item) => item.menuId == menuId);
    if (index != -1) {
      cartItems[index].quantity++;
      cartItems.refresh();
      _saveCart();
    }
  }

  // Decrease quantity
  void decreaseQuantity(int menuId) {
    final index = cartItems.indexWhere((item) => item.menuId == menuId);
    if (index != -1) {
      if (cartItems[index].quantity > 1) {
        cartItems[index].quantity--;
        cartItems.refresh();
        _saveCart();
      } else {
        removeFromCart(menuId);
      }
    }
  }

  // Remove item from cart
  void removeFromCart(int menuId) {
    print('🗑️ Removing item from cart: menuId=$menuId');
    cartItems.removeWhere((item) => item.menuId == menuId);
    _saveCart();
  }

  // Clear all cart
  void clearCart() {
    print('🧹 Clearing all cart items');
    cartItems.clear();
    removePromo();
    _saveCart();
  }

  // Apply promo code
  Future<bool> applyPromo(String code, double discountAmount, double minPurchase) async {
    try {
      // Validasi minimal pembelian
      if (subtotalPrice < minPurchase) {
        Get.snackbar(
          'Promo Tidak Berlaku',
          'Minimal pembelian Rp ${_formatCurrency(minPurchase)} untuk menggunakan promo ini',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return false;
      }

      appliedPromoCode.value = code;
      promoDiscount.value = discountAmount;
      
      Get.snackbar(
        'Promo Berhasil Diterapkan',
        'Anda hemat Rp ${_formatCurrency(discountAmount)}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      
      return true;
    } catch (e) {
      print('❌ Error applying promo: $e');
      return false;
    }
  }

  // Remove promo
  void removePromo() {
    appliedPromoCode.value = null;
    promoDiscount.value = 0.0;
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '\${m[1]}.');
  }

  // Get quantity of specific item
  int getItemQuantity(int menuId) {
    final index = cartItems.indexWhere((item) => item.menuId == menuId);
    return index != -1 ? cartItems[index].quantity : 0;
  }

  // Check if item exists in cart
  bool isInCart(int menuId) {
    return cartItems.any((item) => item.menuId == menuId);
  }

  // Save order to Supabase
  Future<String?> saveOrderToSupabase({String paymentMethod = 'cash', String? note}) async {
    try {
      if (cartItems.isEmpty) {
        throw Exception('Keranjang kosong');
      }

      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Anda harus login terlebih dahulu untuk melakukan pemesanan');
      }

      // 1. Insert order header
      // Note: Jika tabel orders belum memiliki kolom promo_code dan promo_discount,
      // silakan jalankan migration SQL berikut di Supabase:
      // ALTER TABLE orders ADD COLUMN promo_code TEXT;
      // ALTER TABLE orders ADD COLUMN promo_discount NUMERIC(10,2) DEFAULT 0;
      
      final orderData = {
        'user_id': user.id,
        'total_items': totalItems,
        'total_price': totalPrice,
        'status': 'paid',
        'payment_method': paymentMethod,
        'note': note,
      };
      
      // Tambahkan promo jika kolom sudah ada di database
      // Untuk sementara, promo hanya digunakan di frontend
      // Uncomment baris berikut setelah menambahkan kolom di database:
      if (appliedPromoCode.value != null) {
       orderData['promo_code'] = appliedPromoCode.value;
       orderData['promo_discount'] = promoDiscount.value;
     }

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
          'menu_id': item.menuId,
          'menu_nama': item.menuNama,
          'menu_kategori': item.menuKategori,
          'menu_harga': item.menuHarga,
          'quantity': item.quantity,
          'subtotal': item.subtotal,
        };
      }).toList();

      await _supabase.from('order_items').insert(orderItemsData);

      // Clear cart after successful payment
      clearCart();

      return orderId;
    } on SocketException catch (e) {
      print('❌ No Internet Connection: $e');
      throw Exception('Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.');
    } on PostgrestException catch (e) {
      print('❌ Postgrest error: ${e.message}');
      throw Exception('Error database: ${e.message}');
    } catch (e) {
      print('❌ Error saving order to Supabase: $e');
      rethrow;
    }
  }

  @override
  void onClose() {
    print('🔴 CartController onClose() called');
    super.onClose();
  }
}