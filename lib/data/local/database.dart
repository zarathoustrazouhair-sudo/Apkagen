import 'dart:io';
import 'dart:math';
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

class Providers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get serviceType => text()(); // 'Plomberie', 'Electricité', 'Autre'
  TextColumn get phone => text().nullable()();
}

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get floor => integer()();
  IntColumn get apartmentNumber => integer().nullable()();
  TextColumn get role => text()();
  RealColumn get balance => real().withDefault(const Constant(0.0))();
  TextColumn get phoneNumber => text().nullable()();
  // Add other fields if needed, but these are minimal
  TextColumn get accessCode => text().nullable()();
  BoolColumn get isBlocked => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [MutationQueue, Tasks, Users, AppSettings, Transactions, Providers])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.createTable(transactions);
      }
      if (from < 3) {
        await m.addColumn(users, users.phoneNumber);
      }
      if (from < 4) {
        await m.addColumn(users, users.balance);
        await m.addColumn(users, users.accessCode);
        await m.addColumn(users, users.isBlocked);
      }
      if (from < 5) {
        await m.createTable(providers);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');

      // Force populate if residents are missing
      // We check specifically for residents to avoid false positives with just admin user
      final residentCount = await (select(users)..where((t) => t.role.equals('resident'))).get().then((l) => l.length);

      if (residentCount < 5) {
         // If we have fewer than 5 residents, assume data is corrupted or missing -> Seed
         // We might want to clear existing to avoid duplicates if IDs clash, or use INSERT OR REPLACE
         await _populateResidents();
      }

      try {
        final txCount = await (select(transactions).get()).then((l) => l.length);
        if (txCount < 5) {
          await _populateTransactions();
        }
      } catch (e) {
        print('Error checking transactions: $e');
      }
    },
  );

  Future<void> _populateResidents() async {
     await batch((batch) {
      // 1. Insert Residents from Constant
      for (final resident in kInitialResidents) {
        // Random balance for realism: between -2000 (debt) and 500 (credit)
        final randomBalance = (Random().nextInt(2500) - 2000).toDouble();

        batch.insert(
          users,
          UsersCompanion.insert(
            id: Value(resident.id), // Force ID for consistency
            name: resident.name,
            floor: Value(resident.floor),
            apartmentNumber: Value(resident.aptNumber),
            role: Value(resident.role),
            balance: Value(randomBalance),
            phoneNumber: const Value("0600000000"),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }

      // 2. Insert Staff
      // Adjoint
      batch.insert(
        users,
        UsersCompanion.insert(
          id: const Value(100),
          name: kAdjointName,
          role: const Value('adjoint'),
          balance: const Value(0.0),
          phoneNumber: const Value("0600000000"),
        ),
        mode: InsertMode.insertOrReplace,
      );
      // Concierge
      batch.insert(
        users,
        UsersCompanion.insert(
          id: const Value(101),
          name: "Gardien Principal",
          role: const Value('concierge'),
          balance: const Value(0.0),
          phoneNumber: const Value("0600000000"),
        ),
        mode: InsertMode.insertOrReplace,
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
          mode: InsertMode.insertOrReplace,
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
