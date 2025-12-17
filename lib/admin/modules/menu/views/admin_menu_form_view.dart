import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_menu_controller.dart';

class AdminMenuFormView extends GetView<AdminMenuController> {
  const AdminMenuFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              controller.isEdit.value ? 'Edit Menu' : 'Tambah Menu',
            )),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ===== PREVIEW GAMBAR =====
            Obx(() {
              if (controller.pickedImage.value != null) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    controller.pickedImage.value!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                );
              }

              if (controller.imageUrl.value.isNotEmpty) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    controller.imageUrl.value,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _buildFallback(height: 180),
                  ),
                );
              }

              return _buildFallback(height: 180);
            }),

            const SizedBox(height: 16),

            // ===== BUTTON PILIH GAMBAR =====
            OutlinedButton.icon(
              onPressed: controller.pickImage,
              icon: const Icon(Icons.photo_library),
              label: const Text('Pilih Gambar'),
            ),

            const SizedBox(height: 16),

            // ===== NAMA MENU =====
            TextField(
              controller: controller.namaC,
              decoration: const InputDecoration(
                labelText: 'Nama Menu',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // ===== HARGA =====
            TextField(
              controller: controller.hargaC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Harga',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // ===== KATEGORI =====
            Obx(() => DropdownButtonFormField<String>(
                  value: controller.kategori.value.isEmpty
                      ? null
                      : controller.kategori.value,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Makanan', child: Text('Makanan')),
                    DropdownMenuItem(
                        value: 'Minuman', child: Text('Minuman')),
                    DropdownMenuItem(value: 'Snack', child: Text('Snack')),
                  ],
                  onChanged: (value) {
                    controller.kategori.value = value ?? '';
                  },
                )),
            const SizedBox(height: 16),

            // ===== DESKRIPSI =====
            TextField(
              controller: controller.deskripsiC,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // ===== BUTTON SIMPAN / UPDATE =====
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton.icon(
                    icon: Icon(
                        controller.isEdit.value ? Icons.update : Icons.save),
                    label: Text(controller.isEdit.value
                        ? 'Update Menu'
                        : 'Simpan Menu'),
                    onPressed: () {
                      if (controller.isEdit.value) {
                        // TODO: implement update menu
                        Get.back();
                        controller.resetForm();
                        Get.snackbar(
                          'Sukses',
                          'Menu berhasil diperbarui (dummy)',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      } else {
                        controller.insertMenu();
                      }
                    },
                  )),
            ),
          ],
        ),
      ),
    );
  }

  // ===== FALLBACK =====
  Widget _buildFallback({double height = 160}) {
    return Container(
      height: height,
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported,
        size: 48,
        color: Colors.grey.shade600,
      ),
    );
  }
}
