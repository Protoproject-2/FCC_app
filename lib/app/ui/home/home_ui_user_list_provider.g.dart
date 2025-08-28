// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_ui_user_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(UserList)
const userListProvider = UserListProvider._();

final class UserListProvider extends $NotifierProvider<UserList, List<User>> {
  const UserListProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'userListProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userListHash();

  @$internal
  @override
  UserList create() => UserList();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<User> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<User>>(value),
    );
  }
}

String _$userListHash() => r'018cd0ce53a7f9d057286d2a2c7d0574149fafa3';

abstract class _$UserList extends $Notifier<List<User>> {
  List<User> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<User>, List<User>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<List<User>, List<User>>, List<User>, Object?, Object?>;
    element.handleValue(ref, created);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
