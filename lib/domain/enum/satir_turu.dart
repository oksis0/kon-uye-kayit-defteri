/// Defter satırının türü. Sermaye Yüklenmeleri ve Ödemeler tablolarının
/// sütun yapısı aynı olduğu için tek model + bu ayrım kullanılıyor
/// (PLAN.md §4.2).
enum SatirTuru {
  sermaye,
  odeme;

  String get etiket => switch (this) {
        SatirTuru.sermaye => 'Sermaye Yüklenmesi',
        SatirTuru.odeme => 'Ödeme',
      };
}
