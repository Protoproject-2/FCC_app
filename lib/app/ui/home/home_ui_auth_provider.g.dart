// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_ui_auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(HomeUiAuth)
const homeUiAuthProvider = HomeUiAuthProvider._();

final class HomeUiAuthProvider
    extends $NotifierProvider<HomeUiAuth, LoggedInState> {
  const HomeUiAuthProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'homeUiAuthProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$homeUiAuthHash();

  @$internal
  @override
  HomeUiAuth create() => HomeUiAuth();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoggedInState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoggedInState>(value),
    );
  }
}

String _$homeUiAuthHash() => r'd19edd0aad51cce30b92cc30e4cf943bf55adecf';

abstract class _$HomeUiAuth extends $Notifier<LoggedInState> {
  LoggedInState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<LoggedInState, LoggedInState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<LoggedInState, LoggedInState>,
        LoggedInState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
