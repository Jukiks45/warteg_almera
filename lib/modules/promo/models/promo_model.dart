class PromoModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final double discountAmount; // Diskon dalam rupiah
  final double minPurchase; // Minimal pembelian
  final bool isActive;
  final String? promoCode;

  PromoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.startDate,
    required this.endDate,
    required this.discountAmount,
    this.minPurchase = 0,
    this.isActive = true,
    this.promoCode,
  });

  factory PromoModel.fromJson(Map<String, dynamic> json) {
    return PromoModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      startDate: json['start_date'] != null 
          ? DateTime.parse(json['start_date']) 
          : DateTime.now(),
      endDate: json['end_date'] != null 
          ? DateTime.parse(json['end_date']) 
          : DateTime.now().add(const Duration(days: 30)),
      discountAmount: (json['discount_amount'] ?? 0).toDouble(),
      minPurchase: (json['min_purchase'] ?? 0).toDouble(),
      isActive: json['is_active'] ?? true,
      promoCode: json['promo_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'discount_amount': discountAmount,
      'min_purchase': minPurchase,
      'is_active': isActive,
      'promo_code': promoCode,
    };
  }

  bool get isValid {
    final now = DateTime.now();
    return isActive && now.isAfter(startDate) && now.isBefore(endDate);
  }
}
