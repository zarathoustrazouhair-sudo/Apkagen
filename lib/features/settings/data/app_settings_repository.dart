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

  Future<double> getMonthlyFee() async {
    final val = await getSetting('monthly_fee');
    return double.tryParse(val ?? '250.0') ?? 250.0;
  }
}
