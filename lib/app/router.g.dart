// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ★ Auth guard **koşullu**: `env.json` henüz doldurulmadıysa
/// (`Env.bulutYapilandirmasiTamam == false`) giriş ekranı tamamen devre
/// dışı — uygulama Faz 1-2'deki gibi doğrudan arama ekranıyla açılır.
/// Cloudflare/Firebase/Azure hesapları kurulup env.json doldurulduğunda
/// otomatik olarak devreye girer; kod değişikliği gerekmez (PLAN.md §12.5).

@ProviderFor(appRouter)
const appRouterProvider = AppRouterProvider._();

/// ★ Auth guard **koşullu**: `env.json` henüz doldurulmadıysa
/// (`Env.bulutYapilandirmasiTamam == false`) giriş ekranı tamamen devre
/// dışı — uygulama Faz 1-2'deki gibi doğrudan arama ekranıyla açılır.
/// Cloudflare/Firebase/Azure hesapları kurulup env.json doldurulduğunda
/// otomatik olarak devreye girer; kod değişikliği gerekmez (PLAN.md §12.5).

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// ★ Auth guard **koşullu**: `env.json` henüz doldurulmadıysa
  /// (`Env.bulutYapilandirmasiTamam == false`) giriş ekranı tamamen devre
  /// dışı — uygulama Faz 1-2'deki gibi doğrudan arama ekranıyla açılır.
  /// Cloudflare/Firebase/Azure hesapları kurulup env.json doldurulduğunda
  /// otomatik olarak devreye girer; kod değişikliği gerekmez (PLAN.md §12.5).
  const AppRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appRouterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return appRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$appRouterHash() => r'2919823b06bc1dd7ba267edd881312f2ca8e948b';
