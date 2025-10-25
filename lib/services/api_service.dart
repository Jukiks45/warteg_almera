import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class ApiService {
  static const String baseUrl = 'https://api.example.com';
  static const String menuEndpoint = '/menus';

  // Metode 1: Menggunakan package http
  Future<List<dynamic>> getMenuWithHttp() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$menuEndpoint'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
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
        return data['data'] ?? [];
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