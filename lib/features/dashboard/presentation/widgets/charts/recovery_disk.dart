import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:residence_lamandier_b/core/theme/luxury_theme.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_card.dart';

class RecoveryDisk extends StatelessWidget {
  const RecoveryDisk({super.key});

  @override
  Widget build(BuildContext context) {
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
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 35,
                    startDegreeOffset: 270,
                    sections: [
                      PieChartSectionData(
                        color: const Color(0xFF00E5FF),
                        value: 75,
                        title: '',
                        radius: 12,
                      ),
                      PieChartSectionData(
                        color: const Color(0xFFFF0040),
                        value: 25,
                        title: '',
                        radius: 10,
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Text(
                    "75%",
                    style: TextStyle(
                      color: AppTheme.offWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Playfair Display',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.offWhite.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
