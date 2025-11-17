import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../routes/app_routes.dart';
import '/providers/login_providers.dart';

class LoginController extends GetxController {
  final LoginProviders _provider = Get.find<LoginProviders>();

  // --- Login Controllers ---
  final usernameController = TextEditingController(); // email sebenarnya
  final passwordController = TextEditingController();
  
  var isLoading = false.obs;
  var obscurePassword = true.obs;
  var obscureRegisterPassword = true.obs;
  var obscureRegisterConfirmPassword = true.obs;

  // Toggle login password visibility
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  // Toggle register password visibility
  void toggleRegPasswordVisibility() {
    obscureRegisterPassword.value = !obscureRegisterPassword.value;
  }

  // Toggle register confirm password visibility
  void toggleRegConfirmPasswordVisibility() {
    obscureRegisterConfirmPassword.value =
        !obscureRegisterConfirmPassword.value;
  }

  // ---------------------------------------------------------------------------
  //                                 LOGIN
  // ---------------------------------------------------------------------------
  Future<void> login() async {
    final email = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty) return _error("Email tidak boleh kosong");
    if (!email.contains("@")) return _error("Format email tidak valid");

    if (password.isEmpty) return _error("Password tidak boleh kosong");

    isLoading.value = true;

    try {
      final user = await _provider.login(email, password);

      isLoading.value = false;

      if (user != null) {
        _success("Login berhasil!");
        Get.offNamed(AppRoutes.menu);
      } else {
        _error("Login gagal. User tidak ditemukan.");
      }
    } catch (e) {
      isLoading.value = false;
      _error(e.toString().replaceAll("Exception: ", ""));
    }

    if (password.isEmpty) {
      Get.snackbar(
        'Error',
        'Password tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Simulasi proses login
    isLoading.value = true;

    await Future.delayed(const Duration(seconds: 2));

    // Simulasi validasi (username: admin, password: admin123)
    if (username == 'admin' && password == 'admin123') {
      isLoading.value = false;
      
      Get.snackbar(
        'Sukses',
        'Login berhasil!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigasi ke halaman menu dan hapus halaman login dari tumpukan
      Get.offNamed(AppRoutes.menu);
    } else {
      isLoading.value = false;
      
      Get.snackbar(
        'Error',
        'Username atau password salah',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    regEmailController.dispose();
    regUsernameController.dispose();
    regPasswordController.dispose();
    regConfirmPasswordController.dispose();
    super.onClose();
  }
}
