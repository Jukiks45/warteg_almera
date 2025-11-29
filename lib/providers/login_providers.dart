import 'dart:io';
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
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user;
    } on SocketException catch (e) {
      print('❌ No Internet Connection: $e');
      throw Exception('Tidak ada koneksi internet. Periksa koneksi Anda.');
    } on AuthException catch (e) {
      print('❌ Auth Error: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      print('❌ Login Error: $e');
      rethrow;
    }
  }

  Future<User?> register(String email, String password) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      return response.user;
    } on SocketException catch (e) {
      print('❌ No Internet Connection: $e');
      throw Exception('Tidak ada koneksi internet. Periksa koneksi Anda.');
    } on AuthException catch (e) {
      print('❌ Auth Error: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      print('❌ Register Error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } on SocketException catch (e) {
      print('⚠️ No Internet during logout: $e');
      // Continue to clear local session even if network fails
    } catch (e) {
      print('⚠️ Logout Error: $e');
      // Continue to clear local session
    } finally {
      // Clear session from shared preferences
      final authSession = Get.find<AuthSessionService>();
      await authSession.clearSession();
    }
  }
}
