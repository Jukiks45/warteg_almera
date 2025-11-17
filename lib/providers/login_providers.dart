import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../services/auth_session_service.dart';

class LoginProviders extends GetxService {
  late final SupabaseClient _client;

  @override
  void onReady() {
    _client = Get.find<SupabaseService>().client;
    super.onReady();
  }

  Future<User?> login(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response.user;
  }

  Future<User?> register(String email, String password) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );
    return response.user;
  }

  Future<void> logout() async {
    await _client.auth.signOut();
    
    // Clear session from shared preferences
    final authSession = Get.find<AuthSessionService>();
    await authSession.clearSession();
  }
}
