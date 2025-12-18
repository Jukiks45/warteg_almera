import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../dashboard/controllers/dashboard_controller.dart';

class AdminProfileController extends GetxController {
  final supabase = Supabase.instance.client;

  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final currentPasswordC = TextEditingController();
  final newPasswordC = TextEditingController();
  final confirmPasswordC = TextEditingController();

  var isLoading = false.obs;
  var isChangingPassword = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  void loadProfile() {
    final user = supabase.auth.currentUser;
    if (user != null) {
      nameC.text = user.userMetadata?['name'] ?? '';
      emailC.text = user.email ?? '';
    }
  }

  Future<void> updateProfile() async {
    if (nameC.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Nama tidak boleh kosong',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      await supabase.auth.updateUser(
        UserAttributes(
          data: {
            'name': nameC.text.trim(),
          },
        ),
      );
      await supabase.auth.refreshSession();

      // Trigger dashboard refresh to update the admin name
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().loadAdminName();
      }

      Get.snackbar(
        'Sukses',
        'Profil berhasil diperbarui',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memperbarui profil: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  

  Future<void> updateEmail() async {
    if (emailC.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Email tidak boleh kosong',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      await supabase.auth.updateUser(
        UserAttributes(
          email: emailC.text.trim(),
        ),
      );

      Get.snackbar(
        'Sukses',
        'Email berhasil diperbarui. Silakan cek email untuk verifikasi.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memperbarui email: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changePassword() async {
    // Validation
    if (newPasswordC.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Password baru tidak boleh kosong',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (newPasswordC.text.length < 6) {
      Get.snackbar(
        'Error',
        'Password minimal 6 karakter',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (newPasswordC.text != confirmPasswordC.text) {
      Get.snackbar(
        'Error',
        'Konfirmasi password tidak cocok',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isChangingPassword.value = true;

      await supabase.auth.updateUser(
        UserAttributes(
          password: newPasswordC.text,
        ),
      );

      // Clear password fields
      currentPasswordC.clear();
      newPasswordC.clear();
      confirmPasswordC.clear();

      Get.snackbar(
        'Sukses',
        'Password berhasil diperbarui',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengubah password: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isChangingPassword.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await supabase.auth.signOut();
      Get.offAllNamed('/login'); // Navigate to login page
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal logout: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    nameC.dispose();
    emailC.dispose();
    currentPasswordC.dispose();
    newPasswordC.dispose();
    confirmPasswordC.dispose();
    super.onClose();
  }
}
