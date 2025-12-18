class AdminPromoModel {
  final String id;
  final String title;
  final String description;
  final String promoCode;
  final double discountAmount;
  final double minPurchase;
  final DateTime validFrom;
  final DateTime validUntil;
  final bool isActive;
  final int? maxUsage;
  final int? maxUsagePerUser;

  AdminPromoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.promoCode,
    required this.discountAmount,
    required this.minPurchase,
    required this.validFrom,
    required this.validUntil,
    required this.isActive,
    this.maxUsage,
    this.maxUsagePerUser,
  });

  factory AdminPromoModel.fromJson(Map<String, dynamic> json) {
    return AdminPromoModel(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      promoCode: json['promo_code'] ?? '',
      discountAmount: (json['discount_amount'] as num).toDouble(),
      minPurchase: (json['min_purchase'] as num).toDouble(),
      validFrom: DateTime.parse(json['valid_from']),
      validUntil: DateTime.parse(json['valid_until']),
      isActive: json['is_active'] ?? false,
      maxUsage: json['max_usage'],
      maxUsagePerUser: json['max_usage_per_user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'promo_code': promoCode,
      'discount_amount': discountAmount.toInt(),
      'min_purchase': minPurchase.toInt(),
      'valid_from': validFrom.toIso8601String(),
      'valid_until': validUntil.toIso8601String(),
      'is_active': isActive,
      'max_usage': maxUsage,
      'max_usage_per_user': maxUsagePerUser,
    };
  }
}
