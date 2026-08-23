// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'belge_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(belgeRepository)
const belgeRepositoryProvider = BelgeRepositoryProvider._();

final class BelgeRepositoryProvider
    extends
        $FunctionalProvider<BelgeRepository, BelgeRepository, BelgeRepository>
    with $Provider<BelgeRepository> {
  const BelgeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'belgeRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$belgeRepositoryHash();

  @$internal
  @override
  $ProviderElement<BelgeRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BelgeRepository create(Ref ref) {
    return belgeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BelgeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BelgeRepository>(value),
    );
  }
}

String _$belgeRepositoryHash() => r'a02992b2e72b65433a4c39d489cc150ec68a4709';
