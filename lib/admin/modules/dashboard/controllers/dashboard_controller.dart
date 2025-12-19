import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:warung_makan/services/admin_api_service.dart';

class DashboardController extends GetxController {
  final AdminApiService _api = AdminApiService();

  var isLoading = false.obs;
  var totalMenu = 0.obs;
  var totalPromo = 0.obs;
  var adminName = 'Admin'.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
    loadAdminName();
  }

  Future<void> loadDashboard() async {
    try {
      isLoading.value = true;
      totalMenu.value = await _api.getTotalMenu();
      totalPromo.value = await _api.getTotalPromo();
    } catch (_) {
      // optional: error handling
    } finally {
      isLoading.value = false;
    }
  }

  void loadAdminName() {
    final user = Supabase.instance.client.auth.currentUser;
    adminName.value = user?.userMetadata?['name'] ?? 'Admin';
  }
}
