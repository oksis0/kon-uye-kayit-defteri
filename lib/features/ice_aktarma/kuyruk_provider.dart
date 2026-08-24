import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/config/env.dart';
import '../../data/repository/kuyruk_repository.dart';
import '../../data/repository/ocr_repository.dart';
import '../../domain/enum/kuyruk_durumu.dart';
import '../../domain/model/ice_aktarma_isi.dart';

part 'kuyruk_provider.g.dart';

@riverpod
Stream<List<IceAktarmaIsi>> kuyrukListesi(Ref ref) {
  return ref.watch(kuyrukRepositoryProvider).tumunuIzle();
}

class KuyrukIlerlemeDurumu {
  const KuyrukIlerlemeDurumu({
    this.calisiyorMu = false,
    this.toplam = 0,
    this.tamamlanan = 0,
    this.ocrBekleyenSayisi = 0,
    this.suankiDosyaAdi,
    this.sonHata,
  });

  final bool calisiyorMu;
  final int toplam;
  final int tamamlanan;

  /// ★ Bunun için bir "X/Y" yüzdesi GÖSTERİLMİYOR — Azure OCR'ın ne zaman
  /// biteceği bilinmiyor (ağ, kuyruk, Azure'un kendi işlem süresi). Sahte
  /// bir ilerleme çubuğu yanıltıcı olurdu; sadece "kaç belge bekliyor"
  /// dürüstçe gösteriliyor.
  final int ocrBekleyenSayisi;

  final String? suankiDosyaAdi;
  final String? sonHata;

  KuyrukIlerlemeDurumu kopyala({
    bool? calisiyorMu,
    int? toplam,
    int? tamamlanan,
    int? ocrBekleyenSayisi,
    String? suankiDosyaAdi,
    bool suankiDosyaAdiTemizle = false,
    String? sonHata,
    bool sonHataTemizle = false,
  }) {
    return KuyrukIlerlemeDurumu(
      calisiyorMu: calisiyorMu ?? this.calisiyorMu,
      toplam: toplam ?? this.toplam,
      tamamlanan: tamamlanan ?? this.tamamlanan,
      ocrBekleyenSayisi: ocrBekleyenSayisi ?? this.ocrBekleyenSayisi,
      suankiDosyaAdi: suankiDosyaAdiTemizle ? null : (suankiDosyaAdi ?? this.suankiDosyaAdi),
      sonHata: sonHataTemizle ? null : (sonHata ?? this.sonHata),
    );
  }
}

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
@riverpod
class KuyrukIsleyici extends _$KuyrukIsleyici {
  @override
  KuyrukIlerlemeDurumu build() => const KuyrukIlerlemeDurumu();

  Future<void> klasorSecVeIceAktar(String klasorYolu) async {
    final KuyrukRepository repo = ref.read(kuyrukRepositoryProvider);
    state = state.kopyala(calisiyorMu: true, sonHataTemizle: true);

    try {
      await repo.klasordenIceAktar(klasorYolu);
    } catch (e) {
      state = state.kopyala(calisiyorMu: false, sonHata: e.toString());
      return;
    }

    await hazirlamayaDevamEt();
  }

  /// ★ Kesintiye dayanıklı: her iş kendi durumunu Drift'e anında yazıyor,
  /// bu yüzden uygulama ortasında kapansa bile kalan işler bir sonraki
  /// açılışta bu metodun tekrar çağrılmasıyla kaldığı yerden devam eder.
  Future<void> hazirlamayaDevamEt() async {
    final KuyrukRepository repo = ref.read(kuyrukRepositoryProvider);
    final OcrRepository? ocrRepo =
        Env.bulutYapilandirmasiTamam ? ref.read(ocrRepositoryProvider) : null;

    final List<IceAktarmaIsi> tumIsler = await repo.tumunuIzle().first;
    final List<IceAktarmaIsi> bekleyenler =
        tumIsler.where((IceAktarmaIsi is_) => is_.durum == KuyrukDurumu.bekliyor).toList();

    if (bekleyenler.isNotEmpty) {
      state = state.kopyala(
        calisiyorMu: true,
        toplam: bekleyenler.length,
        tamamlanan: 0,
        sonHataTemizle: true,
      );

      // ★ Kota kontrolü (PLAN.md §9) — 500'de kuyruk otomatik duraklar.
      // Firestore'a her iş için tekrar sormak yerine bir kez okuyup
      // yereldeki döngüde düşürüyoruz (aynı anda başka kimse OCR
      // başlatmıyor — 2 kişilik ekip senaryosu).
      int? kalanKota;
      if (ocrRepo != null) {
        final int kullanim = await ocrRepo.kotaKullanimi();
        kalanKota = aylikUcretsizOcrLimiti - kullanim;
      }

      for (final IceAktarmaIsi is_ in bekleyenler) {
        if (kalanKota != null && kalanKota <= 0) {
          state = state.kopyala(
            sonHata: 'Bu ayki 500 sayfa Azure OCR kotası doldu. Kalan '
                '${bekleyenler.length - state.tamamlanan} belge gelecek ay '
                'işlenecek (PLAN.md §9).',
          );
          break;
        }

        state = state.kopyala(suankiDosyaAdi: is_.dosyaAdi);
        await repo.hazirla(is_.id, ocrRepo: ocrRepo);
        if (kalanKota != null) kalanKota--;
        state = state.kopyala(tamamlanan: state.tamamlanan + 1);
      }
    }

    if (ocrRepo != null) {
      await _ocrBeklemeDongusu(repo, ocrRepo);
    }

    state = state.kopyala(calisiyorMu: false, suankiDosyaAdiTemizle: true, ocrBekleyenSayisi: 0);
  }

  Future<void> _ocrBeklemeDongusu(KuyrukRepository repo, OcrRepository ocrRepo) async {
    while (true) {
      final List<IceAktarmaIsi> tumIsler = await repo.tumunuIzle().first;
      final List<IceAktarmaIsi> ocrBekleyenler = tumIsler
          .where((IceAktarmaIsi is_) => is_.durum == KuyrukDurumu.ocrYapiliyor)
          .toList();

      if (ocrBekleyenler.isEmpty) return;

      state = state.kopyala(calisiyorMu: true, ocrBekleyenSayisi: ocrBekleyenler.length);

      for (final IceAktarmaIsi is_ in ocrBekleyenler) {
        await repo.ocrDurumunuKontrolEt(is_.id, ocrRepo);
      }

      await Future<void>.delayed(const Duration(seconds: 2));
    }
  }
}
