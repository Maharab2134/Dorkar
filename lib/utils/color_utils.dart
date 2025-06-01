import 'package:flutter/material.dart';

extension ColorX on Color {
  Color withAlphaValue(double opacity) {
    return withAlpha((opacity * 255).round());
  }
}

class ColorUtils {
  static Color getTransparentColor(Color color, double opacity) {
    return color.withAlphaValue(opacity);
  }

  static Color getSurfaceColor(Color color, double opacity) {
    return color.withAlphaValue(opacity);
  }

  static Color getBackgroundColor(Color color, double opacity) {
    return color.withAlphaValue(opacity);
  }
} 