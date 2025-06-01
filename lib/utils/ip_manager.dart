import 'package:shared_preferences/shared_preferences.dart';

class IPManager {
  static const String _ipKey = 'ip';

  static Future<String> getIP() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_ipKey) ?? '';
  }

  static Future<void> saveIP(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ipKey, ip);
  }

  static Future<void> clearIP() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ipKey);
  }
} 