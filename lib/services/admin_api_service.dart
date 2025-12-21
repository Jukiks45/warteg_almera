import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart' hide Response;
import '../admin/modules/menu/models/admin_menu_model.dart';
import '../admin/modules/promo/models/admin_promo_model.dart';
import '../admin/modules/orders/models/admin_order_model.dart' show AdminOrderModel, OrderItemModel;
import 'supabase_service.dart';
import 'exceptions.dart';

class AdminApiService {
  final Dio _dio = Dio();
  final SupabaseService _supabase = Get.find<SupabaseService>();

  static const String baseUrl =
      'https://vnlmwajtxirlzibojplw.supabase.co/rest/v1';
  static const String menuEndpoint = '/API_Menu';
  static const String promoEndpoint = '/promos';

  Map<String, String> get _headers {
    final token = _supabase.accessToken;

    if (token == null) {
      throw Exception('User belum login');
    }

    return {
      'apikey': dotenv.env['API_KEY']!,
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Prefer': 'count=exact,return=minimal',
    };
  }

  // ==========================
  // GET TOTAL MENU
  // ==========================
  Future<int> getTotalMenu() async {
    try {
      final response = await _dio.get(
        '$baseUrl$menuEndpoint?select=id&limit=0',
        options: Options(headers: _headers),
      );

      return _extractCount(response);
    } catch (e) {
      throw ApiException('Gagal mengambil total menu');
    }
  }

  // ==========================
  // GET TOTAL PROMO
  // ==========================
  Future<int> getTotalPromo() async {
    try {
      final response = await _dio.get(
        '$baseUrl$promoEndpoint?select=id&limit=0',
        options: Options(headers: _headers),
      );

      return _extractCount(response);
    } catch (e) {
      throw ApiException('Gagal mengambil total promo');
    }
  }

  // ==========================
  // GET ADMIN MENU
  // ==========================
  Future<List<AdminMenuModel>> getMenus() async {
    try {
      final response = await _dio.get(
        '$baseUrl$menuEndpoint',
        options: Options(headers: _headers),
      );

      if (response.statusCode != 200) {
        throw ApiException('Gagal mengambil menu admin',
            statusCode: response.statusCode);
      }

      final data = response.data as List;

      return data.map((e) => AdminMenuModel.fromJson(e)).toList();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('AdminApiService.getMenus → $e');
    }
  }

  // ==========================
  // GET ADMIN PROMO
  // ==========================
  Future<List<AdminPromoModel>> getPromos() async {
    try {
      final response = await _dio.get(
        '$baseUrl$promoEndpoint?deleted_at=is.null',
        options: Options(headers: _headers),
      );

      if (response.statusCode != 200) {
        throw ApiException('Gagal mengambil promo admin',
            statusCode: response.statusCode);
      }

      final data = response.data as List;

      return data.map((e) => AdminPromoModel.fromJson(e)).toList();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('AdminApiService.getPromos → $e');
    }
  }

