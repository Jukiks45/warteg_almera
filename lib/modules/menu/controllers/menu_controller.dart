import 'package:get/get.dart';
import '../models/menu_model.dart';
import '../../../services/api_service.dart';

class MenuController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // Variabel untuk status loading dan error
  var isLoading = false.obs;
  var isError = false.obs;
  var errorMessage = ''.obs;

  // Variabel utama untuk data:
  var listMenu = <MenuModel>[].obs; // Menyimpan hasil API call pertama (List)
  var selectedMenu = Rxn<MenuModel>(); // Menyimpan hasil API call kedua (Detail)

  @override
  void onInit() {
    super.onInit();
    // Default load Dio async-await untuk inisialisasi awal
    fetchMenuWithDetail(); 
  }

  // --- 1. Async-Await Chained Request (Dio) ---
  Future<void> fetchMenuWithDetail() async {
    final stopwatch = Stopwatch()..start();
    try {
      isLoading.value = true;
      isError.value = false;
      errorMessage.value = '';

      final result = await _apiService.getMenuWithDetail();

      stopwatch.stop();
      final responseTime = stopwatch.elapsedMilliseconds / 1000;

      listMenu.value = result['menuList'];
      selectedMenu.value = result['selectedMenu'];

      Get.defaultDialog(
        title: 'Response Time (Dio Async-Await)',
        middleText: 'Loaded in ${responseTime.toStringAsFixed(2)} s ✅',
        textConfirm: 'Close',
        onConfirm: () => Get.back(),
      );
    } catch (e) {
      stopwatch.stop();
      isError.value = true;
      errorMessage.value = e.toString();

      Get.defaultDialog(
        title: 'Error (Dio Async-Await)',
        middleText: 'Failed in ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s ❌\n\n$e',
        textConfirm: 'Close',
        onConfirm: () => Get.back(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // --- 2. Callback Chaining Chained Request (Dio) ---
  void fetchMenuWithDetailCallback() { 
    final stopwatch = Stopwatch()..start();
    isLoading.value = true;
    isError.value = false;
    errorMessage.value = '';

    _apiService.getMenuWithDetailCallback(
      onSuccess: (result) {
        stopwatch.stop();

        listMenu.value = result['menuList'];
        selectedMenu.value = result['selectedMenu'];

        Get.defaultDialog(
          title: 'Response Time (Dio Callback)',
          middleText: 'Loaded in ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s ✅',
          textConfirm: 'Close',
          onConfirm: () => Get.back(),
        );

        isLoading.value = false;
      },
      onError: (error) {
        stopwatch.stop();
        isError.value = true;
        errorMessage.value = error;

        Get.defaultDialog(
          title: 'Error (Dio Callback)',
          middleText: 'Failed in ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s ❌\n\n$error',
          textConfirm: 'Close',
          onConfirm: () => Get.back(),
        );

        isLoading.value = false;
      },
    );
  }

  // --- 3. Async-Await Chained Request (HTTP) ---
  Future<void> fetchMenuWithDetailHttp() async {
    final stopwatch = Stopwatch()..start();
    try {
      isLoading.value = true;
      isError.value = false;
      errorMessage.value = '';

      final result = await _apiService.getMenuWithDetailHttp();

      stopwatch.stop();
      final responseTime = stopwatch.elapsedMilliseconds / 1000;

      listMenu.value = result['menuList'];
      selectedMenu.value = result['selectedMenu'];

      Get.defaultDialog(
        title: 'Response Time (HTTP Async-Await)',
        middleText: 'Loaded in ${responseTime.toStringAsFixed(2)} s ✅',
        textConfirm: 'Close',
        onConfirm: () => Get.back(),
      );
    } catch (e) {
      stopwatch.stop();
      isError.value = true;
      errorMessage.value = e.toString();

      Get.defaultDialog(
        title: 'Error (HTTP Async-Await)',
        middleText: 'Failed in ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s ❌\n\n$e',
        textConfirm: 'Close',
        onConfirm: () => Get.back(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // --- 4. Callback Chaining Chained Request (HTTP) ---
  void fetchMenuWithDetailCallbackHttp() {
    final stopwatch = Stopwatch()..start();
    isLoading.value = true;
    isError.value = false;
    errorMessage.value = '';

    _apiService.getMenuWithDetailCallbackHttp(
      onSuccess: (result) {
        stopwatch.stop();

        listMenu.value = result['menuList'];
        selectedMenu.value = result['selectedMenu'];

        Get.defaultDialog(
          title: 'Response Time (HTTP Callback)',
          middleText: 'Loaded in ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s ✅',
          textConfirm: 'Close',
          onConfirm: () => Get.back(),
        );

        isLoading.value = false;
      },
      onError: (error) {
        stopwatch.stop();
        isError.value = true;
        errorMessage.value = error;

        Get.defaultDialog(
          title: 'Error (HTTP Callback)',
          middleText: 'Failed in ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s ❌\n\n$error',
          textConfirm: 'Close',
          onConfirm: () => Get.back(),
        );

        isLoading.value = false;
      },
    );
  }
}