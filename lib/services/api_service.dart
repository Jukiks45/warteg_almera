import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import '../modules/menu/models/menu_model.dart';
import '../modules/promo/models/promo_model.dart';

class ApiService {
  static const String baseUrl =
      'https://vnlmwajtxirlzibojplw.supabase.co/rest/v1';

  static const String menuEndpoint = '/API_Menu';
  static const String promoEndpoint = '/promos';

  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {
          'apikey': dotenv.env['API_KEY']!,
          'Authorization': 'Bearer ${dotenv.env['API_KEY']}',
          'Content-Type': 'application/json',
        },
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  // ===========================
  // MENU API
  // ===========================

  Future<List<MenuModel>> getMenus() async {
    final response = await _dio.get(menuEndpoint);
    return (response.data as List)
        .map((e) => MenuModel.fromJson(e))
        .toList();
  }

  Future<MenuModel?> getMenuById(int id) async {
    final response = await _dio.get(
      menuEndpoint,
      queryParameters: {
        'id': 'eq.$id',
        'select': '*',
      },
    );

    final list = response.data as List;
    return list.isNotEmpty ? MenuModel.fromJson(list.first) : null;
  }

  // ===========================
  // PROMO API
  // ===========================

  Future<List<PromoModel>> getActivePromos() async {
    final response = await _dio.get(
      promoEndpoint,
      queryParameters: {
        'is_active': 'eq.true',
        'order': 'created_at.desc',
      },
    );

    return (response.data as List)
        .map((e) => PromoModel.fromJson(e))
        .toList();
  }

  Future<PromoModel?> getPromoById(String id) async {
    final response = await _dio.get(
      promoEndpoint,
      queryParameters: {
        'id': 'eq.$id',
        'select': '*',
      },
    );

    final list = response.data as List;
    return list.isNotEmpty ? PromoModel.fromJson(list.first) : null;
  }
}
