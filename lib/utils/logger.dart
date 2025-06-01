import 'package:flutter/foundation.dart';

class Logger {
  static void info(String message) {
    if (kDebugMode) {
      print('INFO: $message');
    }
  }

  static void error(String message) {
    if (kDebugMode) {
      print('ERROR: $message');
    }
  }

  static void debug(String message) {
    if (kDebugMode) {
      print('DEBUG: $message');
    }
  }
} 