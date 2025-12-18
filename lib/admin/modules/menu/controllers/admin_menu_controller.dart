import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/admin_menu_model.dart';
import '../../../../services/admin_api_service.dart';
import '../../../../services/supabase_service.dart';
import '../../../../constant/admin_constants.dart';
import '../../../../services/exceptions.dart';
import '../../dashboard/controllers/dashboard_controller.dart';

class AdminMenuController extends GetxController {
  final AdminApiService _api = AdminApiService();
  final SupabaseService _supabase = Get.find<SupabaseService>();
  var isLoading = false.obs;
  var menuList = <AdminMenuModel>[].obs;
  var errorMessage = ''.obs;
  final imageUrl = ''.obs;
  final pickedImage = Rx<File?>(null);

  // ===== ADMIN CHECK =====
  bool get isAdmin => AdminGuard.isAdmin(_supabase);

  void clearError() => errorMessage.value = '';

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

      await _api.insertMenu({
        'Nama': namaC.text,
        'Harga': int.parse(hargaC.text),
        'Kategori': kategori.value,
        'Deskripsi': deskripsiC.text,
        'Gambar': imageUrl,
      });

      // Refresh dashboard
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().loadDashboard();
      }

      Get.back();
      resetForm();
      fetchMenus();

      Get.snackbar(
        'Sukses',
        'Menu berhasil ditambahkan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on ApiException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan tidak terduga',
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
      String? uploadedImagePath;

      try {
        // 1. upload gambar baru (jika dipilih) - atomic operation
        if (pickedImage.value != null) {
          uploadedImagePath = await uploadImageToStorage(pickedImage.value!);
          newImageUrl = uploadedImagePath;
        }

        // 2. update row menu - critical operation
        await _api.updateMenu(editingMenu!.id, {
          'Nama': namaC.text,
          'Harga': int.parse(hargaC.text),
          'Kategori': kategori.value,
          'Deskripsi': deskripsiC.text,
          'Gambar': newImageUrl,
        });

        // 3. hapus gambar lama (jika ganti) - only after DB success
        if (pickedImage.value != null &&
            oldImageUrl != null &&
            oldImageUrl.isNotEmpty &&
            oldImageUrl != newImageUrl) {
          try {
            await deleteImage(oldImageUrl);
          } catch (imageError) {
            debugPrint('Warning: Failed to delete old image: $imageError');
            // Don't fail the whole operation for this
          }
        }

        // Refresh dashboard
        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().loadDashboard();
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
      } catch (e) {
        // Rollback: hapus gambar yang baru di-upload jika DB gagal
        if (uploadedImagePath != null) {
          try {
            await deleteImage(uploadedImagePath);
          } catch (rollbackError) {
            debugPrint('Warning: Failed to rollback uploaded image: $rollbackError');
          }
        }
        rethrow;
      }
    } on ApiException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan tidak terduga',
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
      await _api.deleteMenu(menu.id);

      // Refresh dashboard
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().loadDashboard();
      }

      menuList.removeWhere((m) => m.id == menu.id);

      Get.snackbar(
        'Sukses',
        'Menu berhasil dihapus',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on ApiException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan tidak terduga',
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
