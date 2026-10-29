// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_servisi.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authServisi)
const authServisiProvider = AuthServisiProvider._();

final class AuthServisiProvider
    extends $FunctionalProvider<AuthServisi, AuthServisi, AuthServisi>
    with $Provider<AuthServisi> {
  const AuthServisiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authServisiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authServisiHash();

  @$internal
  @override
  $ProviderElement<AuthServisi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthServisi create(Ref ref) {
    return authServisi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthServisi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthServisi>(value),
    );
  }
}

String _$authServisiHash() => r'848c97e7d5d6f3a4680af6660edf216c6d43485f';

/// Giriş durumunu canlı izler — router guard ve giriş ekranı bunu kullanır.

@ProviderFor(authDurumu)
const authDurumuProvider = AuthDurumuProvider._();

/// Giriş durumunu canlı izler — router guard ve giriş ekranı bunu kullanır.

final class AuthDurumuProvider
    extends $FunctionalProvider<AsyncValue<User?>, User?, Stream<User?>>
    with $FutureModifier<User?>, $StreamProvider<User?> {
  /// Giriş durumunu canlı izler — router guard ve giriş ekranı bunu kullanır.
  const AuthDurumuProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authDurumuProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authDurumuHash();

  @$internal
  @override
  $StreamProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<User?> create(Ref ref) {
    return authDurumu(ref);
  }
}

String _$authDurumuHash() => r'c5c83ac03a480c0f3971e3e397cee80cb1fcaa1d';
