class OrderItemModel {
  final int id;
  final String orderId;
  final int menuId;
  final String menuNama;
  final String? menuKategori;
  final double menuHarga;
  final int quantity;
  final double subtotal;

  OrderItemModel({
    required this.id,
    required this.orderId,
    required this.menuId,
    required this.menuNama,
    this.menuKategori,
    required this.menuHarga,
    required this.quantity,
    required this.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? '',
      menuId: json['menu_id'] ?? 0,
      menuNama: json['menu_nama'] ?? '',
      menuKategori: json['menu_kategori'],
      menuHarga: (json['menu_harga'] is String)
          ? double.tryParse(json['menu_harga']) ?? 0.0
          : (json['menu_harga'] ?? 0.0).toDouble(),
      quantity: json['quantity'] ?? 1,
      subtotal: (json['subtotal'] is String)
          ? double.tryParse(json['subtotal']) ?? 0.0
          : (json['subtotal'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'menu_id': menuId,
      'menu_nama': menuNama,
      'menu_kategori': menuKategori,
      'menu_harga': menuHarga,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }
}
