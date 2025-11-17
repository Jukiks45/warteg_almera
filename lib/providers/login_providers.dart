import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';

class LoginProviders extends GetxService {
  late final SupabaseClient _client;

  @override
  void onInit() {
    super.onInit();
    _client = Get.find<SupabaseService>().client;
  }

  /// Login with email & password
  Future<User?> login(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return response.user;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception("Unknown error: $e");
    }
  }

  /// Register a new user
  Future<User?> register(String email, String password) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      return response.user;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception("Unknown error: $e");
    }
  }

  /// Logout
  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
