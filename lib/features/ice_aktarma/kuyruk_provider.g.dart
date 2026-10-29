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

/// Klasör seçiminden OCR sonucunun hazır olmasına kadar olan akışı yönetir.
///
/// İki aşama:
/// 1. **Hazırlama** (deterministik) — her dosya için format/boyut kontrolü,
///    ardından bulut yapılandırılmışsa Azure OCR'ı BAŞLATIR (beklemez).
/// 2. **OCR bekleme** (belirsiz süreli, sadece bulut yapılandırılmışsa) —
///    `ocrYapiliyor` durumundaki işler 2 saniyede bir sorgulanır, sonuç
///    gelince `onayBekliyor`'a geçer (PLAN.md §8).
///
/// Bulut yapılandırılmamışsa (env.json boş) 2. aşama hiç çalışmaz — her iş
/// hazırlama sonrası doğrudan `onayBekliyor`'a geçer (Faz 1-2 elle akışı).

@ProviderFor(KuyrukIsleyici)
const kuyrukIsleyiciProvider = KuyrukIsleyiciProvider._();

/// Klasör seçiminden OCR sonucunun hazır olmasına kadar olan akışı yönetir.
///
/// İki aşama:
/// 1. **Hazırlama** (deterministik) — her dosya için format/boyut kontrolü,
///    ardından bulut yapılandırılmışsa Azure OCR'ı BAŞLATIR (beklemez).
/// 2. **OCR bekleme** (belirsiz süreli, sadece bulut yapılandırılmışsa) —
///    `ocrYapiliyor` durumundaki işler 2 saniyede bir sorgulanır, sonuç
///    gelince `onayBekliyor`'a geçer (PLAN.md §8).
///
/// Bulut yapılandırılmamışsa (env.json boş) 2. aşama hiç çalışmaz — her iş
/// hazırlama sonrası doğrudan `onayBekliyor`'a geçer (Faz 1-2 elle akışı).
final class KuyrukIsleyiciProvider
    extends $NotifierProvider<KuyrukIsleyici, KuyrukIlerlemeDurumu> {
  /// Klasör seçiminden OCR sonucunun hazır olmasına kadar olan akışı yönetir.
  ///
  /// İki aşama:
  /// 1. **Hazırlama** (deterministik) — her dosya için format/boyut kontrolü,
  ///    ardından bulut yapılandırılmışsa Azure OCR'ı BAŞLATIR (beklemez).
  /// 2. **OCR bekleme** (belirsiz süreli, sadece bulut yapılandırılmışsa) —
  ///    `ocrYapiliyor` durumundaki işler 2 saniyede bir sorgulanır, sonuç
  ///    gelince `onayBekliyor`'a geçer (PLAN.md §8).
  ///
  /// Bulut yapılandırılmamışsa (env.json boş) 2. aşama hiç çalışmaz — her iş
  /// hazırlama sonrası doğrudan `onayBekliyor`'a geçer (Faz 1-2 elle akışı).
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

String _$kuyrukIsleyiciHash() => r'ddda1bde1fa02d39e7f3f25032eaea8c4c26e1e5';

/// Klasör seçiminden OCR sonucunun hazır olmasına kadar olan akışı yönetir.
///
/// İki aşama:
/// 1. **Hazırlama** (deterministik) — her dosya için format/boyut kontrolü,
///    ardından bulut yapılandırılmışsa Azure OCR'ı BAŞLATIR (beklemez).
/// 2. **OCR bekleme** (belirsiz süreli, sadece bulut yapılandırılmışsa) —
///    `ocrYapiliyor` durumundaki işler 2 saniyede bir sorgulanır, sonuç
///    gelince `onayBekliyor`'a geçer (PLAN.md §8).
///
/// Bulut yapılandırılmamışsa (env.json boş) 2. aşama hiç çalışmaz — her iş
/// hazırlama sonrası doğrudan `onayBekliyor`'a geçer (Faz 1-2 elle akışı).

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
