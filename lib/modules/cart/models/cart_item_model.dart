import 'package:hive/hive.dart';
import '../../menu/models/menu_model.dart';

part 'cart_item_model.g.dart';

@HiveType(typeId: 1) // ID harus unik, kita pakai 1 (0 sudah untuk MenuModel)
class CartItemModel extends HiveObject {
  
  @HiveField(0)
  final MenuModel menu;
  
  @HiveField(1)
  int quantity;

  CartItemModel({
    required this.menu,
    this.quantity = 1,
  });

  // Getter subtotal tidak perlu di-anotasi karena akan dihitung otomatis
  double get subtotal => menu.harga * quantity;

  // Fungsi toJson dan fromJson kita biarkan, mungkin masih terpakai
  Map<String, dynamic> toJson() {
    return {
      'menu': menu.toJson(),
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      menu: MenuModel.fromJson(json['menu']),
      quantity: json['quantity'] ?? 1,
    );
  }
}
