// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wizard_intent.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$WizardIntent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() nextStep,
    required TResult Function() previousStep,
    required TResult Function(String name) updateSyndicName,
    required TResult Function(String name) updateAdjointName,
    required TResult Function(String name) updateConciergeName,
    required TResult Function() submit,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? nextStep,
    TResult? Function()? previousStep,
    TResult? Function(String name)? updateSyndicName,
    TResult? Function(String name)? updateAdjointName,
    TResult? Function(String name)? updateConciergeName,
    TResult? Function()? submit,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? nextStep,
    TResult Function()? previousStep,
    TResult Function(String name)? updateSyndicName,
    TResult Function(String name)? updateAdjointName,
    TResult Function(String name)? updateConciergeName,
    TResult Function()? submit,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NextStep value) nextStep,
    required TResult Function(PreviousStep value) previousStep,
    required TResult Function(UpdateSyndicName value) updateSyndicName,
    required TResult Function(UpdateAdjointName value) updateAdjointName,
    required TResult Function(UpdateConciergeName value) updateConciergeName,
    required TResult Function(Submit value) submit,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NextStep value)? nextStep,
    TResult? Function(PreviousStep value)? previousStep,
    TResult? Function(UpdateSyndicName value)? updateSyndicName,
    TResult? Function(UpdateAdjointName value)? updateAdjointName,
    TResult? Function(UpdateConciergeName value)? updateConciergeName,
    TResult? Function(Submit value)? submit,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NextStep value)? nextStep,
    TResult Function(PreviousStep value)? previousStep,
    TResult Function(UpdateSyndicName value)? updateSyndicName,
    TResult Function(UpdateAdjointName value)? updateAdjointName,
    TResult Function(UpdateConciergeName value)? updateConciergeName,
    TResult Function(Submit value)? submit,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WizardIntentCopyWith<$Res> {
  factory $WizardIntentCopyWith(
    WizardIntent value,
    $Res Function(WizardIntent) then,
  ) = _$WizardIntentCopyWithImpl<$Res, WizardIntent>;
}

/// @nodoc
class _$WizardIntentCopyWithImpl<$Res, $Val extends WizardIntent>
    implements $WizardIntentCopyWith<$Res> {
  _$WizardIntentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WizardIntent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$NextStepImplCopyWith<$Res> {
  factory _$$NextStepImplCopyWith(
    _$NextStepImpl value,
    $Res Function(_$NextStepImpl) then,
  ) = __$$NextStepImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$NextStepImplCopyWithImpl<$Res>
    extends _$WizardIntentCopyWithImpl<$Res, _$NextStepImpl>
    implements _$$NextStepImplCopyWith<$Res> {
  __$$NextStepImplCopyWithImpl(
    _$NextStepImpl _value,
    $Res Function(_$NextStepImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WizardIntent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$NextStepImpl implements NextStep {
  const _$NextStepImpl();

  @override
  String toString() {
    return 'WizardIntent.nextStep()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$NextStepImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() nextStep,
    required TResult Function() previousStep,
    required TResult Function(String name) updateSyndicName,
    required TResult Function(String name) updateAdjointName,
    required TResult Function(String name) updateConciergeName,
    required TResult Function() submit,
  }) {
    return nextStep();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? nextStep,
    TResult? Function()? previousStep,
    TResult? Function(String name)? updateSyndicName,
    TResult? Function(String name)? updateAdjointName,
    TResult? Function(String name)? updateConciergeName,
    TResult? Function()? submit,
  }) {
    return nextStep?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? nextStep,
    TResult Function()? previousStep,
    TResult Function(String name)? updateSyndicName,
    TResult Function(String name)? updateAdjointName,
    TResult Function(String name)? updateConciergeName,
    TResult Function()? submit,
    required TResult orElse(),
  }) {
    if (nextStep != null) {
      return nextStep();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NextStep value) nextStep,
    required TResult Function(PreviousStep value) previousStep,
    required TResult Function(UpdateSyndicName value) updateSyndicName,
    required TResult Function(UpdateAdjointName value) updateAdjointName,
    required TResult Function(UpdateConciergeName value) updateConciergeName,
    required TResult Function(Submit value) submit,
  }) {
    return nextStep(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NextStep value)? nextStep,
    TResult? Function(PreviousStep value)? previousStep,
    TResult? Function(UpdateSyndicName value)? updateSyndicName,
    TResult? Function(UpdateAdjointName value)? updateAdjointName,
    TResult? Function(UpdateConciergeName value)? updateConciergeName,
    TResult? Function(Submit value)? submit,
  }) {
    return nextStep?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NextStep value)? nextStep,
    TResult Function(PreviousStep value)? previousStep,
    TResult Function(UpdateSyndicName value)? updateSyndicName,
    TResult Function(UpdateAdjointName value)? updateAdjointName,
    TResult Function(UpdateConciergeName value)? updateConciergeName,
    TResult Function(Submit value)? submit,
    required TResult orElse(),
  }) {
    if (nextStep != null) {
      return nextStep(this);
    }
    return orElse();
  }
}

