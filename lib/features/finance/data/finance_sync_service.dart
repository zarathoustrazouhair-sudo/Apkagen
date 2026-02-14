import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:drift/drift.dart' as drift;
import 'package:residence_lamandier_b/data/local/database.dart';

part 'finance_sync_service.g.dart';

@riverpod
FinanceSyncService financeSyncService(FinanceSyncServiceRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return FinanceSyncService(db);
}

class FinanceSyncService {
  final AppDatabase _db;
  final SupabaseClient _client = Supabase.instance.client;

  FinanceSyncService(this._db) {
    _initListener();
  }

  void _initListener() {
    // Listen to cloud changes on 'apartments_status' and update local DB
    _client
      .from('apartments_status')
      .stream(primaryKey: ['apartment_number'])
      .listen((List<Map<String, dynamic>> data) async {
        for (var row in data) {
          final aptNum = row['apartment_number'] as int;
          final balance = (row['current_balance'] as num).toDouble();

          // Find user by apartment number and update balance
          await (_db.update(_db.users)
            ..where((t) => t.apartmentNumber.equals(aptNum))
          ).write(UsersCompanion(balance: drift.Value(balance)));
        }
      });
  }

  // Called after local transaction
  Future<void> syncBalanceToCloud(int apartmentNumber, double newBalance) async {
    try {
      await _client.from('apartments_status').upsert({
        'apartment_number': apartmentNumber,
        'current_balance': newBalance,
        'last_updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print("Sync failed: $e");
    }
  }
}
