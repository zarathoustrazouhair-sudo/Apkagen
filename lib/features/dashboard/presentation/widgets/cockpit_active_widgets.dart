import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:residence_lamandier_b/core/theme/app_palettes.dart';
import 'package:residence_lamandier_b/data/local/database.dart';
import 'package:drift/drift.dart' as drift;

class CockpitActiveWidgets extends ConsumerWidget {
  const CockpitActiveWidgets({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);

    return Column(
      children: [
        // 1. SURVIVAL EMOJI ROW
        StreamBuilder<List<Transaction>>(
          stream: db.select(db.transactions).watch(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();

            final txs = snapshot.data!;
            double cash = 0.0;
            for (var tx in txs) {
              if (tx.type == 'income') cash += tx.amount;
              if (tx.type == 'expense') cash -= tx.amount;
            }

            String emoji = "😐";
            String status = "STABLE";
            Color color = Colors.orange;

            if (cash > 50000) {
              emoji = "🤑";
              status = "RICHE";
              color = Colors.greenAccent;
            } else if (cash > 10000) {
              emoji = "😎";
              status = "CONFORT";
              color = Colors.green;
            } else if (cash < 0) {
              emoji = "💀";
              status = "CRITIQUE";
              color = Colors.red;
            }

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppPalettes.offBlack.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("SANTÉ FINANCIÈRE", style: TextStyle(color: AppPalettes.offWhite.withOpacity(0.7), fontSize: 10)),
                      Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  Text(emoji, style: const TextStyle(fontSize: 32)),
                  Text("${cash.toStringAsFixed(0)} DH", style: TextStyle(color: AppPalettes.offWhite, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        // 2. INCIDENTS & TASKS
        StreamBuilder<List<Task>>(
          stream: (db.select(db.tasks)..where((t) => t.isCompleted.not())).watch(),
          builder: (context, snapshot) {
            final tasks = snapshot.data ?? [];
            final incidentCount = tasks.length; // Assume all open tasks are "incidents" or to-dos

            return Row(
              children: [
                // INCIDENTS COUNTER
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 100,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.5)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                        const SizedBox(height: 4),
                         // FIX OVERFLOW: Using FittedBox
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text("$incidentCount", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        ),
                        const Text("INCIDENTS", style: TextStyle(color: Colors.redAccent, fontSize: 8)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // AUTO TASKS LIST (Top 2)
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 100,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppPalettes.navy,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppPalettes.gold.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("ACTIONS REQUISES", style: TextStyle(color: AppPalettes.gold, fontSize: 10, fontWeight: FontWeight.bold)),
                            Icon(Icons.add_task, color: AppPalettes.gold.withOpacity(0.7), size: 14),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (tasks.isEmpty)
                          const Center(child: Text("Rien à signaler", style: TextStyle(color: Colors.grey, fontSize: 10)))
                        else
                          Expanded(
                            child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: tasks.take(2).length,
                              itemBuilder: (context, index) {
                                final task = tasks[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.circle, size: 6, color: Colors.orange),
                                      const SizedBox(width: 6),
                                      Expanded(child: Text(task.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 10))),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