abstract class NextStep implements WizardIntent {
  const factory NextStep() = _$NextStepImpl;
}

/// @nodoc
abstract class _$$PreviousStepImplCopyWith<$Res> {
  factory _$$PreviousStepImplCopyWith(
    _$PreviousStepImpl value,
    $Res Function(_$PreviousStepImpl) then,
  ) = __$$PreviousStepImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$PreviousStepImplCopyWithImpl<$Res>
    extends _$WizardIntentCopyWithImpl<$Res, _$PreviousStepImpl>
    implements _$$PreviousStepImplCopyWith<$Res> {
  __$$PreviousStepImplCopyWithImpl(
    _$PreviousStepImpl _value,
    $Res Function(_$PreviousStepImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WizardIntent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$PreviousStepImpl implements PreviousStep {
  const _$PreviousStepImpl();

  @override
  String toString() {
    return 'WizardIntent.previousStep()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$PreviousStepImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() nextStep,
    required TResult Function() previousStep,
    required TResult Function(String name) updateSyndicName,
    required TResult Function(String name) updateAdjointName,
    required TResult Function(String name) updateConciergeName,
    required TResult Function() submit,
  }) {
    return previousStep();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? nextStep,
    TResult? Function()? previousStep,
    TResult? Function(String name)? updateSyndicName,
    TResult? Function(String name)? updateAdjointName,
    TResult? Function(String name)? updateConciergeName,
    TResult? Function()? submit,
  }) {
    return previousStep?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? nextStep,
    TResult Function()? previousStep,
    TResult Function(String name)? updateSyndicName,
    TResult Function(String name)? updateAdjointName,
    TResult Function(String name)? updateConciergeName,
    TResult Function()? submit,
    required TResult orElse(),
  }) {
    if (previousStep != null) {
      return previousStep();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NextStep value) nextStep,
    required TResult Function(PreviousStep value) previousStep,
    required TResult Function(UpdateSyndicName value) updateSyndicName,
    required TResult Function(UpdateAdjointName value) updateAdjointName,
    required TResult Function(UpdateConciergeName value) updateConciergeName,
    required TResult Function(Submit value) submit,
  }) {
    return previousStep(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NextStep value)? nextStep,
    TResult? Function(PreviousStep value)? previousStep,
    TResult? Function(UpdateSyndicName value)? updateSyndicName,
    TResult? Function(UpdateAdjointName value)? updateAdjointName,
    TResult? Function(UpdateConciergeName value)? updateConciergeName,
    TResult? Function(Submit value)? submit,
  }) {
    return previousStep?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NextStep value)? nextStep,
    TResult Function(PreviousStep value)? previousStep,
    TResult Function(UpdateSyndicName value)? updateSyndicName,
    TResult Function(UpdateAdjointName value)? updateAdjointName,
    TResult Function(UpdateConciergeName value)? updateConciergeName,
    TResult Function(Submit value)? submit,
    required TResult orElse(),
  }) {
    if (previousStep != null) {
      return previousStep(this);
    }
    return orElse();
  }
}

abstract class PreviousStep implements WizardIntent {
  const factory PreviousStep() = _$PreviousStepImpl;
}

/// @nodoc
abstract class _$$UpdateSyndicNameImplCopyWith<$Res> {
  factory _$$UpdateSyndicNameImplCopyWith(
    _$UpdateSyndicNameImpl value,
    $Res Function(_$UpdateSyndicNameImpl) then,
  ) = __$$UpdateSyndicNameImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String name});
}

