import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_promo_controller.dart';
import '../models/admin_promo_model.dart';
import '../../../../routes/app_routes.dart';

class AdminPromoView extends GetView<AdminPromoController> {
  const AdminPromoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Promo'),
        centerTitle: true,
      ),

      // ===== BUTTON TAMBAH PROMO =====
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.resetForm();
          Get.toNamed(AppRoutes.adminPromoForm);
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
                  onPressed: controller.fetchPromos,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        if (controller.promoList.isEmpty) {
          return const Center(child: Text('Belum ada promo'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.promoList.length,
          itemBuilder: (context, index) {
            final promo = controller.promoList[index];

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () => _showAdminPromoDetail(context, promo),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              promo.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          _buildStatusBadge(promo.isActive),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Kode: ${promo.promoCode}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Diskon: Rp ${_formatCurrency(promo.discountAmount)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Min. Pembelian: Rp ${_formatCurrency(promo.minPurchase)}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _showAdminPromoDetail(BuildContext context, AdminPromoModel promo) {
    Get.defaultDialog(
      title: promo.title,
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ===== STATUS =====
            Row(
              children: [
                const Text('Status: '),
                _buildStatusBadge(promo.isActive),
              ],
            ),

            const SizedBox(height: 12),

            // ===== DETAIL =====
            _buildDetailRow('Kode Promo', promo.promoCode),
            _buildDetailRow('Diskon', 'Rp ${_formatCurrency(promo.discountAmount)}'),
            _buildDetailRow('Min. Pembelian', 'Rp ${_formatCurrency(promo.minPurchase)}'),
            _buildDetailRow('Berlaku Dari', _formatDate(promo.validFrom)),
            _buildDetailRow('Berlaku Sampai', _formatDate(promo.validUntil)),

            if (promo.maxUsage != null)
              _buildDetailRow('Max Penggunaan', promo.maxUsage.toString()),

            if (promo.maxUsagePerUser != null)
              _buildDetailRow('Max/User', promo.maxUsagePerUser.toString()),

            const SizedBox(height: 8),
            Text(
              promo.description,
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
                      controller.setEditPromo(promo);
                      Get.toNamed(AppRoutes.adminPromoForm);
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
                      controller.deletePromo(promo);
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

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'AKTIF' : 'NONAKTIF',
        style: TextStyle(
          color: isActive ? Colors.green.shade800 : Colors.red.shade800,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
