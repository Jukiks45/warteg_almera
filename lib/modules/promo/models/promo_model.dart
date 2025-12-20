import 'package:flutter/foundation.dart';

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
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      startDate: DateTime.parse(json['valid_from']).toLocal(),
      endDate: DateTime.parse(json['valid_until']).toLocal(),
      discountAmount: (json['discount_amount'] as num).toDouble(),
      minPurchase: (json['min_purchase'] as num?)?.toDouble() ?? 0,
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
    debugPrint('NOW LOCAL: $now');
    debugPrint('START LOCAL: $startDate');
    debugPrint('END LOCAL: $endDate');
    return isActive && !now.isBefore(startDate) && !now.isAfter(endDate);
  }
}