/// @nodoc
class __$$UpdateSyndicNameImplCopyWithImpl<$Res>
    extends _$WizardIntentCopyWithImpl<$Res, _$UpdateSyndicNameImpl>
    implements _$$UpdateSyndicNameImplCopyWith<$Res> {
  __$$UpdateSyndicNameImplCopyWithImpl(
    _$UpdateSyndicNameImpl _value,
    $Res Function(_$UpdateSyndicNameImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WizardIntent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null}) {
    return _then(
      _$UpdateSyndicNameImpl(
        null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$UpdateSyndicNameImpl implements UpdateSyndicName {
  const _$UpdateSyndicNameImpl(this.name);

  @override
  final String name;

  @override
  String toString() {
    return 'WizardIntent.updateSyndicName(name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateSyndicNameImpl &&
            (identical(other.name, name) || other.name == name));
  }

  @override
  int get hashCode => Object.hash(runtimeType, name);

  /// Create a copy of WizardIntent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateSyndicNameImplCopyWith<_$UpdateSyndicNameImpl> get copyWith =>
      __$$UpdateSyndicNameImplCopyWithImpl<_$UpdateSyndicNameImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() nextStep,
    required TResult Function() previousStep,
    required TResult Function(String name) updateSyndicName,
    required TResult Function(String name) updateAdjointName,
    required TResult Function(String name) updateConciergeName,
    required TResult Function() submit,
  }) {
    return updateSyndicName(name);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? nextStep,
    TResult? Function()? previousStep,
    TResult? Function(String name)? updateSyndicName,
    TResult? Function(String name)? updateAdjointName,
    TResult? Function(String name)? updateConciergeName,
    TResult? Function()? submit,
  }) {
    return updateSyndicName?.call(name);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? nextStep,
    TResult Function()? previousStep,
    TResult Function(String name)? updateSyndicName,
    TResult Function(String name)? updateAdjointName,
    TResult Function(String name)? updateConciergeName,
    TResult Function()? submit,
    required TResult orElse(),
  }) {
    if (updateSyndicName != null) {
      return updateSyndicName(name);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NextStep value) nextStep,
    required TResult Function(PreviousStep value) previousStep,
    required TResult Function(UpdateSyndicName value) updateSyndicName,
    required TResult Function(UpdateAdjointName value) updateAdjointName,
    required TResult Function(UpdateConciergeName value) updateConciergeName,
    required TResult Function(Submit value) submit,
  }) {
    return updateSyndicName(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NextStep value)? nextStep,
    TResult? Function(PreviousStep value)? previousStep,
    TResult? Function(UpdateSyndicName value)? updateSyndicName,
    TResult? Function(UpdateAdjointName value)? updateAdjointName,
    TResult? Function(UpdateConciergeName value)? updateConciergeName,
    TResult? Function(Submit value)? submit,
  }) {
    return updateSyndicName?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NextStep value)? nextStep,
    TResult Function(PreviousStep value)? previousStep,
    TResult Function(UpdateSyndicName value)? updateSyndicName,
    TResult Function(UpdateAdjointName value)? updateAdjointName,
    TResult Function(UpdateConciergeName value)? updateConciergeName,
    TResult Function(Submit value)? submit,
    required TResult orElse(),
  }) {
    if (updateSyndicName != null) {
      return updateSyndicName(this);
    }
    return orElse();
  }
}

abstract class UpdateSyndicName implements WizardIntent {
  const factory UpdateSyndicName(final String name) = _$UpdateSyndicNameImpl;

  String get name;

  /// Create a copy of WizardIntent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateSyndicNameImplCopyWith<_$UpdateSyndicNameImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UpdateAdjointNameImplCopyWith<$Res> {
  factory _$$UpdateAdjointNameImplCopyWith(
    _$UpdateAdjointNameImpl value,
    $Res Function(_$UpdateAdjointNameImpl) then,
  ) = __$$UpdateAdjointNameImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String name});
}

