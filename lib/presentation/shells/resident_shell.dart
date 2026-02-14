import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:residence_lamandier_b/core/theme/luxury_theme.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_card.dart';
import 'package:residence_lamandier_b/features/blog/presentation/blog_feed_screen.dart';
import 'package:residence_lamandier_b/features/documents/presentation/documents_screen.dart';
import 'package:residence_lamandier_b/data/local/database.dart';
import 'package:drift/drift.dart' as drift;
import 'package:residence_lamandier_b/core/theme/widgets/luxury_button.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_text_field.dart';
import 'package:residence_lamandier_b/features/dashboard/presentation/widgets/syndic_mood_widget.dart';

class ResidentShell extends ConsumerStatefulWidget {
  const ResidentShell({super.key});

  @override
  ConsumerState<ResidentShell> createState() => _ResidentShellState();
}

class _ResidentShellState extends ConsumerState<ResidentShell> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const MyApartmentScreen(),
    const BlogFeedScreen(),
    const DocumentsScreen(),
    const ResidentProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: AppTheme.darkNavy,
          selectedItemColor: AppTheme.gold,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'MON APPART'),
            BottomNavigationBarItem(icon: Icon(Icons.article_outlined), activeIcon: Icon(Icons.article), label: 'ACTUALITÉS'),
            BottomNavigationBarItem(icon: Icon(Icons.folder_open), activeIcon: Icon(Icons.folder), label: 'DOCS'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'PROFIL'),
          ],
        ),
      ),
    );
  }
}

class MyApartmentScreen extends ConsumerWidget {
  const MyApartmentScreen({super.key});

