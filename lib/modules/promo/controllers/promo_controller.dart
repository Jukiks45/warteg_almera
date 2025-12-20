import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/promo_model.dart';
import '../views/promo_detail_view.dart';
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

    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      final promoId = args['promoId'];
      if (promoId != null) {
        _handlePromoFromNotification(promoId.toString());
      }
    }
  }

  /// Load semua promo dari Supabase
  Future<void> loadPromos() async {
    try {
      isLoading.value = true;
      promos.value = await _apiService.getActivePromos();
      debugPrint('Promo count after loading: ${promos.length}');
      for (final promo in promos) {
        debugPrint('PROMO ${promo.title} valid? ${promo.isValid}');
      }
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

  /// Handle promo dari notifikasi
  Future<void> _handlePromoFromNotification(String promoId) async {
    await loadPromoById(promoId);
    if (selectedPromo.value != null) {
      Get.off(
        () => PromoDetailView(promo: selectedPromo.value!),
        transition: Transition.fadeIn,
      );
    }
  }

  /// Refresh promo list
  Future<void> refreshPromos() async {
    await loadPromos();
  }
}
