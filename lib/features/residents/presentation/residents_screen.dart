import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:drift/drift.dart' as drift;
import 'package:residence_lamandier_b/core/theme/luxury_theme.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_card.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_text_field.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_button.dart';
import 'package:residence_lamandier_b/data/local/database.dart';
import 'package:residence_lamandier_b/core/router/role_guards.dart';
import 'package:residence_lamandier_b/core/router/app_router.dart';

class ResidentListScreen extends ConsumerWidget {
  const ResidentListScreen({super.key});

  Future<void> _makeWhatsAppCall(String? phoneNumber, String name) async {
    if (phoneNumber == null || phoneNumber.isEmpty) return;
    String formatted = phoneNumber.replaceAll(' ', '');
    if (formatted.startsWith('0')) formatted = '212${formatted.substring(1)}';
    final url = "https://wa.me/$formatted?text=Bonjour M./Mme $name,";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, User user) {
    final nameCtrl = TextEditingController(text: user.name);
    final phoneCtrl = TextEditingController(text: user.phoneNumber);
    // Civility Dropdown logic could be added here if 'civility' column existed, assume name includes it or new column needed.
    // For now, simple name edit.

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkNavy,
        title: const Text("Modifier Résident", style: TextStyle(color: AppTheme.gold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LuxuryTextField(label: "Nom & Prénom", controller: nameCtrl),
            const SizedBox(height: 16),
            LuxuryTextField(label: "Téléphone", controller: phoneCtrl, keyboardType: TextInputType.phone),
            // Add 'Type' switch (Propriétaire/Locataire) if DB supports it.
            // Currently using 'role'='resident', maybe add 'isTenant'?
            // Sticking to basic fields for stability.
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("ANNULER", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.gold),
            onPressed: () async {
              final db = ref.read(appDatabaseProvider);
              await (db.update(db.users)..where((t) => t.id.equals(user.id))).write(
                UsersCompanion(
                  name: drift.Value(nameCtrl.text),
                  phoneNumber: drift.Value(phoneCtrl.text),
                ),
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text("SAUVEGARDER", style: TextStyle(color: AppTheme.darkNavy)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    final userRole = ref.watch(userRoleProvider);
    final isSyndic = userRole == UserRole.syndic;

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

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: residents.length,
            itemBuilder: (context, index) {
              final resident = residents[index];
              final isDebt = resident.balance < 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: LuxuryCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Avatar / Civility
                      CircleAvatar(
                        backgroundColor: isDebt ? Colors.red.withValues(alpha: 0.2) : Colors.green.withValues(alpha: 0.2),
                        child: Text(
                          "${resident.apartmentNumber ?? '?'}",
                          style: TextStyle(color: isDebt ? Colors.red : Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              resident.name,
                              style: const TextStyle(color: AppTheme.offWhite, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            // Badge (Mock logic for Tenant/Owner based on name or field)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.gold.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text("Propriétaire", style: TextStyle(color: AppTheme.gold, fontSize: 10)),
                            ),
                          ],
                        ),
                      ),

                      // Actions
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chat, color: Colors.green), // WhatsApp
                            onPressed: () => _makeWhatsAppCall(resident.phoneNumber, resident.name),
                          ),
                          if (isSyndic)
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.grey),
                              onPressed: () => _showEditDialog(context, ref, resident),
                            ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios, color: AppTheme.gold, size: 16),
                            onPressed: () => context.pushNamed('resident_detail', pathParameters: {'id': resident.id.toString()}),
                          ),
                        ],
                      )
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