  void _showReportIncidentDialog(BuildContext context, WidgetRef ref) {
    final descCtrl = TextEditingController();
    final db = ref.read(appDatabaseProvider);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkNavy,
        title: const Text("Signaler un Incident", style: TextStyle(color: AppTheme.gold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Décrivez le problème (Fuite, Panne, etc.)", style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 10),
            // LuxuryTextField usually doesn't have maxLines, using basic TextField or wrapper if needed.
            // Assuming standard TextField for now or fixing LuxuryTextField elsewhere.
            // Using standard TextField with Luxury styling decoration to avoid error if LuxuryTextField lacks maxLines.
            TextField(
              controller: descCtrl,
              maxLines: 3,
              style: const TextStyle(color: AppTheme.offWhite),
              decoration: InputDecoration(
                labelText: "Description",
                labelStyle: TextStyle(color: AppTheme.gold.withValues(alpha: 0.8)),
                filled: true,
                fillColor: AppTheme.darkNavy.withValues(alpha: 0.5),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.gold.withValues(alpha: 0.3))),
                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppTheme.gold)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("ANNULER", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed), // Fixed: AppTheme.red -> AppTheme.errorRed
            onPressed: () async {
              if (descCtrl.text.isNotEmpty) {
                // 'type' and 'authorId' will be available after build_runner runs.
                // We assume they are generated correctly.
                await db.into(db.tasks).insert(
                  TasksCompanion.insert(
                    description: descCtrl.text,
                    type: drift.Value('incident'), // Will work after codegen
                    isCompleted: const drift.Value(false),
                  ),
                );
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Incident signalé au Syndic !")));
                }
              }
            },
            child: const Text("SIGNALER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myId = 1;
    final db = ref.watch(appDatabaseProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      appBar: AppBar(
        title: Text('MON APPARTEMENT', style: AppTheme.luxuryTheme.textTheme.headlineMedium?.copyWith(color: AppTheme.gold, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<User?>(
              stream: (db.select(db.users)..where((t) => t.id.equals(myId))).watchSingleOrNull(),
              builder: (context, snapshot) {
                final user = snapshot.data;
                return Text("Bonjour, ${user?.name ?? 'Résident'}", style: const TextStyle(color: AppTheme.offWhite, fontSize: 24, fontFamily: 'Playfair Display'));
              }
            ),
            const SizedBox(height: 24),

            LuxuryCard(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("SOLDE ACTUEL", style: TextStyle(color: AppTheme.offWhite.withValues(alpha: 0.6), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      const SizedBox(height: 8),
                      StreamBuilder<User?>(
                        stream: (db.select(db.users)..where((t) => t.id.equals(myId))).watchSingleOrNull(),
                        builder: (context, snapshot) {
                          final balance = snapshot.data?.balance ?? 0.0;
                          final isOk = balance >= 0;
                          return Text("${balance.toStringAsFixed(2)} DH", style: TextStyle(color: isOk ? const Color(0xFF00E5FF) : AppTheme.errorRed, fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'Playfair Display'));
                        }
                      ),
                    ],
                  ),
                  const Icon(Icons.check_circle_outline, color: Color(0xFF00E5FF), size: 40),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text("SANTÉ DU SYNDIC", style: TextStyle(color: AppTheme.gold, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const SyndicMoodWidget(),

            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppTheme.errorRed.withValues(alpha: 0.5)),
              ),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sos, color: AppTheme.errorRed),
                    SizedBox(width: 8),
                    Text("SOS URGENCES", style: TextStyle(color: AppTheme.errorRed, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showReportIncidentDialog(context, ref),
        backgroundColor: AppTheme.gold,
        label: const Text("SIGNALER INCIDENT", style: TextStyle(color: AppTheme.darkNavy, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.warning_amber, color: AppTheme.darkNavy),
      ),
    );
  }
}

class ResidentProfileScreen extends ConsumerWidget {
  const ResidentProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myId = 1;
    final db = ref.watch(appDatabaseProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      appBar: AppBar(title: const Text("MON PROFIL", style: TextStyle(color: AppTheme.gold)), backgroundColor: Colors.transparent, elevation: 0, centerTitle: true, automaticallyImplyLeading: false),
      body: StreamBuilder<User?>(
        stream: (db.select(db.users)..where((t) => t.id.equals(myId))).watchSingleOrNull(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final user = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const CircleAvatar(radius: 50, backgroundColor: AppTheme.gold, child: Icon(Icons.person, size: 50, color: AppTheme.darkNavy)),
                const SizedBox(height: 16),
                Text(user.name, style: const TextStyle(color: AppTheme.offWhite, fontSize: 20, fontWeight: FontWeight.bold)),
                Text("Appartement ${user.apartmentNumber}", style: TextStyle(color: AppTheme.offWhite.withValues(alpha: 0.7))),
                const SizedBox(height: 32),
                LuxuryCard(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.phone, color: AppTheme.gold),
                        title: const Text("Téléphone", style: TextStyle(color: AppTheme.offWhite, fontSize: 12)),
                        subtitle: Text(user.phoneNumber ?? "Non renseigné", style: const TextStyle(color: AppTheme.offWhite, fontWeight: FontWeight.bold)),
                        trailing: const Icon(Icons.edit, size: 16, color: Colors.grey),
                        onTap: () => _showEditFieldDialog(context, ref, user, "Téléphone", user.phoneNumber, (val) => UsersCompanion(phoneNumber: drift.Value(val))),
                      ),
                      const Divider(color: Colors.white10),
                      ListTile(
                        leading: const Icon(Icons.lock, color: AppTheme.gold),
                        title: const Text("Code d'accès", style: TextStyle(color: AppTheme.offWhite, fontSize: 12)),
                        subtitle: Text("****", style: const TextStyle(color: AppTheme.offWhite, fontWeight: FontWeight.bold)),
                        trailing: const Icon(Icons.edit, size: 16, color: Colors.grey),
                        onTap: () => _showEditFieldDialog(context, ref, user, "Code PIN", user.accessCode, (val) => UsersCompanion(accessCode: drift.Value(val))),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditFieldDialog(BuildContext context, WidgetRef ref, User user, String label, String? currentValue, UsersCompanion Function(String) companionBuilder) {
    final ctrl = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkNavy,
        title: Text("Modifier $label", style: const TextStyle(color: AppTheme.gold)),
        content: LuxuryTextField(label: label, controller: ctrl),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("ANNULER", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.gold),
            onPressed: () async {
              final db = ref.read(appDatabaseProvider);
              await (db.update(db.users)..where((t) => t.id.equals(user.id))).write(companionBuilder(ctrl.text));
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text("SAUVEGARDER", style: TextStyle(color: AppTheme.darkNavy)),
          )
        ],
      ),
    );
  }
}
