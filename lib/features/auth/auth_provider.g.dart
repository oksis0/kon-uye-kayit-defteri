// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Giriş ekranındaki buton/form durumu (yükleniyor/hata) — [AuthServisi]'nin
/// kendisinden ayrı tutuluyor çünkü bu tamamen UI'a özgü, geçici bir durum.

@ProviderFor(GirisIslemi)
const girisIslemiProvider = GirisIslemiProvider._();

/// Giriş ekranındaki buton/form durumu (yükleniyor/hata) — [AuthServisi]'nin
/// kendisinden ayrı tutuluyor çünkü bu tamamen UI'a özgü, geçici bir durum.
final class GirisIslemiProvider
    extends $NotifierProvider<GirisIslemi, AsyncValue<void>> {
  /// Giriş ekranındaki buton/form durumu (yükleniyor/hata) — [AuthServisi]'nin
  /// kendisinden ayrı tutuluyor çünkü bu tamamen UI'a özgü, geçici bir durum.
  const GirisIslemiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'girisIslemiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$girisIslemiHash();

  @$internal
  @override
  GirisIslemi create() => GirisIslemi();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$girisIslemiHash() => r'd5c4cadea787098fb421177fcdc7acf5b8004185';

/// Giriş ekranındaki buton/form durumu (yükleniyor/hata) — [AuthServisi]'nin
/// kendisinden ayrı tutuluyor çünkü bu tamamen UI'a özgü, geçici bir durum.

abstract class _$GirisIslemi extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
