import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:drift/drift.dart';
import 'package:residence_lamandier_b/data/local/database.dart';

part 'app_settings_repository.g.dart';

@riverpod
AppSettingsRepository appSettingsRepository(AppSettingsRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return AppSettingsRepository(db);
}

class AppSettingsRepository {
  final AppDatabase _db;

  AppSettingsRepository(this._db);

  Future<void> saveSetting(String key, String value) async {
    await _db.into(_db.appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(key: key, value: value),
    );
  }

  Future<String?> getSetting(String key) async {
    final result = await (_db.select(_db.appSettings)..where((t) => t.key.equals(key))).getSingleOrNull();
    return result?.value;
  }

  // Monthly Fee per resident (Income side)
  Future<double> getMonthlyFee() async {
    final val = await getSetting('monthly_fee');
    return double.tryParse(val ?? '250.0') ?? 250.0;
  }

  // Monthly Fixed Costs (Expense side: Concierge + Cleaning + etc)
  Future<double> getMonthlyFixedCosts() async {
    final val = await getSetting('monthly_fixed_costs');
    return double.tryParse(val ?? '0.0') ?? 0.0;
  }

  Future<void> setMonthlyFixedCosts(double amount) async {
    await saveSetting('monthly_fixed_costs', amount.toString());
  }

  Future<void> setAdminPassword(String password) async {
    await saveSetting('admin_password', password);
  }

  Future<bool> verifyAdminPassword(String password) async {
    final stored = await getSetting('admin_password');
    return stored == password;
  }

  Future<bool> isSetupCompleted() async {
    final val = await getSetting('setup_completed');
    return val == 'true';
  }

  Future<void> completeSetup() async {
    await saveSetting('setup_completed', 'true');
  }
}
