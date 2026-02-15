import 'dart:io';
import 'dart:math';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:residence_lamandier_b/core/sync/mutation_queue_entity.dart';
import 'package:residence_lamandier_b/features/tasks/data/task_entity.dart';
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

class ServiceProviders extends Table {
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
  TextColumn get accessCode => text().nullable()();
  BoolColumn get isBlocked => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [MutationQueue, Tasks, Users, AppSettings, Transactions, ServiceProviders])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 6;

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
        await m.createTable(serviceProviders);
      }
      if (from < 6) {
         // Migration for v6: Add 'type' and 'authorId' to tasks if missing
         // Note: If columns already exist (e.g., from dev), try/catch or check.
         // Assuming clean migration path or recreation.
         try {
           await m.addColumn(tasks, tasks.type as GeneratedColumn<Object>);
           await m.addColumn(tasks, tasks.authorId as GeneratedColumn<Object>);
         } catch (e) {
           // Ignore if column already exists
           print("Migration error (column might exist): $e");
         }
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');

      // Force populate if database is empty
      // Check for residents specifically
      final residentCount = await (select(users)..where((t) => t.role.equals('resident'))).get().then((l) => l.length);

      // Also check transactions
      final transactionCount = await (select(transactions)).get().then((l) => l.length);

      if (residentCount < 5 || transactionCount < 5) {
         print("DATABASE SEEDING: Database appears empty or incomplete. Seeding initial data...");
         // Force insertion of residents and transactions
         await _populateInitialData();
      }
    },
  );

  Future<void> _populateInitialData() async {
     await batch((batch) {
      // 1. Insert Residents from Constant (15 residents)
      for (final resident in kInitialResidents) {
        // Random balance for realism: between -2000 (debt) and 500 (credit)
        final randomBalance = (Random().nextInt(2500) - 2000).toDouble();

        batch.insert(
          users,
          UsersCompanion.insert(
            id: Value(resident.id), // Force ID for consistency
            name: resident.name,
            floor: resident.floor, // Required int
            apartmentNumber: Value(resident.aptNumber),
            role: resident.role, // Required String
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
          floor: 0,
          role: 'adjoint',
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
          floor: 0,
          role: 'concierge',
          balance: const Value(0.0),
          phoneNumber: const Value("0600000000"),
        ),
        mode: InsertMode.insertOrReplace,
      );
    });

    // 3. Insert Transactions (AFTER users are inserted)
    await batch((batch) {
      // Create 10 transactions linked to the first 10 residents
      for (int i = 0; i < 10; i++) {
        final userId = (i % 15) + 1; // 1 to 15
        final isIncome = i % 2 == 0;

        batch.insert(
          transactions,
          TransactionsCompanion.insert(
            amount: (i + 1) * 100.0,
            date: DateTime.now().subtract(Duration(days: i * 2)),
            description: isIncome ? 'Cotisation Mensuelle' : 'Achat Petit Matériel',
            userId: Value(userId),
            type: isIncome ? 'income' : 'expense',
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });

    print("DATABASE SEEDING: Completed.");
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
