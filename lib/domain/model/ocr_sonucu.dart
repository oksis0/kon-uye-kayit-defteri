import 'package:freezed_annotation/freezed_annotation.dart';

import 'defter_satiri.dart';

part 'ocr_sonucu.freezed.dart';

/// Tek bir alanın OCR'dan çıkarılan değeri + güven skoru.
/// Skor, Azure'un o metni oluşturan kelimelerin ortalama tanıma güvenidir
/// (semantik doğruluk değil, OCR karakter tanıma kesinliği).
@freezed
abstract class OcrAlan with _$OcrAlan {
  const factory OcrAlan({required String metin, required double guven}) = _OcrAlan;
}

/// Azure OCR'ın (prebuilt-layout) ham sonucundan ayrıştırılmış alanlar.
///
/// ★ Her alan `null` olabilir — etiket eşleyici sayfada ilgili etiketi
/// bulamazsa alan boş kalır, kullanıcı elle doldurur. "İnsan yazar, OCR
/// ön-doldurur" zihniyeti — hiçbir alan zorunlu değil (PLAN.md §7.2).
@freezed
abstract class OcrSonucu with _$OcrSonucu {
  const factory OcrSonucu({
    OcrAlan? ortakNo,
    OcrAlan? adSoyad,
    OcrAlan? babaAdi,
    OcrAlan? dogumYeri,
    OcrAlan? dogumTarihi,
    OcrAlan? girisTarihi,
    OcrAlan? cikisTarihi,
    OcrAlan? ikametAdresi,
    OcrAlan? nufusKayitYeri,
    @Default(<DefterSatiri>[]) List<DefterSatiri> sermayeSatirlari,
    @Default(<DefterSatiri>[]) List<DefterSatiri> odemeSatirlari,
  }) = _OcrSonucu;
}
