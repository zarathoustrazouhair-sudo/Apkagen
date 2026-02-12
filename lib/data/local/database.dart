import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:residence_lamandier_b/core/sync/mutation_queue_entity.dart';
import 'package:residence_lamandier_b/features/tasks/data/task_entity.dart';
import 'package:residence_lamandier_b/features/users/data/user_entity.dart';
import 'package:residence_lamandier_b/features/settings/data/app_settings_entity.dart';
import 'package:residence_lamandier_b/core/constants/initial_data.dart';

part 'database.g.dart';

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get description => text()();
  IntColumn get userId => integer().nullable().references(Users, #id)(); // Optional link
  TextColumn get type => text()(); // 'income', 'expense'
}

@DriftDatabase(tables: [MutationQueue, Tasks, Users, AppSettings, Transactions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.createTable(transactions);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');

      // Force populate if empty, regardless of creation status (safe check)
      final userCount = await (select(users).get()).then((l) => l.length);
      if (userCount == 0) {
         await _populateResidents();
      }

      // Check if transactions table exists (it should if migration ran) and is empty
      // To be safe we wrap in try-catch or just check count if table exists
      try {
        final txCount = await (select(transactions).get()).then((l) => l.length);
        if (txCount == 0) {
          await _populateTransactions();
        }
      } catch (e) {
        print('Error checking transactions: $e');
      }
    },
  );

  Future<void> _populateResidents() async {
     await batch((batch) {
      // 1. Insert Residents
      for (final resident in kInitialResidents) {
        batch.insert(
          users,
          UsersCompanion.insert(
            name: resident.name,
            floor: Value(resident.floor),
            apartmentNumber: Value(resident.aptNumber),
            role: Value(resident.role),
          ),
        );
      }

      // 2. Insert Staff
      // Adjoint
      batch.insert(
        users,
        UsersCompanion.insert(
          id: Value(100),
          name: kAdjointName,
          role: Value('adjoint'),
        ),
      );
      // Concierge
      batch.insert(
        users,
        UsersCompanion.insert(
          id: Value(101),
          name: "Gardien Principal",
          role: Value('concierge'),
        ),
      );
    });
  }

  Future<void> _populateTransactions() async {
    // We need residents to link transactions
    final allUsers = await select(users).get();
    if (allUsers.isEmpty) return;

    await batch((batch) {
      for (int i = 0; i < 10; i++) {
        final user = allUsers[i % allUsers.length];
        final isIncome = i % 2 == 0;
        batch.insert(
          transactions,
          TransactionsCompanion.insert(
            amount: (i + 1) * 100.0,
            date: DateTime.now().subtract(Duration(days: i * 2)),
            description: isIncome ? 'Cotisation ${user.name}' : 'Achat matériel',
            userId: Value(user.id),
            type: isIncome ? 'income' : 'expense',
          ),
        );
      }
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

@riverpod
AppDatabase appDatabase(AppDatabaseRef ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}
