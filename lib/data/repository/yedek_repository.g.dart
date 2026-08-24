// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'yedek_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(yedekRepository)
const yedekRepositoryProvider = YedekRepositoryProvider._();

final class YedekRepositoryProvider
    extends
        $FunctionalProvider<YedekRepository, YedekRepository, YedekRepository>
    with $Provider<YedekRepository> {
  const YedekRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'yedekRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$yedekRepositoryHash();

  @$internal
  @override
  $ProviderElement<YedekRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  YedekRepository create(Ref ref) {
    return yedekRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(YedekRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<YedekRepository>(value),
    );
  }
}

String _$yedekRepositoryHash() => r'6d5f26d76f0b86b63c6dde8ddbd9d6b37b31d60d';
