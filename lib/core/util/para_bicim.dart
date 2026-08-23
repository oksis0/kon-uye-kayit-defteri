import 'package:intl/intl.dart';

/// Para alanları neden `int` (kuruş) — bkz. `domain/model/defter_satiri.dart`
/// üzerindeki gerekçe: `double` ikili kayan nokta hataları muhasebe
/// toplamlarını bozar (PLAN.md §4.2).

final NumberFormat _paraFormat = NumberFormat.currency(
  locale: 'tr_TR',
  symbol: '₺',
  decimalDigits: 2,
);

/// Kuruşu "1.250,50 ₺" gibi Türkçe para biçimine çevirir.
String kurusuBicimlendir(int kurus) => _paraFormat.format(kurus / 100);

/// "1.250,50", "1250,50", "1250.50" gibi serbest metni kuruşa çevirir.
/// Ayrıştırılamazsa `null` döner (OCR ham metni veya boş kullanıcı girdisi
/// için — çağıran taraf 0 varsayıp varsaymayacağına kendi karar verir).
int? paraMetniniKurusaCevir(String? metin) {
  if (metin == null) return null;
  final String temizlenmis = metin.trim();
  if (temizlenmis.isEmpty) return null;

  // Türkçe biçimde binlik ayıracı '.', ondalık ayıracı ',' — ikisi de
  // olabilir (OCR hangisini okuduğundan emin olamayız), bu yüzden:
  // son ',' veya '.' ondalık ayıracı kabul edilir, öncekiler temizlenir.
  final String rakamVeAyiraclar = temizlenmis.replaceAll(
    RegExp(r'[^\d.,]'),
    '',
  );
  if (rakamVeAyiraclar.isEmpty) return null;

  final int sonNokta = rakamVeAyiraclar.lastIndexOf('.');
  final int sonVirgul = rakamVeAyiraclar.lastIndexOf(',');
  final int ondalikKonumu = sonNokta > sonVirgul ? sonNokta : sonVirgul;

  final String tamKisim;
  final String ondalikKisim;
  if (ondalikKonumu == -1) {
    tamKisim = rakamVeAyiraclar;
    ondalikKisim = '00';
  } else {
    tamKisim = rakamVeAyiraclar
        .substring(0, ondalikKonumu)
        .replaceAll(RegExp(r'[.,]'), '');
    ondalikKisim = rakamVeAyiraclar
        .substring(ondalikKonumu + 1)
        .replaceAll(RegExp(r'[.,]'), '')
        .padRight(2, '0')
        .substring(0, 2);
  }

  final int? tamSayi = int.tryParse(tamKisim.isEmpty ? '0' : tamKisim);
  final int? ondalikSayi = int.tryParse(ondalikKisim);
  if (tamSayi == null || ondalikSayi == null) return null;

  return tamSayi * 100 + ondalikSayi;
}
