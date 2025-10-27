import 'package:get/get.dart';
import '../models/menu_model.dart';
import '../../../services/api_service.dart';

class MenuController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  var isLoading = false.obs;
  var isError = false.obs;
  var errorMessage = ''.obs;
  var listMenu = <MenuModel>[].obs;
  var filteredMenu = <MenuModel>[].obs;
  var selectedCategory = 'Semua'.obs;

  // Daftar kategori untuk filter
  var categories = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchMenus();
  }

  /// Fetch data menu dari API
  /// Gunakan salah satu metode: HTTP atau Dio
  Future<void> fetchMenus() async {
    final stopwatch = Stopwatch()..start(); // ⏱ Start timing

    try {
      isLoading.value = true;
      isError.value = false;
      errorMessage.value = '';

      final raw = await _apiService.getMenuWithHttp();

      stopwatch.stop(); // ⏱ Stop timing
      final responseTime = stopwatch.elapsedMilliseconds / 1000;

      // ✅ Show popup dialog with response time
      Get.defaultDialog(
        title: 'Response Time',
        middleText: 'Loaded in ${responseTime.toStringAsFixed(2)} seconds ✅',
        textConfirm: 'Close',
        onConfirm: () => Get.back(),
      );

      final menus = raw.map((json) => MenuModel.fromJson(json)).toList();

      listMenu.value = menus;
      filteredMenu.value = List<MenuModel>.from(menus);

      final uniqueCategories =
          menus.map((menu) => menu.kategori).toSet().toList();
      categories.value = ['Semua', ...uniqueCategories];

      isLoading.value = false;
    } catch (e) {
      stopwatch.stop();
      isLoading.value = false;
      isError.value = true;
      errorMessage.value = e.toString();

      // ✅ Show popup for error speed too
      Get.defaultDialog(
        title: 'Error',
        middleText:
            'Failed in ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} seconds ❌\n\n$e',
        textConfirm: 'Close',
        onConfirm: () => Get.back(),
      );

      Get.snackbar(
        'Error',
        'Gagal memuat data menu: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Filter menu berdasarkan kategori
  void filterByCategory(String category) {
    selectedCategory.value = category;

    if (category == 'Semua') {
      filteredMenu.value = List<MenuModel>.from(listMenu);
    } else {
      filteredMenu.value =
          listMenu.where((menu) => menu.kategori == category).toList();
    }
  }

  /// Refresh data menu
  Future<void> refreshMenus() async {
    await fetchMenus();
  }

  /// Backwards-compatible API used by views
  Future<void> refreshData() async {
    await fetchMenus();
  }
}
