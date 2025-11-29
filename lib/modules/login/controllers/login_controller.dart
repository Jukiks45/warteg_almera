import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_session_service.dart';
import '/providers/login_providers.dart';

class LoginController extends GetxController {
  final LoginProviders _provider = Get.find<LoginProviders>();

  // --- Login Controllers ---
  final usernameController = TextEditingController(); // email sebenarnya
  final passwordController = TextEditingController();

  // --- Register Controllers ---
  final regEmailController = TextEditingController();
  final regUsernameController =
      TextEditingController(); // optional, for your DB
  final regPasswordController = TextEditingController();
  final regConfirmPasswordController = TextEditingController();

  // UI State
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
    
        final authSession = Get.find<AuthSessionService>();
        await authSession.saveSession(
          userId: user.id,
          email: user.email ?? email,
        );
        
        _success("Login berhasil!");
        Get.offNamed(AppRoutes.menu);
      } else {
        _error("Login gagal. User tidak ditemukan.");
      }
    } on Exception catch (e) {
      isLoading.value = false;
      final cleanMessage = e.toString().replaceAll("Exception: ", "");
      print('❌ Login error: $cleanMessage');
      _error(cleanMessage);
    } catch (e) {
      isLoading.value = false;
      print('❌ Unexpected login error: $e');
      _error("Terjadi kesalahan tidak terduga");
    }
  }

  // ---------------------------------------------------------------------------
  //                                 REGISTER
  // ---------------------------------------------------------------------------
  Future<void> register() async {
    final email = regEmailController.text.trim();
    final username = regUsernameController.text.trim();
    final password = regPasswordController.text.trim();
    final confirmPassword = regConfirmPasswordController.text.trim();

    if (email.isEmpty) return _error("Email tidak boleh kosong");
    if (!email.contains("@")) return _error("Format email tidak valid");
    if (username.isEmpty) return _error("Username tidak boleh kosong");
    if (password.isEmpty) return _error("Password tidak boleh kosong");
    if (password.length < 6) return _error("Password minimal 6 karakter");
    if (confirmPassword.isEmpty)
      return _error("Konfirmasi password harus diisi");
    if (password != confirmPassword)
      return _error("Password dan konfirmasi tidak sama");

    isLoading.value = true;

    try {
      print('📝 Attempting registration for: $email');
      final user = await _provider.register(email, password);

      isLoading.value = false;

      if (user != null) {
        print('✅ Registration successful for: $email');
        _success("Registrasi berhasil! Silakan login.");
        Get.back();
      } else {
        _error("Registrasi gagal. Coba lagi.");
      }
    } on Exception catch (e) {
      isLoading.value = false;
      final cleanMessage = e.toString().replaceAll("Exception: ", "");
      print('❌ Registration error: $cleanMessage');
      _error(cleanMessage);
    } catch (e) {
      isLoading.value = false;
      print('❌ Unexpected registration error: $e');
      _error("Terjadi kesalahan tidak terduga");
    }
  }

  // ---------------------------------------------------------------------------
  //                              Snackbars
  // ---------------------------------------------------------------------------
  void _error(String message) {
    Get.snackbar(
      "Error",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void _success(String message) {
    Get.snackbar(
      "Sukses",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
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