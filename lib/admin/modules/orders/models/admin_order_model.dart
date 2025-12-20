class AdminOrderModel {
  final String id;
  final String userId;
  final String userName;
  final List<OrderItemModel> items;
  final double totalPrice;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  AdminOrderModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory AdminOrderModel.fromJson(Map<String, dynamic> json) {
    return AdminOrderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_id'] as String, // Temporarily use userId as name
      items: const [], // Will be populated separately from order_items table
      totalPrice: (json['total_price'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'items': items.map((item) => item.toJson()).toList(),
      'total_price': totalPrice,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class OrderItemModel {
  final int menuId;
  final String menuName;
  final int quantity;
  final double menuHarga;
  final double subtotal;

  OrderItemModel({
    required this.menuId,
    required this.menuName,
    required this.quantity,
    required this.menuHarga,
    required this.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      menuId: json['menu_id'],
      menuName: json['menu_nama'],
      quantity: json['quantity'],
      menuHarga: (json['menu_harga'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menu_id': menuId,
      'menu_nama': menuName,
      'quantity': quantity,
      'menu_harga': menuHarga,
      'subtotal': subtotal,
    };
  }
}
