import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:residence_lamandier_b/core/theme/luxury_theme.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_card.dart';
import 'package:residence_lamandier_b/features/finance/data/finance_provider.dart';

class RecoveryDisk extends ConsumerWidget {
  const RecoveryDisk({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(recoveryStatsProvider);

    return LuxuryCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "RECOUVREMENT",
            style: TextStyle(
              color: AppTheme.offWhite.withOpacity(0.6),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: statsAsync.when(
              data: (stats) {
                final paid = stats['paid']!;
                final unpaid = stats['unpaid']!;
                final percentage = stats['percentage']!;

                // Avoid empty chart if no data
                if (paid == 0 && unpaid == 0) {
                  return const Center(child: Text("Pas de données", style: TextStyle(color: Colors.white)));
                }

                return Stack(
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 4,
                        centerSpaceRadius: 35,
                        startDegreeOffset: 270,
                        sections: [
                          PieChartSectionData(
                            color: const Color(0xFF00E5FF),
                            value: paid,
                            title: '',
                            radius: 12,
                          ),
                          PieChartSectionData(
                            color: const Color(0xFFFF0040),
                            value: unpaid,
                            title: '',
                            radius: 10,
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: Text(
                        "${percentage.toInt()}%",
                        style: const TextStyle(
                          color: AppTheme.offWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Playfair Display',
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              error: (err, stack) => const Center(child: Icon(Icons.error, color: Colors.red)),
            ),
          ),
        ],
      ),
    );
  }
}
