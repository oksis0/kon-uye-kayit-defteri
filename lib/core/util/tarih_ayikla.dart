/// Metin içindeki tarih veya yıl bilgisini güvenli bir biçimde [DateTime]'a çevirir.
DateTime? tarihiAyristir(String? hamMetin) {
  if (hamMetin == null) return null;
  final String metin = hamMetin.trim();
  if (metin.isEmpty) return null;

  // 1) Sadece 4 haneli yıl (örn: "1974", "1995")
  final RegExp yilRegex = RegExp(r'^(19\d{2}|20\d{2})$');
  final Match? yilEslesme = yilRegex.firstMatch(metin);
  if (yilEslesme != null) {
    final int? yil = int.tryParse(yilEslesme.group(1)!);
    if (yil != null) {
      return DateTime(yil, 1, 1);
    }
  }

  // 2) Gün.Ay.Yıl biçimi (örn: 15.04.1974, 15/4/1995, 1-1-1980)
  final RegExp gunAyYilRegex = RegExp(r'^(\d{1,2})[./\-](\d{1,2})[./\-](\d{2,4})$');
  final Match? gayEslesme = gunAyYilRegex.firstMatch(metin);
  if (gayEslesme != null) {
    final int gun = int.parse(gayEslesme.group(1)!);
    final int ay = int.parse(gayEslesme.group(2)!);
    int yil = int.parse(gayEslesme.group(3)!);
    if (yil < 100) {
      yil += (yil < 50 ? 2000 : 1900);
    }
    if (ay >= 1 && ay <= 12 && gun >= 1 && gun <= 31) {
      try {
        return DateTime(yil, ay, gun);
      } catch (_) {
        return null;
      }
    }
  }

  // 3) Yıl-Ay-Gün biçimi (ISO standardı, örn: 1974-04-15)
  final DateTime? isoTarih = DateTime.tryParse(metin);
  if (isoTarih != null) return isoTarih;

  // 4) Metin içinde geçen 4 haneli ilk yılı bulma (örn: "Doğum: 1974")
  final RegExp icindeYilRegex = RegExp(r'\b(19\d{2}|20\d{2})\b');
  final Match? icindeYilEslesme = icindeYilRegex.firstMatch(metin);
  if (icindeYilEslesme != null) {
    final int? yil = int.tryParse(icindeYilEslesme.group(1)!);
    if (yil != null) {
      return DateTime(yil, 1, 1);
    }
  }

  return null;
}
