import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import '../../../providers/login_providers.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // DO NOT initialize SupabaseService here.
    // It is initialized in main.dart and registered globally.

    Get.lazyPut<LoginProviders>(() => LoginProviders());
    Get.lazyPut<LoginController>(() => LoginController());
  }
}
