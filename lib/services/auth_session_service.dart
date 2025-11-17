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

  // Save login session
  Future<void> saveSession({
    required String userId,
    required String email,
  }) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserId, userId);
    await _prefs.setString(_keyUserEmail, email);
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Get user ID
  String? getUserId() {
    return _prefs.getString(_keyUserId);
  }

  // Get user email
  String? getUserEmail() {
    return _prefs.getString(_keyUserEmail);
  }

  // Clear session (logout)
  Future<void> clearSession() async {
    await _prefs.remove(_keyIsLoggedIn);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserEmail);
  }

  // Clear all data
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
