import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService extends GetxService {
  late final SupabaseClient client;

  Future<SupabaseService> init() async {
    try {
      // Load environment variables with better error handling
      if (kDebugMode) {
        debugPrint('Loading .env file...');
      }

      final supabaseUrl = dotenv.env['SUPABASE_URL'];
      final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

      if (supabaseUrl == null || supabaseUrl.isEmpty) {
        throw Exception(
          'SUPABASE_URL not found in .env file\n'
          'Please add: SUPABASE_URL=your_url',
        );
      }

      if (supabaseAnonKey == null || supabaseAnonKey.isEmpty) {
        throw Exception(
          'SUPABASE_ANON_KEY not found in .env file\n'
          'Please add: SUPABASE_ANON_KEY=your_key',
        );
      }

      if (kDebugMode) {
        debugPrint('Initializing Supabase...');
      }

      await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

      client = Supabase.instance.client;

      if (kDebugMode) {
        debugPrint('Supabase initialized successfully');
        debugPrint('URL: $supabaseUrl');
      }

      return this;
    } on SocketException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ No Internet Connection: $e');
      }
      throw Exception(
          'Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.');
    } catch (e) {
      if (e.toString().contains('FileSystemException') ||
          e.toString().contains('.env')) {
        throw Exception(
          '.env file not found!\n\n'
          'Please create a .env file in the root directory with:\n'
          'SUPABASE_URL=your_supabase_url\n'
          'SUPABASE_ANON_KEY=your_anon_key\n\n'
          'You can copy from .env.example if available.',
        );
      }
      rethrow;
    }
  }

  // Auth helpers
  User? get currentUser => client.auth.currentUser;
  Session? get currentSession => client.auth.currentSession;
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  // Database helpers
  SupabaseQueryBuilder from(String table) => client.from(table);
  SupabaseStorageClient get storage => client.storage;

  String? get accessToken {
    return client.auth.currentSession?.accessToken;
  }

  bool get isAuthenticated {
    return client.auth.currentSession != null;
  }
}
