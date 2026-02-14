import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:residence_lamandier_b/core/theme/app_palettes.dart';
import 'package:residence_lamandier_b/features/dashboard/presentation/widgets/cockpit_active_widgets.dart'; // We can reuse logic or components
import 'package:residence_lamandier_b/data/local/database.dart';
import 'package:drift/drift.dart' as drift;

class IncidentsScreen extends ConsumerWidget {
  const IncidentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);

    return Scaffold(
      backgroundColor: AppPalettes.navy,
      appBar: AppBar(
        title: const Text("INCIDENTS", style: TextStyle(color: AppPalettes.gold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<List<Task>>(
        stream: (db.select(db.tasks)
          ..where((t) => t.type.equals('incident'))
          ..orderBy([(t) => drift.OrderingTerm(expression: t.createdAt, mode: drift.OrderingMode.desc)])
        ).watch(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final incidents = snapshot.data!;
          if (incidents.isEmpty) return const Center(child: Text("Aucun incident.", style: TextStyle(color: Colors.white)));

          return ListView.builder(
            itemCount: incidents.length,
            itemBuilder: (context, index) {
              final incident = incidents[index];
              return Card(
                color: Colors.black26,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.warning, color: Colors.red),
                  title: Text(incident.description, style: const TextStyle(color: Colors.white)),
                  trailing: Checkbox(
                    value: incident.isCompleted,
                    activeColor: Colors.green,
                    onChanged: (val) {
                      (db.update(db.tasks)..where((t) => t.id.equals(incident.id))).write(
                        TasksCompanion(isCompleted: drift.Value(val!)),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
