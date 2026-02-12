import 'package:freezed_annotation/freezed_annotation.dart';

part 'wizard_intent.freezed.dart';

@freezed
class WizardIntent with _$WizardIntent {
  const factory WizardIntent.nextStep() = NextStep;
  const factory WizardIntent.previousStep() = PreviousStep;
  const factory WizardIntent.updateSyndicName(String name) = UpdateSyndicName;
  const factory WizardIntent.updateAdjointName(String name) = UpdateAdjointName;
  const factory WizardIntent.updateConciergeName(String name) = UpdateConciergeName;
  const factory WizardIntent.submit() = Submit;
}
