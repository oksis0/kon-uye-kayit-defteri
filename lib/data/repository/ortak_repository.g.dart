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

String _$ortakRepositoryHash() => r'b1cea715175310ec6d46fa6c36ea9016a00a417f';

/// Uygulama açılışında BİR KEZ çalışır (app.dart'ta `ref.watch` edilir,
/// `keepAlive` sayesinde tekrar tetiklenmez). Bulut yapılandırılmamışsa
/// hiçbir şey yapmaz.

@ProviderFor(baslangicSenkronu)
const baslangicSenkronuProvider = BaslangicSenkronuProvider._();

/// Uygulama açılışında BİR KEZ çalışır (app.dart'ta `ref.watch` edilir,
/// `keepAlive` sayesinde tekrar tetiklenmez). Bulut yapılandırılmamışsa
/// hiçbir şey yapmaz.

final class BaslangicSenkronuProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Uygulama açılışında BİR KEZ çalışır (app.dart'ta `ref.watch` edilir,
  /// `keepAlive` sayesinde tekrar tetiklenmez). Bulut yapılandırılmamışsa
  /// hiçbir şey yapmaz.
  const BaslangicSenkronuProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'baslangicSenkronuProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$baslangicSenkronuHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return baslangicSenkronu(ref);
  }
}

String _$baslangicSenkronuHash() => r'd050926f0a01fe8560e95fb0fd806f3e9adf7722';
