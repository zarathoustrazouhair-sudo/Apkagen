import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:residence_lamandier_b/core/theme/app_palettes.dart';
import 'package:residence_lamandier_b/features/dashboard/presentation/widgets/apartment_grid.dart';
import 'package:residence_lamandier_b/features/dashboard/presentation/widgets/charts/cashflow_curve.dart';
import 'package:residence_lamandier_b/features/dashboard/presentation/widgets/charts/recovery_disk.dart';
import 'package:residence_lamandier_b/features/dashboard/presentation/widgets/kpi_cards.dart';
import 'package:residence_lamandier_b/features/dashboard/presentation/widgets/reminder_row.dart';
import 'package:residence_lamandier_b/features/dashboard/presentation/widgets/cockpit_active_widgets.dart';
import 'package:residence_lamandier_b/core/router/role_guards.dart';
import 'package:residence_lamandier_b/core/router/app_router.dart';
import 'package:residence_lamandier_b/features/incidents/presentation/incidents_screen.dart';
import 'package:residence_lamandier_b/features/tasks/presentation/tasks_screen.dart';

class CockpitScreen extends ConsumerWidget {
  const CockpitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRole = ref.watch(userRoleProvider);
    final canEditFinance = RoleGuards.canEditFinance(userRole);
    final canViewFinance = userRole != UserRole.concierge;

    return Scaffold(
      backgroundColor: AppPalettes.navy,
      floatingActionButton: canEditFinance
          ? FloatingActionButton(
              onPressed: () {
                context.push('/finance/add');
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
            // INTERACTIVE ACTIVE WIDGETS
            // Wrap in InkWell handled within CockpitActiveWidgets if possible, or wrap here.
            // Since CockpitActiveWidgets has multiple children, wrapping the whole thing goes to one place?
            // The plan says "Wrap SyndiMood -> Finance", "Incidents -> Incidents", "Actions -> Tasks".
            // Since CockpitActiveWidgets encapsulates them, we should modify it to accept callbacks or handle taps internally.
            // But for "Emergency Refactor", simpler to wrap the whole block or modify internal.
            // Let's modify CockpitActiveWidgets to be interactive.
            // Wait, I can't pass callbacks easily without refactoring CockpitActiveWidgets extensively.
            // I'll wrap CockpitActiveWidgets in a Column of InkWells if I can split it, or just rely on the user clicking the specific area?
            // Actually, `CockpitActiveWidgets` builds a `Column` of rows. I should ideally refactor it to return separate widgets.
            // For now, let's wrap the whole `CockpitActiveWidgets` in a GestureDetector that navigates to Incidents as a fallback? No, confusing.
            // I will update `CockpitActiveWidgets` to include the navigation logic directly.

            // Re-importing logic here to keep it simple:
            // Actually, I can just use `CockpitActiveWidgets` and let it handle taps if I update it.
            // I'll update `CockpitActiveWidgets` in the next write.
            CockpitActiveWidgets(hideFinance: !canViewFinance),

            const SizedBox(height: 24),

            if (canViewFinance) ...[
              InkWell(
                onTap: () => context.push('/finance'),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => AppPalettes.textGoldGradient,
                        child: const Text(
                          "SOLDE GLOBAL",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const KpiCards(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            const ReminderRow(),
            const SizedBox(height: 24),

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
            const ApartmentGrid(),
            const SizedBox(height: 24),

            if (canViewFinance) ...[
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
              InkWell(
                onTap: () => context.push('/finance'),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: RecoveryDisk()),
                    SizedBox(width: 8),
                    Expanded(child: CashflowCurve()),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }
}