/// @nodoc
class __$$UpdateAdjointNameImplCopyWithImpl<$Res>
    extends _$WizardIntentCopyWithImpl<$Res, _$UpdateAdjointNameImpl>
    implements _$$UpdateAdjointNameImplCopyWith<$Res> {
  __$$UpdateAdjointNameImplCopyWithImpl(
    _$UpdateAdjointNameImpl _value,
    $Res Function(_$UpdateAdjointNameImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WizardIntent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null}) {
    return _then(
      _$UpdateAdjointNameImpl(
        null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$UpdateAdjointNameImpl implements UpdateAdjointName {
  const _$UpdateAdjointNameImpl(this.name);

  @override
  final String name;

  @override
  String toString() {
    return 'WizardIntent.updateAdjointName(name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateAdjointNameImpl &&
            (identical(other.name, name) || other.name == name));
  }

  @override
  int get hashCode => Object.hash(runtimeType, name);

  /// Create a copy of WizardIntent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateAdjointNameImplCopyWith<_$UpdateAdjointNameImpl> get copyWith =>
      __$$UpdateAdjointNameImplCopyWithImpl<_$UpdateAdjointNameImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() nextStep,
    required TResult Function() previousStep,
    required TResult Function(String name) updateSyndicName,
    required TResult Function(String name) updateAdjointName,
    required TResult Function(String name) updateConciergeName,
    required TResult Function() submit,
  }) {
    return updateAdjointName(name);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? nextStep,
    TResult? Function()? previousStep,
    TResult? Function(String name)? updateSyndicName,
    TResult? Function(String name)? updateAdjointName,
    TResult? Function(String name)? updateConciergeName,
    TResult? Function()? submit,
  }) {
    return updateAdjointName?.call(name);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? nextStep,
    TResult Function()? previousStep,
    TResult Function(String name)? updateSyndicName,
    TResult Function(String name)? updateAdjointName,
    TResult Function(String name)? updateConciergeName,
    TResult Function()? submit,
    required TResult orElse(),
  }) {
    if (updateAdjointName != null) {
      return updateAdjointName(name);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NextStep value) nextStep,
    required TResult Function(PreviousStep value) previousStep,
    required TResult Function(UpdateSyndicName value) updateSyndicName,
    required TResult Function(UpdateAdjointName value) updateAdjointName,
    required TResult Function(UpdateConciergeName value) updateConciergeName,
    required TResult Function(Submit value) submit,
  }) {
    return updateAdjointName(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NextStep value)? nextStep,
    TResult? Function(PreviousStep value)? previousStep,
    TResult? Function(UpdateSyndicName value)? updateSyndicName,
    TResult? Function(UpdateAdjointName value)? updateAdjointName,
    TResult? Function(UpdateConciergeName value)? updateConciergeName,
    TResult? Function(Submit value)? submit,
  }) {
    return updateAdjointName?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NextStep value)? nextStep,
    TResult Function(PreviousStep value)? previousStep,
    TResult Function(UpdateSyndicName value)? updateSyndicName,
    TResult Function(UpdateAdjointName value)? updateAdjointName,
    TResult Function(UpdateConciergeName value)? updateConciergeName,
    TResult Function(Submit value)? submit,
    required TResult orElse(),
  }) {
    if (updateAdjointName != null) {
      return updateAdjointName(this);
    }
    return orElse();
  }
}

abstract class UpdateAdjointName implements WizardIntent {
  const factory UpdateAdjointName(final String name) = _$UpdateAdjointNameImpl;

  String get name;

  /// Create a copy of WizardIntent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateAdjointNameImplCopyWith<_$UpdateAdjointNameImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UpdateConciergeNameImplCopyWith<$Res> {
  factory _$$UpdateConciergeNameImplCopyWith(
    _$UpdateConciergeNameImpl value,
    $Res Function(_$UpdateConciergeNameImpl) then,
  ) = __$$UpdateConciergeNameImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String name});
}

/// @nodoc
class __$$UpdateConciergeNameImplCopyWithImpl<$Res>
    extends _$WizardIntentCopyWithImpl<$Res, _$UpdateConciergeNameImpl>
    implements _$$UpdateConciergeNameImplCopyWith<$Res> {
  __$$UpdateConciergeNameImplCopyWithImpl(
    _$UpdateConciergeNameImpl _value,
    $Res Function(_$UpdateConciergeNameImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WizardIntent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null}) {
    return _then(
      _$UpdateConciergeNameImpl(
        null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$UpdateConciergeNameImpl implements UpdateConciergeName {
  const _$UpdateConciergeNameImpl(this.name);

  @override
  final String name;

  @override
  String toString() {
    return 'WizardIntent.updateConciergeName(name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateConciergeNameImpl &&
            (identical(other.name, name) || other.name == name));
  }

  @override
  int get hashCode => Object.hash(runtimeType, name);

  /// Create a copy of WizardIntent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateConciergeNameImplCopyWith<_$UpdateConciergeNameImpl> get copyWith =>
      __$$UpdateConciergeNameImplCopyWithImpl<_$UpdateConciergeNameImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() nextStep,
    required TResult Function() previousStep,
    required TResult Function(String name) updateSyndicName,
    required TResult Function(String name) updateAdjointName,
    required TResult Function(String name) updateConciergeName,
    required TResult Function() submit,
  }) {
    return updateConciergeName(name);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? nextStep,
    TResult? Function()? previousStep,
    TResult? Function(String name)? updateSyndicName,
    TResult? Function(String name)? updateAdjointName,
    TResult? Function(String name)? updateConciergeName,
    TResult? Function()? submit,
  }) {
    return updateConciergeName?.call(name);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? nextStep,
    TResult Function()? previousStep,
    TResult Function(String name)? updateSyndicName,
    TResult Function(String name)? updateAdjointName,
    TResult Function(String name)? updateConciergeName,
    TResult Function()? submit,
    required TResult orElse(),
  }) {
    if (updateConciergeName != null) {
      return updateConciergeName(name);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NextStep value) nextStep,
    required TResult Function(PreviousStep value) previousStep,
    required TResult Function(UpdateSyndicName value) updateSyndicName,
    required TResult Function(UpdateAdjointName value) updateAdjointName,
    required TResult Function(UpdateConciergeName value) updateConciergeName,
    required TResult Function(Submit value) submit,
  }) {
    return updateConciergeName(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NextStep value)? nextStep,
    TResult? Function(PreviousStep value)? previousStep,
    TResult? Function(UpdateSyndicName value)? updateSyndicName,
    TResult? Function(UpdateAdjointName value)? updateAdjointName,
    TResult? Function(UpdateConciergeName value)? updateConciergeName,
    TResult? Function(Submit value)? submit,
  }) {
    return updateConciergeName?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NextStep value)? nextStep,
    TResult Function(PreviousStep value)? previousStep,
    TResult Function(UpdateSyndicName value)? updateSyndicName,
    TResult Function(UpdateAdjointName value)? updateAdjointName,
    TResult Function(UpdateConciergeName value)? updateConciergeName,
    TResult Function(Submit value)? submit,
    required TResult orElse(),
  }) {
    if (updateConciergeName != null) {
      return updateConciergeName(this);
    }
    return orElse();
  }
}

