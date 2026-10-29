import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/config/env.dart';
import '../../data/repository/kuyruk_repository.dart';
import '../../data/repository/ocr_ayristirici.dart';
import '../../data/repository/ocr_repository.dart';
import '../../data/uzak/auth_servisi.dart';
import '../../data/yerel/veritabani.dart';
import '../../domain/enum/kuyruk_durumu.dart';
import '../../domain/model/ice_aktarma_isi.dart';
import '../../domain/model/ocr_sonucu.dart';

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

  bool _islemSuruyor = false;
  bool _yeniIstekVar = false;

  Future<void> klasorSecVeIceAktar(String klasorYolu) async {
    final KuyrukRepository repo = ref.read(kuyrukRepositoryProvider);
    state = state.kopyala(calisiyorMu: true, sonHataTemizle: true);

    try {
      await repo.klasordenIceAktar(klasorYolu);
    } catch (e) {
      state = state.kopyala(calisiyorMu: false, sonHata: e.toString());
      rethrow;
    }

    await hazirlamayaDevamEt();
  }

  /// Mobilde kamera/galeriden gelen TEK bir fotoğrafı kuyruğa ekler ve
  /// hemen işlemeye başlar (PLAN.md §6.2).
  Future<void> tekDosyaEkleVeIsle(String dosyaYolu) async {
    final KuyrukRepository repo = ref.read(kuyrukRepositoryProvider);
    state = state.kopyala(calisiyorMu: true, sonHataTemizle: true);

    try {
      await repo.dosyaEkle(dosyaYolu);
    } catch (e) {
      state = state.kopyala(calisiyorMu: false, sonHata: e.toString());
      rethrow;
    }

    await hazirlamayaDevamEt();
  }

  /// Seçilen tek veya birden çok dosyayı kuyruğa ekler ve otomatik OCR başlatır.
  Future<void> dosyalariEkleVeIsle(List<String> dosyaYollari) async {
    final KuyrukRepository repo = ref.read(kuyrukRepositoryProvider);
    state = state.kopyala(calisiyorMu: true, sonHataTemizle: true);

    try {
      for (final String yol in dosyaYollari) {
        await repo.dosyaEkle(yol);
      }
    } catch (e) {
      state = state.kopyala(calisiyorMu: false, sonHata: e.toString());
      rethrow;
    }

    await hazirlamayaDevamEt();
  }

  /// Tek bir işi sıfırlayıp OCR'a gönderir
  Future<void> tekIsiOcrYap(String isId) async {
    final KuyrukRepository repo = ref.read(kuyrukRepositoryProvider);
    await repo.ocrIcinYenidenKuyrugaAl(isId);
    await hazirlamayaDevamEt();
  }

  /// Kuyrukta OCR yapılmadan kalmış tüm işleri sıfırlayıp OCR'a gönderir
  Future<void> ocrOlmayanlariIsle() async {
    final KuyrukRepository repo = ref.read(kuyrukRepositoryProvider);
    final List<IceAktarmaIsi> tumIsler = await repo.tumunuIzle().first;
    final List<IceAktarmaIsi> eksikler = tumIsler
        .where((IceAktarmaIsi is_) =>
            (is_.durum == KuyrukDurumu.onayBekliyor || is_.durum == KuyrukDurumu.hata) &&
            is_.ocrHamJson == null &&
            is_.olusanOrtakId == null)
        .toList();
    for (final IceAktarmaIsi is_ in eksikler) {
      await repo.ocrIcinYenidenKuyrugaAl(is_.id);
    }
    await hazirlamayaDevamEt();
  }

  /// ★ Kesintiye dayanıklı: her iş kendi durumunu Drift'e anında yazıyor,
  /// bu yüzden uygulama ortasında kapansa bile kalan işler bir sonraki
  /// açılışta bu metodun tekrar çağrılmasıyla kaldığı yerden devam eder.
  Future<void> hazirlamayaDevamEt() async {
    if (_islemSuruyor) {
      _yeniIstekVar = true;
      return;
    }

    _islemSuruyor = true;
    try {
      do {
        _yeniIstekVar = false;
        await _hazirlaVeBekleDongusu();
      } while (_yeniIstekVar);
    } finally {
      _islemSuruyor = false;
    }
  }

  Future<void> _hazirlaVeBekleDongusu() async {
    final KuyrukRepository repo = ref.read(kuyrukRepositoryProvider);
    final AuthServisi auth = ref.read(authServisiProvider);
    final String? token = await auth.idTokenAl();
    final bool bulutGirisli = token != null && token.isNotEmpty;
    final OcrRepository? ocrRepo =
        (Env.bulutYapilandirmasiTamam && bulutGirisli) ? ref.read(ocrRepositoryProvider) : null;

    if (Env.bulutYapilandirmasiTamam && !bulutGirisli) {
      state = state.kopyala(
        calisiyorMu: false,
        sonHata: 'Bulut oturumu bulunamadı. Otomatik OCR taraması için lütfen Ayarlar veya Giriş ekranından giriş yapın.',
      );
      return;
    }

    final List<IceAktarmaIsi> tumIsler = await repo.tumunuIzle().first;

    // Eğer bulut yapılandırması ve yetkili oturum varsa; daha önce
    // OCR yapılamadan 'onayBekliyor'a düşmüş veya hata almış işleri de otomatik olarak
    // kuyruğa geri alıp Azure OCR'a yönlendiriyoruz.
    if (ocrRepo != null) {
      final List<IceAktarmaIsi> eksikler = tumIsler
          .where((IceAktarmaIsi is_) =>
              (is_.durum == KuyrukDurumu.onayBekliyor || is_.durum == KuyrukDurumu.hata) &&
              is_.ocrHamJson == null &&
              is_.olusanOrtakId == null)
          .toList();
      for (final IceAktarmaIsi is_ in eksikler) {
        await repo.ocrIcinYenidenKuyrugaAl(is_.id);
      }
    }

    // Zaten kayıtlı üyelerin belgelerini incelemeye göndermeyip doğrudan tamamlandıya bağla
    final List<IceAktarmaIsi> onayBekleyenler = tumIsler
        .where((IceAktarmaIsi is_) =>
            is_.durum == KuyrukDurumu.onayBekliyor &&
            is_.ocrHamJson != null &&
            is_.olusanOrtakId == null)
        .toList();
    for (final IceAktarmaIsi is_ in onayBekleyenler) {
      try {
        final Object? cozulmus = jsonDecode(is_.ocrHamJson!);
        if (cozulmus is! Map<String, dynamic>) continue;
        final OcrSonucu ocr = azureSonucunuAyristir(cozulmus);
        final String tc = ocr.tcKimlikNo?.metin.replaceAll(RegExp(r'\D'), '') ?? '';
        if (tc.length == 11) {
          final OrtakSatiri? kayitli = await repo.tcIleKayitliOrtakBul(tc);
          if (kayitli != null) {
            await repo.tamamlandiIsaretle(is_.id, kayitli.id);
          }
        }
      } catch (_) {}
    }

    final List<IceAktarmaIsi> guncelIsler =
        ocrRepo != null ? await repo.tumunuIzle().first : tumIsler;
    final List<IceAktarmaIsi> bekleyenler =
        guncelIsler.where((IceAktarmaIsi is_) => is_.durum == KuyrukDurumu.bekliyor).toList();

    if (bekleyenler.isNotEmpty) {
      state = state.kopyala(
        calisiyorMu: true,
        toplam: bekleyenler.length,
        tamamlanan: 0,
        sonHataTemizle: true,
      );

      // ★ Kota kontrolü (PLAN.md §9) — 500'de kuyruk otomatik duraklar.
      int? kalanKota;
      if (ocrRepo != null) {
        try {
          final int kullanim = await ocrRepo.kotaKullanimi();
          kalanKota = aylikUcretsizOcrLimiti - kullanim;
        } catch (_) {
          kalanKota = null;
        }
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
        bool basarili = false;
        while (!basarili) {
          try {
            await repo.hazirla(is_.id, ocrRepo: ocrRepo);
            basarili = true;
          } catch (e) {
            if (e.toString().contains('429') || e.toString().contains('rate limit')) {
              state = state.kopyala(
                sonHata: 'Azure ücretsiz hız sınırı (429). 25 saniye bekleniyor...',
              );
              await Future<void>.delayed(const Duration(seconds: 25));
              state = state.kopyala(sonHataTemizle: true);
            } else {
              break;
            }
          }
        }
        if (kalanKota != null) kalanKota--;
        state = state.kopyala(tamamlanan: state.tamamlanan + 1);

        // Azure F0 ücretsiz katman sınırını (15 istek/dk) korumak için 4 sn aralık
        if (ocrRepo != null) {
          await Future<void>.delayed(const Duration(seconds: 4));
        }
      }
    }

    if (ocrRepo != null) {
      await _ocrBeklemeDongusu(repo, ocrRepo);
    }

    state = state.kopyala(calisiyorMu: false, suankiDosyaAdiTemizle: true, ocrBekleyenSayisi: 0);

    // Kuyrukta yeni eklenen bekleyen belgeler varsa tekrar işle
    final List<IceAktarmaIsi> sonKontrol = await repo.tumunuIzle().first;
    if (sonKontrol.any((IceAktarmaIsi is_) => is_.durum == KuyrukDurumu.bekliyor)) {
      _yeniIstekVar = true;
    }
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
        try {
          final OcrIslemSonucu? sonuc = await repo.ocrDurumunuKontrolEt(is_.id, ocrRepo);
          if (sonuc is OcrIslemSonucuHizSiniri) {
            state = state.kopyala(
              sonHata: 'Azure ücretsiz hız sınırı (429). ${sonuc.beklemeSaniyesi} saniye bekleniyor...',
            );
            await Future<void>.delayed(Duration(seconds: sonuc.beklemeSaniyesi));
            state = state.kopyala(sonHataTemizle: true);
            break;
          }
        } catch (e) {
          if (e.toString().contains('429') || e.toString().contains('rate limit')) {
            state = state.kopyala(
              sonHata: 'Azure ücretsiz hız sınırı (429). 25 saniye bekleniyor...',
            );
            await Future<void>.delayed(const Duration(seconds: 25));
            state = state.kopyala(sonHataTemizle: true);
            break;
          }
        }

        // Azure F0 hız sınırı (15 çağrı/dakika) için her sorgu arasına 4 sn aralık
        await Future<void>.delayed(const Duration(seconds: 4));
      }

      await Future<void>.delayed(const Duration(seconds: 2));
    }
  }
}