  // ==========================
  // INSERT PROMO
  // ==========================
  Future<void> insertPromo(Map<String, dynamic> promoData) async {
    try {
      // Refresh token untuk pastikan masih valid
      await _supabase.client.auth.refreshSession();

      if (kDebugMode) {
        debugPrint('✅ Token refreshed');
        debugPrint('📧 Current user: ${_supabase.currentUser?.email}');
        debugPrint('📨 Promo data: $promoData');
      }

      final response = await _dio.post(
        '$baseUrl$promoEndpoint',
        data: promoData,
        options: Options(headers: _headers),
      );

      if (response.statusCode != 201) {
        throw ApiException(
          'Gagal menambah promo (Status: ${response.statusCode}) - ${response.data}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DioException: ${e.response?.statusCode}');
        debugPrint('📋 Response: ${e.response?.data}');
        debugPrint('🔑 Headers sent: $_headers');
      }
      throw ApiException(
        'Error INSERT Promo: ${e.response?.statusCode} - ${e.response?.data}',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('AdminApiService.insertPromo → $e');
    }
  }

  // ==========================
  // UPDATE PROMO
  // ==========================
  Future<void> updatePromo(
      String promoId, Map<String, dynamic> promoData) async {
    try {
      final response = await _dio.patch(
        '$baseUrl$promoEndpoint?id=eq.$promoId',
        data: promoData,
        options: Options(headers: _headers),
      );

      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300) {
        throw ApiException('Gagal update promo',
            statusCode: response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('AdminApiService.updatePromo → $e');
    }
  }

  // ==========================
  // INSERT MENU
  // ==========================
  Future<void> insertMenu(Map<String, dynamic> menuData) async {
    try {
      final response = await _dio.post(
        '$baseUrl$menuEndpoint',
        data: menuData,
        options: Options(headers: _headers),
      );

      if (response.statusCode != 201) {
        throw ApiException(
          'Gagal menambah menu (Status: ${response.statusCode}) - ${response.data}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ApiException(
        'Error INSERT Menu: ${e.response?.statusCode} - ${e.response?.data}',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('AdminApiService.insertMenu → $e');
    }
  }

  // ==========================
  // UPDATE MENU
  // ==========================
  Future<void> updateMenu(int menuId, Map<String, dynamic> menuData) async {
    try {
      final response = await _dio.patch(
        '$baseUrl$menuEndpoint?id=eq.$menuId',
        data: menuData,
        options: Options(headers: _headers),
      );

      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300) {
        throw ApiException('Gagal update menu',
            statusCode: response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('AdminApiService.updateMenu → $e');
    }
  }

  // ==========================
  // DELETE MENU
  // ==========================
  Future<void> deleteMenu(int menuId) async {
    try {
      final response = await _dio.delete(
        '$baseUrl$menuEndpoint?id=eq.$menuId',
        options: Options(headers: _headers),
      );

      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300) {
        throw ApiException('Gagal hapus menu', statusCode: response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('AdminApiService.deleteMenu → $e');
    }
  }

  // ==========================
  // DELETE PROMO
  // ==========================
  Future<void> deletePromo(String promoId) async {
    try {
      final response = await _dio.delete(
        '$baseUrl$promoEndpoint?id=eq.$promoId',
        options: Options(headers: _headers),
      );

      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300) {
        throw ApiException(
          'Gagal menghapus promo',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('AdminApiService.deletePromo → $e');
    }
  }

  // ==========================
  // GET ADMIN ORDERS
  // ==========================
  Future<List<AdminOrderModel>> getOrders() async {
    try {
      final response = await _dio.get(
        '$baseUrl/orders?order=created_at.desc',
        options: Options(headers: _headers),
      );

      if (response.statusCode != 200) {
        throw ApiException(
          'Gagal mengambil orders',
          statusCode: response.statusCode,
        );
      }

      final data = response.data as List;
      return data.map((e) => AdminOrderModel.fromJson(e)).toList();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('AdminApiService.getOrders → $e');
    }
  }

  // ==========================
  // UPDATE ORDER STATUS
  // ==========================
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      final response = await _dio.patch(
        '$baseUrl/orders?id=eq.$orderId',
        data: {
          'status': status,
        },
        options: Options(headers: _headers),
      );

      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300) {
        throw ApiException(
          'Gagal update status order',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('AdminApiService.updateOrderStatus → $e');
    }
  }

  // ==========================
  // GET ORDER ITEMS BY ORDER ID
  // ==========================
  Future<List<OrderItemModel>> getOrderItems(String orderId) async {
    try {
      final response = await _dio.get(
        '$baseUrl/order_items?order_id=eq.$orderId',
        options: Options(headers: _headers),
      );

      if (response.statusCode != 200) {
        throw ApiException(
          'Gagal mengambil order items',
          statusCode: response.statusCode,
        );
      }

      final data = response.data as List;
      return data.map((e) => OrderItemModel.fromJson(e)).toList();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('AdminApiService.getOrderItems → $e');
    }
  }

  int _extractCount(Response response) {
    final contentRange = response.headers.value('content-range');
    if (contentRange == null) return 0;

    final total = contentRange.split('/').last;
    return int.tryParse(total) ?? 0;
  }
}
