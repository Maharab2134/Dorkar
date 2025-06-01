import 'package:flutter/material.dart';
import '../constants/my_colors.dart';

class AnimatedCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool isGradient;
  final double elevation;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.isGradient = false,
    this.elevation = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: isGradient
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      softBlue.withOpacity(0.8),
                      darkBlue,
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      vanilla,
                      vanilla.withOpacity(0.9),
                    ],
                  ),
          ),
          child: child,
        ),
      ),
    );
  }
} 