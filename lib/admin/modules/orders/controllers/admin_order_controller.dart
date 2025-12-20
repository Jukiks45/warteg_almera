import 'package:get/get.dart';
import '../../../../services/admin_api_service.dart';
import '../models/admin_order_model.dart';

class AdminOrderController extends GetxController {
  final AdminApiService _api = Get.find<AdminApiService>();

  var orders = <AdminOrderModel>[].obs;
  var orderItems = <String, List<OrderItemModel>>{}.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;

      orders.value = await _api.getOrders();
      orderItems.clear();

      for (final order in orders) {
        final items = await _api.getOrderItems(order.id);
        orderItems[order.id] = items;
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _api.updateOrderStatus(orderId, status);
      fetchOrders();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  List<OrderItemModel> getItems(String orderId) {
    return orderItems[orderId] ?? [];
  }
}
