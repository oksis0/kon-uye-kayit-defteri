// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kuyruk_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(kuyrukRepository)
const kuyrukRepositoryProvider = KuyrukRepositoryProvider._();

final class KuyrukRepositoryProvider
    extends
        $FunctionalProvider<
          KuyrukRepository,
          KuyrukRepository,
          KuyrukRepository
        >
    with $Provider<KuyrukRepository> {
  const KuyrukRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kuyrukRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kuyrukRepositoryHash();

  @$internal
  @override
  $ProviderElement<KuyrukRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  KuyrukRepository create(Ref ref) {
    return kuyrukRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KuyrukRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KuyrukRepository>(value),
    );
  }
}

String _$kuyrukRepositoryHash() => r'8ffb5d58da7a875ff7f81bdecf8bafd166aa076d';
