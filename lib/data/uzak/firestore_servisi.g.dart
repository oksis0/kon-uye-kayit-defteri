// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firestore_servisi.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ★ Sadece `Env.bulutYapilandirmasiTamam == true` iken okunmalı —
/// `FirebaseFirestore.instance` Firebase başlatılmadan çağrılırsa hata
/// fırlatır. Riverpod tembel (lazy) olduğu için bu provider hiç
/// `watch`/`read` edilmezse `FirebaseFirestore.instance`'a hiç dokunulmaz.

@ProviderFor(firestoreServisi)
const firestoreServisiProvider = FirestoreServisiProvider._();

/// ★ Sadece `Env.bulutYapilandirmasiTamam == true` iken okunmalı —
/// `FirebaseFirestore.instance` Firebase başlatılmadan çağrılırsa hata
/// fırlatır. Riverpod tembel (lazy) olduğu için bu provider hiç
/// `watch`/`read` edilmezse `FirebaseFirestore.instance`'a hiç dokunulmaz.

final class FirestoreServisiProvider
    extends
        $FunctionalProvider<
          FirestoreServisi,
          FirestoreServisi,
          FirestoreServisi
        >
    with $Provider<FirestoreServisi> {
  /// ★ Sadece `Env.bulutYapilandirmasiTamam == true` iken okunmalı —
  /// `FirebaseFirestore.instance` Firebase başlatılmadan çağrılırsa hata
  /// fırlatır. Riverpod tembel (lazy) olduğu için bu provider hiç
  /// `watch`/`read` edilmezse `FirebaseFirestore.instance`'a hiç dokunulmaz.
  const FirestoreServisiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firestoreServisiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firestoreServisiHash();

  @$internal
  @override
  $ProviderElement<FirestoreServisi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FirestoreServisi create(Ref ref) {
    return firestoreServisi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirestoreServisi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirestoreServisi>(value),
    );
  }
}

String _$firestoreServisiHash() => r'c84e75cd7b9838e4a9cbc135005f448a68f1de08';
