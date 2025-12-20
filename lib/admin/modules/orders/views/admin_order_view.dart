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
          return const Center(
            child: Text('No orders found'),
          );
        }

        return ListView.builder(
          itemCount: controller.orders.length,
          itemBuilder: (context, index) {
            final order = controller.orders[index];
            final items = controller.getItems(order.id);
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ExpansionTile(
                title: Text('Order #${order.id.substring(0, 8)}'),
                subtitle: Text(
                  'Customer: ${order.userId.substring(0, 8)} | Total: Rp ${order.totalPrice.toStringAsFixed(0)}',
                ),
                trailing: _buildStatusChip(order.status),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status: ${order.status}'),
                        const SizedBox(height: 8),
                        Text('Created: ${order.createdAt.toString()}'),
                        const SizedBox(height: 16),
                        if (items.isNotEmpty) ...[
                          const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                          ...items.map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text('${item.menuName} x${item.quantity}'),
                                ),
                                Text('Rp ${item.subtotal.toStringAsFixed(0)}'),
                              ],
                            ),
                          )),
                        ],
                        const SizedBox(height: 16),
                        if (order.status == 'pending')
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () => controller.updateOrderStatus(order.id, 'processing'),
                                child: const Text('Confirm'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => controller.updateOrderStatus(order.id, 'rejected'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Cancel'),
                              ),
                            ],
                          ),
                        if (order.status == 'processing')
                          ElevatedButton(
                            onPressed: () => controller.updateOrderStatus(order.id, 'completed'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text('Mark as Completed'),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'processing':
        color = Colors.blue;
        break;
      case 'completed':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        status,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }
}
