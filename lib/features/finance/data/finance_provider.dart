import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:residence_lamandier_b/data/local/database.dart';

// Stream of all transactions
final transactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.select(db.transactions).watch();
});

// Derived: Total Balance
// Explicitly using Riverpod's Provider to avoid conflict if any (though renaming Providers table solved the main one)
final totalBalanceProvider = Provider<AsyncValue<double>>((ref) {
  final transactionsAsync = ref.watch(transactionsProvider);

  return transactionsAsync.whenData((transactions) {
    if (transactions.isEmpty) return 0.0;

    double total = 0.0;
    for (var t in transactions) {
      if (t.type == 'income') {
        total += t.amount;
      } else {
        total -= t.amount;
      }
    }
    return total;
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
  final residents = await (db.select(db.users)..where((t) => t.role.equals('resident'))).get();

  if (residents.isEmpty) return {'paid': 0.0, 'unpaid': 0.0, 'percentage': 0.0};

  int paidCount = 0;
  for (var r in residents) {
    if (r.balance >= 0) paidCount++;
  }

  double percentage = (paidCount / residents.length) * 100;
  return {
    'paid': paidCount.toDouble(),
    'unpaid': (residents.length - paidCount).toDouble(),
    'percentage': percentage,
  };
});

// Derived: Cashflow History
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
          monthlyNet[index] += t.amount; // t.amount is double, list is double
        } else {
          monthlyNet[index] -= t.amount;
        }
      }
    }
    return monthlyNet;
  });
});
