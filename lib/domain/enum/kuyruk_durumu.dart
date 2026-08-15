/// Bir içe aktarma işinin kuyruktaki durumu (PLAN.md §4.3, §8).
///
/// Akış: `bekliyor` → `hazirlaniyor` (görüntü format/boyut/netlik) →
/// `ocrYapiliyor` → `onayBekliyor` (kullanıcı formu düzenliyor) →
/// `tamamlandi`. `hata` ve `atlandi` her aşamadan ulaşılabilen uç durumlar.
enum KuyrukDurumu {
  bekliyor,
  hazirlaniyor,
  ocrYapiliyor,
  onayBekliyor,
  tamamlandi,
  hata,
  atlandi;

  String get etiket => switch (this) {
        KuyrukDurumu.bekliyor => 'Bekliyor',
        KuyrukDurumu.hazirlaniyor => 'Hazırlanıyor',
        KuyrukDurumu.ocrYapiliyor => 'OCR Yapılıyor',
        KuyrukDurumu.onayBekliyor => 'Onay Bekliyor',
        KuyrukDurumu.tamamlandi => 'Tamamlandı',
        KuyrukDurumu.hata => 'Hata',
        KuyrukDurumu.atlandi => 'Atlandı',
      };

  /// Kuyruk işleyicisinin bu iş üzerinde durması gereken uç durumlar.
  bool get sonDurum =>
      this == KuyrukDurumu.tamamlandi || this == KuyrukDurumu.atlandi;
}
