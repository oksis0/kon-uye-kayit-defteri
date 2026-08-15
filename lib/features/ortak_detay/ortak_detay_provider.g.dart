// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ortak_detay_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ortakDetay)
const ortakDetayProvider = OrtakDetayFamily._();

final class OrtakDetayProvider
    extends $FunctionalProvider<AsyncValue<Ortak?>, Ortak?, Stream<Ortak?>>
    with $FutureModifier<Ortak?>, $StreamProvider<Ortak?> {
  const OrtakDetayProvider._({
    required OrtakDetayFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'ortakDetayProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$ortakDetayHash();

  @override
  String toString() {
    return r'ortakDetayProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Ortak?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Ortak?> create(Ref ref) {
    final argument = this.argument as String;
    return ortakDetay(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is OrtakDetayProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ortakDetayHash() => r'b1a4457d635f408a76b819d4922e154ff2e93610';

final class OrtakDetayFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Ortak?>, String> {
  const OrtakDetayFamily._()
    : super(
        retry: null,
        name: r'ortakDetayProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  OrtakDetayProvider call(String id) =>
      OrtakDetayProvider._(argument: id, from: this);

  @override
  String toString() => r'ortakDetayProvider';
}

@ProviderFor(ortakSatirlari)
const ortakSatirlariProvider = OrtakSatirlariFamily._();

final class OrtakSatirlariProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DefterSatiri>>,
          List<DefterSatiri>,
          Stream<List<DefterSatiri>>
        >
    with
        $FutureModifier<List<DefterSatiri>>,
        $StreamProvider<List<DefterSatiri>> {
  const OrtakSatirlariProvider._({
    required OrtakSatirlariFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'ortakSatirlariProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$ortakSatirlariHash();

  @override
  String toString() {
    return r'ortakSatirlariProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<DefterSatiri>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<DefterSatiri>> create(Ref ref) {
    final argument = this.argument as String;
    return ortakSatirlari(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is OrtakSatirlariProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ortakSatirlariHash() => r'037a1ab9e1ffcf4cc47e7aa12b9e6992067a5b9f';

final class OrtakSatirlariFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<DefterSatiri>>, String> {
  const OrtakSatirlariFamily._()
    : super(
        retry: null,
        name: r'ortakSatirlariProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  OrtakSatirlariProvider call(String ortakId) =>
      OrtakSatirlariProvider._(argument: ortakId, from: this);

  @override
  String toString() => r'ortakSatirlariProvider';
}
