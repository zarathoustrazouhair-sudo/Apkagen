import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import 'package:residence_lamandier_b/core/theme/luxury_theme.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_card.dart';
import 'package:residence_lamandier_b/features/finance/data/finance_provider.dart';
import 'package:residence_lamandier_b/core/services/pdf_generator_service.dart';
import 'package:residence_lamandier_b/features/settings/data/app_settings_repository.dart';
import 'package:residence_lamandier_b/data/local/database.dart';
import 'package:residence_lamandier_b/core/router/role_guards.dart';
import 'package:residence_lamandier_b/core/router/app_router.dart';

class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _generateHallState(BuildContext context, WidgetRef ref) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Génération du PDF en cours...')));

      final db = ref.read(appDatabaseProvider);
      final settingsRepo = ref.read(appSettingsRepositoryProvider);
      final pdfService = PdfGeneratorService(settingsRepo);

      final residents = await (db.select(db.users)
        ..where((t) => t.role.equals('resident'))
        ..orderBy([(t) => drift.OrderingTerm(expression: t.apartmentNumber)])
      ).get();

      await pdfService.generateHallState(residents, DateTime.now());

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF généré avec succès !'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final userRole = ref.watch(userRoleProvider);
    final canEditFinance = RoleGuards.canEditFinance(userRole);

    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      appBar: AppBar(
        title: Text("FINANCES", style: AppTheme.luxuryTheme.textTheme.headlineMedium?.copyWith(color: AppTheme.gold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (canEditFinance)
            IconButton(
              icon: const Icon(Icons.print, color: AppTheme.gold),
              tooltip: "État Cotisations (Hall)",
              onPressed: () => _generateHallState(context, ref),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.gold,
          labelColor: AppTheme.gold,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "TRANSACTIONS"),
            Tab(text: "PRESTATAIRES"),
            Tab(text: "BUDGET"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: TRANSACTIONS LIST
          transactionsAsync.when(
            data: (transactions) {
              if (transactions.isEmpty) return const Center(child: Text("Aucune transaction.", style: TextStyle(color: Colors.white)));

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  final isIncome = tx.type == 'income';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: LuxuryCard(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                        Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: isIncome ? Colors.green : Colors.red),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tx.description, style: const TextStyle(color: AppTheme.offWhite, fontWeight: FontWeight.bold)),
                              Text("${tx.date.day}/${tx.date.month}/${tx.date.year}", style: TextStyle(color: AppTheme.offWhite.withValues(alpha: 0.6), fontSize: 12)),
                            ],
                          ),
                        ),
                        Text(
                          "${isIncome ? '+' : '-'}${tx.amount.toStringAsFixed(2)} DH",
                          style: TextStyle(color: isIncome ? const Color(0xFF00E5FF) : AppTheme.errorRed, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text("Erreur: $err", style: const TextStyle(color: Colors.red))),
          ),

          // TAB 2: PRESTATAIRES (Providers)
          const Center(child: Text("Liste des Prestataires (À venir)", style: TextStyle(color: Colors.white))),

          // TAB 3: BUDGET CONFIG
          const Center(child: Text("Configuration Budget (À venir)", style: TextStyle(color: Colors.white))),
        ],
      ),
      floatingActionButton: canEditFinance
        ? FloatingActionButton(
            onPressed: () => context.push('/finance/add'),
            backgroundColor: AppTheme.gold,
            child: const Icon(Icons.add, color: AppTheme.darkNavy),
          )
        : null,
    );
  }
}
