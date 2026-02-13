import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart';
import 'package:residence_lamandier_b/data/local/database.dart';

// Stream of all transactions
final transactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.select(db.transactions).watch();
});

// Derived: Total Balance (OPTIMIZED SQL)
final totalBalanceProvider = StreamProvider<double>((ref) {
  final db = ref.watch(appDatabaseProvider);

  return db.customSelect(
    'SELECT '
    '(SELECT COALESCE(SUM(amount), 0) FROM transactions WHERE type = \'income\') - '
    '(SELECT COALESCE(SUM(amount), 0) FROM transactions WHERE type = \'expense\') AS total'
  ).watch().map((rows) {
    if (rows.isEmpty) return 0.0;
    return rows.first.read<double>('total');
  });
});

// Derived: Survival
const kMonthlyBurnRate = 10000.0;

final monthlySurvivalProvider = Provider<AsyncValue<double>>((ref) {
  final balanceAsync = ref.watch(totalBalanceProvider);

  return balanceAsync.whenData((balance) {
    if (balance <= 0) return 0.0;
    return balance / kMonthlyBurnRate;
  });
});

// Derived: Recovery Stats
final recoveryStatsProvider = FutureProvider<Map<String, double>>((ref) async {
  final db = ref.watch(appDatabaseProvider);

  final residentCountQuery = await (db.selectOnly(db.users)
    ..addColumns([db.users.id.count()])
    ..where(db.users.role.equals('resident'))
  ).getSingle();

  final residentCount = residentCountQuery.read(db.users.id.count()) ?? 0; // Fix null safety

  if (residentCount == 0) return {'paid': 0.0, 'unpaid': 0.0, 'percentage': 0.0};

  final paidCountQuery = await (db.selectOnly(db.users)
    ..addColumns([db.users.id.count()])
    ..where(db.users.balance.isBiggerOrEqualValue(0.0) & db.users.role.equals('resident'))
  ).getSingle();

  final paidCount = paidCountQuery.read(db.users.id.count()) ?? 0; // Fix null safety

  double percentage = (paidCount / residentCount) * 100;
  return {
    'paid': paidCount.toDouble(),
    'unpaid': (residentCount - paidCount).toDouble(),
    'percentage': percentage,
  };
});

// Derived: Cashflow History
// Keeping this in Dart for now as complex date grouping in SQLite varies by platform
final cashflowHistoryProvider = Provider<AsyncValue<List<double>>>((ref) {
  final transactionsAsync = ref.watch(transactionsProvider);

  return transactionsAsync.whenData((transactions) {
    final now = DateTime.now();
    List<double> monthlyNet = List.filled(6, 0.0);

    for (var t in transactions) {
      final diffInMonths = (now.year - t.date.year) * 12 + now.month - t.date.month;

      if (diffInMonths >= 0 && diffInMonths < 6) {
        final index = 5 - diffInMonths;
        if (t.type == 'income') {
          monthlyNet[index] += t.amount;
        } else {
          monthlyNet[index] -= t.amount;
        }
      }
    }
    return monthlyNet;
  });
});
