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

String _$ortakRepositoryHash() => r'f892e715c1a9f269943b4da7281c0e88548d9b32';

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

String _$baslangicSenkronuHash() => r'0d4938a08885dc0137610a72446bf924c9be2455';
