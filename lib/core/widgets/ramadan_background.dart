import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fazakkir/core/theme/app_colors.dart';

class RamadanBackground extends StatelessWidget {
  final Widget child;
  final bool showGradient;

  const RamadanBackground({
    super.key,
    required this.child,
    this.showGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Background Image
        Positioned.fill(
          child: Opacity(
            opacity: 0.1,
            child: Image.asset("assets/images/bg.png", fit: BoxFit.cover),
          ),
        ),

        // Islamic Pattern Overlay (Subtle)
        Positioned.fill(
          child: Opacity(
            opacity: 0.05,
            child: SvgPicture.asset(
              "assets/images/prayer_header_pattern.svg",
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                isDark ? Colors.white : AppColors.islamicBrown,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),

        // I need to add SvgPicture, so I need to import flutter_svg
        // Let's do the import first in a separate step or assume I can rewrite the whole file.
        // Rewriting the whole file is safer to include imports.

        // Gradient Overlay REMOVED

        // Decorative Elements (Ramadan Vibes)
        // Top Right Lantern
        Positioned(
          top: -20,
          right: 20,
          child: Opacity(
            opacity: 0.8,
            child: Image.asset(
              "assets/images/lantern.png", // Assuming we have or will use a shape
              width: 80,
              errorBuilder: (_, __, ___) => const SizedBox(), // Safe fail
            ),
          ),
        ),

        // Scattered Stars (Icons)
        Positioned(
          top: 80,
          left: 30,
          child: Opacity(
            opacity: 0.2,
            child: Icon(
              Icons.star,
              size: 20,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
        Positioned(
          top: 150,
          right: 100,
          child: Opacity(
            opacity: 0.15,
            child: Icon(
              Icons.star_border,
              size: 15,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
        Positioned(
          top: 40,
          left: 120,
          child: Opacity(
            opacity: 0.1,
            child: Icon(
              Icons.nightlight_round,
              size: 25,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),

        // Content
        Positioned.fill(child: child),
      ],
    );
  }
}
