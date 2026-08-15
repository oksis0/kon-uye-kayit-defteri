// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'veritabani_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Uygulama boyunca tek bir veritabanı bağlantısı — `keepAlive: true`,
/// çünkü kapanıp yeniden açılması gereksiz ve dosya kilidi sorunlarına
/// yol açabilir.

@ProviderFor(veritabani)
const veritabaniProvider = VeritabaniProvider._();

/// Uygulama boyunca tek bir veritabanı bağlantısı — `keepAlive: true`,
/// çünkü kapanıp yeniden açılması gereksiz ve dosya kilidi sorunlarına
/// yol açabilir.

final class VeritabaniProvider
    extends $FunctionalProvider<AppVeritabani, AppVeritabani, AppVeritabani>
    with $Provider<AppVeritabani> {
  /// Uygulama boyunca tek bir veritabanı bağlantısı — `keepAlive: true`,
  /// çünkü kapanıp yeniden açılması gereksiz ve dosya kilidi sorunlarına
  /// yol açabilir.
  const VeritabaniProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'veritabaniProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$veritabaniHash();

  @$internal
  @override
  $ProviderElement<AppVeritabani> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppVeritabani create(Ref ref) {
    return veritabani(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppVeritabani value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppVeritabani>(value),
    );
  }
}

String _$veritabaniHash() => r'84fe0fa03dac04266a90ee71aeaf8820c6f7d554';
