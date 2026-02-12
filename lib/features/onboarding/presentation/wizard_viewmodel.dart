import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:residence_lamandier_b/features/onboarding/presentation/wizard_state.dart';
import 'package:residence_lamandier_b/features/onboarding/presentation/wizard_intent.dart';
import 'package:residence_lamandier_b/features/settings/data/app_settings_repository.dart';

part 'wizard_viewmodel.g.dart';

@riverpod
class WizardViewModel extends _$WizardViewModel {
  @override
  WizardState build() {
    return const WizardState();
  }

  void processIntent(WizardIntent intent) {
    intent.when(
      nextStep: () {
        if (state.currentStep < 2) {
          state = state.copyWith(currentStep: state.currentStep + 1);
        }
      },
      previousStep: () {
        if (state.currentStep > 0) {
          state = state.copyWith(currentStep: state.currentStep - 1);
        }
      },
      updateSyndicName: (name) {
        state = state.copyWith(syndicName: name);
      },
      updateAdjointName: (name) {
        state = state.copyWith(adjointName: name);
      },
      updateConciergeName: (name) {
        state = state.copyWith(conciergeName: name);
      },
      submit: () async {
        state = state.copyWith(isLoading: true, error: null);
        try {
          // 1. Save Settings to Local DB
          final settingsRepo = ref.read(appSettingsRepositoryProvider);
          await settingsRepo.saveSetting('syndic_name', state.syndicName);
          await settingsRepo.saveSetting('adjoint_name', state.adjointName);
          await settingsRepo.saveSetting('concierge_name', state.conciergeName);
          await settingsRepo.saveSetting('monthly_fee', '250.0'); // Default

          // 2. Trigger Initial Sync (Mock for now, or call SyncManager)
          // await ref.read(syncManagerProvider).syncAll();

          await Future.delayed(const Duration(seconds: 1)); // Simulate work

          state = state.copyWith(isLoading: false);
          // Navigation handled by UI listener or Router redirect on settings change
        } catch (e) {
          state = state.copyWith(isLoading: false, error: e.toString());
        }
      },
    );
  }
}
