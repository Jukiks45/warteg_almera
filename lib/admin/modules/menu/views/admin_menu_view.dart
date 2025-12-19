import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_menu_controller.dart';
import '../models/admin_menu_model.dart';
import '../../../../routes/app_routes.dart';


class AdminMenuView extends GetView<AdminMenuController> {
  const AdminMenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Menu'),
        centerTitle: true,
      ),

      // ===== BUTTON TAMBAH MENU =====
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.resetForm();
          Get.toNamed(AppRoutes.adminMenuForm);
        },
        child: const Icon(Icons.add),
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Gagal memuat data',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: controller.fetchMenus,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        if (controller.menuList.isEmpty) {
          return const Center(child: Text('Belum ada menu'));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemCount: controller.menuList.length,
          itemBuilder: (context, index) {
            final menu = controller.menuList[index];

            return GestureDetector(
              onTap: () => _showAdminMenuDetail(context, menu),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: menu.gambar != null && menu.gambar!.isNotEmpty
                            ? Image.network(
                                menu.gambar!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildFallbackIcon(menu.kategori),
                              )
                            : _buildFallbackIcon(menu.kategori),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            menu.nama,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rp ${_formatCurrency(menu.harga)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Chip(
                            label: Text(
                              menu.kategori,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _showAdminMenuDetail(BuildContext context, AdminMenuModel menu) {
    Get.defaultDialog(
      title: menu.nama,
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ===== GAMBAR MENU =====
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: menu.gambar != null && menu.gambar!.isNotEmpty
                  ? Image.network(
                      menu.gambar!,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _buildFallbackIcon(menu.kategori, height: 180),
                    )
                  : _buildFallbackIcon(menu.kategori, height: 180),
            ),

            const SizedBox(height: 12),

            // ===== DETAIL =====
            Text(
              'Rp ${_formatCurrency(menu.harga)}',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
            ),
            const SizedBox(height: 4),
            Chip(
              label: Text(menu.kategori),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(height: 8),
            Text(
              menu.deskripsi,
              style: TextStyle(color: Colors.grey.shade700),
            ),

            const SizedBox(height: 20),

            // ===== BUTTON ADMIN =====
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.back();
                      controller.setEditMenu(menu);
                      Get.toNamed(AppRoutes.adminMenuForm);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  onPressed: () {
                    Get.back();
                    _confirmDelete(menu);
                  },
                    icon: const Icon(Icons.delete),
                    label: const Text('Hapus'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      textConfirm: 'Tutup',
      onConfirm: () => Get.back(),
    );
  }

  void _confirmDelete(AdminMenuModel menu) {
    Get.defaultDialog(
      title: 'Hapus Menu',
      middleText: 'Yakin ingin menghapus "${menu.nama}"?',
      textCancel: 'Batal',
      textConfirm: 'Hapus',
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        controller.deleteMenu(menu);
      },
    );
  }

  Widget _buildFallbackIcon(String kategori, {double height = 160}) {
    return Container(
      height: height,
      alignment: Alignment.center,
      color: Colors.grey.shade200,
      child: Icon(
        _getIconByCategory(kategori),
        size: 48,
        color: Colors.grey.shade600,
      ),
    );
  }

  IconData _getIconByCategory(String kategori) {
    switch (kategori.toLowerCase()) {
      case 'minuman':
        return Icons.local_drink;
      case 'snack':
      case 'cemilan':
        return Icons.fastfood;
      default:
        return Icons.restaurant;
    }
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }
}
