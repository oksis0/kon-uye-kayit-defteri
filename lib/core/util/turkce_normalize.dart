/// Türkçe karakter katlaması. Standart `toLowerCase()` kullanılmıyor çünkü
/// Dart/ICU 'I'.toLowerCase() İngilizce kurala göre 'i' üretir ama
/// 'İ' (nokta) ayrı bir harf olduğu için karışıklık çıkar. Bu yüzden
/// önce Türkçe harfler elle katlanıyor, ardından ASCII küçültme yapılıyor
/// (PLAN.md §5).
const Map<String, String> _harfHaritasi = {
  'ı': 'i',
  'İ': 'i',
  'I': 'i',
  'ş': 's',
  'Ş': 's',
  'ğ': 'g',
  'Ğ': 'g',
  'ü': 'u',
  'Ü': 'u',
  'ö': 'o',
  'Ö': 'o',
  'ç': 'c',
  'Ç': 'c',
  'â': 'a',
  'Â': 'a',
  'î': 'i',
  'Î': 'i',
  'û': 'u',
  'Û': 'u',
};

final RegExp _noktalamaVeFazlaBosluk = RegExp(r'[^\p{L}\p{N}\s]+', unicode: true);
final RegExp _cokluBosluk = RegExp(r'\s+');

/// Arama alanlarını normalize eder: Türkçe karakter katlaması + küçük harf +
/// noktalama temizliği + boşluk sadeleştirme.
///
/// Hem kayıt yazılırken (`aramaAnahtari` üretilirken) hem arama yapılırken
/// aynı fonksiyon kullanılmalı — aksi halde eşleşme tutmaz.
///
/// Örnek: `turkceNormalize("Şükrü YILMAZOĞLU")` → `"sukru yilmazoglu"`
String turkceNormalize(String girdi) {
  final StringBuffer katlanmis = StringBuffer();
  for (final String karakter in girdi.split('')) {
    katlanmis.write(_harfHaritasi[karakter] ?? karakter);
  }

  final String kucukHarf = katlanmis.toString().toLowerCase();
  final String noktalamasiz = kucukHarf.replaceAll(_noktalamaVeFazlaBosluk, ' ');
  final String sadelestirilmis = noktalamasiz.replaceAll(_cokluBosluk, ' ');

  return sadelestirilmis.trim();
}

/// Birden çok alanı tek bir arama anahtarında birleştirir. `null`/boş
/// alanlar atlanır (PLAN.md §4.4 — `aramaAnahtari` üretimi).
String aramaAnahtariUret(Iterable<String?> alanlar) {
  final String birlesik = alanlar
      .where((String? alan) => alan != null && alan.trim().isNotEmpty)
      .join(' ');
  return turkceNormalize(birlesik);
}
