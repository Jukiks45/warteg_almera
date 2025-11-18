import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthSessionService extends GetxService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  
  late SharedPreferences _prefs;

  Future<AuthSessionService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  Future<void> saveSession({
    required String userId,
    required String email,
  }) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserId, userId);
    await _prefs.setString(_keyUserEmail, email);
  }

  
  bool isLoggedIn() {
    return _prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  
  String? getUserId() {
    return _prefs.getString(_keyUserId);
  }

  
  String? getUserEmail() {
    return _prefs.getString(_keyUserEmail);
  }

 
  Future<void> clearSession() async {
    await _prefs.remove(_keyIsLoggedIn);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserEmail);
  }

  
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
