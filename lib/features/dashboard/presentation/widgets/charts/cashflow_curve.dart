import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:residence_lamandier_b/core/theme/app_palettes.dart';
import 'package:residence_lamandier_b/core/theme/luxury_widgets.dart';
import 'package:residence_lamandier_b/features/finance/data/finance_provider.dart';

class CashflowCurve extends ConsumerWidget {
  const CashflowCurve({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(cashflowHistoryProvider);

    return LuxuryCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "FLUX DE TRÉSORERIE (6 MOIS)",
            style: TextStyle(
              color: AppPalettes.offWhite.withOpacity(0.6),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          AspectRatio(
            aspectRatio: 1.70,
            child: historyAsync.when(
              data: (history) {
                if (history.every((e) => e == 0)) return const Center(child: Text("Pas de données", style: TextStyle(color: Colors.white)));

                // Calculate spots
                final spots = <FlSpot>[];
                double maxVal = 0;
                for (int i = 0; i < history.length; i++) {
                  double val = history[i];
                  spots.add(FlSpot(i.toDouble(), val));
                  if (val.abs() > maxVal) maxVal = val.abs();
                }

                // Add some buffer to maxVal
                if (maxVal == 0) maxVal = 100;
                maxVal = maxVal * 1.2;

                return LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: maxVal / 4,
                      verticalInterval: 1,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: AppPalettes.offWhite.withOpacity(0.1),
                        strokeWidth: 1,
                      ),
                      getDrawingVerticalLine: (value) => FlLine(
                        color: AppPalettes.offWhite.withOpacity(0.1),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 1,
                          getTitlesWidget: (value, meta) => bottomTitleWidgets(value, meta, context),
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: maxVal / 4,
                          getTitlesWidget: (value, meta) => leftTitleWidgets(value, meta, maxVal),
                          reservedSize: 42,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: const Color(0xff37434d)),
                    ),
                    minX: 0,
                    maxX: 5,
                    minY: -maxVal,
                    maxY: maxVal,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00FF88), Color(0xFF00E5FF)],
                        ),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF00FF88).withOpacity(0.3),
                              const Color(0xFF00E5FF).withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => const Center(child: Icon(Icons.error)),
            ),
          ),
        ],
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta, BuildContext context) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 10,
      color: Colors.grey,
    );

    // Map index 0-5 to Month Names
    final now = DateTime.now();
    final monthIndex = (now.month - (5 - value.toInt()) - 1) % 12;
    // Month array
    const months = ['JAN', 'FEV', 'MAR', 'AVR', 'MAI', 'JUN', 'JUL', 'AOU', 'SEP', 'OCT', 'NOV', 'DEC'];

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(months[monthIndex], style: style),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta, double maxVal) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 8,
      color: Colors.grey,
    );

    // Simplified formatter K
    String text = "${(value / 1000).toStringAsFixed(0)}k";
    if (value == 0) text = "0";

    return Text(text, style: style, textAlign: TextAlign.left);
  }
}
