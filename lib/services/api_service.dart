import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import '../modules/menu/models/menu_model.dart';

class ApiService {
  static const String baseUrl =
      'https://vnlmwajtxirlzibojplw.supabase.co/rest/v1';
  static const String menuEndpoint = '/API_Menu';

  Map<String, String> get supabaseHeaders => {
        'apikey': dotenv.env['API_KEY']!,
        'Authorization': 'Bearer ${dotenv.env['API_KEY']}',
        'Content-Type': 'application/json',
      };
  // ===========================
  // HTTP - Async-Await
  // ===========================
  Future<Map<String, dynamic>> getMenuWithDetailHttp() async {
    final urlMenu = Uri.parse('$baseUrl$menuEndpoint');

    try {
      final startTimeMenu = DateTime.now();

      debugPrint('📤 HTTP REQUEST [Menu List]');
      debugPrint('➡ URL: $urlMenu');
      debugPrint('➡ Headers: {Content-Type: application/json}');

      // First API call - get menu list
      final response = await http.get(
        Uri.parse('$baseUrl$menuEndpoint'),
        headers: supabaseHeaders,
      );

      final endTimeMenu = DateTime.now();
      final durationMenu = endTimeMenu.difference(startTimeMenu).inMilliseconds;

      debugPrint('\n📥 HTTP RESPONSE [Menu List]');
      debugPrint('✅ Status Code: ${response.statusCode}');
      debugPrint('⏱ Duration: ${durationMenu / 1000} seconds');
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
        final urlDetail = Uri.parse(
          '$baseUrl$menuEndpoint?id=eq.${menus[0].id}&select=*',
        );
        final startTimeDetail = DateTime.now();

        debugPrint('\n\n📤 HTTP REQUEST [Menu Detail]');
        debugPrint('➡ URL: $urlDetail');
        debugPrint('➡ Headers: {Content-Type: application/json}');

        final detailResponse = await http.get(
          urlDetail,
          headers: supabaseHeaders,
        );

        final endTimeDetail = DateTime.now();
        final durationDetail =
            endTimeDetail.difference(startTimeDetail).inMilliseconds;

        debugPrint('\n📥 HTTP RESPONSE [Menu Detail]');
        debugPrint('✅ Status Code: ${detailResponse.statusCode}');
        debugPrint('⏱ Duration: ${durationDetail / 1000} seconds');
        // print('📦 Body: ${detailResponse.body}'); // Opsional: tampilkan body

        if (detailResponse.statusCode == 200) {
          final detailList = json.decode(detailResponse.body) as List;
          if (detailList.isNotEmpty) {
            menuDetail = MenuModel.fromJson(detailList.first);
          }
        }
      }

      return {
        'menuList': menus,
        'selectedMenu': menuDetail,
      };
    } on DioException catch (e) {
      debugPrint('❌ Dio ERROR: ${e.type} - ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Koneksi timeout. Jaringan Anda mungkin lambat.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
            'Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.');
      } else if (e.response != null) {
        throw Exception('Error dari server: ${e.response?.statusCode}');
      } else {
        throw Exception(
            'Gagal terhubung ke server. Periksa koneksi internet Anda.');
      }
    } on SocketException catch (e) {
      debugPrint('❌ No Internet Connection: $e');
      throw Exception(
          'Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.');
    } on TimeoutException catch (e) {
      debugPrint('❌ Request Timeout: $e');
      throw Exception('Koneksi timeout. Jaringan Anda mungkin lambat.');
    } on FormatException catch (e) {
      debugPrint('❌ Format Error: $e');
      throw Exception('Format data tidak valid dari server.');
    } catch (e) {
      debugPrint('❌ Dio ERROR: $e');
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

    debugPrint('📤 HTTP REQUEST [Menu List - Callback]');
    debugPrint('➡ URL: $urlMenu');
    debugPrint('➡ Headers: {Content-Type: application/json}');

    http.get(urlMenu, headers: supabaseHeaders).then((response) {
      final endTimeMenu = DateTime.now();
      final durationMenu = endTimeMenu.difference(startTimeMenu).inMilliseconds;

      debugPrint('\n📥 HTTP RESPONSE [Menu List - Callback]');
      debugPrint('✅ Status Code: ${response.statusCode}');
      debugPrint('⏱ Duration: ${durationMenu / 1000} seconds');
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
          final urlDetail = Uri.parse(
            '$baseUrl$menuEndpoint?id=eq.${menus[0].id}&select=*',
          );
          final startTimeDetail = DateTime.now();

          debugPrint('\n\n📤 HTTP REQUEST [Menu Detail - Callback]');
          debugPrint('➡ URL: $urlDetail');
          debugPrint('➡ Headers: {Content-Type: application/json}');

          http.get(urlDetail, headers: supabaseHeaders).then((detailResponse) {
            final endTimeDetail = DateTime.now();
            final durationDetail =
                endTimeDetail.difference(startTimeDetail).inMilliseconds;

            debugPrint('\n📥 HTTP RESPONSE [Menu Detail - Callback]');
            debugPrint('✅ Status Code: ${detailResponse.statusCode}');
            debugPrint('⏱ Duration: ${durationDetail / 1000} seconds');
            // print('📦 Body: ${detailResponse.body}'); // Opsional: tampilkan body

            if (detailResponse.statusCode == 200) {
              final detailList = json.decode(detailResponse.body) as List;
              if (detailList.isNotEmpty) {
                final menuDetail = MenuModel.fromJson(detailList.first);
                onSuccess({
                  'menuList': menus,
                  'selectedMenu': menuDetail,
                });
              } else {
                onError('Menu detail tidak ditemukan');
              }
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
      debugPrint('❌ HTTP ERROR: $e');
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
      final response = await dio.get(
        '$baseUrl$menuEndpoint',
        options: Options(headers: supabaseHeaders),
      );

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
      final index = menus.length > 3 ? 3 : 0;
      if (menus.isNotEmpty) {
        final detailResponse = await dio.get(
          '$baseUrl$menuEndpoint',
          queryParameters: {
            'id': 'eq.${menus[index].id}',
            'select': '*',
          },
          options: Options(headers: supabaseHeaders),
        );
        if (detailResponse.statusCode == 200 &&
            detailResponse.data is List &&
            detailResponse.data.isNotEmpty) {
          menuDetail = MenuModel.fromJson(detailResponse.data.first);
        }
      }

      return {'menuList': menus, 'selectedMenu': menuDetail};
    } on DioException catch (e) {
      debugPrint('❌ Dio ERROR: ${e.type} - ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Koneksi timeout. Jaringan Anda mungkin lambat.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
            'Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.');
      } else if (e.response != null) {
        throw Exception('Error dari server: ${e.response?.statusCode}');
      } else {
        throw Exception(
            'Gagal terhubung ke server. Periksa koneksi internet Anda.');
      }
    } on SocketException catch (e) {
      debugPrint('❌ No Internet Connection: $e');
      throw Exception(
          'Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.');
    } on TimeoutException catch (e) {
      debugPrint('❌ Request Timeout: $e');
      throw Exception('Koneksi timeout. Jaringan Anda mungkin lambat.');
    } on FormatException catch (e) {
      debugPrint('❌ Format Error: $e');
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

    dio
        .get(
      '$baseUrl$menuEndpoint',
      options: Options(headers: supabaseHeaders),
    )
        .then((response) {
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
        final index = menus.length > 3 ? 3 : 0;
        if (menus.isNotEmpty) {
          dio
              .get(
            '$baseUrl$menuEndpoint',
            queryParameters: {
              'id': 'eq.${menus[index].id}',
              'select': '*',
            },
            options: Options(headers: supabaseHeaders),
          )
              .then((detailResponse) {
            if (detailResponse.statusCode == 200 &&
                detailResponse.data is List &&
                detailResponse.data.isNotEmpty) {
              final menuDetail = MenuModel.fromJson(detailResponse.data.first);
              onSuccess({'menuList': menus, 'selectedMenu': menuDetail});
            } else {
              onError('Menu detail tidak ditemukan');
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
      debugPrint('❌ Dio Callback ERROR: $e');
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          onError('Koneksi timeout. Jaringan Anda mungkin lambat.');
        } else if (e.type == DioExceptionType.connectionError) {
          onError(
              'Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.');
        } else {
          onError('Gagal terhubung ke server. Periksa koneksi internet Anda.');
        }
      } else if (e is SocketException) {
        onError(
            'Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.');
      } else {
        onError('Error getting menu list: $e');
      }
    });
  }
}
