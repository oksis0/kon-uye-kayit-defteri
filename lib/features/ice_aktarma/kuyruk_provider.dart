import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repository/kuyruk_repository.dart';
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
    this.suankiDosyaAdi,
    this.sonHata,
  });

  final bool calisiyorMu;
  final int toplam;
  final int tamamlanan;
  final String? suankiDosyaAdi;
  final String? sonHata;

  KuyrukIlerlemeDurumu kopyala({
    bool? calisiyorMu,
    int? toplam,
    int? tamamlanan,
    String? suankiDosyaAdi,
    bool suankiDosyaAdiTemizle = false,
    String? sonHata,
    bool sonHataTemizle = false,
  }) {
    return KuyrukIlerlemeDurumu(
      calisiyorMu: calisiyorMu ?? this.calisiyorMu,
      toplam: toplam ?? this.toplam,
      tamamlanan: tamamlanan ?? this.tamamlanan,
      suankiDosyaAdi: suankiDosyaAdiTemizle ? null : (suankiDosyaAdi ?? this.suankiDosyaAdi),
      sonHata: sonHataTemizle ? null : (sonHata ?? this.sonHata),
    );
  }
}

/// Klasör seçiminden görüntü hazırlama tamamlanana kadar olan akışı yönetir.
///
/// ★ Faz 2 kapsamı: sadece görüntü hazırlama (format/boyut). OCR YOK —
/// Faz 3+'ta bu Notifier'a `ocrYapiliyor` adımı eklenecek, arayüz ve
/// ilerleme mantığı değişmeyecek (PLAN.md §8).
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

  /// Bekleyen (henüz hazırlanmamış) tüm işleri sırayla hazırlar.
  /// ★ Kesintiye dayanıklı: her iş kendi durumunu Drift'e anında yazıyor
  /// (KuyrukRepository.hazirla), bu yüzden uygulama ortasında kapansa bile
  /// kalan işler bir sonraki açılışta bu metodun tekrar çağrılmasıyla
  /// kaldığı yerden devam eder.
  Future<void> hazirlamayaDevamEt() async {
    final KuyrukRepository repo = ref.read(kuyrukRepositoryProvider);
    final List<IceAktarmaIsi> tumIsler = await repo.tumunuIzle().first;
    final List<IceAktarmaIsi> bekleyenler =
        tumIsler.where((IceAktarmaIsi is_) => is_.durum == KuyrukDurumu.bekliyor).toList();

    if (bekleyenler.isEmpty) {
      state = state.kopyala(calisiyorMu: false, suankiDosyaAdiTemizle: true);
      return;
    }

    state = state.kopyala(
      calisiyorMu: true,
      toplam: bekleyenler.length,
      tamamlanan: 0,
      sonHataTemizle: true,
    );

    for (final IceAktarmaIsi is_ in bekleyenler) {
      state = state.kopyala(suankiDosyaAdi: is_.dosyaAdi);
      await repo.hazirla(is_.id);
      state = state.kopyala(tamamlanan: state.tamamlanan + 1);
    }

    state = state.kopyala(calisiyorMu: false, suankiDosyaAdiTemizle: true);
  }
}
