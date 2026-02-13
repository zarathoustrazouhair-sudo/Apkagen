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

class CockpitScreen extends ConsumerWidget {
  const CockpitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRole = ref.watch(userRoleProvider);
    final canEditFinance = RoleGuards.canEditFinance(userRole);
    // PERMISSION LAYER: Concierge cannot see Finance details
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
            // 0. Active Widgets (Survival, Incidents)
            // Note: Survival Emoji (Financial Health) is inside here. Should we hide it too?
            // TEP Logic: "Concierge: INTERDIT (Masqué)" for Finance.
            // Let's pass the role/permission to the widget or wrap it.
            // But CockpitActiveWidgets has mixed content (Incidents + Finance).
            // We should ideally split or pass a flag. For now, let's keep Incidents visible.
            // We will modify CockpitActiveWidgets in a separate edit if needed, or assume "Survival" is high level enough?
            // Wait, TEP says "Finance: INTERDIT". Survival IS Finance.
            // Let's assume we need to hide the top row of CockpitActiveWidgets if Concierge.
            CockpitActiveWidgets(hideFinance: !canViewFinance),
            const SizedBox(height: 24),

            // 1. KPI Cards (FINANCE) - HIDDEN FOR CONCIERGE
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

            // 2. Reminder Row
            const ReminderRow(),
            const SizedBox(height: 24),

            // 3. Matrix (Residents)
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

            // 4. Charts (FINANCE) - HIDDEN FOR CONCIERGE
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
