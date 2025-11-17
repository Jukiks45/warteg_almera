import 'package:get/get.dart';
import '../../../services/api_service.dart';
import '../controllers/menu_controller.dart';
import '../../cart/controllers/cart_controller.dart';

class MenuBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiService>(() => ApiService());
    Get.lazyPut<MenuController>(() => MenuController());
    Get.lazyPut<CartController>(() => CartController());
  }
}