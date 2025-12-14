// File: lib\modules\menu\views\menu_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/menu_controller.dart' as menu;
import '../models/menu_model.dart';
import '../../../routes/app_routes.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../../providers/login_providers.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import '../../../services/notification_service.dart';

class MenuView extends GetView<menu.MenuController> {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Menu'),
        centerTitle: true,
        actions: [
          // Promo Icon dengan Badge Hot
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.local_offer),
                onPressed: () => Get.toNamed(AppRoutes.promo),
                tooltip: 'Promo & Penawaran',
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'HOT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long),
            onPressed: () => Get.toNamed(AppRoutes.orderHistory),
            tooltip: 'Riwayat Pesanan',
          ),
          // Cart Icon with Badge
          Obx(() => Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () => Get.toNamed(AppRoutes.cart),
                    tooltip: 'Keranjang',
                  ),
                  if (cartController.totalItems > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cartController.totalItems}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              )),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchMenuWithDetailHttp(),
            tooltip: 'Reload Async-Await',
          ),
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: () {
              Get.toNamed(AppRoutes.lokasi);
            },
            tooltip: 'Lokasi Saya',
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
                onConfirm: () async {
                  Get.back();

                  // Logout dari Supabase dan hapus session
                  final loginProvider = Get.find<LoginProviders>();
                  await loginProvider.logout();

                  Get.offAllNamed(AppRoutes.login);

                  Get.snackbar(
                    'Sukses',
                    'Anda telah logout',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Obx(() {
// ... (Bagian Body lainnya tetap sama)
// ... (Semua fungsi helper _buildSelectedMenuCard, _showMenuDetail, dll tetap sama)
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

                // === BANNER PROMO ===
                _buildPromoBanner(context),

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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                child: menu.gambar != null &&
                                        menu.gambar!.isNotEmpty
                                    ? Image.network(
                                        menu.gambar!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return _buildFallbackIcon(
                                              context, menu.kategori);
                                        },
                                      )
                                    : _buildFallbackIcon(
                                        context, menu.kategori),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    menu.nama,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rp ${_formatCurrency(menu.harga)}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                  ),
                                  const SizedBox(height: 4),
                                  Chip(
                                    label: Text(
                                      menu.kategori,
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
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
                const SizedBox(
                    height: 20), // Memberi sedikit jarak di bawah Grid
              ],
            ),
          ),
        );
      }),
    );
  }

  // ============================================
// ... (Semua Helper Methods _buildSelectedMenuCard, _showMenuDetail, _formatCurrency, dll. tetap sama)

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
        border: Border.all(
            color: Theme.of(context).colorScheme.primary, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Menu Pilihan
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: selectedMenu.gambar != null &&
                    selectedMenu.gambar!.isNotEmpty
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
                  '⭐ MENU PILIHAN',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
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
// ... (Bagian _showMenuDetail dan _showHiveDebugDialog tetap sama)

  void _showMenuDetail(BuildContext context, MenuModel menu) {
    final cartController = Get.find<CartController>();

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
              cartController.addToCart(menu);
              Get.back();
              Get.snackbar(
                'Keranjang',
                '${menu.nama} berhasil ditambahkan ke keranjang',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
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
// ... (Semua Helper Methods lainnya tetap sama)

  // Helper method untuk debug Hive (unused tapi bisa berguna untuk debugging)
  // ignore: unused_element
  void _showHiveDebugDialog(BuildContext context) {
    final cartController = Get.find<CartController>();

    Get.dialog(
      AlertDialog(
        title: const Text('Hive Debug Info'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('ℹ️ Debug Information:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // Check if Hive is initialized
              Text('Hive initialized: ${Hive.isBoxOpen('cartBox')}'),
              const SizedBox(height: 8),

              // Cart items in memory
              Text('Items in memory: ${cartController.cartItems.length}'),
              const SizedBox(height: 8),

              // Items in Hive
              Builder(builder: (context) {
                try {
                  final box = Hive.box('cartBox');
                  final savedCart = box.get('cart_items');
                  final count = savedCart is List ? savedCart.length : 0;
                  return Text('Items in Hive: $count');
                } catch (e) {
                  return Text('Error reading Hive: $e',
                      style: const TextStyle(color: Colors.red));
                }
              }),
              const SizedBox(height: 16),

              const Divider(),
              const SizedBox(height: 16),

              const Text('🛠️ Actions:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              ElevatedButton.icon(
                onPressed: () async {
                  // Reload cart dari Hive
                  final box = Hive.box('cartBox');
                  final savedCart = box.get('cart_items');
                  if (savedCart != null && savedCart is List) {
                    Get.back();
                    Get.snackbar(
                      'Debug',
                      'Found ${savedCart.length} items in Hive',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  } else {
                    Get.back();
                    Get.snackbar(
                      'Debug',
                      'No data found in Hive',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.orange,
                    );
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Check Hive Data'),
              ),
              const SizedBox(height: 8),

              ElevatedButton.icon(
                onPressed: () async {
                  await Hive.deleteBoxFromDisk('cartBox');
                  await Hive.openBox('cartBox');
                  cartController.cartItems.clear();
                  Get.back();
                  Get.snackbar(
                    'Debug',
                    'Hive cart cleared & reopened',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                },
                icon: const Icon(Icons.delete_forever),
                label: const Text('Clear Hive Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
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

  /// Build banner promo yang menarik
  Widget _buildPromoBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.promo),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6B35).withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon Promo
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_offer,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Promo Spesial Hari Ini! 🎉',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lihat semua penawaran menarik',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Arrow Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
