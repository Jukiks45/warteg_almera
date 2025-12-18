import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_promo_controller.dart';

class AdminPromoFormView extends GetView<AdminPromoController> {
  const AdminPromoFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              controller.isEdit.value ? 'Edit Promo' : 'Tambah Promo',
            )),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ===== TITLE =====
            TextField(
              controller: controller.titleC,
              decoration: const InputDecoration(
                labelText: 'Judul Promo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // ===== PROMO CODE =====
            TextField(
              controller: controller.codeC,
              decoration: const InputDecoration(
                labelText: 'Kode Promo',
                border: OutlineInputBorder(),
                hintText: 'WELCOME10',
              ),
            ),
            const SizedBox(height: 16),

            // ===== DISCOUNT AMOUNT =====
            TextField(
              controller: controller.discountC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah Diskon',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
                hintText: '10000',
              ),
            ),
            const SizedBox(height: 16),

            // ===== MIN PURCHASE =====
            TextField(
              controller: controller.minPurchaseC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Minimal Pembelian',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
                hintText: '50000',
              ),
            ),
            const SizedBox(height: 16),

            // ===== VALID FROM =====
            Obx(() => InkWell(
                  onTap: () => _selectDate(context, true),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Berlaku Dari',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      controller.validFrom.value != null
                          ? _formatDate(controller.validFrom.value!)
                          : 'Pilih tanggal',
                    ),
                  ),
                )),
            const SizedBox(height: 16),

            // ===== VALID UNTIL =====
            Obx(() => InkWell(
                  onTap: () => _selectDate(context, false),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Berlaku Sampai',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      controller.validUntil.value != null
                          ? _formatDate(controller.validUntil.value!)
                          : 'Pilih tanggal',
                    ),
                  ),
                )),
            const SizedBox(height: 16),

            // ===== MAX USAGE =====
            TextField(
              controller: controller.maxUsageC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Max Penggunaan (Opsional)',
                border: OutlineInputBorder(),
                hintText: '100',
              ),
            ),
            const SizedBox(height: 16),

            // ===== MAX USAGE PER USER =====
            TextField(
              controller: controller.maxUsagePerUserC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Max Penggunaan per User (Opsional)',
                border: OutlineInputBorder(),
                hintText: '1',
              ),
            ),
            const SizedBox(height: 16),

            // ===== DESCRIPTION =====
            TextField(
              controller: controller.descC,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(),
                hintText: 'Diskon 10% untuk semua menu',
              ),
            ),
            const SizedBox(height: 16),

            // ===== ACTIVE SWITCH =====
            Obx(() => SwitchListTile(
                  title: const Text('Status Aktif'),
                  value: controller.isActive.value,
                  onChanged: (value) {
                    controller.isActive.value = value;
                  },
                )),
            const SizedBox(height: 24),

            // ===== BUTTON SIMPAN / UPDATE =====
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton.icon(
                    icon: controller.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            controller.isEdit.value ? Icons.update : Icons.save),
                    label: Text(controller.isLoading.value
                        ? 'Menyimpan...'
                        : (controller.isEdit.value
                            ? 'Update Promo'
                            : 'Simpan Promo')),
                    onPressed: controller.isLoading.value ? null : _validateAndSave,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  void _selectDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFrom
          ? controller.validFrom.value ?? DateTime.now()
          : controller.validUntil.value ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      if (isFrom) {
        controller.validFrom.value = picked;
      } else {
        controller.validUntil.value = picked;
      }
    }
  }

  void _validateAndSave() {
    // Basic validation
    if (controller.titleC.text.isEmpty ||
        controller.codeC.text.isEmpty ||
        controller.discountC.text.isEmpty ||
        controller.minPurchaseC.text.isEmpty ||
        controller.validFrom.value == null ||
        controller.validUntil.value == null) {
      Get.snackbar(
        'Validasi Error',
        'Harap isi semua field yang wajib',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Validate discount and min purchase
    try {
      int.parse(controller.discountC.text);
      int.parse(controller.minPurchaseC.text);
    } catch (e) {
      Get.snackbar(
        'Validasi Error',
        'Jumlah diskon dan minimal pembelian harus berupa angka',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Validate dates
    if (controller.validUntil.value!.isBefore(controller.validFrom.value!)) {
      Get.snackbar(
        'Validasi Error',
        'Tanggal berakhir harus setelah tanggal mulai',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Validate optional fields
    if (controller.maxUsageC.text.isNotEmpty) {
      try {
        int.parse(controller.maxUsageC.text);
      } catch (e) {
        Get.snackbar(
          'Validasi Error',
          'Max penggunaan harus berupa angka',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    if (controller.maxUsagePerUserC.text.isNotEmpty) {
      try {
        int.parse(controller.maxUsagePerUserC.text);
      } catch (e) {
        Get.snackbar(
          'Validasi Error',
          'Max penggunaan per user harus berupa angka',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    // Save
    if (controller.isEdit.value) {
      controller.updatePromo();
    } else {
      controller.insertPromo();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
