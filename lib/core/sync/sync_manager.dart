import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:residence_lamandier_b/data/local/database.dart';
import 'dart:convert';
import 'package:residence_lamandier_b/core/sync/mutation_queue_entity.dart';
import 'package:drift/drift.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

part 'sync_manager.g.dart';

@riverpod
SyncManager syncManager(SyncManagerRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return SyncManager(db);
}

class SyncManager {
  final AppDatabase _db;
  final supabase.SupabaseClient _client = supabase.Supabase.instance.client;

  SyncManager(this._db) {
    // Listen to connectivity changes
    Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        processQueue();
      }
    });
  }

  Future<void> enqueueMutation({
    required String type,
    required String payloadJson,
  }) async {
    await _db.into(_db.mutationQueue).insert(
      MutationQueueCompanion.insert(
        type: type,
        payloadJson: payloadJson,
        status: const Value('pending'),
      ),
    );
    // Try to process immediately if connected
    processQueue();
  }

  Future<void> processQueue() async {
    final pending = await (_db.select(_db.mutationQueue)
      ..where((tbl) => tbl.status.equals('pending')))
      .get();

    if (pending.isEmpty) return;

    // Check connectivity again before processing loop
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) return;

    for (var item in pending) {
      try {
        await _executeMutation(item);

        // Success: Mark as completed or Delete
        await (_db.delete(_db.mutationQueue)
          ..where((tbl) => tbl.id.equals(item.id)))
          .go();

      } catch (e) {
        // Failure: Increment retry count
        await (_db.update(_db.mutationQueue)
          ..where((tbl) => tbl.id.equals(item.id)))
          .write(MutationQueueCompanion(
            retryCount: Value(item.retryCount + 1),
            // Optionally set status to 'failed' after N retries
          ));
        // Stop processing to preserve order/consistency if needed, or continue
      }
    }
  }

  Future<void> _executeMutation(MutationQueueData item) async {
    final payload = jsonDecode(item.payloadJson);
    final table = payload['table'];
    final action = payload['action']; // 'insert', 'update', 'delete'
    final data = payload['data'];

    switch (action) {
      case 'insert':
        await _client.from(table).insert(data);
        break;
      case 'update':
        final id = payload['id'];
        await _client.from(table).update(data).eq('id', id);
        break;
      case 'delete':
        final id = payload['id'];
        await _client.from(table).delete().eq('id', id);
        break;
      default:
        throw Exception("Unknown mutation action: $action");
    }
  }
}
