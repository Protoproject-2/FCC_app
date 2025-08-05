// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_ui_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(HomeUiViewModel)
const homeUiViewModelProvider = HomeUiViewModelProvider._();

final class HomeUiViewModelProvider
    extends $NotifierProvider<HomeUiViewModel, HomeUiState> {
  const HomeUiViewModelProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'homeUiViewModelProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$homeUiViewModelHash();

  @$internal
  @override
  HomeUiViewModel create() => HomeUiViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeUiState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeUiState>(value),
    );
  }
}

String _$homeUiViewModelHash() => r'c8ce290981c83d2b5b024051e415082c0149054b';

abstract class _$HomeUiViewModel extends $Notifier<HomeUiState> {
  HomeUiState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<HomeUiState, HomeUiState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<HomeUiState, HomeUiState>, HomeUiState, Object?, Object?>;
    element.handleValue(ref, created);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
