import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/menu_model.dart';
import '../../../services/api_service.dart';

class MenuController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  var isLoading = false.obs;
  var isError = false.obs;
  var errorMessage = ''.obs;

  var listMenu = <MenuModel>[].obs;
  var selectedMenu = Rxn<MenuModel>();

  @override
  void onInit() {
    super.onInit();
    fetchMenus();
  }

  Future<void> fetchMenus() async {
    try {
      isLoading.value = true;
      isError.value = false;
      errorMessage.value = '';

      listMenu.value = await _apiService.getMenus();

      // Set first menu as selected by default
      if (listMenu.isNotEmpty) {
        selectedMenu.value = listMenu.first;
      }
    } catch (e) {
      isError.value = true;
      errorMessage.value = e.toString();

      Get.snackbar(
        'Error',
        'Gagal memuat menu',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMenuById(int id) async {
    try {
      isLoading.value = true;
      selectedMenu.value = await _apiService.getMenuById(id);

      if (selectedMenu.value == null) {
        Get.snackbar(
          'Error',
          'Menu tidak ditemukan',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint('Error loading menu: $e');
      Get.snackbar(
        'Error',
        'Gagal memuat detail menu',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshMenus() async {
    await fetchMenus();
  }
}
