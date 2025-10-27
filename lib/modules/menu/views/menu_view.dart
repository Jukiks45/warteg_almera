// File: menu_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/menu_controller.dart' as menu;
import '../models/menu_model.dart'; // Wajib ada
import '../../../routes/app_routes.dart';

class MenuView extends GetView<menu.MenuController> {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Menu'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchMenuWithDetailHttp(),
            tooltip: 'Reload Async-Await',
          ),
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () =>
                controller.fetchMenuWithDetailCallbackHttp(),
            tooltip: 'Reload Callback Chaining',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Get.defaultDialog(
                title: 'Konfirmasi',
                middleText: 'Apakah Anda yakin ingin logout?',
                textConfirm: 'Ya',
                textCancel: 'Tidak',
                confirmTextColor: Colors.white,
                onConfirm: () {
                  Get.back();
                  Get.offAllNamed(AppRoutes.login);
                },
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.listMenu.isEmpty) {
          return _buildLoadingIndicator(context);
        }

        if (controller.isError.value && controller.listMenu.isEmpty) {
          return _buildErrorState(context);
        }

        if (controller.listMenu.isEmpty) {
          return _buildEmptyState(context);
        }

        // KOREKSI: Menggunakan SingleChildScrollView dan Column
        return RefreshIndicator(
          onRefresh: controller.fetchMenuWithDetailHttp,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === MENU PILIHAN BARU (Menggunakan selectedMenu) ===
                _buildSelectedMenuCard(context, controller.selectedMenu.value),
                
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
                  child: Text(
                    'Semua Menu (${controller.listMenu.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),

                // Grid 2 kolom (Tampilan Asli Anda)
                // Menggunakan GridView.builder di dalam Column butuh Physics: NeverScrollableScrollPhysics
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(), // Wajib
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: controller.listMenu.length,
                  itemBuilder: (context, index) {
                    final menu = controller.listMenu[index];
                    return GestureDetector(
                      onTap: () => _showMenuDetail(context, menu),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12)),
                                child: menu.gambar != null && menu.gambar!.isNotEmpty
                                    ? Image.network(
                                        menu.gambar!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return _buildFallbackIcon(context, menu.kategori);
                                        },
                                      )
                                    : _buildFallbackIcon(context, menu.kategori),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    menu.nama,
                                    style:
                                        const TextStyle(fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rp ${_formatCurrency(menu.harga)}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary),
                                  ),
                                  const SizedBox(height: 4),
                                  Chip(
                                    label: Text(
                                      menu.kategori,
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 4),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20), // Memberi sedikit jarak di bawah Grid
              ],
            ),
          ),
        );
      }),
    );
  }

  // ============================================
  // BARU: Menu Pilihan (Menggunakan selectedMenu)
  // ============================================
  Widget _buildSelectedMenuCard(BuildContext context, MenuModel? selectedMenu) {
    if (selectedMenu == null) {
      return const SizedBox.shrink(); // Sembunyikan jika selectedMenu null
    }

    return Container(
      margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withAlpha(102),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Menu Pilihan
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: selectedMenu.gambar != null && selectedMenu.gambar!.isNotEmpty
                ? Image.network(
                    selectedMenu.gambar!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => 
                        _buildFallbackIconSmall(context, selectedMenu.kategori),
                  )
                : _buildFallbackIconSmall(context, selectedMenu.kategori),
          ),
          const SizedBox(width: 12),
          // Detail Menu Pilihan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '★ MENU PILIHAN',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red),
                ),
                Text(
                  selectedMenu.nama,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp ${_formatCurrency(selectedMenu.harga)}',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  selectedMenu.deskripsi,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================
  // POP-UP DETAIL
  // =====================
  void _showMenuDetail(BuildContext context, MenuModel menu) {
    Get.defaultDialog(
      title: menu.nama,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (menu.gambar != null && menu.gambar!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(menu.gambar!, fit: BoxFit.cover)),
          const SizedBox(height: 8),
          Text('Harga: Rp ${_formatCurrency(menu.harga)}'),
          Text('Kategori: ${menu.kategori}'),
          Text('Deskripsi: ${menu.deskripsi}'),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Keranjang',
                '${menu.nama} berhasil ditambahkan ke keranjang',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            icon: const Icon(Icons.shopping_cart),
            label: const Text('Masukkan Keranjang'),
          ),
        ],
      ),
      textConfirm: 'Tutup',
      onConfirm: () => Get.back(),
    );
  }

  // =====================
  // HELPER METHODS
  // =====================
  
  // Helper khusus untuk gambar kecil di Selected Menu Card
  Widget _buildFallbackIconSmall(BuildContext context, String kategori) {
    return Container(
      width: 80,
      height: 80,
      alignment: Alignment.center,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Icon(
        _getIconByCategory(kategori),
        color: Theme.of(context).colorScheme.primary,
        size: 30,
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Memuat data menu...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text('Gagal memuat data',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: controller.fetchMenuWithDetailHttp, 
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Belum ada menu tersedia',
              style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
  
  Widget _buildFallbackIcon(BuildContext context, String kategori) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Icon(
        _getIconByCategory(kategori),
        color: Theme.of(context).colorScheme.primary,
        size: 40,
      ),
    );
  }

  IconData _getIconByCategory(String kategori) {
    switch (kategori.toLowerCase()) {
      case 'minuman':
        return Icons.local_drink;
      case 'makanan utama':
        return Icons.restaurant;
      case 'snack':
      case 'cemilan':
        return Icons.fastfood;
      default:
        return Icons.restaurant_menu;
    }
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }
}