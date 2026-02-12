// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tasks_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeTaskCountHash() => r'121d3df4d6e9bfab382d5471b9f56be2d85da1e2';

/// See also [activeTaskCount].
@ProviderFor(activeTaskCount)
final activeTaskCountProvider = AutoDisposeStreamProvider<int>.internal(
  activeTaskCount,
  name: r'activeTaskCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeTaskCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveTaskCountRef = AutoDisposeStreamProviderRef<int>;
String _$tasksViewModelHash() => r'ded4d6c8f69b13c8be4d141eef6ce5c968ce4761';

/// See also [TasksViewModel].
@ProviderFor(TasksViewModel)
final tasksViewModelProvider =
    AutoDisposeStreamNotifierProvider<TasksViewModel, List<Task>>.internal(
      TasksViewModel.new,
      name: r'tasksViewModelProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$tasksViewModelHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TasksViewModel = AutoDisposeStreamNotifier<List<Task>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
