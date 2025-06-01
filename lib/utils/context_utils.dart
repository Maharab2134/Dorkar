import 'package:flutter/material.dart';

extension BuildContextX on BuildContext {
  bool get isMounted {
    return mounted;
  }

  Future<T?> safeAsync<T>(Future<T> Function() callback) async {
    if (!mounted) return null;
    try {
      return await callback();
    } catch (e) {
      if (!mounted) return null;
      rethrow;
    }
  }

  void safeSetState(State state, VoidCallback fn) {
    if (state.mounted) {
      fn();
    }
  }
} 