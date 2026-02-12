import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:residence_lamandier_b/core/theme/luxury_theme.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_button.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_card.dart';
import 'package:residence_lamandier_b/core/theme/widgets/luxury_text_field.dart';
import 'package:residence_lamandier_b/features/onboarding/presentation/wizard_intent.dart';
import 'package:residence_lamandier_b/features/onboarding/presentation/wizard_viewmodel.dart';
import 'package:residence_lamandier_b/features/onboarding/presentation/wizard_state.dart';

class WizardScreen extends ConsumerStatefulWidget {
  const WizardScreen({super.key});

  @override
  ConsumerState<WizardScreen> createState() => _WizardScreenState();
}

class _WizardScreenState extends ConsumerState<WizardScreen> {
  late final TextEditingController _syndicController;
  late final TextEditingController _adjointController;
  late final TextEditingController _conciergeController;

  @override
  void initState() {
    super.initState();
    _syndicController = TextEditingController();
    _adjointController = TextEditingController();
    _conciergeController = TextEditingController();
  }

  @override
  void dispose() {
    _syndicController.dispose();
    _adjointController.dispose();
    _conciergeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wizardViewModelProvider);
    final viewModel = ref.read(wizardViewModelProvider.notifier);

    // Logic to check if settings exist, if so skip wizard (Pseudo-code as we are in build)
    // In production, this check happens in a SplashScreen or AppRouter redirection logic
    // For TEP 13.0 "Loop": If Wizard completes, we save settings.

    // Ensure controllers are in sync with state when navigating back/forth
    if (_syndicController.text != state.syndicName) {
      _syndicController.text = state.syndicName;
    }
    if (_adjointController.text != state.adjointName) {
      _adjointController.text = state.adjointName;
    }
    if (_conciergeController.text != state.conciergeName) {
      _conciergeController.text = state.conciergeName;
    }

    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      appBar: AppBar(
        title: Text(
          'INITIAL SETUP',
          style: AppTheme.luxuryTheme.textTheme.headlineMedium,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Progress Indicator
            LinearProgressIndicator(
              value: (state.currentStep + 1) / 3,
              backgroundColor: AppTheme.gold.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.gold),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _buildStep(state, viewModel),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (state.currentStep > 0)
                  LuxuryButton(
                    label: 'BACK',
                    onPressed: () => viewModel.processIntent(const WizardIntent.previousStep()),
                  )
                else
                  const SizedBox.shrink(),
                LuxuryButton(
                  label: state.currentStep == 2 ? 'INITIALIZE SYSTEM' : 'NEXT',
                  isLoading: state.isLoading,
                  onPressed: () {
                    if (state.currentStep == 2) {
                      viewModel.processIntent(const WizardIntent.submit());
                      // TEP 13.0: After submit, we should save AppSettings and sync
                      // The ViewModel should handle the side effects (Save Settings repo)
                    } else {
                      viewModel.processIntent(const WizardIntent.nextStep());
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(WizardState state, WizardViewModel viewModel) {
    switch (state.currentStep) {
      case 0:
        return LuxuryCard(
          key: const ValueKey('step0'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SYNDIC INFORMATION',
                style: AppTheme.luxuryTheme.textTheme.displaySmall,
              ),
              const SizedBox(height: 24),
              LuxuryTextField(
                label: 'FULL NAME',
                hint: 'Enter Syndic Name',
                controller: _syndicController,
                onChanged: (val) => viewModel.processIntent(WizardIntent.updateSyndicName(val)),
              ),
            ],
          ),
        );
      case 1:
        return LuxuryCard(
          key: const ValueKey('step1'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ADJOINT INFORMATION',
                style: AppTheme.luxuryTheme.textTheme.displaySmall,
              ),
              const SizedBox(height: 24),
              LuxuryTextField(
                label: 'FULL NAME',
                hint: 'Enter Adjoint Name',
                controller: _adjointController,
                onChanged: (val) => viewModel.processIntent(WizardIntent.updateAdjointName(val)),
              ),
            ],
          ),
        );
      case 2:
        return LuxuryCard(
          key: const ValueKey('step2'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'CONCIERGE INFORMATION',
                style: AppTheme.luxuryTheme.textTheme.displaySmall,
              ),
              const SizedBox(height: 24),
              LuxuryTextField(
                label: 'FULL NAME',
                hint: 'Enter Concierge Name',
                controller: _conciergeController,
                onChanged: (val) => viewModel.processIntent(WizardIntent.updateConciergeName(val)),
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
