import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/menu_controller.dart' as  Menu;
import '../../../routes/app_routes.dart';

class MenuView extends GetView<Menu.MenuController> {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Menu'),
        centerTitle: true,
        actions: [
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
                  Get.offAllNamed(AppRoutes.LOGIN);
                },
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        // Loading state
        if (controller.isLoading.value) {
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

        // Error state
        if (controller.isError.value && controller.listMenu.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[300],
                ),
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
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: controller.refreshData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        // Empty state
        if (controller.listMenu.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant_menu,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada menu tersedia',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          );
        }

        // Success state - Show menu list
        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.listMenu.length,
            itemBuilder: (context, index) {
              final menu = controller.listMenu[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Hero(
                    tag: 'menu-${menu.id}',
                    child: Material(
                      child: InkWell(
                        onTap: () {
                          // Tampilkan gambar full screen ketika di tap
                          if (menu.gambar != null && menu.gambar!.isNotEmpty) {
                            Get.to(() => Scaffold(
                              appBar: AppBar(
                                backgroundColor: Colors.black,
                                leading: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white),
                                  onPressed: () => Get.back(),
                                ),
                              ),
                              backgroundColor: Colors.black,
                              body: Center(
                                child: InteractiveViewer(
                                  child: Image.network(
                                    menu.gambar!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ));
                          }
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: menu.gambar != null && menu.gambar!.isNotEmpty
                              ? Image.network(
                                  menu.gambar!,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildFallbackIcon(context, menu.kategori);
                                  },
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return _buildLoadingIndicator(context);
                                  },
                                )
                              : _buildFallbackIcon(context, menu.kategori),
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    menu.nama,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        menu.deskripsi,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Chip(
                        label: Text(
                          menu.kategori,
                          style: const TextStyle(fontSize: 11),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rp ${_formatCurrency(menu.harga)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: Obx(() => controller.listMenu.isNotEmpty
          ? FloatingActionButton(
              onPressed: controller.refreshData,
              child: const Icon(Icons.refresh),
            )
          : const SizedBox.shrink()),
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
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  Widget _buildFallbackIcon(BuildContext context, String kategori) {
    return Container(
      width: 80,
      height: 80,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Icon(
        _getIconByCategory(kategori),
        color: Theme.of(context).colorScheme.primary,
        size: 40,
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}