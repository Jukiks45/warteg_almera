import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  Future<LocalStorageService> init() async {
    await Hive.initFlutter();
    await Hive.openBox('appBox');
    return this;
  }
}
