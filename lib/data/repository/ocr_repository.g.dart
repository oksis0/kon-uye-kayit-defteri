// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ocr_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ocrRepository)
const ocrRepositoryProvider = OcrRepositoryProvider._();

final class OcrRepositoryProvider
    extends $FunctionalProvider<OcrRepository, OcrRepository, OcrRepository>
    with $Provider<OcrRepository> {
  const OcrRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ocrRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ocrRepositoryHash();

  @$internal
  @override
  $ProviderElement<OcrRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OcrRepository create(Ref ref) {
    return ocrRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OcrRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OcrRepository>(value),
    );
  }
}

String _$ocrRepositoryHash() => r'd8e2eb6d173ef84615ea0e96a0c6e4c1679341ee';
