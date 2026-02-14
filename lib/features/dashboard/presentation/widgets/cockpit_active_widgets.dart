import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:residence_lamandier_b/core/theme/app_palettes.dart';
import 'package:residence_lamandier_b/data/local/database.dart';
import 'package:drift/drift.dart' as drift;
import 'package:residence_lamandier_b/features/dashboard/presentation/widgets/syndic_mood_widget.dart';

class CockpitActiveWidgets extends ConsumerWidget {
  final bool hideFinance;
  const CockpitActiveWidgets({super.key, this.hideFinance = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);

    return Column(
      children: [
        // 1. SURVIVAL EMOJI ROW (FINANCE) - HIDDEN IF hideFinance
        if (!hideFinance)
          const SyndicMoodWidget(),

        if (!hideFinance) const SizedBox(height: 16),

        // 2. INCIDENTS & TASKS
        StreamBuilder<List<Task>>(
          stream: (db.select(db.tasks)
            ..where((t) => t.isCompleted.not())
            ..orderBy([(t) => drift.OrderingTerm(expression: t.createdAt, mode: drift.OrderingMode.desc)])
          ).watch(),
          builder: (context, snapshot) {
            final tasks = snapshot.data ?? [];

            // FILTER: Real Incidents (type = 'incident')
            final realIncidents = tasks.where((t) => t.type == 'incident').toList();
            final incidentCount = realIncidents.length;

            // FILTER: Tasks/Todos (type = 'todo')
            final todoTasks = tasks.where((t) => t.type == 'todo' || t.type == null).toList();

            return Row(
              children: [
                // INCIDENTS COUNTER
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 100,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: incidentCount > 0 ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.2), // Green if 0 incidents
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: incidentCount > 0 ? Colors.red.withOpacity(0.5) : Colors.green.withOpacity(0.5)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          incidentCount > 0 ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                          color: incidentCount > 0 ? Colors.red : Colors.green,
                          size: 24
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "$incidentCount",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold
                              )
                            ),
                          ),
                        ),
                        const Text("INCIDENTS", style: TextStyle(color: Colors.white70, fontSize: 8), overflow: TextOverflow.ellipsis),
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
                        if (todoTasks.isEmpty)
                          const Center(child: Text("Rien à signaler", style: TextStyle(color: Colors.grey, fontSize: 10)))
                        else
                          Expanded(
                            child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: todoTasks.take(2).length,
                              itemBuilder: (context, index) {
                                final task = todoTasks[index];
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
