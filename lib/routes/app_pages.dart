import 'package:get/get.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/login/views/register_view.dart';
import '../modules/menu/bindings/menu_binding.dart';
import '../modules/menu/views/menu_view.dart';
import '../modules/cart/bindings/cart_binding.dart';
import '../modules/cart/views/cart_view.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    // LOGIN PAGE
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),

    // REGISTER PAGE
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: LoginBinding(),
    ),

    // MENU PAGE
    GetPage(
      name: AppRoutes.menu,
      page: () => const MenuView(),
      binding: MenuBinding(),
    ),
    GetPage(
      name: AppRoutes.cart,
      page: () => const CartView(),
      binding: CartBinding(),
    ),
  ];
}
