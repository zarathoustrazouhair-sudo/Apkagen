import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import 'package:residence_lamandier_b/core/theme/luxury_theme.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_card.dart';
import 'package:residence_lamandier_b/data/local/database.dart';

class ResidentListScreen extends ConsumerWidget {
  const ResidentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      appBar: AppBar(
        title: Text("RÉSIDENTS", style: AppTheme.luxuryTheme.textTheme.headlineMedium?.copyWith(color: AppTheme.gold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<List<User>>(
        stream: (db.select(db.users)
          ..where((t) => t.role.equals('resident'))
          ..orderBy([(t) => drift.OrderingTerm(expression: t.apartmentNumber)])
        ).watch(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final residents = snapshot.data!;
          if (residents.isEmpty) return const Center(child: Text("Aucun résident.", style: TextStyle(color: Colors.white)));

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 columns
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: residents.length,
            itemBuilder: (context, index) {
              final resident = residents[index];
              final isDebt = resident.balance < 0;

              return GestureDetector(
                onTap: () => context.pushNamed('resident_detail', pathParameters: {'id': resident.id.toString()}),
                child: LuxuryCard(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: isDebt ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                        child: Text(
                          "${resident.apartmentNumber ?? '?'}",
                          style: TextStyle(color: isDebt ? Colors.red : Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        resident.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppTheme.offWhite, fontWeight: FontWeight.bold, fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${resident.balance.toStringAsFixed(0)} DH",
                        style: TextStyle(
                          color: isDebt ? AppTheme.errorRed : const Color(0xFF00E5FF),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
