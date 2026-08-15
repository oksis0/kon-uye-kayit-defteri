// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'arama_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AramaSorgusu)
const aramaSorgusuProvider = AramaSorgusuProvider._();

final class AramaSorgusuProvider
    extends $NotifierProvider<AramaSorgusu, String> {
  const AramaSorgusuProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aramaSorgusuProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aramaSorgusuHash();

  @$internal
  @override
  AramaSorgusu create() => AramaSorgusu();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$aramaSorgusuHash() => r'4cd5bddff8cc0aea2f61892f57f5f4708779e41a';

abstract class _$AramaSorgusu extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(PasifleriDeGoster)
const pasifleriDeGosterProvider = PasifleriDeGosterProvider._();

final class PasifleriDeGosterProvider
    extends $NotifierProvider<PasifleriDeGoster, bool> {
  const PasifleriDeGosterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pasifleriDeGosterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pasifleriDeGosterHash();

  @$internal
  @override
  PasifleriDeGoster create() => PasifleriDeGoster();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$pasifleriDeGosterHash() => r'b6d88de20631e4a4e7c16ae40a0cc9b0dc60bd40';

abstract class _$PasifleriDeGoster extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// ★ Debounce yok — dataset küçük (≈2.000 kayıt), SQL sorgusu <5ms sürüyor.
/// Erken optimizasyon yapılmıyor (PLAN.md §5).

@ProviderFor(aramaSonuclari)
const aramaSonuclariProvider = AramaSonuclariProvider._();

/// ★ Debounce yok — dataset küçük (≈2.000 kayıt), SQL sorgusu <5ms sürüyor.
/// Erken optimizasyon yapılmıyor (PLAN.md §5).

final class AramaSonuclariProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Ortak>>,
          List<Ortak>,
          Stream<List<Ortak>>
        >
    with $FutureModifier<List<Ortak>>, $StreamProvider<List<Ortak>> {
  /// ★ Debounce yok — dataset küçük (≈2.000 kayıt), SQL sorgusu <5ms sürüyor.
  /// Erken optimizasyon yapılmıyor (PLAN.md §5).
  const AramaSonuclariProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aramaSonuclariProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aramaSonuclariHash();

  @$internal
  @override
  $StreamProviderElement<List<Ortak>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Ortak>> create(Ref ref) {
    return aramaSonuclari(ref);
  }
}

String _$aramaSonuclariHash() => r'7edcd2d7341e373e78e747a04ce9a2c762a2a122';

/// Geniş ekranda (masaüstü) ana-detay yan yana düzeni için seçili kayıt
/// (PLAN.md §14).

@ProviderFor(SeciliOrtakId)
const seciliOrtakIdProvider = SeciliOrtakIdProvider._();

/// Geniş ekranda (masaüstü) ana-detay yan yana düzeni için seçili kayıt
/// (PLAN.md §14).
final class SeciliOrtakIdProvider
    extends $NotifierProvider<SeciliOrtakId, String?> {
  /// Geniş ekranda (masaüstü) ana-detay yan yana düzeni için seçili kayıt
  /// (PLAN.md §14).
  const SeciliOrtakIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'seciliOrtakIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$seciliOrtakIdHash();

  @$internal
  @override
  SeciliOrtakId create() => SeciliOrtakId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$seciliOrtakIdHash() => r'af90576571fbc70578a74119de98f00a26efad3f';

/// Geniş ekranda (masaüstü) ana-detay yan yana düzeni için seçili kayıt
/// (PLAN.md §14).

abstract class _$SeciliOrtakId extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
