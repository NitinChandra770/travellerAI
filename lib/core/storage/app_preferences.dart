import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String _loggedInKey = 'isLoggedIn';
  static const String _mobileNumberKey = 'mobileNumber';

  static Future<void> setLoggedIn(bool value, {String? mobileNumber}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, value);
    if (value && mobileNumber != null) {
      await prefs.setString(_mobileNumberKey, mobileNumber);
    }
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loggedInKey) ?? false;
  }

  static Future<String?> getMobileNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_mobileNumberKey);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loggedInKey);
    await prefs.remove(_mobileNumberKey);
  }
}