abstract class UpdateConciergeName implements WizardIntent {
  const factory UpdateConciergeName(final String name) =
      _$UpdateConciergeNameImpl;

  String get name;

  /// Create a copy of WizardIntent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateConciergeNameImplCopyWith<_$UpdateConciergeNameImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SubmitImplCopyWith<$Res> {
  factory _$$SubmitImplCopyWith(
    _$SubmitImpl value,
    $Res Function(_$SubmitImpl) then,
  ) = __$$SubmitImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SubmitImplCopyWithImpl<$Res>
    extends _$WizardIntentCopyWithImpl<$Res, _$SubmitImpl>
    implements _$$SubmitImplCopyWith<$Res> {
  __$$SubmitImplCopyWithImpl(
    _$SubmitImpl _value,
    $Res Function(_$SubmitImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WizardIntent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SubmitImpl implements Submit {
  const _$SubmitImpl();

  @override
  String toString() {
    return 'WizardIntent.submit()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SubmitImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() nextStep,
    required TResult Function() previousStep,
    required TResult Function(String name) updateSyndicName,
    required TResult Function(String name) updateAdjointName,
    required TResult Function(String name) updateConciergeName,
    required TResult Function() submit,
  }) {
    return submit();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? nextStep,
    TResult? Function()? previousStep,
    TResult? Function(String name)? updateSyndicName,
    TResult? Function(String name)? updateAdjointName,
    TResult? Function(String name)? updateConciergeName,
    TResult? Function()? submit,
  }) {
    return submit?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? nextStep,
    TResult Function()? previousStep,
    TResult Function(String name)? updateSyndicName,
    TResult Function(String name)? updateAdjointName,
    TResult Function(String name)? updateConciergeName,
    TResult Function()? submit,
    required TResult orElse(),
  }) {
    if (submit != null) {
      return submit();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NextStep value) nextStep,
    required TResult Function(PreviousStep value) previousStep,
    required TResult Function(UpdateSyndicName value) updateSyndicName,
    required TResult Function(UpdateAdjointName value) updateAdjointName,
    required TResult Function(UpdateConciergeName value) updateConciergeName,
    required TResult Function(Submit value) submit,
  }) {
    return submit(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NextStep value)? nextStep,
    TResult? Function(PreviousStep value)? previousStep,
    TResult? Function(UpdateSyndicName value)? updateSyndicName,
    TResult? Function(UpdateAdjointName value)? updateAdjointName,
    TResult? Function(UpdateConciergeName value)? updateConciergeName,
    TResult? Function(Submit value)? submit,
  }) {
    return submit?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NextStep value)? nextStep,
    TResult Function(PreviousStep value)? previousStep,
    TResult Function(UpdateSyndicName value)? updateSyndicName,
    TResult Function(UpdateAdjointName value)? updateAdjointName,
    TResult Function(UpdateConciergeName value)? updateConciergeName,
    TResult Function(Submit value)? submit,
    required TResult orElse(),
  }) {
    if (submit != null) {
      return submit(this);
    }
    return orElse();
  }
}

abstract class Submit implements WizardIntent {
  const factory Submit() = _$SubmitImpl;
}
