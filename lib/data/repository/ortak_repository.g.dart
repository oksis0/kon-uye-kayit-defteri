// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ortak_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ortakRepository)
const ortakRepositoryProvider = OrtakRepositoryProvider._();

final class OrtakRepositoryProvider
    extends
        $FunctionalProvider<OrtakRepository, OrtakRepository, OrtakRepository>
    with $Provider<OrtakRepository> {
  const OrtakRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ortakRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ortakRepositoryHash();

  @$internal
  @override
  $ProviderElement<OrtakRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OrtakRepository create(Ref ref) {
    return ortakRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrtakRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrtakRepository>(value),
    );
  }
}

String _$ortakRepositoryHash() => r'b50e38eae02760dfd7eb9892f3f74de8dc8d7d73';
