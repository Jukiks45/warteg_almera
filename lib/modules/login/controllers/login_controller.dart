import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../routes/app_routes.dart';

class LoginController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final _supabase = Supabase.instance.client;
  
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

    isLoading.value = true;

    try {
      // Login ke Supabase Auth menggunakan email format
      // Format: username@warteg.com (atau bisa custom domain)
      final email = '$username@warteg.com';
      
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        isLoading.value = false;
        
        Get.snackbar(
          'Sukses',
          'Login berhasil sebagai $username!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Navigasi ke halaman menu
        Get.offNamed(AppRoutes.menu);
      }
    } on AuthException catch (e) {
      isLoading.value = false;
      
      // Handle auth errors
      String errorMessage = 'Login gagal';
      if (e.message.contains('Invalid login credentials')) {
        errorMessage = 'Username atau password salah';
      } else if (e.message.contains('Email not confirmed')) {
        errorMessage = 'Email belum dikonfirmasi';
      } else {
        errorMessage = e.message;
      }
      
      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      isLoading.value = false;
      
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
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