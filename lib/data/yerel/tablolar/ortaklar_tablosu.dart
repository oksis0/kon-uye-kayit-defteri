import 'package:drift/drift.dart';

/// Bir kaydın buluta göre durumu. ★ Sadece Drift'te var — domain modeli
/// [Ortak] bunu bilmez, bu saf bir yerel senkronizasyon detayıdır
/// (PLAN.md §4.1).
enum SenkronDurumu { senkron, beklemede, hata }

/// PLAN.md §4.1 — ortak kimlik bilgileri.
///
/// ★ Üretilen satır sınıfı bilinçli olarak `OrtakSatiri` (domain'deki
/// `Ortak`'tan farklı isim) — repository katmanı ikisi arasında çeviri
/// yapar, hiçbir yerde isim çakışması veya karışıklık olmasın diye
/// (PLAN.md §3, katman kuralı).
@DataClassName('OrtakSatiri')
class Ortaklar extends Table {
  TextColumn get id => text()();
  TextColumn get ortakNo => text()();
  TextColumn get adSoyad => text()();
  TextColumn get babaAdi => text().nullable()();
  TextColumn get dogumYeri => text().nullable()();
  TextColumn get dogumTarihiHam => text().nullable()();
  DateTimeColumn get dogumTarihi => dateTime().nullable()();
  TextColumn get girisTarihiHam => text().nullable()();
  DateTimeColumn get girisTarihi => dateTime().nullable()();
  TextColumn get cikisTarihiHam => text().nullable()();
  DateTimeColumn get cikisTarihi => dateTime().nullable()();
  TextColumn get ikametAdresi => text().nullable()();
  TextColumn get nufusKayitYeri => text().nullable()();

  /// Türkçe normalize edilmiş, tüm metin alanlarının birleşimi.
  /// Arama bu sütun üzerinden yapılır (PLAN.md §5).
  TextColumn get aramaAnahtari => text()();

  TextColumn get belgeR2Anahtari => text().nullable()();
  RealColumn get ocrGuvenOrtalama => real().nullable()();

  BoolColumn get aktif => boolean().withDefault(const Constant(true))();
  TextColumn get pasifNedeni => text().nullable()();
  DateTimeColumn get pasifTarihi => dateTime().nullable()();

  DateTimeColumn get olusturmaTarihi => dateTime()();
  DateTimeColumn get guncellemeTarihi => dateTime()();

  TextColumn get senkronDurumu => textEnum<SenkronDurumu>()
      .withDefault(Constant(SenkronDurumu.beklemede.name))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
