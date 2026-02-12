import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:residence_lamandier_b/core/theme/app_palettes.dart';
import 'package:residence_lamandier_b/core/theme/luxury_widgets.dart';
import 'package:residence_lamandier_b/features/dashboard/presentation/widgets/apartment_grid.dart';
import 'package:residence_lamandier_b/features/dashboard/presentation/widgets/charts/cashflow_curve.dart';
import 'package:residence_lamandier_b/features/dashboard/presentation/widgets/charts/recovery_disk.dart';
import 'package:residence_lamandier_b/features/dashboard/presentation/widgets/kpi_cards.dart';
import 'package:residence_lamandier_b/features/dashboard/presentation/widgets/reminder_row.dart';
import 'package:residence_lamandier_b/core/router/role_guards.dart';
import 'package:residence_lamandier_b/core/router/app_router.dart';

class CockpitScreen extends ConsumerWidget {
  const CockpitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRole = ref.watch(userRoleProvider);
    final canEditFinance = RoleGuards.canEditFinance(userRole);

    return Scaffold(
      backgroundColor: AppPalettes.navy,
      floatingActionButton: canEditFinance
          ? FloatingActionButton(
              onPressed: () {
                // Add Finance Transaction
              },
              backgroundColor: AppPalettes.gold,
              child: const Icon(Icons.add, color: AppPalettes.navy),
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. KPI Cards with Gold Shimmer Title
            ShaderMask(
              shaderCallback: (bounds) => AppPalettes.textGoldGradient,
              child: const Text(
                "SOLDE GLOBAL",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: Colors.white, // Required for ShaderMask
                ),
              ),
            ),
            const SizedBox(height: 8),
            const KpiCards(),
            const SizedBox(height: 16),

            // 2. Reminder Row
            const ReminderRow(),
            const SizedBox(height: 24),

            // 3. Matrix
            Text(
              "MATRICE RÉSIDENTS",
              style: TextStyle(
                color: AppPalettes.offWhite.withOpacity(0.7),
                fontSize: 12,
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const ApartmentGrid(), // Updated internally to use StatusBadge or logic if needed
            const SizedBox(height: 24),

            // 4. Charts
             Text(
              "ANALYSE FINANCIÈRE",
              style: TextStyle(
                color: AppPalettes.offWhite.withOpacity(0.7),
                fontSize: 12,
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: RecoveryDisk()),
                SizedBox(width: 8),
                Expanded(child: CashflowCurve()),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
