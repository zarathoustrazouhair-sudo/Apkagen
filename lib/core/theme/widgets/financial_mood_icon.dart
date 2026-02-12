import 'package:flutter/material.dart';
import 'package:residence_lamandier_b/core/theme/luxury_theme.dart';

class FinancialMoodIcon extends StatelessWidget {
  final double monthsOfSurvival;
  final double size;

  const FinancialMoodIcon({super.key, required this.monthsOfSurvival, this.size = 24.0});

  @override
  Widget build(BuildContext context) {
    if (monthsOfSurvival >= 3.0) {
      // GREEN: Happy / Relaxed
      return Icon(
        Icons.sentiment_very_satisfied,
        color: const Color(0xFF00E5FF), // Cyan/Greenish
        size: size,
      );
    } else if (monthsOfSurvival >= 0.0) {
      // ORANGE: Stress / Sweating (Simulated with neutral + color)
      return Icon(
        Icons.sentiment_neutral,
        color: const Color(0xFFFFAB00), // Amber/Orange
        size: size,
      );
    } else {
      // RED: Panic / Siren
      return Icon(
        Icons.add_alert, // Alert Siren equivalent
        color: AppTheme.errorRed,
        size: size,
      );
    }
  }
}
