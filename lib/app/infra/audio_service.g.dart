// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(audioService)
const audioServiceProvider = AudioServiceProvider._();

final class AudioServiceProvider
    extends $FunctionalProvider<AudioService, AudioService, AudioService>
    with $Provider<AudioService> {
  const AudioServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'audioServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$audioServiceHash();

  @$internal
  @override
  $ProviderElement<AudioService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AudioService create(Ref ref) {
    return audioService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AudioService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AudioService>(value),
    );
  }
}

String _$audioServiceHash() => r'a98462eb2d4fd2f6120a62b66bd04bcaff744c55';

@ProviderFor(IsRecording)
const isRecordingProvider = IsRecordingProvider._();

final class IsRecordingProvider extends $NotifierProvider<IsRecording, bool> {
  const IsRecordingProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'isRecordingProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isRecordingHash();

  @$internal
  @override
  IsRecording create() => IsRecording();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isRecordingHash() => r'48d24ff0e3bb7d5775f6a5a2e0967e9919a5eaeb';

abstract class _$IsRecording extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<bool, bool>, bool, Object?, Object?>;
    element.handleValue(ref, created);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
