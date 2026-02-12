import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:residence_lamandier_b/data/local/database.dart';
import 'package:residence_lamandier_b/features/tasks/data/task_entity.dart';
import 'package:drift/drift.dart';

part 'tasks_viewmodel.g.dart';

@riverpod
class TasksViewModel extends _$TasksViewModel {
  @override
  Stream<List<Task>> build() {
    final db = ref.watch(appDatabaseProvider);
    return (db.select(db.tasks)
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<void> addTask(String description) async {
    final db = ref.read(appDatabaseProvider);
    await db.into(db.tasks).insert(
          TasksCompanion.insert(description: description),
        );
  }

  Future<void> toggleTask(int id, bool isCompleted) async {
    final db = ref.read(appDatabaseProvider);
    await (db.update(db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(isCompleted: Value(isCompleted)),
    );
  }
}

@riverpod
Stream<int> activeTaskCount(ActiveTaskCountRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.selectOnly(db.tasks)
        ..addColumns([db.tasks.id.count()])
        ..where(db.tasks.isCompleted.equals(false)))
      .map((row) => row.read(db.tasks.id.count()) ?? 0)
      .watchSingle();
}
