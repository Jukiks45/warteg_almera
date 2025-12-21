import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_order_controller.dart';

class AdminOrderView extends GetView<AdminOrderController> {
  const AdminOrderView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Orders'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.orders.isEmpty) {
          return const Center(child: Text('No orders found'));
        }

        return ListView.builder(
          itemCount: controller.orders.length,
          itemBuilder: (context, index) {
            final order = controller.orders[index];
            final items = controller.getItems(order.id);
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text('Order #${order.id.substring(0, 8)}'),
                subtitle: Text(
                  'Customer: ${order.userId.substring(0, 8)} | Total: Rp ${order.totalPrice.toStringAsFixed(0)}',
                ),
                trailing: _buildStatusChip(order.status),
                // Ketika di klik, panggil fungsi dialog di bawah
                onTap: () => _showOrderDetailsDialog(context, order, items),
              ),
            );
          },
        );
      }),
    );
  }

  // --- FUNGSI DIALOG (PINDAHKAN KE SINI) ---
  void _showOrderDetailsDialog(BuildContext context, order, items) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Order #${order.id.substring(0, 8)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(height: 30),
                
                _buildPopupRow("Status:", order.status.toUpperCase()),
                _buildPopupRow("Created:", order.createdAt.toString().split('.')[0]),
                _buildPopupRow("Customer:", order.userId.substring(0, 8)),
                _buildPopupRow("Total:", "Rp ${order.totalPrice.toStringAsFixed(0)}"),
                
                const SizedBox(height: 20),
                const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                
                // Menampilkan daftar item
                if (items.isNotEmpty)
                  ...items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text('${item.menuName} x${item.quantity}')),
                            Text('Rp ${item.subtotal.toStringAsFixed(0)}'),
                          ],
                        ),
                      )),

                const Divider(height: 30),

                // Action Buttons
                if (order.status == 'pending')
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            controller.updateOrderStatus(order.id, 'processing');
                            Get.back();
                          },
                          child: const Text('Confirm'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            controller.updateOrderStatus(order.id, 'rejected');
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                
                if (order.status == 'processing')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        controller.updateOrderStatus(order.id, 'completed');
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Mark as Completed', style: TextStyle(color: Colors.white)),
                    ),
                  ),

                const SizedBox(height: 10),
                
                // Tombol Tutup (Sesuai Desain Promo)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Tutup', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper untuk baris detail di dalam popup
  Widget _buildPopupRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending': color = Colors.orange; break;
      case 'processing': color = Colors.blue; break;
      case 'completed': color = Colors.green; break;
      case 'rejected': color = Colors.red; break;
      default: color = Colors.grey;
    }

    return Chip(
      label: Text(status, style: const TextStyle(color: Colors.white, fontSize: 10)),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}