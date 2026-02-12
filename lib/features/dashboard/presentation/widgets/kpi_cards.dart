import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:residence_lamandier_b/core/theme/luxury_theme.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_card.dart';
import 'package:residence_lamandier_b/core/theme/widgets/financial_mood_icon.dart';
import 'package:residence_lamandier_b/features/finance/data/finance_provider.dart';

class KpiCards extends ConsumerWidget {
  const KpiCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(totalBalanceProvider);
    final survivalAsync = ref.watch(monthlySurvivalProvider);

    final currencyFormat = NumberFormat.currency(locale: 'fr_MA', symbol: 'DH', decimalDigits: 2);

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
                balanceAsync.when(
                  data: (balance) => Text(
                    currencyFormat.format(balance),
                    style: TextStyle(
                      color: balance >= 0 ? AppTheme.gold : AppTheme.errorRed,
                      fontSize: 18, // Reduced slightly to fit
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Playfair Display',
                    ),
                  ),
                  loading: () => const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  error: (err, stack) => const Text("Erreur", style: TextStyle(color: Colors.red, fontSize: 10)),
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
                survivalAsync.when(
                  data: (months) => Row(
                    children: [
                      FinancialMoodIcon(monthsOfSurvival: months, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        "${months.toStringAsFixed(1)} MOIS",
                        style: const TextStyle(
                          color: AppTheme.offWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  loading: () => const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  error: (err, stack) => const Text("-", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
