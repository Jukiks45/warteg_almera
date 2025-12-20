import 'package:get/get.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/login/views/register_view.dart';
import '../modules/menu/bindings/menu_binding.dart';
import '../modules/menu/views/menu_view.dart';
import '../modules/cart/bindings/cart_binding.dart';
import '../modules/cart/views/cart_view.dart';
import '../modules/order_history/bindings/order_history_binding.dart';
import '../modules/order_history/views/order_history_view.dart';
import '../modules/location/bindings/location_binding.dart';
import '../modules/location/views/location_view.dart';
import '../modules/promo/bindings/promo_binding.dart';
import '../modules/promo/views/promo_view.dart';
import '../admin/modules/dashboard/bindings/dashboard_binding.dart';
import '../admin/modules/dashboard/views/dashboard_view.dart';
import '../admin/modules/menu/bindings/admin_menu_binding.dart';
import '../admin/modules/menu/views/admin_menu_view.dart';
import '../admin/modules/menu/views/admin_menu_form_view.dart';
import '../admin/modules/promo/bindings/admin_promo_binding.dart';
import '../admin/modules/promo/views/admin_promo_view.dart';
import '../admin/modules/promo/views/admin_promo_form_view.dart';
import '../admin/modules/profiles/bindings/admin_profile_binding.dart';
import '../admin/modules/profiles/views/admin_profile_view.dart';
import '../admin/modules/orders/bindings/admin_order_binding.dart';
import '../admin/modules/orders/views/admin_order_view.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
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
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.orderHistory,
      page: () => const OrderHistoryView(),
      binding: OrderHistoryBinding(),
    ),
    GetPage(
      name: AppRoutes.lokasi,
      page: () => const LocationView(),
      binding: LocationBinding(),
    ),
    GetPage(
      name: AppRoutes.promo,
      page: () => const PromoView(),
      binding: PromoBinding(),
    ),
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.adminMenu,
      page: () => const AdminMenuView(),
      binding: AdminMenuBinding(),
    ),
    GetPage(
      name: AppRoutes.adminMenuForm,
      page: () => const AdminMenuFormView(),
      binding: AdminMenuBinding(),
    ),
    GetPage(
      name: AppRoutes.adminPromo,
      page: () => const AdminPromoView(),
      binding: AdminPromoBinding(),
    ),
    GetPage(
      name: AppRoutes.adminPromoForm,
      page: () => const AdminPromoFormView(),
      binding: AdminPromoBinding(),
    ),
    GetPage(
      name: AppRoutes.adminOrders,
      page: () => const AdminOrderView(),
      binding: AdminOrderBinding(),
    ),
    GetPage(
      name: AppRoutes.adminProfile,
      page: () => const AdminProfileView(),
      binding: AdminProfileBinding(),
    ),
  ];
}
