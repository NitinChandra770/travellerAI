import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String _loggedInKey = 'isLoggedIn';
  static const String _mobileNumberKey = 'mobileNumber';
  static const String _keyProfileImagePrefix = 'profile_image_';
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception(
        'AppPreferences not initialized. Call AppPreferences.init() first.',
      );
    }
    return _prefs!;
  }

  static Future<void> setLoggedIn(bool value, {String? mobileNumber}) async {
    // Ensure initialized or fallback to getInstance if called too early (though init should be called in main)
    if (_prefs == null) await init();
    await _prefs!.setBool(_loggedInKey, value);
    if (value && mobileNumber != null) {
      await _prefs!.setString(_mobileNumberKey, mobileNumber);
    }
  }

  static Future<bool> isLoggedIn() async {
    if (_prefs == null) await init();
    return _prefs!.getBool(_loggedInKey) ?? false;
  }

  static Future<String?> getMobileNumber() async {
    if (_prefs == null) await init();
    return _prefs!.getString(_mobileNumberKey);
  }

  static Future<void> logout() async {
    if (_prefs == null) await init();
    await _prefs!.remove(_loggedInKey);
    await _prefs!.remove(_mobileNumberKey);
  }

  // --- New Methods for Profile Image ---

  static Future<void> setProfileImage(String mobile, String path) async {
    if (_prefs == null) await init();
    await _prefs!.setString('$_keyProfileImagePrefix$mobile', path);
  }

  static Future<String?> getProfileImage(String mobile) async {
    if (_prefs == null) await init();
    return _prefs!.getString('$_keyProfileImagePrefix$mobile');
  }

  static Future<void> removeProfileImage(String mobile) async {
    if (_prefs == null) await init();
    await _prefs!.remove('$_keyProfileImagePrefix$mobile');
  }
}
