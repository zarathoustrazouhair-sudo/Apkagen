import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:residence_lamandier_b/core/theme/app_palettes.dart';
import 'package:residence_lamandier_b/data/local/database.dart';
import 'package:drift/drift.dart' as drift;

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);

    return Scaffold(
      backgroundColor: AppPalettes.navy,
      appBar: AppBar(
        title: const Text("TÂCHES & ACTIONS", style: TextStyle(color: AppPalettes.gold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<List<Task>>(
        stream: (db.select(db.tasks)
          ..where((t) => t.type.equals('todo')) // Only Todos
          ..orderBy([(t) => drift.OrderingTerm(expression: t.createdAt, mode: drift.OrderingMode.desc)])
        ).watch(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final tasks = snapshot.data!;
          if (tasks.isEmpty) return const Center(child: Text("Aucune tâche.", style: TextStyle(color: Colors.white)));

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ListTile(
                leading: const Icon(Icons.check_circle_outline, color: AppPalettes.gold),
                title: Text(task.description, style: const TextStyle(color: Colors.white)),
                // Add logic for "Public Note" / "Action Requise" if needed
              );
            },
          );
        },
      ),
    );
  }
}
