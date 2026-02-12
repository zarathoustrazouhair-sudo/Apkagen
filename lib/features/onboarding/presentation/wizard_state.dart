import 'package:freezed_annotation/freezed_annotation.dart';

part 'wizard_state.freezed.dart';

@freezed
class WizardState with _$WizardState {
  const factory WizardState({
    @Default(0) int currentStep,
    @Default('') String syndicName,
    @Default('') String adjointName,
    @Default('') String conciergeName,
    @Default(false) bool isLoading,
    String? error,
  }) = _WizardState;
}
