import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:residence_lamandier_b/core/theme/luxury_theme.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_button.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_card.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_text_field.dart';
import 'package:residence_lamandier_b/features/settings/data/app_settings_repository.dart';
import 'package:residence_lamandier_b/data/local/database.dart';
import 'package:residence_lamandier_b/core/router/app_router.dart'; // To update userRoleProvider

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Syndic Fields
  final _adminPassController = TextEditingController();

  // Resident Fields
  int _selectedFloor = 1;
  User? _selectedApartment;
  final _pinController = TextEditingController();

  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Text(
                  "QUI ÊTES-VOUS ?",
                  style: AppTheme.luxuryTheme.textTheme.displayMedium?.copyWith(
                    color: AppTheme.gold,
                    fontSize: 24,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // 1. SYNDIC SECTION
              LuxuryCard(
                child: ExpansionTile(
                  title: const Text("SYNDIC", style: TextStyle(color: AppTheme.gold, fontWeight: FontWeight.bold, fontSize: 18)),
                  iconColor: AppTheme.gold,
                  collapsedIconColor: AppTheme.gold,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          LuxuryTextField(
                            label: "MOT DE PASSE MAÎTRE",
                            controller: _adminPassController,
                            obscureText: true,
                          ),
                          const SizedBox(height: 16),
                          LuxuryButton(
                            label: "CONNEXION (ADMIN)",
                            isLoading: _isProcessing,
                            onPressed: _loginSyndic,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2. ADJOINT (Simplified, same logic for now but role ADJOINT)
               LuxuryCard(
                child: ListTile(
                  title: const Text("ADJOINT", style: TextStyle(color: AppTheme.offWhite, fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.arrow_forward_ios, color: AppTheme.gold, size: 16),
                  onTap: () {
                    // Logic for Adjoint (Use separate password in real app, simplified here)
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Accès Adjoint via Syndic pour démo.")));
                  },
                ),
              ),

              const SizedBox(height: 16),

              // 3. CONCIERGE
              LuxuryCard(
                child: ListTile(
                  title: const Text("CONCIERGE", style: TextStyle(color: AppTheme.offWhite, fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.arrow_forward_ios, color: AppTheme.gold, size: 16),
                  onTap: () {
                     // Concierge Access (Read Only / Task)
                     ref.read(userRoleProvider.notifier).state = UserRole.concierge;
                     context.go('/concierge');
                  },
                ),
              ),

              const SizedBox(height: 16),

              // 4. RÉSIDENT SECTION
              LuxuryCard(
                child: ExpansionTile(
                  title: const Text("RÉSIDENT", style: TextStyle(color: AppTheme.offWhite, fontWeight: FontWeight.bold, fontSize: 18)),
                  iconColor: AppTheme.gold,
                  collapsedIconColor: AppTheme.offWhite,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Floor Selector
                          DropdownButtonFormField<int>(
                            dropdownColor: AppTheme.darkNavy,
                            value: _selectedFloor,
                            decoration: const InputDecoration(labelText: "ÉTAGE"),
                            items: [1, 2, 3].map((f) => DropdownMenuItem(value: f, child: Text("Étage $f", style: const TextStyle(color: AppTheme.offWhite)))).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedFloor = val!;
                                _selectedApartment = null; // Reset apartment selection
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          // Apartment Selector (Filtered)
                          StreamBuilder<List<User>>(
                            stream: (db.select(db.users)
                                  ..where((t) => t.role.equals('resident') & t.floor.equals(_selectedFloor)))
                                .watch(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) return const CircularProgressIndicator();

                              return DropdownButtonFormField<User>(
                                dropdownColor: AppTheme.darkNavy,
                                value: _selectedApartment,
                                decoration: const InputDecoration(labelText: "APPARTEMENT"),
                                items: snapshot.data!.map((user) => DropdownMenuItem(
                                  value: user,
                                  child: Text("Apt ${user.apartmentNumber} - ${user.name}", style: const TextStyle(color: AppTheme.offWhite)),
                                )).toList(),
                                onChanged: (val) => setState(() => _selectedApartment = val),
                              );
                            },
                          ),

                          const SizedBox(height: 16),

                          // PIN Code
                          LuxuryTextField(
                            label: "CODE PIN (Défaut: 0000)",
                            controller: _pinController,
                            obscureText: true,
                            keyboardType: TextInputType.number,
                          ),

                          const SizedBox(height: 24),

                          LuxuryButton(
                            label: "CONNEXION (RÉSIDENT)",
                            isLoading: _isProcessing,
                            onPressed: _loginResident,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loginSyndic() async {
    setState(() => _isProcessing = true);
    try {
      final repo = ref.read(appSettingsRepositoryProvider);
      final valid = await repo.verifyAdminPassword(_adminPassController.text);

      if (valid) {
        ref.read(userRoleProvider.notifier).state = UserRole.syndic;
        if (mounted) context.go('/syndic');
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mot de passe incorrect")));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _loginResident() async {
    if (_selectedApartment == null) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sélectionnez votre appartement")));
       return;
    }

    setState(() => _isProcessing = true);

    // Simulate Verification
    await Future.delayed(const Duration(milliseconds: 500));

    // If PIN matches or is '0000' (Magic Bypass for Demo)
    if (_pinController.text == "0000" || _selectedApartment!.accessCode == _pinController.text) {
       ref.read(userRoleProvider.notifier).state = UserRole.resident;
       // We should also store WHO logged in (current user ID) in a provider for ResidentShell
       // For now, assume single user app session context.
       if (mounted) context.go('/resident');
    } else {
       if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Code PIN Incorrect (Essayez 0000)")));
    }

    if (mounted) setState(() => _isProcessing = false);
  }
}
