import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import '../modules/menu/models/menu_model.dart';

class ApiService {
  static const String baseUrl = 'https://68fce98b96f6ff19b9f6afe8.mockapi.io/Almera';
  static const String menuEndpoint = '/menu';

  // Metode 1: Menggunakan async-await dengan HTTP
  Future<List<dynamic>> getMenuWithHttp() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$menuEndpoint'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) return data;
        if (data is Map && data.containsKey('data')) {
          final inner = data['data'];
          if (inner is List) return inner;
        }
        return [];
      } else {
        throw Exception('Gagal memuat menu: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error saat mengambil data: $e');
    }
  }

  // Metode 2: Menggunakan async-await dengan Dio
  Future<List<dynamic>> getMenuWithDio() async {
    try {
      final dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      ));

      dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
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

  // Implementasi 1: Chained Request dengan async-await
  Future<Map<String, dynamic>> getMenuWithDetail() async {
    try {
      // First API call - get menu list
      final menuList = await getMenuWithDio();
      final List<MenuModel> menus = menuList
          .map((item) => MenuModel.fromJson(item))
          .toList();

      // Second API call - get detail for first menu
      if (menus.isNotEmpty) {
        final detailResponse = await Dio().get('$baseUrl$menuEndpoint/${menus[0].id}');
        if (detailResponse.statusCode == 200) {
          final menuDetail = MenuModel.fromJson(detailResponse.data);
          return {
            'menuList': menus,
            'selectedMenu': menuDetail,
          };
        }
      }

      return {
        'menuList': menus,
        'selectedMenu': null,
      };
    } catch (e) {
      throw Exception('Error in chained request: $e');
    }
  }

  // Implementasi 2: Chained Request dengan callback
  void getMenuWithDetailCallback({
    required Function(Map<String, dynamic>) onSuccess,
    required Function(String) onError,
  }) {
    getMenuWithDio().then((menuList) {
      try {
        final menus = menuList
            .map((item) => MenuModel.fromJson(item))
            .toList();
        
        if (menus.isNotEmpty) {
          Dio().get('$baseUrl$menuEndpoint/${menus[0].id}')
              .then((detailResponse) {
            if (detailResponse.statusCode == 200) {
              final menuDetail = MenuModel.fromJson(detailResponse.data);
              onSuccess({
                'menuList': menus,
                'selectedMenu': menuDetail,
              });
            } else {
              onError('Failed to get menu detail: ${detailResponse.statusCode}');
            }
          }).catchError((error) {
            onError('Error getting menu detail: $error');
          });
        } else {
          onSuccess({
            'menuList': menus,
            'selectedMenu': null,
          });
        }
      } catch (e) {
        onError('Error processing menu data: $e');
      }
    }).catchError((error) {
      onError('Error getting menu list: $error');
    });
  }

  // Helper method untuk mendapatkan detail menu by ID
  Future<MenuModel?> getMenuDetail(int id) async {
    try {
      final response = await Dio().get('$baseUrl$menuEndpoint/$id');
      if (response.statusCode == 200) {
        return MenuModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting menu detail: $e');
    }
  }
}