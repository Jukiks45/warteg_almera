import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';
import '../models/order_item_model.dart';

class OrderHistoryController extends GetxController {
  final _supabase = Supabase.instance.client;
  
  var orders = <OrderModel>[].obs;
  var orderItems = <String, List<OrderItemModel>>{}.obs;
  var isLoading = false.obs;
  var isError = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  // Fetch orders from Supabase
  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      isError.value = false;
      errorMessage.value = '';

      final user = _supabase.auth.currentUser;
      if (user == null) {
        // User tidak login, set list kosong tanpa error
        orders.value = [];
        orderItems.clear();
        isLoading.value = false;
        return;
      }

      // Fetch orders
      final response = await _supabase
          .from('orders')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      // Safely parse response
      orders.value = (response as List)
          .map((json) {
            try {
              return OrderModel.fromJson(json as Map<String, dynamic>);
            } catch (e) {
              debugPrint('Error parsing order: $e');
              return null;
            }
          })
          .whereType<OrderModel>()
          .toList();

      // Fetch items for each order
      for (var order in orders) {
        await fetchOrderItems(order.id);
      }

      isLoading.value = false;
    } on SocketException catch (e) {
      isLoading.value = false;
      isError.value = true;
      errorMessage.value = 'Tidak ada koneksi internet. Periksa koneksi Anda.';
      debugPrint('❌ No Internet Connection: $e');
      orders.value = [];
      orderItems.clear();
    } catch (e) {
      isLoading.value = false;
      isError.value = true;
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      debugPrint('Error fetching orders: $e');
      // Set empty list on error
      orders.value = [];
      orderItems.clear();
    }
  }

  // Fetch order items
  Future<void> fetchOrderItems(String orderId) async {
    try {
      final response = await _supabase
          .from('order_items')
          .select()
          .eq('order_id', orderId);

      // Safely parse response
      orderItems[orderId] = (response as List)
          .map((json) {
            try {
              return OrderItemModel.fromJson(json as Map<String, dynamic>);
            } catch (e) {
              debugPrint('Error parsing order item: $e');
              return null;
            }
          })
          .whereType<OrderItemModel>()
          .toList();
    } on SocketException catch (e) {
      debugPrint('❌ No Internet Connection for order items: $e');
      orderItems[orderId] = [];
    } catch (e) {
      debugPrint('Error fetching order items for $orderId: $e');
      orderItems[orderId] = [];
    }
  }

  // Get items for specific order
  List<OrderItemModel> getOrderItems(String orderId) {
    return orderItems[orderId] ?? [];
  }

  // Format currency
  String formatCurrency(double amount) {
    try {
      final formatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );
      return formatter.format(amount);
    } catch (e) {
      // Fallback manual formatting
      return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      )}';
    }
  }

  // Format date
  String formatDate(DateTime date) {
    try {
      final formatter = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
      return formatter.format(date);
    } catch (e) {
      // Fallback manual formatting
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  // Refresh orders
  Future<void> refreshOrders() async {
    await fetchOrders();
  }
}
