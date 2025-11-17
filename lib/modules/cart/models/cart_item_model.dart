import '../../menu/models/menu_model.dart';

class CartItemModel {
  final MenuModel menu;
  int quantity;

  CartItemModel({
    required this.menu,
    this.quantity = 1,
  });

  double get subtotal => menu.harga * quantity;

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
