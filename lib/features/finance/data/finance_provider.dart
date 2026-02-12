import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:residence_lamandier_b/data/local/database.dart';

// Stream of all transactions
final transactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.select(db.transactions).watch();
});

// Derived: Total Balance
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

// Derived: Survival (Assuming monthly burn rate of 10,000 DH for example)
// In a real app, this would be calculated from average expenses over time.
const kMonthlyBurnRate = 10000.0;

final monthlySurvivalProvider = Provider<AsyncValue<double>>((ref) {
  final balanceAsync = ref.watch(totalBalanceProvider);

  return balanceAsync.whenData((balance) {
    if (balance <= 0) return 0.0;
    return balance / kMonthlyBurnRate;
  });
});
