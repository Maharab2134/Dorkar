import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool animate;
  final Color? primaryColor;
  final Color? secondaryColor;

  const AppLogo({
    super.key,
    this.size = 120,
    this.animate = true,
    this.primaryColor,
    this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final primary = primaryColor ?? Theme.of(context).primaryColor;
    final secondary = secondaryColor ?? Colors.white;

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: animate ? 1 : 1),
      duration: const Duration(milliseconds: 1500),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primary,
                  primary.withOpacity(0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.handyman_rounded,
                    size: size * 0.5,
                    color: secondary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'DORKAR',
                    style: TextStyle(
                      color: secondary,
                      fontSize: size * 0.2,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
} 