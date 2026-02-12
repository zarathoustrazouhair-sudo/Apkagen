// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wizard_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$WizardState {
  int get currentStep => throw _privateConstructorUsedError;
  String get syndicName => throw _privateConstructorUsedError;
  String get adjointName => throw _privateConstructorUsedError;
  String get conciergeName => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of WizardState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WizardStateCopyWith<WizardState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WizardStateCopyWith<$Res> {
  factory $WizardStateCopyWith(
    WizardState value,
    $Res Function(WizardState) then,
  ) = _$WizardStateCopyWithImpl<$Res, WizardState>;
  @useResult
  $Res call({
    int currentStep,
    String syndicName,
    String adjointName,
    String conciergeName,
    bool isLoading,
    String? error,
  });
}

/// @nodoc
class _$WizardStateCopyWithImpl<$Res, $Val extends WizardState>
    implements $WizardStateCopyWith<$Res> {
  _$WizardStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WizardState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStep = null,
    Object? syndicName = null,
    Object? adjointName = null,
    Object? conciergeName = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            currentStep: null == currentStep
                ? _value.currentStep
                : currentStep // ignore: cast_nullable_to_non_nullable
                      as int,
            syndicName: null == syndicName
                ? _value.syndicName
                : syndicName // ignore: cast_nullable_to_non_nullable
                      as String,
            adjointName: null == adjointName
                ? _value.adjointName
                : adjointName // ignore: cast_nullable_to_non_nullable
                      as String,
            conciergeName: null == conciergeName
                ? _value.conciergeName
                : conciergeName // ignore: cast_nullable_to_non_nullable
                      as String,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WizardStateImplCopyWith<$Res>
    implements $WizardStateCopyWith<$Res> {
  factory _$$WizardStateImplCopyWith(
    _$WizardStateImpl value,
    $Res Function(_$WizardStateImpl) then,
  ) = __$$WizardStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int currentStep,
    String syndicName,
    String adjointName,
    String conciergeName,
    bool isLoading,
    String? error,
  });
}

/// @nodoc
class __$$WizardStateImplCopyWithImpl<$Res>
    extends _$WizardStateCopyWithImpl<$Res, _$WizardStateImpl>
    implements _$$WizardStateImplCopyWith<$Res> {
  __$$WizardStateImplCopyWithImpl(
    _$WizardStateImpl _value,
    $Res Function(_$WizardStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WizardState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStep = null,
    Object? syndicName = null,
    Object? adjointName = null,
    Object? conciergeName = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(
      _$WizardStateImpl(
        currentStep: null == currentStep
            ? _value.currentStep
            : currentStep // ignore: cast_nullable_to_non_nullable
                  as int,
        syndicName: null == syndicName
            ? _value.syndicName
            : syndicName // ignore: cast_nullable_to_non_nullable
                  as String,
        adjointName: null == adjointName
            ? _value.adjointName
            : adjointName // ignore: cast_nullable_to_non_nullable
                  as String,
        conciergeName: null == conciergeName
            ? _value.conciergeName
            : conciergeName // ignore: cast_nullable_to_non_nullable
                  as String,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$WizardStateImpl implements _WizardState {
  const _$WizardStateImpl({
    this.currentStep = 0,
    this.syndicName = '',
    this.adjointName = '',
    this.conciergeName = '',
    this.isLoading = false,
    this.error,
  });

  @override
  @JsonKey()
  final int currentStep;
  @override
  @JsonKey()
  final String syndicName;
  @override
  @JsonKey()
  final String adjointName;
  @override
  @JsonKey()
  final String conciergeName;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;

  @override
  String toString() {
    return 'WizardState(currentStep: $currentStep, syndicName: $syndicName, adjointName: $adjointName, conciergeName: $conciergeName, isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WizardStateImpl &&
            (identical(other.currentStep, currentStep) ||
                other.currentStep == currentStep) &&
            (identical(other.syndicName, syndicName) ||
                other.syndicName == syndicName) &&
            (identical(other.adjointName, adjointName) ||
                other.adjointName == adjointName) &&
            (identical(other.conciergeName, conciergeName) ||
                other.conciergeName == conciergeName) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    currentStep,
    syndicName,
    adjointName,
    conciergeName,
    isLoading,
    error,
  );

  /// Create a copy of WizardState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WizardStateImplCopyWith<_$WizardStateImpl> get copyWith =>
      __$$WizardStateImplCopyWithImpl<_$WizardStateImpl>(this, _$identity);
}

abstract class _WizardState implements WizardState {
  const factory _WizardState({
    final int currentStep,
    final String syndicName,
    final String adjointName,
    final String conciergeName,
    final bool isLoading,
    final String? error,
  }) = _$WizardStateImpl;

  @override
  int get currentStep;
  @override
  String get syndicName;
  @override
  String get adjointName;
  @override
  String get conciergeName;
  @override
  bool get isLoading;
  @override
  String? get error;

  /// Create a copy of WizardState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WizardStateImplCopyWith<_$WizardStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
