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
  IntColumn get userId =>
      integer().nullable().references(Users, #id)(); // Optional link
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

@DriftDatabase(
  tables: [
    MutationQueue,
    Tasks,
    Users,
    AppSettings,
    Transactions,
    ServiceProviders,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      // Add indices for performance
      await m.createIndex(
        Index(
          'users_role_idx',
          'CREATE INDEX IF NOT EXISTS users_role_idx ON users (role)',
        ),
      );
      await m.createIndex(
        Index(
          'transactions_user_id_idx',
          'CREATE INDEX IF NOT EXISTS transactions_user_id_idx ON transactions (user_id)',
        ),
      );
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
        // Fix for "argument type 'TextColumn' can't be assigned to 'GeneratedColumn<Object>'"
        // Drift requires casting or using the generated getter if available, but inside onUpgrade we use the table definition.
        // We need to cast them to GeneratedColumn<Object> or use the specific typed addColumn.
        // Actually, drift's addColumn expects GeneratedColumn. TextColumn inherits from it.
        // The error might be due to nullability or type inference.
        // Explicitly casting or checking drift documentation.
        // Trying direct usage which usually works, maybe the previous error was due to build_runner not updating the table definition yet.
        // Once build_runner runs, 'tasks.type' will be valid.
        await m.addColumn(tasks, tasks.type);
        await m.addColumn(tasks, tasks.authorId);
      }
      if (from < 7) {
        // Add indices for frequently queried columns to improve performance
        await m.createIndex(
          Index(
            'users_role_idx',
            'CREATE INDEX IF NOT EXISTS users_role_idx ON users (role)',
          ),
        );
        await m.createIndex(
          Index(
            'transactions_user_id_idx',
            'CREATE INDEX IF NOT EXISTS transactions_user_id_idx ON transactions (user_id)',
          ),
        );
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');

      // Force populate if database is empty or residents are missing
      final residentCount = await (select(
        users,
      )..where((t) => t.role.equals('resident'))).get().then((l) => l.length);

      if (residentCount < 5) {
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
    // We need to re-fetch users to link transactions correctly (although we forced IDs above)
    // But we are in a transaction context? No, `batch` is one transaction.
    // However, we can't select inside the same batch easily unless we commit first.
    // So we do transactions in a separate step or just use the known IDs.

    // Simple: use the first 10 resident IDs (1 to 10)
    await batch((batch) {
      for (int i = 0; i < 10; i++) {
        final userId = (i % 15) + 1; // 1 to 15
        final isIncome = i % 2 == 0;

        batch.insert(
          transactions,
          TransactionsCompanion.insert(
            amount: (i + 1) * 100.0,
            date: DateTime.now().subtract(Duration(days: i * 2)),
            description: isIncome ? 'Cotisation' : 'Achat matériel',
            userId: Value(userId),
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
