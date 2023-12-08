import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  static SharedPreferences? _prefs;
  static getSharedPreferenceInstance() async {
    if (_prefs != null) {
      return _prefs;
    } else {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  static setToken(String token) async {
    await _prefs!.setString('token', token);
  }

  static getToken() {
    String? stringValue = _prefs!.getString('token');
    return stringValue;
  }

  static setUserId(String userId) async {
    await _prefs!.setString('userId', userId);
  }

  static getUserId() {
    String? stringValue = _prefs!.getString('userId');
    return stringValue;
  }

  static setEmail(String email) async {
    await _prefs!.setString('email', email);
  }

  static getEmail() {
    String? stringValue = _prefs!.getString('email');
    return stringValue;
  }

  static removeToken() async {
    await _prefs!.remove('token');
  }

  static removeUserId() async {
    await _prefs!.remove('userId');
  }

  static removeEmail() async {
    await _prefs!.remove('email');
  }

  static addStringToSF(String key, String value) async {
    await _prefs!.setString(key, value);
  }

  static getStringValuesSF(String key) {
    String? stringValue = _prefs!.getString(key);
    return stringValue;
  }
}
