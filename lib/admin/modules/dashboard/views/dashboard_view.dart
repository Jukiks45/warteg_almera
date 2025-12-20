import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../../../../routes/app_routes.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== HEADER =====
            Obx(() => Text(
              'Selamat Datang, ${controller.adminName.value} 👋',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            )),
            const SizedBox(height: 6),
            Text(
              'Kelola data aplikasi dari sini',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 24),

            // ===== CARD MENU =====
            _buildAdminCard(
              context,
              title: 'Menu',
              subtitle: Obx(
                () => Text(
                  'Total: ${controller.totalMenu.value} menu',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              icon: Icons.restaurant_menu,
              color: Colors.orange,
              onTap: () {
                Get.toNamed(AppRoutes.adminMenu);
              },
            ),

            const SizedBox(height: 16),

            // ===== CARD ORDERS =====
            _buildAdminCard(
              context,
              title: 'Orders',
              subtitle: const Text(
                'Kelola pesanan pelanggan',
                style: TextStyle(color: Colors.grey),
              ),
              icon: Icons.receipt_long,
              color: Colors.green,
              onTap: () {
                Get.toNamed(AppRoutes.adminOrders);
              },
            ),

            const SizedBox(height: 16),

            // ===== CARD PROMO =====
            _buildAdminCard(
              context,
              title: 'Promo',
              subtitle: Obx(
                () => Text(
                  'Total: ${controller.totalPromo.value} promo',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              icon: Icons.local_offer,
              color: Colors.redAccent,
              onTap: () {
                Get.toNamed(AppRoutes.adminPromo);
              },
            ),
            const SizedBox(height: 16),
            // ===== CARD PROFIL =====
            _buildAdminCard(
              context,
              title: 'Profil Admin',
              subtitle: const Text(
                'Kelola informasi akun',
                style: TextStyle(color: Colors.grey),
              ),
              icon: Icons.person,
              color: Colors.blue,
              onTap: () {
                Get.toNamed(AppRoutes.adminProfile);
              },
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildAdminCard(
  BuildContext context, {
  required String title,
  required Widget subtitle,
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  subtitle,
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    ),
  );
}
