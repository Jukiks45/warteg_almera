import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:warung_makan/constant/admin_constants.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_session_service.dart';
import '../../../services/supabase_service.dart';
import '/providers/login_providers.dart';

class LoginController extends GetxController {
  final LoginProviders _provider = Get.find<LoginProviders>();
  final supabaseService = Get.find<SupabaseService>();

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
      debugPrint('🔐 Login attempt for: $email');
      final user = await _provider.login(email, password);

      isLoading.value = false;

      if (user != null) {
        final authSession = Get.find<AuthSessionService>();
        await authSession.saveSession(
          userId: user.id,
          email: user.email ?? email,
        );

        _success("Login berhasil!");
        if (supabaseService.currentUser?.id == AdminConstants.adminUid) {
          Get.offAllNamed(AppRoutes.adminDashboard);
        } else {
          Get.offAllNamed(AppRoutes.menu);
        }
      } else {
        _error("Login gagal. User tidak ditemukan.");
      }
    } on Exception catch (e) {
      isLoading.value = false;
      var cleanMessage = e.toString().replaceAll("Exception: ", "");
      debugPrint('❌ Login Exception: $cleanMessage');

      // Deteksi error connection-related
      final errorLower = cleanMessage.toLowerCase();
      if (errorLower.contains('clientexception') ||
          errorLower.contains('socketexception') ||
          errorLower.contains('socket') ||
          errorLower.contains('failed host lookup') ||
          errorLower.contains('host lookup') ||
          errorLower.contains('no address') ||
          errorLower.contains('network') ||
          errorLower.contains('connection')) {
        cleanMessage =
            "Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.";
      }

      _error(cleanMessage);
    } catch (e) {
      isLoading.value = false;
      debugPrint('❌ Unexpected login error: $e');
      debugPrint('❌ Error type: ${e.runtimeType}');

      // Deteksi error connection-related di catch umum
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('clientexception') ||
          errorStr.contains('socketexception') ||
          errorStr.contains('socket') ||
          errorStr.contains('failed host lookup') ||
          errorStr.contains('host lookup') ||
          errorStr.contains('no address') ||
          errorStr.contains('network') ||
          errorStr.contains('connection')) {
        _error(
            "Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.");
      } else {
        _error("Terjadi kesalahan tidak terduga");
      }
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
    if (confirmPassword.isEmpty) {
      return _error("Konfirmasi password harus diisi");
    }
    if (password != confirmPassword) {
      return _error("Password dan konfirmasi tidak sama");
    }

    isLoading.value = true;

    try {
      debugPrint('📝 Attempting registration for: $email');
      final user = await _provider.register(email, password);

      isLoading.value = false;

      if (user != null) {
        debugPrint('✅ Registration successful for: $email');
        _success("Registrasi berhasil! Silakan login.");
        Get.back();
      } else {
        _error("Registrasi gagal. Coba lagi.");
      }
    } on Exception catch (e) {
      isLoading.value = false;
      var cleanMessage = e.toString().replaceAll("Exception: ", "");
      debugPrint('❌ Registration Exception: $cleanMessage');

      // Deteksi error connection-related
      final errorLower = cleanMessage.toLowerCase();
      if (errorLower.contains('clientexception') ||
          errorLower.contains('socketexception') ||
          errorLower.contains('socket') ||
          errorLower.contains('failed host lookup') ||
          errorLower.contains('host lookup') ||
          errorLower.contains('no address') ||
          errorLower.contains('network') ||
          errorLower.contains('connection')) {
        cleanMessage =
            "Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.";
      }

      _error(cleanMessage);
    } catch (e) {
      isLoading.value = false;
      debugPrint('❌ Unexpected registration error: $e');
      debugPrint('❌ Error type: ${e.runtimeType}');

      // Deteksi error connection-related di catch umum
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('clientexception') ||
          errorStr.contains('socketexception') ||
          errorStr.contains('socket') ||
          errorStr.contains('failed host lookup') ||
          errorStr.contains('host lookup') ||
          errorStr.contains('no address') ||
          errorStr.contains('network') ||
          errorStr.contains('connection')) {
        _error(
            "Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.");
      } else {
        _error("Terjadi kesalahan tidak terduga");
      }
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
