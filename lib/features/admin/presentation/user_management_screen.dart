import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:residence_lamandier_b/core/theme/luxury_theme.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_card.dart';
import 'package:residence_lamandier_b/data/local/database.dart';
import 'dart:math';

class UserManagementScreen extends ConsumerWidget {
  const UserManagementScreen({super.key});

  String _generateCode() {
    return (1000 + Random().nextInt(9000)).toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      appBar: AppBar(
        title: Text(
          "GESTION UTILISATEURS",
          style: AppTheme.luxuryTheme.textTheme.headlineMedium?.copyWith(
            color: AppTheme.gold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<List<User>>(
        stream: db.select(db.users).watch(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: LuxuryCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(
                                  color: AppTheme.gold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Role: ${user.role} | Apt: ${user.apartmentNumber ?? '-'}",
                                style: TextStyle(
                                  color: AppTheme.offWhite.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: user.isBlocked,
                            activeColor: AppTheme.errorRed,
                            onChanged: (val) {
                              (db.update(db.users)..where((t) => t.id.equals(user.id))).write(
                                UsersCompanion(isBlocked: drift.Value(val)),
                              );
                            },
                          ),
                        ],
                      ),
                      const Divider(color: Colors.grey),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "CODE: ${user.accessCode ?? '----'}",
                            style: const TextStyle(
                              color: AppTheme.offWhite,
                              fontFamily: 'Courier',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.refresh, size: 16, color: AppTheme.gold),
                            label: const Text("RÉGÉNÉRER", style: TextStyle(color: AppTheme.gold, fontSize: 10)),
                            onPressed: () {
                              (db.update(db.users)..where((t) => t.id.equals(user.id))).write(
                                UsersCompanion(accessCode: drift.Value(_generateCode())),
                              );
                            },
                          )
                        ],
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
