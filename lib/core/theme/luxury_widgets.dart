import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:residence_lamandier_b/core/theme/app_palettes.dart';

class LuxuryCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const LuxuryCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: AppPalettes.navy.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppPalettes.gold.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }
    return card;
  }
}

class GoldButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const GoldButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: AppPalettes.goldGradient,
        boxShadow: [
          BoxShadow(
            color: AppPalettes.gold.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppPalettes.navy,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: AppPalettes.navy),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      color: AppPalettes.navy,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final double monthsOfSurvival;

  const StatusBadge({super.key, required this.monthsOfSurvival});

  @override
  Widget build(BuildContext context) {
    // Divine (> 6 months)
    if (monthsOfSurvival > 6) {
      return const Icon(Icons.workspace_premium, color: AppPalettes.gold, size: 24);
    }
    // Healthy (> 3 months)
    if (monthsOfSurvival > 3) {
      return const Icon(Icons.sentiment_very_satisfied, color: AppPalettes.green, size: 24);
    }
    // Stable (> 1 month)
    if (monthsOfSurvival > 1) {
      return const Icon(Icons.sentiment_satisfied, color: AppPalettes.green, size: 24);
    }
    // Warning (> 0)
    if (monthsOfSurvival > 0) {
      return const Icon(Icons.sentiment_neutral, color: Colors.orange, size: 24);
    }
    // Critical (< 0)
    return const Icon(Icons.warning_amber_rounded, color: AppPalettes.red, size: 24);
  }
}
