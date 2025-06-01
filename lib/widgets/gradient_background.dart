import 'package:flutter/material.dart';
import '../constants/my_colors.dart';
import '../utils/color_utils.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final bool isAppBar;

  const GradientBackground({
    super.key,
    required this.child,
    this.isAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary,
            ColorUtils.getTransparentColor(primary, 0.8),
          ],
        ),
      ),
      child: child,
    );
  }
} 