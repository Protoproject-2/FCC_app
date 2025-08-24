// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_notification_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(localNotificationService)
const localNotificationServiceProvider = LocalNotificationServiceProvider._();

final class LocalNotificationServiceProvider extends $FunctionalProvider<
    LocalNotificationService,
    LocalNotificationService,
    LocalNotificationService> with $Provider<LocalNotificationService> {
  const LocalNotificationServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'localNotificationServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$localNotificationServiceHash();

  @$internal
  @override
  $ProviderElement<LocalNotificationService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LocalNotificationService create(Ref ref) {
    return localNotificationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalNotificationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalNotificationService>(value),
    );
  }
}

String _$localNotificationServiceHash() =>
    r'de89fee4ec0940a94077976a66e6dcc4702c5b27';

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
