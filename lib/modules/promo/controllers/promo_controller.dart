import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/promo_model.dart';
import '../../../services/api_service.dart';

class PromoController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final RxList<PromoModel> promos = <PromoModel>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<PromoModel?> selectedPromo = Rx<PromoModel?>(null);

  @override
  void onInit() {
    super.onInit();
    loadPromos();
  }

  /// Load semua promo dari Supabase
  Future<void> loadPromos() async {
    try {
      isLoading.value = true;
      promos.value = await _apiService.getActivePromos();
    } catch (e) {
      debugPrint('Error loading promos: $e');
      Get.snackbar(
        'Error',
        'Gagal memuat promo',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load promo berdasarkan ID (dari notifikasi)
  Future<void> loadPromoById(String promoId) async {
    try {
      isLoading.value = true;
      selectedPromo.value = await _apiService.getPromoById(promoId);
      if (selectedPromo.value == null) {
        Get.snackbar(
          'Error',
          'Promo tidak ditemukan',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint('Error loading promo: $e');
      Get.snackbar(
        'Error',
        'Promo tidak ditemukan',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh promo list
  Future<void> refreshPromos() async {
    await loadPromos();
  }
}
