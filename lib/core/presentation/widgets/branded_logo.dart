import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// A premium, branded logo for Session Guard.
/// Uses layered icons and gradients to create a high-fidelity visual identity.
class BrandedLogo extends StatelessWidget {
  final double size;
  final bool showShadow;

  const BrandedLogo({super.key, this.size = 72, this.showShadow = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                  blurRadius: size * 0.33,
                  offset: Offset(0, size * 0.11),
                ),
              ]
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background subtle pattern/glow
          Icon(
            Icons.shield_rounded,
            color: Colors.white.withValues(alpha: 0.2),
            size: size * 0.7,
          ),
          // Main Icon
          Icon(Icons.shield_rounded, color: Colors.white, size: size * 0.5),
          // Inner detail
          Positioned(
            bottom: size * 0.3,
            child: Container(
              width: size * 0.15,
              height: size * 0.04,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
