import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:residence_lamandier_b/core/theme/luxury_theme.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_card.dart';
import 'package:residence_lamandier_b/features/finance/data/finance_provider.dart';

class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      appBar: AppBar(
        title: Text("FINANCES", style: AppTheme.luxuryTheme.textTheme.headlineMedium?.copyWith(color: AppTheme.gold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: transactionsAsync.when(
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
                          Text("${tx.date.day}/${tx.date.month}/${tx.date.year}", style: TextStyle(color: AppTheme.offWhite.withOpacity(0.6), fontSize: 12)),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/finance/add'),
        backgroundColor: AppTheme.gold,
        child: const Icon(Icons.add, color: AppTheme.darkNavy),
      ),
    );
  }
}
