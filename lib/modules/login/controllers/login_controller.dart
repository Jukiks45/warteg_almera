import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class LoginController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  
  var isLoading = false.obs;
  var obscurePassword = true.obs;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    // Validasi input
    if (username.isEmpty) {
      Get.snackbar(
        'Error',
        'Username tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
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
    super.onClose();
  }
}