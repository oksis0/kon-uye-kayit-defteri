// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kuyruk_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(kuyrukListesi)
const kuyrukListesiProvider = KuyrukListesiProvider._();

final class KuyrukListesiProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<IceAktarmaIsi>>,
          List<IceAktarmaIsi>,
          Stream<List<IceAktarmaIsi>>
        >
    with
        $FutureModifier<List<IceAktarmaIsi>>,
        $StreamProvider<List<IceAktarmaIsi>> {
  const KuyrukListesiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kuyrukListesiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kuyrukListesiHash();

  @$internal
  @override
  $StreamProviderElement<List<IceAktarmaIsi>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<IceAktarmaIsi>> create(Ref ref) {
    return kuyrukListesi(ref);
  }
}

String _$kuyrukListesiHash() => r'3a90656dab864279070a193e4f181678211d90d3';

/// Klasör seçiminden görüntü hazırlama tamamlanana kadar olan akışı yönetir.
///
/// ★ Faz 2 kapsamı: sadece görüntü hazırlama (format/boyut). OCR YOK —
/// Faz 3+'ta bu Notifier'a `ocrYapiliyor` adımı eklenecek, arayüz ve
/// ilerleme mantığı değişmeyecek (PLAN.md §8).

@ProviderFor(KuyrukIsleyici)
const kuyrukIsleyiciProvider = KuyrukIsleyiciProvider._();

/// Klasör seçiminden görüntü hazırlama tamamlanana kadar olan akışı yönetir.
///
/// ★ Faz 2 kapsamı: sadece görüntü hazırlama (format/boyut). OCR YOK —
/// Faz 3+'ta bu Notifier'a `ocrYapiliyor` adımı eklenecek, arayüz ve
/// ilerleme mantığı değişmeyecek (PLAN.md §8).
final class KuyrukIsleyiciProvider
    extends $NotifierProvider<KuyrukIsleyici, KuyrukIlerlemeDurumu> {
  /// Klasör seçiminden görüntü hazırlama tamamlanana kadar olan akışı yönetir.
  ///
  /// ★ Faz 2 kapsamı: sadece görüntü hazırlama (format/boyut). OCR YOK —
  /// Faz 3+'ta bu Notifier'a `ocrYapiliyor` adımı eklenecek, arayüz ve
  /// ilerleme mantığı değişmeyecek (PLAN.md §8).
  const KuyrukIsleyiciProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kuyrukIsleyiciProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kuyrukIsleyiciHash();

  @$internal
  @override
  KuyrukIsleyici create() => KuyrukIsleyici();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KuyrukIlerlemeDurumu value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KuyrukIlerlemeDurumu>(value),
    );
  }
}

String _$kuyrukIsleyiciHash() => r'eb54cc68cfe754090d7d448147579cdbb5c1e01f';

/// Klasör seçiminden görüntü hazırlama tamamlanana kadar olan akışı yönetir.
///
/// ★ Faz 2 kapsamı: sadece görüntü hazırlama (format/boyut). OCR YOK —
/// Faz 3+'ta bu Notifier'a `ocrYapiliyor` adımı eklenecek, arayüz ve
/// ilerleme mantığı değişmeyecek (PLAN.md §8).

abstract class _$KuyrukIsleyici extends $Notifier<KuyrukIlerlemeDurumu> {
  KuyrukIlerlemeDurumu build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<KuyrukIlerlemeDurumu, KuyrukIlerlemeDurumu>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<KuyrukIlerlemeDurumu, KuyrukIlerlemeDurumu>,
              KuyrukIlerlemeDurumu,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
