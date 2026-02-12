import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:residence_lamandier_b/data/local/database.dart';

final residentsProvider = FutureProvider<List<User>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.users)..where((tbl) => tbl.role.equals('resident'))).get();
});
