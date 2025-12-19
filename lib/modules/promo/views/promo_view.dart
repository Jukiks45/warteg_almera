import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/promo_controller.dart';
import 'promo_detail_view.dart';

class PromoView extends GetView<PromoController> {
  const PromoView({super.key});

  @override
  Widget build(BuildContext context) {
    // Cek jika ada arguments untuk langsung ke detail promo
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      final promoId = args['promoId'];
      if (promoId != null) {
        // Load promo by ID dan navigasi ke detail
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.loadPromoById(promoId.toString()).then((_) {
            if (controller.selectedPromo.value != null) {
              Get.off(
                () => PromoDetailView(promo: controller.selectedPromo.value!),
                transition: Transition.fadeIn,
              );
            }
          });
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Promo & Penawaran'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.promos.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.promos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_offer_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada promo tersedia',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: controller.refreshPromos,
                  child: const Text('Refresh'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshPromos,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.promos.length,
            itemBuilder: (context, index) {
              final promo = controller.promos[index];
              return _PromoCard(
                promo: promo,
                onTap: () {
                  Get.to(
                    () => PromoDetailView(promo: promo),
                    transition: Transition.rightToLeft,
                  );
                },
              );
            },
          ),
        );
      }),
    );
  }
}

class _PromoCard extends StatelessWidget {
  final dynamic promo;
  final VoidCallback onTap;

  const _PromoCard({
    required this.promo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            // ClipRRect(
            //   borderRadius: const BorderRadius.vertical(
            //     top: Radius.circular(12),
            //   ),
            //   child: Image.network(
            //     promo.imageUrl,
            //     height: 180,
            //     width: double.infinity,
            //     fit: BoxFit.cover,
            //     errorBuilder: (context, error, stackTrace) {
            //       return Container(
            //         height: 180,
            //         color: Colors.grey[300],
            //         child: const Center(
            //           child: Icon(
            //             Icons.image_not_supported,
            //             size: 50,
            //             color: Colors.grey,
            //           ),
            //         ),
            //       );
            //     },
            //     loadingBuilder: (context, child, loadingProgress) {
            //       if (loadingProgress == null) return child;
            //       return Container(
            //         height: 180,
            //         color: Colors.grey[200],
            //         child: const Center(
            //           child: CircularProgressIndicator(),
            //         ),
            //       );
            //     },
            //   ),
            // ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge & Title
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Rp ${_formatCurrency(promo.discountAmount)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (promo.isValid)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'AKTIF',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Title
                  Text(
                    promo.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Description
                  Text(
                    promo.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Validity period
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Berlaku sampai ${_formatDate(promo.endDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  
                  // Promo code
                  if (promo.promoCode != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.confirmation_number_outlined,
                          size: 16,
                          color: Colors.orange[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Kode: ${promo.promoCode}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }
}
