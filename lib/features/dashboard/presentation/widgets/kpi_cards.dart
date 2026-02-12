import 'package:flutter/material.dart';
import 'package:residence_lamandier_b/core/theme/luxury_theme.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_card.dart';
import 'package:residence_lamandier_b/core/theme/widgets/financial_mood_icon.dart';

class KpiCards extends StatelessWidget {
  const KpiCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Solde Global Card
        Expanded(
          child: LuxuryCard(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "SOLDE GLOBAL",
                  style: TextStyle(
                    color: AppTheme.offWhite.withOpacity(0.6),
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "124,500 DH",
                  style: TextStyle(
                    color: AppTheme.gold,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Playfair Display',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Survival Months Card
        Expanded(
          child: LuxuryCard(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "SURVIE (MOIS)",
                  style: TextStyle(
                    color: AppTheme.offWhite.withOpacity(0.6),
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const FinancialMoodIcon(monthsOfSurvival: 4.5, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      "4.5 MOIS",
                      style: TextStyle(
                        color: AppTheme.offWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
