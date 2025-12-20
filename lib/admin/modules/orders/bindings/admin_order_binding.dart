import 'package:get/get.dart';
import '../controllers/admin_order_controller.dart';

class AdminOrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminOrderController>(() => AdminOrderController());
  }
}
