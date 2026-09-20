import 'package:freezed_annotation/freezed_annotation.dart';

part 'ortak.freezed.dart';

/// Bir ortağın kimlik bilgileri. Saf iş nesnesi — Drift'i, Firestore'u
/// bilmez (PLAN.md §3, katman kuralı).
///
/// Tarih alanlarının hem ham OCR metni hem parse edilmiş hali tutulur:
/// el yazısı OCR her zaman doğru parse edilemeyebilir, ham metin denetim
/// için her zaman saklanır (PLAN.md §4.1).
@freezed
abstract class Ortak with _$Ortak {
  const factory Ortak({
    required String id,
    required String ortakNo,
    String? sayfaNo,
    String? tcKimlikNo,
    required String adSoyad,
    String? babaAdi,
    String? dogumYeri,
    String? dogumTarihiHam,
    DateTime? dogumTarihi,
    String? girisTarihiHam,
    DateTime? girisTarihi,
    String? cikisTarihiHam,
    DateTime? cikisTarihi,
    String? ikametAdresi,
    String? nufusKayitYeri,
    String? yerelDosyaYolu,
    required String aramaAnahtari,
    String? belgeR2Anahtari,
    double? ocrGuvenOrtalama,
    @Default(true) bool aktif,
    String? pasifNedeni,
    DateTime? pasifTarihi,
    required DateTime olusturmaTarihi,
    required DateTime guncellemeTarihi,
  }) = _Ortak;

  const Ortak._();

  /// Ortak hâlâ üye mi? Çıkış tarihi girilmemişse aktif sayılır.
  bool get halaUye => cikisTarihi == null && cikisTarihiHam == null;
}
