import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../admin/modules/menu/models/admin_menu_model.dart';

class AdminApiService {
  final Dio _dio = Dio();

  static const String baseUrl =
      'https://vnlmwajtxirlzibojplw.supabase.co/rest/v1';
  static const String menuEndpoint = '/API_Menu';

  Map<String, String> get _headers => {
        'apikey': dotenv.env['API_KEY']!,
        'Authorization': 'Bearer ${dotenv.env['API_KEY']}',
        'Content-Type': 'application/json',
      };

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
        throw Exception('Gagal mengambil menu admin');
      }

      final data = response.data as List;

      return data
          .map((e) => AdminMenuModel.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('AdminApiService.getMenus → $e');
    }
  }
}
