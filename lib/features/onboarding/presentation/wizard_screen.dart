import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:residence_lamandier_b/core/theme/luxury_theme.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_button.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_card.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_text_field.dart';
import 'package:residence_lamandier_b/features/settings/data/app_settings_repository.dart';
import 'package:residence_lamandier_b/data/local/database.dart';

class WizardScreen extends ConsumerStatefulWidget {
  const WizardScreen({super.key});

  @override
  ConsumerState<WizardScreen> createState() => _WizardScreenState();
}

class _WizardScreenState extends ConsumerState<WizardScreen> {
  final _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Controllers
  final _residenceNameController = TextEditingController(text: "Résidence L'Amandier B");
  final _syndicNameController = TextEditingController(text: "Abdelati KENBOUCHI");
  final _adminPasswordController = TextEditingController();
  final _fixedCostController = TextEditingController(text: "15000"); // Default guess

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      appBar: AppBar(
        title: Text('INITIALISATION (v1.0.1)', style: AppTheme.luxuryTheme.textTheme.headlineMedium?.copyWith(color: AppTheme.gold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Progress
            LinearProgressIndicator(
              value: (_currentStep + 1) / 3,
              backgroundColor: AppTheme.gold.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.gold),
            ),
            const SizedBox(height: 32),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  LuxuryButton(
                    label: 'RETOUR',
                    onPressed: _prevStep,
                    // Small width for back
                  )
                else
                  const SizedBox(width: 10), // Spacer

                LuxuryButton(
                  label: _currentStep == 2 ? 'TERMINER' : 'SUIVANT',
                  isLoading: _isLoading,
                  onPressed: _currentStep == 2 ? _finishSetup : _nextStep,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return LuxuryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("IDENTITÉ", style: AppTheme.luxuryTheme.textTheme.displaySmall),
          const SizedBox(height: 24),
          LuxuryTextField(label: "NOM RÉSIDENCE", controller: _residenceNameController),
          const SizedBox(height: 16),
          LuxuryTextField(label: "NOM SYNDIC", controller: _syndicNameController),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return LuxuryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("FINANCES", style: AppTheme.luxuryTheme.textTheme.displaySmall),
          const SizedBox(height: 8),
          Text(
            "Total mensuel (Concierge + Ménage + Élec + Eau + Maintenance)",
            style: TextStyle(color: AppTheme.offWhite.withOpacity(0.7), fontSize: 12),
          ),
          const SizedBox(height: 24),
          LuxuryTextField(
            label: "CHARGES FIXES (DH)",
            controller: _fixedCostController,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return LuxuryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("SÉCURITÉ", style: AppTheme.luxuryTheme.textTheme.displaySmall),
          const SizedBox(height: 8),
          Text(
            "Ce mot de passe vous donnera accès au Cockpit Syndic.",
            style: TextStyle(color: AppTheme.offWhite.withOpacity(0.7), fontSize: 12),
          ),
          const SizedBox(height: 24),
          LuxuryTextField(
            label: "MOT DE PASSE MAÎTRE",
            controller: _adminPasswordController,
            obscureText: true,
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    setState(() {
      _currentStep++;
      _pageController.animateToPage(_currentStep, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    });
  }

  void _prevStep() {
    setState(() {
      _currentStep--;
      _pageController.animateToPage(_currentStep, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    });
  }

  Future<void> _finishSetup() async {
    if (_adminPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mot de passe requis !")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(appSettingsRepositoryProvider);

      // 1. Save Settings
      await repo.saveSetting('residence_name', _residenceNameController.text);
      await repo.saveSetting('syndic_name', _syndicNameController.text);
      await repo.setMonthlyFixedCosts(double.tryParse(_fixedCostController.text) ?? 0.0);
      await repo.setAdminPassword(_adminPasswordController.text);

      // 2. Mark Complete
      await repo.completeSetup();

      // 3. Navigate
      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
