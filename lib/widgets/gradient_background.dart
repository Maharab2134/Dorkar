import 'package:flutter/material.dart';
import '../constants/my_colors.dart';

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
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isAppBar
              ? [softBlue, darkBlue]
              : [Colors.white, softBlue.withOpacity(0.1)],
        ),
      ),
      child: child,
    );
  }
} 