import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import '../modules/menu/models/menu_model.dart';

class ApiService {
  static const String baseUrl =
      'https://68fce98b96f6ff19b9f6afe8.mockapi.io/Almera';
  static const String menuEndpoint = '/menu';

  // ===========================
  // HTTP - Async-Await
  // ===========================
  Future<Map<String, dynamic>> getMenuWithDetailHttp() async {
    final urlMenu = Uri.parse('$baseUrl$menuEndpoint');

    try {
      final startTimeMenu = DateTime.now();

      print('📤 HTTP REQUEST [Menu List]');
      print('➡ URL: $urlMenu');
      print('➡ Headers: {Content-Type: application/json}');

      // First API call - get menu list
      final response = await http.get(
        urlMenu,
        headers: {'Content-Type': 'application/json'},
      );

      final endTimeMenu = DateTime.now();
      final durationMenu = endTimeMenu.difference(startTimeMenu).inMilliseconds;

      print('\n📥 HTTP RESPONSE [Menu List]');
      print('✅ Status Code: ${response.statusCode}');
      print('⏱ Duration: ${durationMenu / 1000} seconds');
      // print('📦 Body: ${response.body}'); // Opsional: tampilkan body

      if (response.statusCode != 200) {
        throw Exception('Gagal memuat menu: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      List menusData = [];
      if (data is List) {
        menusData = data;
      } else if (data is Map && data.containsKey('data')) {
        final inner = data['data'];
        if (inner is List) menusData = inner;
      }

      final List<MenuModel> menus =
          menusData.map((item) => MenuModel.fromJson(item)).toList();

      // Second API call - get detail for first menu
      MenuModel? menuDetail;
      if (menus.isNotEmpty) {
        final urlDetail = Uri.parse('$baseUrl$menuEndpoint/${menus[0].id}');
        final startTimeDetail = DateTime.now();

        print('\n\n📤 HTTP REQUEST [Menu Detail]');
        print('➡ URL: $urlDetail');
        print('➡ Headers: {Content-Type: application/json}');

        final detailResponse = await http.get(
          urlDetail,
          headers: {'Content-Type': 'application/json'},
        );

        final endTimeDetail = DateTime.now();
        final durationDetail =
            endTimeDetail.difference(startTimeDetail).inMilliseconds;

        print('\n📥 HTTP RESPONSE [Menu Detail]');
        print('✅ Status Code: ${detailResponse.statusCode}');
        print('⏱ Duration: ${durationDetail / 1000} seconds');
        // print('📦 Body: ${detailResponse.body}'); // Opsional: tampilkan body

        if (detailResponse.statusCode == 200) {
          final detailData = json.decode(detailResponse.body);
          menuDetail = MenuModel.fromJson(detailData);
        }
      }

      return {
        'menuList': menus,
        'selectedMenu': menuDetail,
      };
    } on DioException catch (e) {
      print('❌ Dio ERROR: ${e.type} - ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Koneksi timeout. Jaringan Anda mungkin lambat.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.');
      } else if (e.response != null) {
        throw Exception('Error dari server: ${e.response?.statusCode}');
      } else {
        throw Exception('Gagal terhubung ke server. Periksa koneksi internet Anda.');
      }
    } on SocketException catch (e) {
      print('❌ No Internet Connection: $e');
      throw Exception('Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.');
    } on TimeoutException catch (e) {
      print('❌ Request Timeout: $e');
      throw Exception('Koneksi timeout. Jaringan Anda mungkin lambat.');
    } on FormatException catch (e) {
      print('❌ Format Error: $e');
      throw Exception('Format data tidak valid dari server.');
    } catch (e) {
      print('❌ Dio ERROR: $e');
      throw Exception('Error in Dio chained request: $e');
    }
  }

  // ===========================
  // HTTP - Callback
  // ===========================
  void getMenuWithDetailCallbackHttp({
    required Function(Map<String, dynamic>) onSuccess,
    required Function(String) onError,
  }) {
    final urlMenu = Uri.parse('$baseUrl$menuEndpoint');
    final startTimeMenu = DateTime.now();

    print('📤 HTTP REQUEST [Menu List - Callback]');
    print('➡ URL: $urlMenu');
    print('➡ Headers: {Content-Type: application/json}');

    http.get(urlMenu, headers: {'Content-Type': 'application/json'}).then(
        (response) {
      final endTimeMenu = DateTime.now();
      final durationMenu = endTimeMenu.difference(startTimeMenu).inMilliseconds;

      print('\n📥 HTTP RESPONSE [Menu List - Callback]');
      print('✅ Status Code: ${response.statusCode}');
      print('⏱ Duration: ${durationMenu / 1000} seconds');
      // print('📦 Body: ${response.body}'); // Opsional: tampilkan body

      if (response.statusCode != 200) {
        onError('Failed to get menu list: ${response.statusCode}');
        return;
      }

      try {
        final data = json.decode(response.body);
        List menusData = [];
        if (data is List) {
          menusData = data;
        } else if (data is Map && data.containsKey('data')) {
          final inner = data['data'];
          if (inner is List) menusData = inner;
        }

        final menus =
            menusData.map((item) => MenuModel.fromJson(item)).toList();

        if (menus.isNotEmpty) {
          final urlDetail = Uri.parse('$baseUrl$menuEndpoint/${menus[0].id}');
          final startTimeDetail = DateTime.now();

          print('\n\n📤 HTTP REQUEST [Menu Detail - Callback]');
          print('➡ URL: $urlDetail');
          print('➡ Headers: {Content-Type: application/json}');

          http.get(urlDetail, headers: {
            'Content-Type': 'application/json'
          }).then((detailResponse) {
            final endTimeDetail = DateTime.now();
            final durationDetail =
                endTimeDetail.difference(startTimeDetail).inMilliseconds;

            print('\n📥 HTTP RESPONSE [Menu Detail - Callback]');
            print('✅ Status Code: ${detailResponse.statusCode}');
            print('⏱ Duration: ${durationDetail / 1000} seconds');
            // print('📦 Body: ${detailResponse.body}'); // Opsional: tampilkan body

            if (detailResponse.statusCode == 200) {
              final detailData = json.decode(detailResponse.body);
              final menuDetail = MenuModel.fromJson(detailData);
              onSuccess({
                'menuList': menus,
                'selectedMenu': menuDetail,
              });
            } else {
              onError(
                  'Failed to get menu detail: ${detailResponse.statusCode}');
            }
          }).catchError((e) {
            onError('Error getting menu detail: $e');
          });
        } else {
          onSuccess({'menuList': menus, 'selectedMenu': null});
        }
      } catch (e) {
        onError('Error processing menu list: $e');
      }
    }).catchError((e) {
      print('❌ HTTP ERROR: $e');
      onError('Error getting menu list: $e');
    });
  }

  // ===========================
  // Dio - Async-Await
  // ===========================
  Future<Map<String, dynamic>> getMenuWithDetail() async {
    try {
      final dio = Dio();
      dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ));
      final response = await dio.get('$baseUrl$menuEndpoint');

      if (response.statusCode != 200) {
        throw Exception('Gagal memuat menu: ${response.statusCode}');
      }

      final data = response.data;
      List menusData = [];
      if (data is List) {
        menusData = data;
      } else if (data is Map && data.containsKey('data')) {
        final inner = data['data'];
        if (inner is List) menusData = inner;
      }

      final menus = menusData.map((item) => MenuModel.fromJson(item)).toList();

      MenuModel? menuDetail;
      if (menus.isNotEmpty) {
        final detailResponse =
            await dio.get('$baseUrl$menuEndpoint/${menus[3].id}');
        if (detailResponse.statusCode == 200) {
          menuDetail = MenuModel.fromJson(detailResponse.data);
        }
      }

      return {'menuList': menus, 'selectedMenu': menuDetail};
    } on DioException catch (e) {
      print('❌ Dio ERROR: ${e.type} - ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Koneksi timeout. Jaringan Anda mungkin lambat.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.');
      } else if (e.response != null) {
        throw Exception('Error dari server: ${e.response?.statusCode}');
      } else {
        throw Exception('Gagal terhubung ke server. Periksa koneksi internet Anda.');
      }
    } on SocketException catch (e) {
      print('❌ No Internet Connection: $e');
      throw Exception('Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.');
    } on TimeoutException catch (e) {
      print('❌ Request Timeout: $e');
      throw Exception('Koneksi timeout. Jaringan Anda mungkin lambat.');
    } on FormatException catch (e) {
      print('❌ Format Error: $e');
      throw Exception('Format data tidak valid dari server.');
    } catch (e) {
      throw Exception('Error in Dio chained request: $e');
    }
  }

  // ===========================
  // Dio - Callback
  // ===========================
  void getMenuWithDetailCallback({
    required Function(Map<String, dynamic>) onSuccess,
    required Function(String) onError,
  }) {
    final dio = Dio();
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));

    dio.get('$baseUrl$menuEndpoint').then((response) {
      if (response.statusCode != 200) {
        onError('Failed to get menu list: ${response.statusCode}');
        return;
      }

      try {
        final data = response.data;
        List menusData = [];
        if (data is List) {
          menusData = data;
        } else if (data is Map && data.containsKey('data')) {
          final inner = data['data'];
          if (inner is List) menusData = inner;
        }

        final menus =
            menusData.map((item) => MenuModel.fromJson(item)).toList();

        if (menus.isNotEmpty) {
          dio
              .get('$baseUrl$menuEndpoint/${menus[3].id}')
              .then((detailResponse) {
            if (detailResponse.statusCode == 200) {
              final menuDetail = MenuModel.fromJson(detailResponse.data);
              onSuccess({'menuList': menus, 'selectedMenu': menuDetail});
            } else {
              onError(
                  'Failed to get menu detail: ${detailResponse.statusCode}');
            }
          }).catchError((e) {
            onError('Error getting menu detail: $e');
          });
        } else {
          onSuccess({'menuList': menus, 'selectedMenu': null});
        }
      } catch (e) {
        onError('Error processing menu list: $e');
      }
    }).catchError((e) {
      print('❌ Dio Callback ERROR: $e');
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout || 
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          onError('Koneksi timeout. Jaringan Anda mungkin lambat.');
        } else if (e.type == DioExceptionType.connectionError) {
          onError('Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.');
        } else {
          onError('Gagal terhubung ke server. Periksa koneksi internet Anda.');
        }
      } else if (e is SocketException) {
        onError('Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.');
      } else {
        onError('Error getting menu list: $e');
      }
    });
  }
}
