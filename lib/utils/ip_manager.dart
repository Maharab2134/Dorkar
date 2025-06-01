import 'package:shared_preferences/shared_preferences.dart';

class IPManager {
  static const String _ipKey = 'server_ip';
  static String? _cachedIP;

  // Get IP address from cache or SharedPreferences
  static Future<String> getIP() async {
    if (_cachedIP != null) {
      return _cachedIP!;
    }

    final prefs = await SharedPreferences.getInstance();
    _cachedIP = prefs.getString(_ipKey);
    return _cachedIP ?? '';
  }

  // Save IP address to SharedPreferences and cache
  static Future<void> saveIP(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ipKey, ip);
    _cachedIP = ip;
  }

  // Check if IP is set
  static Future<bool> isIPSet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_ipKey);
  }

  // Clear IP address
  static Future<void> clearIP() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ipKey);
    _cachedIP = null;
  }
} 