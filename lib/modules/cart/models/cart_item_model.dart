import 'package:hive/hive.dart';
import '../../menu/models/menu_model.dart';

part 'cart_item_model.g.dart';

@HiveType(typeId: 2)
class CartItemModel {
  @HiveField(0)
  final int menuId;

  @HiveField(1)
  final String menuNama;

  @HiveField(2)
  final String menuDeskripsi;

  @HiveField(3)
  final double menuHarga;

  @HiveField(4)
  final String menuKategori;

  @HiveField(5)
  final String? menuGambar;

  @HiveField(6)
  int quantity;

  CartItemModel({
    required this.menuId,
    required this.menuNama,
    required this.menuDeskripsi,
    required this.menuHarga,
    required this.menuKategori,
    this.menuGambar,
    this.quantity = 1,
  });

  // Helper getter untuk kompatibilitas dengan kode lama
  MenuModel get menu => MenuModel(
        id: menuId,
        nama: menuNama,
        deskripsi: menuDeskripsi,
        harga: menuHarga,
        kategori: menuKategori,
        gambar: menuGambar,
      );

  double get subtotal => menuHarga * quantity;

  // Factory dari MenuModel
  factory CartItemModel.fromMenu(MenuModel menu, {int quantity = 1}) {
    return CartItemModel(
      menuId: menu.id,
      menuNama: menu.nama,
      menuDeskripsi: menu.deskripsi,
      menuHarga: menu.harga,
      menuKategori: menu.kategori,
      menuGambar: menu.gambar,
      quantity: quantity,
    );
  }

  // Keep JSON methods untuk Supabase
  Map<String, dynamic> toJson() {
    return {
      'menu': {
        'id': menuId,
        'nama': menuNama,
        'deskripsi': menuDeskripsi,
        'harga': menuHarga,
        'kategori': menuKategori,
        'Image_network': menuGambar,
      },
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final menuData = json['menu'] as Map<String, dynamic>;
    return CartItemModel(
      menuId: int.tryParse(menuData['id']?.toString() ?? '0') ?? 0,
      menuNama: menuData['nama']?.toString() ?? '',
      menuDeskripsi: menuData['deskripsi']?.toString() ?? '',
      menuHarga: double.tryParse(menuData['harga']?.toString() ?? '0') ?? 0.0,
      menuKategori: menuData['kategori']?.toString() ?? '',
      menuGambar: menuData['Image_network']?.toString(),
      quantity: json['quantity'] ?? 1,
    );
  }
}