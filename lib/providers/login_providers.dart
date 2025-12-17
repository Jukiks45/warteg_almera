import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' show ClientException;
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
      debugPrint('🔐 Attempting login for: $email');
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      debugPrint('✅ Login successful');
      return response.user;
    } on AuthException catch (e) {
      debugPrint('❌ Auth Error: ${e.message}');
      // Provide more user-friendly messages
      if (e.message.contains('Invalid login credentials')) {
        throw Exception('Email atau password salah. Silakan coba lagi.');
      } else if (e.message.contains('Email not confirmed')) {
        throw Exception('Email belum diverifikasi. Cek inbox Anda.');
      } else if (e.message.contains('User not found')) {
        throw Exception('Akun tidak ditemukan. Silakan register terlebih dahulu.');
      } else {
        throw Exception(e.message);
      }
    } on ClientException catch (e) {
      debugPrint('❌ ClientException (Network Error): $e');
      throw Exception('Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.');
    } on SocketException catch (e) {
      debugPrint('❌ SocketException (No Internet): $e');
      throw Exception('Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.');
    } catch (e) {
      debugPrint('❌ Unexpected Login Error: $e');
      debugPrint('❌ Error Type: ${e.runtimeType}');
      // Check if error message contains connection-related keywords
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('clientexception') ||
          errorStr.contains('socket') || 
          errorStr.contains('network') || 
          errorStr.contains('connection') ||
          errorStr.contains('host lookup') ||
          errorStr.contains('failed host') ||
          errorStr.contains('no address associated')) {
        throw Exception('Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.');
      }
      throw Exception('Login gagal: ${e.toString()}');
    }
  }

  Future<User?> register(String email, String password) async {
    try {
      debugPrint('📝 Attempting registration for: $email');
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      debugPrint('✅ Registration successful');
      return response.user;
    } on AuthException catch (e) {
      debugPrint('❌ Auth Error: ${e.message}');
      // Provide more user-friendly messages
      if (e.message.contains('User already registered')) {
        throw Exception('Email sudah terdaftar. Silakan login.');
      } else if (e.message.contains('Password should be at least')) {
        throw Exception('Password terlalu lemah. Minimal 6 karakter.');
      } else if (e.message.contains('Invalid email')) {
        throw Exception('Format email tidak valid.');
      } else {
        throw Exception(e.message);
      }
    } on ClientException catch (e) {
      debugPrint('❌ ClientException (Network Error): $e');
      throw Exception('Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.');
    } on SocketException catch (e) {
      debugPrint('❌ SocketException (No Internet): $e');
      throw Exception('Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.');
    } catch (e) {
      debugPrint('❌ Unexpected Register Error: $e');
      debugPrint('❌ Error Type: ${e.runtimeType}');
      // Check if error message contains connection-related keywords
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('clientexception') ||
          errorStr.contains('socket') || 
          errorStr.contains('network') || 
          errorStr.contains('connection') ||
          errorStr.contains('host lookup') ||
          errorStr.contains('failed host') ||
          errorStr.contains('no address associated')) {
        throw Exception('Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.');
      }
      throw Exception('Registrasi gagal: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } on SocketException catch (e) {
      debugPrint('⚠️ No Internet during logout: $e');
      // Continue to clear local session even if network fails
    } catch (e) {
      debugPrint('⚠️ Logout Error: $e');
      // Continue to clear local session
    } finally {
      // Clear session from shared preferences
      final authSession = Get.find<AuthSessionService>();
      await authSession.clearSession();
    }
  }
}
