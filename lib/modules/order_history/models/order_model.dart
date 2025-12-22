class OrderModel {
  final String id;
  final String userId;
  final int totalItems;
  final double totalPrice;
  final String status;
  final String paymentMethod;
  final String? note;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.totalItems,
    required this.totalPrice,
    required this.status,
    required this.paymentMethod,
    this.note,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      totalItems: json['total_items'] ?? 0,
      totalPrice: (json['total_price'] is String)
          ? double.tryParse(json['total_price']) ?? 0.0
          : (json['total_price'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'pending',
      paymentMethod: json['payment_method'] ?? 'cash',
      note: json['note'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'total_items': totalItems,
      'total_price': totalPrice,
      'status': status,
      'payment_method': paymentMethod,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'processing':
        return 'Diproses';
      case 'completed':
        return 'Selesai';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

}
