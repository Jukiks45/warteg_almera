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

      final user = response.user;

      if (user != null) {
        debugPrint('✅ Login successful, syncing profiles...');
        
        // Menggunakan upsert agar jika ID sudah ada, data tetap aman (tidak duplikat)
        await _client.from('profiles').upsert({
          'id': user.id,
          'email': user.email,
          'updated_at': DateTime.now().toIso8601String(),
        }, onConflict: 'id');

        debugPrint('✅ Sync profiles berhasil.');
      }

      return user;
    } on AuthException catch (e) {
      debugPrint('❌ Auth Error: ${e.message}');
      if (e.message.contains('Invalid login credentials')) {
        throw Exception('Email atau password salah.');
      } else if (e.message.contains('Email not confirmed')) {
        throw Exception('Email belum diverifikasi. Cek inbox Anda.');
      } else {
        throw Exception(e.message);
      }
    } catch (e) {
      debugPrint('❌ Login Error: $e');
      // Jika terjadi error koneksi, lempar pesan koneksi
      if (e.toString().toLowerCase().contains('socket') || 
          e.toString().toLowerCase().contains('connection')) {
        throw Exception('Tidak ada koneksi internet.');
      }
      throw Exception('Login gagal: $e');
    }
  }

  Future<User?> register(String email, String password) async {
    try {
      debugPrint('📝 Attempting registration for: $email');
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user != null) {
        debugPrint('✅ Registration successful, inserting into profiles...');
        // Pastikan nama tabel benar: profiles
        await _client.from('profiles').insert({
          'id': user.id,
          'email': user.email,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
      return user;
    } on AuthException catch (e) {
      debugPrint('❌ Auth Error: ${e.message}');
      if (e.message.contains('already registered')) {
        throw Exception('Email sudah terdaftar. Silakan login.');
      } else {
        throw Exception(e.message);
      }
    } catch (e) {
      debugPrint('❌ Register Error: $e');
      throw Exception('Registrasi gagal.');
    }
  }

  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      debugPrint('⚠️ Logout Error: $e');
    } finally {
      final authSession = Get.find<AuthSessionService>();
      await authSession.clearSession();
    }
  }
}