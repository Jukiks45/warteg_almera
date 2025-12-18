import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import '../models/admin_menu_model.dart';
import '../../../../services/admin_api_service.dart';
import '../../../../services/supabase_service.dart';
import '../../../../constant/admin_constants.dart';

class AdminMenuController extends GetxController {
  final AdminApiService _api = AdminApiService();
  final SupabaseService _supabase = Get.find<SupabaseService>();
  var isLoading = false.obs;
  var menuList = <AdminMenuModel>[].obs;
  var errorMessage = ''.obs;
  final imageUrl = ''.obs;
  final pickedImage = Rx<File?>(null);

  static const String baseUrl =
      'https://vnlmwajtxirlzibojplw.supabase.co/rest/v1';
  static const String menuEndpoint = '/API_Menu';

  // ===== ADMIN CHECK =====
  bool get isAdmin {
    return _supabase.currentUser?.id == AdminConstants.adminUid;
  }

  // ===== ADMIN HEADERS =====
  Map<String, String> get adminHeaders {
    final token = _supabase.accessToken;

    if (token == null) {
      throw Exception('User belum login');
    }

    return {
      'apikey': dotenv.env['API_KEY']!,
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Prefer': 'return=representation',
    };
  }

  @override
  void onInit() {
    super.onInit();
    fetchMenus();
  }

  Future<void> fetchMenus() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _api.getMenus();
      menuList.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ===== INSERT MENU =====
  Future<void> insertMenu() async {
    if (!isAdmin) {
      Get.snackbar(
        'Akses Ditolak',
        'Hanya admin yang dapat menambah menu',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      String? imageUrl;

      if (pickedImage.value != null) {
        imageUrl = await uploadImageToStorage(pickedImage.value!);
      }

      final response = await http.post(
        Uri.parse('$baseUrl$menuEndpoint'),
        headers: adminHeaders,
        body: jsonEncode({
          'Nama': namaC.text,
          'Harga': int.parse(hargaC.text),
          'Kategori': kategori.value,
          'Deskripsi': deskripsiC.text,
          'Gambar': imageUrl,
        }),
      );

      if (response.statusCode == 201) {
        Get.back();
        resetForm();
        fetchMenus();

        Get.snackbar(
          'Sukses',
          'Menu berhasil ditambahkan',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw Exception('Gagal menambah menu: ${response.body}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ===== FORM CONTROLLERS =====
  final namaC = TextEditingController();
  final hargaC = TextEditingController();
  final deskripsiC = TextEditingController();
  final kategori = ''.obs;

  // ===== EDIT MODE =====
  final isEdit = false.obs;
  AdminMenuModel? editingMenu;

  // ===== INIT EDIT =====
  void setEditMenu(AdminMenuModel menu) {
    isEdit.value = true;
    editingMenu = menu;

    namaC.text = menu.nama;
    hargaC.text = menu.harga.toStringAsFixed(0);
    deskripsiC.text = menu.deskripsi;
    imageUrl.value = menu.gambar ?? '';
    kategori.value = menu.kategori;
  }

  // ===== RESET FORM =====
  void resetForm() {
    isEdit.value = false;
    editingMenu = null;

    namaC.clear();
    hargaC.clear();
    deskripsiC.clear();
    imageUrl.value = '';
    kategori.value = '';
    pickedImage.value = null;
  }

  Future<void> updateMenu() async {
    if (!isAdmin) {
      Get.snackbar(
        'Akses Ditolak',
        'Hanya admin yang dapat mengubah menu',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      String? newImageUrl = imageUrl.value;
      final oldImageUrl = editingMenu?.gambar;

      // 1. upload gambar baru (jika dipilih)
      if (pickedImage.value != null) {
        newImageUrl = await uploadImageToStorage(pickedImage.value!);
      }

      // 2. update row menu
      final response = await http.patch(
        Uri.parse('$baseUrl$menuEndpoint?id=eq.${editingMenu!.id}'),
        headers: adminHeaders,
        body: jsonEncode({
          'Nama': namaC.text,
          'Harga': int.parse(hargaC.text),
          'Kategori': kategori.value,
          'Deskripsi': deskripsiC.text,
          'Gambar': newImageUrl,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // 3. hapus gambar lama (jika ganti)
        if (pickedImage.value != null &&
            oldImageUrl != null &&
            oldImageUrl.isNotEmpty &&
            oldImageUrl != newImageUrl) {
          await deleteImage(oldImageUrl);
        }

        Get.back();
        resetForm();
        fetchMenus();

        Get.snackbar(
          'Sukses',
          'Menu berhasil diperbarui',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw Exception('Gagal update menu');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ===== PICK IMAGE =====
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      pickedImage.value = File(image.path);
    }
  }

  // ===== UPLOAD IMAGE TO SUPABASE =====
  Future<String> uploadImageToStorage(File file) async {
    final fileName = 'menu_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final path = 'menus/$fileName';

    await _supabase.storage.from('menu-images').upload(
          path,
          file,
        );

    return _supabase.storage.from('menu-images').getPublicUrl(path);
  }

  // ===== EXTRACT STORAGE PATH FROM PUBLIC URL =====
  String getStoragePathFromUrl(String url) {
    final uri = Uri.parse(url);
    final index = uri.pathSegments.indexOf('public');

    return uri.pathSegments.sublist(index + 2).join('/');
  }

  // ===== DELETE IMAGE FROM STORAGE =====
  Future<void> deleteImage(String imageUrl) async {
    final path = getStoragePathFromUrl(imageUrl);

    await _supabase.storage.from('menu-images').remove([path]);
  }

  // ===== DELETE MENU + IMAGE =====
  Future<void> deleteMenu(AdminMenuModel menu) async {
    if (!isAdmin) {
      Get.snackbar(
        'Akses Ditolak',
        'Hanya admin yang dapat menghapus menu',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      // 1. delete image (jika ada)
      try {
        if (menu.gambar != null && menu.gambar!.isNotEmpty) {
          await deleteImage(menu.gambar!);
        }
      } catch (_) {
        debugPrint('Gagal hapus gambar, lanjut hapus menu');
      }

      // 2. delete row
      final response = await http.delete(
        Uri.parse('$baseUrl$menuEndpoint?id=eq.${menu.id}'),
        headers: adminHeaders,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        menuList.removeWhere((m) => m.id == menu.id);

        Get.snackbar(
          'Sukses',
          'Menu berhasil dihapus',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw Exception('Gagal hapus menu: ${response.body}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    namaC.dispose();
    hargaC.dispose();
    deskripsiC.dispose();
    super.onClose();
  }
}
