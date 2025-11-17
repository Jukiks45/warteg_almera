import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cart_item_model.dart';
import '../../menu/models/menu_model.dart';

class CartController extends GetxController {
  // --- BAGIAN YANG DIUBAH (INTEGRASI HIVE) ---
  late Box<CartItemModel> cartBox;
  final cartItems = <CartItemModel>[].obs; // Ini sekarang menjadi 'cermin' data di DB
  
  // --- BAGIAN ASLI ANDA (TIDAK DIUBAH) ---
  final _supabase = Supabase.instance.client;

  @override
  void onInit() {
    super.onInit();
    // Inisialisasi dan muat data dari database lokal
    cartBox = Hive.box<CartItemModel>('cart_items');
    loadCartItemsFromDb();
  }

  // Fungsi baru untuk sinkronisasi
  void loadCartItemsFromDb() {
    cartItems.assignAll(cartBox.values.toList());
  }

  // --- BAGIAN ASLI ANDA (TIDAK DIUBAH) ---
  int get totalItems => cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => cartItems.fold(0.0, (sum, item) => sum + item.subtotal);

  // --- FUNGSI YANG DIMODIFIKASI UNTUK MENYIMPAN KE DB LOKAL ---

  void addToCart(MenuModel menu, {int quantity = 1}) {
    final existingItem = cartItems.firstWhereOrNull((item) => item.menu.id == menu.id);
    
    if (existingItem != null) {
      increaseQuantity(menu.id, count: quantity);
    } else {
      final newItem = CartItemModel(menu: menu, quantity: quantity);
      cartBox.add(newItem); // Simpan ke DB
      loadCartItemsFromDb(); // Update UI
    }
  }

  void increaseQuantity(int menuId, {int count = 1}) {
    final item = cartItems.firstWhere((item) => item.menu.id == menuId);
    item.quantity += count;
    item.save(); // Simpan perubahan ke DB
    cartItems.refresh();
  }

  void decreaseQuantity(int menuId) {
    final item = cartItems.firstWhere((item) => item.menu.id == menuId);
    if (item.quantity > 1) {
      item.quantity--;
      item.save(); // Simpan perubahan ke DB
      cartItems.refresh();
    } else {
      removeFromCart(menuId);
    }
  }

  void removeFromCart(int menuId) {
    final itemToRemove = cartItems.firstWhere((item) => item.menu.id == menuId);
    itemToRemove.delete(); // Hapus dari DB
    loadCartItemsFromDb(); // Update UI
  }

  void clearCart() {
    cartBox.clear(); // Kosongkan DB
    loadCartItemsFromDb(); // Update UI
  }

  // --- BAGIAN ASLI ANDA (TIDAK DIUBAH) ---
  int getItemQuantity(int menuId) {
    final index = cartItems.indexWhere((item) => item.menu.id == menuId);
    return index != -1 ? cartItems[index].quantity : 0;
  }

  bool isInCart(int menuId) {
    return cartItems.any((item) => item.menu.id == menuId);
  }

  // --- BAGIAN ASLI ANDA (HANYA DITAMBAH clearCart() di akhir) ---
  Future<String?> saveOrderToSupabase({String paymentMethod = 'cash', String? note}) async {
    try {
      if (cartItems.isEmpty) {
        throw Exception('Keranjang kosong');
      }
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Anda harus login terlebih dahulu untuk melakukan pemesanan');
      }
      final orderData = {
        'user_id': user.id,
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

      // Setelah order berhasil, kosongkan keranjang lokal
      clearCart();

      return orderId;
    } catch (e) {
      print('Error saving order to Supabase: $e');
      rethrow;
    }
  }
}
