import 'package:get/get.dart';
import '../models/promo_model.dart';
// Uncomment when using Supabase for real data
// import '../../../services/supabase_service.dart';

class PromoController extends GetxController {
  // Uncomment when using Supabase for real data
  // final SupabaseService _supabaseService = Get.find<SupabaseService>();
  
  final RxList<PromoModel> promos = <PromoModel>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<PromoModel?> selectedPromo = Rx<PromoModel?>(null);

  @override
  void onInit() {
    super.onInit();
    loadPromos();
  }

  /// Load semua promo dari Supabase atau dummy data
  Future<void> loadPromos() async {
    try {
      isLoading.value = true;
      
      // TODO: Uncomment ketika tabel promo sudah ada di Supabase
      // final response = await _supabaseService.client
      //     .from('promos')
      //     .select()
      //     .eq('is_active', true)
      //     .order('created_at', ascending: false);
      
      // promos.value = (response as List)
      //     .map((json) => PromoModel.fromJson(json))
      //     .toList();

      // Dummy data untuk testing
      promos.value = _getDummyPromos();
      
    } catch (e) {
      print('Error loading promos: $e');
      Get.snackbar(
        'Error',
        'Gagal memuat promo: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load promo berdasarkan ID (dari notifikasi)
  Future<void> loadPromoById(String promoId) async {
    try {
      isLoading.value = true;
      
      // TODO: Uncomment ketika tabel promo sudah ada
      // final response = await _supabaseService.client
      //     .from('promos')
      //     .select()
      //     .eq('id', promoId)
      //     .single();
      
      // selectedPromo.value = PromoModel.fromJson(response);

      // Dummy: cari dari list
      final promo = promos.firstWhereOrNull((p) => p.id == promoId);
      if (promo != null) {
        selectedPromo.value = promo;
      } else {
        // Load ulang jika belum ada
        await loadPromos();
        selectedPromo.value = promos.firstWhereOrNull((p) => p.id == promoId);
      }
      
    } catch (e) {
      print('Error loading promo: $e');
      Get.snackbar(
        'Error',
        'Gagal memuat detail promo',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh promo list
  Future<void> refreshPromos() async {
    await loadPromos();
  }

  /// Dummy data untuk testing
  List<PromoModel> _getDummyPromos() {
    return [
      PromoModel(
        id: '1',
        title: 'Diskon Rp 5.000',
        description: 'Hemat Rp 5.000 untuk pembelian minimal Rp 10.000. Cocok untuk pembelian kecil!',
        imageUrl: 'https://via.placeholder.com/400x200/FF5722/FFFFFF?text=Diskon+5K',
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 7)),
        discountAmount: 5000,
        minPurchase: 10000,
        isActive: true,
        promoCode: 'HEMAT5K',
      ),
      PromoModel(
        id: '2',
        title: 'Potongan Rp 10.000',
        description: 'Dapatkan potongan harga Rp 10.000 untuk pembelian minimal Rp 20.000',
        imageUrl: 'https://via.placeholder.com/400x200/4CAF50/FFFFFF?text=Potongan+10K',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 14)),
        discountAmount: 10000,
        minPurchase: 20000,
        isActive: true,
        promoCode: 'SAVE10K',
      ),
      PromoModel(
        id: '3',
        title: 'Diskon Rp 15.000',
        description: 'Diskon Rp 15.000 untuk pembelian minimal Rp 50.000. Promo spesial!',
        imageUrl: 'https://via.placeholder.com/400x200/2196F3/FFFFFF?text=Diskon+15K',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        discountAmount: 15000,
        minPurchase: 50000,
        isActive: true,
        promoCode: 'SUPER15',
      ),
      PromoModel(
        id: '4',
        title: 'Gratis Ongkir - Rp 8.000',
        description: 'Gratis ongkir setara Rp 8.000 untuk semua pesanan minimal Rp 15.000',
        imageUrl: 'https://via.placeholder.com/400x200/FF9800/FFFFFF?text=Gratis+Ongkir',
        startDate: DateTime.now().subtract(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 5)),
        discountAmount: 8000,
        minPurchase: 15000,
        isActive: true,
        promoCode: 'FREEONGKIR',
      ),
    ];
  }
}
