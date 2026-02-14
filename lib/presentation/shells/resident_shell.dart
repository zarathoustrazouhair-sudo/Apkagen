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
    const DocumentsScreen(), // Replaced placeholder
    const ResidentProfileScreen(), // Replaced placeholder
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
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'MON APPART',
            ),
             BottomNavigationBarItem(
              icon: Icon(Icons.article_outlined),
              activeIcon: Icon(Icons.article),
              label: 'ACTUALITÉS',
            ),
             BottomNavigationBarItem(
              icon: Icon(Icons.folder_open),
              activeIcon: Icon(Icons.folder),
              label: 'DOCS',
            ),
             BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'PROFIL',
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// MY APARTMENT (HOME)
// -----------------------------------------------------------------------------
class MyApartmentScreen extends ConsumerWidget {
  const MyApartmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ideally fetch logged in user from a proper AuthProvider.
    // For MVP, we might mock or grab the first resident logic if strict Auth isn't fully piped.
    // But since LoginScreen sets the UserRole, we don't have the ID in a global provider yet.
    // Let's assume we are viewing a generic resident dashboard or using a mock for "M. Amrani".

    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      appBar: AppBar(
        title: Text(
          'MON APPARTEMENT',
          style: AppTheme.luxuryTheme.textTheme.headlineMedium?.copyWith(
            color: AppTheme.gold,
            fontWeight: FontWeight.bold,
          ),
        ),
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
            // Welcome Header
            const Text(
              "Bonjour, Résident", // Generic fallback
              style: TextStyle(
                color: AppTheme.offWhite,
                fontSize: 24,
                fontFamily: 'Playfair Display',
              ),
            ),
            const SizedBox(height: 24),

            // Balance Card
            LuxuryCard(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "SOLDE ACTUEL",
                        style: TextStyle(
                          color: AppTheme.offWhite.withOpacity(0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "0.00 DH",
                        style: TextStyle(
                          color: Color(0xFF00E5FF), // Cyan for OK
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Playfair Display',
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.check_circle_outline, color: Color(0xFF00E5FF), size: 40),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // SOS Button (Slide Action Placeholder)
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withOpacity(0.2),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppTheme.errorRed.withOpacity(0.5)),
              ),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sos, color: AppTheme.errorRed),
                    SizedBox(width: 8),
                    Text(
                      "SOS URGENCES",
                      style: TextStyle(
                        color: AppTheme.errorRed,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Report Incident
        },
        backgroundColor: AppTheme.gold,
        label: const Text("SIGNALER INCIDENT", style: TextStyle(color: AppTheme.darkNavy, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.build, color: AppTheme.darkNavy),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// RESIDENT PROFILE (SELF-EDIT)
// -----------------------------------------------------------------------------
class ResidentProfileScreen extends ConsumerWidget {
  const ResidentProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In a real app, grab ID from AuthProvider. Here, we mock ID=1 for demo self-edit.
    final myId = 1;
    final db = ref.watch(appDatabaseProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      appBar: AppBar(
        title: Text("MON PROFIL", style: AppTheme.luxuryTheme.textTheme.headlineMedium?.copyWith(color: AppTheme.gold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<User?>(
        stream: (db.select(db.users)..where((t) => t.id.equals(myId))).watchSingleOrNull(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final user = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.gold,
                  child: Icon(Icons.person, size: 50, color: AppTheme.darkNavy),
                ),
                const SizedBox(height: 16),
                Text(user.name, style: const TextStyle(color: AppTheme.offWhite, fontSize: 20, fontWeight: FontWeight.bold)),
                Text("Appartement ${user.apartmentNumber}", style: TextStyle(color: AppTheme.offWhite.withOpacity(0.7))),
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
                const SizedBox(height: 24),
                LuxuryButton(
                  label: "DÉCONNEXION",
                  onPressed: () {
                    // Navigate back to login
                    // ref.read(userRoleProvider.notifier).state = ... (reset if needed)
                    // context.go('/login');
                  },
                  // style: red button...
                )
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditFieldDialog(
    BuildContext context,
    WidgetRef ref,
    User user,
    String label,
    String? currentValue,
    UsersCompanion Function(String) companionBuilder,
  ) {
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
