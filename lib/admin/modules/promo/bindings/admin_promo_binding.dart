import 'package:get/get.dart';
import '../controllers/admin_promo_controller.dart';

class AdminPromoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminPromoController>(() => AdminPromoController());
  }
}
