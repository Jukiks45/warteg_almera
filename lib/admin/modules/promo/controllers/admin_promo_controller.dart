import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/admin_promo_model.dart';
import '../../../../services/admin_api_service.dart';
import '../../../../services/supabase_service.dart';
import '../../../../constant/admin_constants.dart';
import '../../../../services/exceptions.dart';
import '../../dashboard/controllers/dashboard_controller.dart';

class AdminPromoController extends GetxController {
  final AdminApiService _api = AdminApiService();
  final SupabaseService _supabase = Get.find<SupabaseService>();

  var isLoading = false.obs;
  var promoList = <AdminPromoModel>[].obs;
  var errorMessage = ''.obs;

  // ===== ADMIN CHECK =====
  bool get isAdmin => AdminGuard.isAdmin(_supabase);

  void clearError() => errorMessage.value = '';

  @override
  void onInit() {
    super.onInit();
    fetchPromos();
  }

  Future<void> fetchPromos() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      promoList.assignAll(await _api.getPromos());
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan tidak terduga';
    } finally {
      isLoading.value = false;
    }
  }

  // ===== FORM CONTROLLERS =====
  final titleC = TextEditingController();
  final descC = TextEditingController();
  final codeC = TextEditingController();
  final discountC = TextEditingController();
  final minPurchaseC = TextEditingController();
  final maxUsageC = TextEditingController();
  final maxUsagePerUserC = TextEditingController();

  final validFrom = Rxn<DateTime>();
  final validUntil = Rxn<DateTime>();
  final isActive = true.obs;

  final isEdit = false.obs;
  AdminPromoModel? editingPromo;

  void resetForm() {
    isEdit.value = false;
    editingPromo = null;

    titleC.clear();
    descC.clear();
    codeC.clear();
    discountC.clear();
    minPurchaseC.clear();
    maxUsageC.clear();
    maxUsagePerUserC.clear();

    validFrom.value = null;
    validUntil.value = null;
    isActive.value = true;
  }

  void setEditPromo(AdminPromoModel promo) {
    isEdit.value = true;
    editingPromo = promo;

    titleC.text = promo.title;
    descC.text = promo.description;
    codeC.text = promo.promoCode;
    discountC.text = promo.discountAmount.toStringAsFixed(0);
    minPurchaseC.text = promo.minPurchase.toStringAsFixed(0);
    maxUsageC.text = promo.maxUsage?.toString() ?? '';
    maxUsagePerUserC.text = promo.maxUsagePerUser?.toString() ?? '';

    validFrom.value = promo.validFrom;
    validUntil.value = promo.validUntil;
    isActive.value = promo.isActive;
  }

  // ===== INSERT =====
  Future<void> insertPromo() async {
    if (!isAdmin) {
      Get.snackbar(
        'Akses Ditolak',
        'Hanya admin yang dapat menambah promo',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      await _api.insertPromo({
        'title': titleC.text,
        'description': descC.text,
        'promo_code': codeC.text,
        'discount_amount': int.parse(discountC.text),
        'min_purchase': int.parse(minPurchaseC.text),
        'valid_from': validFrom.value!.toIso8601String(),
        'valid_until': validUntil.value!.toIso8601String(),
        'max_usage': maxUsageC.text.isEmpty ? null : int.parse(maxUsageC.text),
        'max_usage_per_user': maxUsagePerUserC.text.isEmpty
            ? null
            : int.parse(maxUsagePerUserC.text),
        'is_active': isActive.value,
      });

      // Refresh dashboard
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().loadDashboard();
      }

      Get.back();
      resetForm();
      fetchPromos();

      Get.snackbar(
        'Sukses',
        'Promo berhasil ditambahkan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on ApiException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan tidak terduga',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ===== UPDATE =====
  Future<void> updatePromo() async {
    if (!isAdmin || editingPromo == null) {
      Get.snackbar(
        'Akses Ditolak',
        'Hanya admin yang dapat mengubah promo',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Confirm dialog for updates
    final confirmed = await Get.defaultDialog<bool>(
      title: 'Konfirmasi Update',
      middleText: 'Yakin ingin memperbarui promo "${editingPromo!.title}"?',
      textCancel: 'Batal',
      textConfirm: 'Update',
      confirmTextColor: Colors.white,
      buttonColor: Colors.blue,
      onConfirm: () => Get.back(result: true),
      onCancel: () => Get.back(result: false),
    );

    if (!(confirmed ?? false)) return;

    try {
      isLoading.value = true;

      await _api.updatePromo(editingPromo!.id, {
        'title': titleC.text,
        'description': descC.text,
        'promo_code': codeC.text,
        'discount_amount': int.parse(discountC.text),
        'min_purchase': int.parse(minPurchaseC.text),
        'valid_from': validFrom.value!.toIso8601String(),
        'valid_until': validUntil.value!.toIso8601String(),
        'max_usage': maxUsageC.text.isEmpty ? null : int.parse(maxUsageC.text),
        'max_usage_per_user': maxUsagePerUserC.text.isEmpty
            ? null
            : int.parse(maxUsagePerUserC.text),
        'is_active': isActive.value,
      });

      // Refresh dashboard
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().loadDashboard();
      }

      Get.back();
      resetForm();
      fetchPromos();

      Get.snackbar(
        'Sukses',
        'Promo berhasil diperbarui',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on ApiException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan tidak terduga',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ===== DELETE =====
  Future<void> deletePromo(AdminPromoModel promo) async {
    if (!isAdmin) {
      Get.snackbar(
        'Akses Ditolak',
        'Hanya admin yang dapat menghapus promo',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      await _api.deletePromo(promo.id);

      // Refresh dashboard
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().loadDashboard();
      }

      promoList.removeWhere((p) => p.id == promo.id);

      Get.snackbar(
        'Sukses',
        'Promo berhasil dihapus',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on ApiException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    titleC.dispose();
    descC.dispose();
    codeC.dispose();
    discountC.dispose();
    minPurchaseC.dispose();
    maxUsageC.dispose();
    maxUsagePerUserC.dispose();
    super.onClose();
  }
}
