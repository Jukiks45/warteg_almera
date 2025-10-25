import 'package:get/get.dart';
import '../../../services/api_service.dart';
import '../models/menu_model.dart';

class MenuController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  var isLoading = false.obs;
  var isError = false.obs;
  var errorMessage = ''.obs;
  var listMenu = <MenuModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchMenuData();
  }

  // Mengambil data menu menggunakan salah satu metode dari ApiService
  Future<void> fetchMenuData() async {
    try {
      isLoading.value = true;
      isError.value = false;
      errorMessage.value = '';

      // Pilih salah satu metode:
      // Opsi 1: Menggunakan http
      final data = await _apiService.getMenuWithHttp();
      
      // Opsi 2: Menggunakan dio (uncomment untuk menggunakan)
      // final data = await _apiService.getMenuWithDio();

      listMenu.value = data.map((json) => MenuModel.fromJson(json)).toList();
      
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      isError.value = true;
      errorMessage.value = e.toString();
      
      // Fallback: gunakan data dummy jika API gagal
      _loadDummyData();
    }
  }

  // Data dummy untuk development/testing
  void _loadDummyData() {
    listMenu.value = [
      MenuModel(
        id: 1,
        nama: 'Nasi Goreng',
        deskripsi: 'Nasi goreng spesial dengan telur dan ayam',
        harga: 15000,
        kategori: 'Makanan Utama',
      ),
      MenuModel(
        id: 2,
        nama: 'Mie Ayam',
        deskripsi: 'Mie ayam dengan bakso dan pangsit',
        harga: 12000,
        kategori: 'Makanan Utama',
      ),
      MenuModel(
        id: 3,
        nama: 'Soto Ayam',
        deskripsi: 'Soto ayam kuah bening dengan soun',
        harga: 13000,
        kategori: 'Makanan Utama',
      ),
      MenuModel(
        id: 4,
        nama: 'Es Teh Manis',
        deskripsi: 'Teh manis dingin segar',
        harga: 3000,
        kategori: 'Minuman',
      ),
      MenuModel(
        id: 5,
        nama: 'Jus Jeruk',
        deskripsi: 'Jus jeruk segar tanpa gula',
        harga: 8000,
        kategori: 'Minuman',
      ),
      MenuModel(
        id: 6,
        nama: 'Ayam Goreng',
        deskripsi: 'Ayam goreng crispy dengan nasi',
        harga: 18000,
        kategori: 'Makanan Utama',
      ),
    ];
  }

  // Refresh data
  Future<void> refreshData() async {
    await fetchMenuData();
  }

  // Filter menu berdasarkan kategori
  List<MenuModel> getMenuByCategory(String kategori) {
    return listMenu.where((menu) => menu.kategori == kategori).toList();
  }

  // Get semua kategori unik
  List<String> getCategories() {
    return listMenu.map((menu) => menu.kategori).toSet().toList();
  }
}