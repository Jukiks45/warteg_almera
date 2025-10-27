import 'dart:convert';
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
    try {
      // First API call - get menu list
      final response = await http.get(
        Uri.parse('$baseUrl$menuEndpoint'),
        headers: {'Content-Type': 'application/json'},
      );

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
        final detailResponse = await http.get(
          Uri.parse('$baseUrl$menuEndpoint/${menus[3].id}'),
          headers: {'Content-Type': 'application/json'},
        );
        if (detailResponse.statusCode == 200) {
          final detailData = json.decode(detailResponse.body);
          menuDetail = MenuModel.fromJson(detailData);
        }
      }

      return {
        'menuList': menus,
        'selectedMenu': menuDetail,
      };
    } catch (e) {
      throw Exception('Error in HTTP chained request: $e');
    }
  }

  // ===========================
  // HTTP - Callback
  // ===========================
  void getMenuWithDetailCallbackHttp({
    required Function(Map<String, dynamic>) onSuccess,
    required Function(String) onError,
  }) {
    http.get(Uri.parse('$baseUrl$menuEndpoint'),
        headers: {'Content-Type': 'application/json'}).then((response) {
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
          http.get(Uri.parse('$baseUrl$menuEndpoint/${menus[3].id}'), headers: {
            'Content-Type': 'application/json'
          }).then((detailResponse) {
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
      onError('Error getting menu list: $e');
    });
  }
}
