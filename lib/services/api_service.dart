import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class ApiService {
  // Base URL should be the API root. Keep endpoints separate to avoid
  // accidental duplication like .../menu/menu when combining baseUrl+endpoint.
  static const String baseUrl = 'https://68fce98b96f6ff19b9f6afe8.mockapi.io/Almera';
  static const String menuEndpoint = '/menu';

  // Metode 1: Menggunakan package http
  Future<List<dynamic>> getMenuWithHttp() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$menuEndpoint'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Some APIs return a top-level list, others wrap the list in a map
        // under the 'data' key. Handle both cases to be robust.
        if (data is List) {
          return data;
        } else if (data is Map && data.containsKey('data')) {
          final inner = data['data'];
          if (inner is List) return inner;
        }

        // If structure is unexpected, return empty list with clear message
        return [];
      } else {
        throw Exception('Gagal memuat menu: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error saat mengambil data: $e');
    }
  }

  // Metode 2: Menggunakan package dio
  Future<List<dynamic>> getMenuWithDio() async {
    try {
      final dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      ));

      final response = await dio.get(menuEndpoint);

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is List) return data;
        if (data is Map && data.containsKey('data')) {
          final inner = data['data'];
          if (inner is List) return inner;
        }

        return [];
      } else {
        throw Exception('Gagal memuat menu: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Koneksi timeout');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Receive timeout');
      } else {
        throw Exception('Error Dio: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error saat mengambil data: $e');
    }
  }
}