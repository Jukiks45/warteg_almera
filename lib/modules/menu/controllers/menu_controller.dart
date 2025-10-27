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
  var selectedMenu = Rxn<MenuModel>();

  // Daftar kategori untuk filter
  var categories = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchMenuWithDetail(); // Changed to use chained request
  }

  // Implementasi 1: Async-await untuk chained request
  Future<void> fetchMenuWithDetail() async {
    final stopwatch = Stopwatch()..start();

    try {
      isLoading.value = true;
      isError.value = false;
      errorMessage.value = '';

      final result = await _apiService.getMenuWithDetail();
      
      stopwatch.stop();
      final responseTime = stopwatch.elapsedMilliseconds / 1000;

      // Show response time dialog
      Get.defaultDialog(
        title: 'Response Time',
        middleText: 'Loaded in ${responseTime.toStringAsFixed(2)} seconds ✅',
        textConfirm: 'Close',
        onConfirm: () => Get.back(),
      );

      // Update state with results
      listMenu.value = result['menuList'];
      selectedMenu.value = result['selectedMenu'];
      filteredMenu.value = List<MenuModel>.from(listMenu);

      // Update categories
      final uniqueCategories = 
          listMenu.map((menu) => menu.kategori).toSet().toList();
      categories.value = ['Semua', ...uniqueCategories];

    } catch (e) {
      stopwatch.stop();
      isError.value = true;
      errorMessage.value = e.toString();

      // Show error dialog
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
    } finally {
      isLoading.value = false;
    }
  }

  // Implementasi 2: Callback untuk chained request
  void fetchMenuWithDetailCallback() {
    final stopwatch = Stopwatch()..start();
    isLoading.value = true;
    isError.value = false;
    errorMessage.value = '';

    _apiService.getMenuWithDetailCallback(
      onSuccess: (result) {
        stopwatch.stop();
        
        // Update state with results
        listMenu.value = result['menuList'];
        selectedMenu.value = result['selectedMenu'];
        filteredMenu.value = List<MenuModel>.from(listMenu);

        // Update categories
        final uniqueCategories = 
            listMenu.map((menu) => menu.kategori).toSet().toList();
        categories.value = ['Semua', ...uniqueCategories];

        // Show success dialog
        Get.defaultDialog(
          title: 'Response Time',
          middleText: 
              'Loaded in ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} seconds ✅',
          textConfirm: 'Close',
          onConfirm: () => Get.back(),
        );

        isLoading.value = false;
      },
      onError: (error) {
        stopwatch.stop();
        
        isError.value = true;
        errorMessage.value = error;

        // Show error dialog
        Get.defaultDialog(
          title: 'Error',
          middleText: 
              'Failed in ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} seconds ❌\n\n$error',
          textConfirm: 'Close',
          onConfirm: () => Get.back(),
        );

        Get.snackbar(
          'Error',
          'Gagal memuat data menu: $error',
          snackPosition: SnackPosition.BOTTOM,
        );

        isLoading.value = false;
      },
    );
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
    await fetchMenuWithDetail(); // Changed to use chained request
  }

  /// Backwards-compatible API used by views
  Future<void> refreshData() async {
    await fetchMenuWithDetail(); // Changed to use chained request
  }
}