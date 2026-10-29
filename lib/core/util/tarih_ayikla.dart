/// Metin içindeki tarih veya yıl bilgisini güvenli bir biçimde [DateTime]'a çevirir.
DateTime? tarihiAyristir(String? hamMetin) {
  if (hamMetin == null) return null;
  final String metin = hamMetin.trim();
  if (metin.isEmpty) return null;

  // Noktalama ve boşluk temizliği
  final String temiz = metin.replaceAll(RegExp(r'[.,;:\-]+$'), '').trim();
  final String bosluksuz = temiz.replaceAllMapped(
    RegExp(r'\s*([./\-])\s*'),
    (Match m) => m.group(1)!,
  );

  // 1) Sadece 4 haneli yıl (örn: "1974", "1995")
  final RegExp yilRegex = RegExp(r'^(19\d{2}|20\d{2})$');
  final Match? yilEslesme = yilRegex.firstMatch(temiz);
  if (yilEslesme != null) {
    final int? yil = int.tryParse(yilEslesme.group(1)!);
    if (yil != null) {
      return DateTime(yil, 1, 1);
    }
  }

  // 2) Gün.Ay.Yıl biçimi (örn: 15.04.1974, 15/4/1995, 1-1-1980, 15 . 04 . 1974)
  final RegExp gunAyYilRegex = RegExp(r'^(\d{1,2})[./\-](\d{1,2})[./\-](\d{2,4})$');
  final Match? gayEslesme = gunAyYilRegex.firstMatch(bosluksuz);
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

  // 3) Türkçe ay isimleri ile tarih (örn: "15 Nisan 1974", "1 Mayıs 1980")
  const Map<String, int> turkceAylar = <String, int>{
    'ocak': 1, 'şubat': 2, 'subat': 2, 'mart': 3, 'nisan': 4,
    'mayıs': 5, 'mayis': 5, 'haziran': 6, 'temmuz': 7,
    'ağustos': 8, 'agustos': 8, 'eylül': 9, 'eylul': 9,
    'ekim': 10, 'kasım': 11, 'kasim': 11, 'aralık': 12, 'aralik': 12,
  };
  final RegExp trAyRegex = RegExp(r'(\d{1,2})\s+([a-zA-ZçğıöşüÇĞİÖŞÜ]+)\s+(\d{2,4})');
  final Match? trEslesme = trAyRegex.firstMatch(temiz);
  if (trEslesme != null) {
    final int gun = int.parse(trEslesme.group(1)!);
    final String ayAdi = trEslesme.group(2)!.toLowerCase();
    int yil = int.parse(trEslesme.group(3)!);
    if (yil < 100) {
      yil += (yil < 50 ? 2000 : 1900);
    }
    final int? ay = turkceAylar[ayAdi];
    if (ay != null && gun >= 1 && gun <= 31) {
      try {
        return DateTime(yil, ay, gun);
      } catch (_) {
        return null;
      }
    }
  }

  // 4) Metin içinde geçen gün.ay.yıl biçimi (örn: "ULUS 15.04.1974", "Tarih: 01.01.1980")
  final RegExp icindeTamTarihRegex = RegExp(r'(\d{1,2})[./\-](\d{1,2})[./\-](\d{2,4})');
  final Match? icTamEslesme = icindeTamTarihRegex.firstMatch(bosluksuz);
  if (icTamEslesme != null) {
    final int gun = int.parse(icTamEslesme.group(1)!);
    final int ay = int.parse(icTamEslesme.group(2)!);
    int yil = int.parse(icTamEslesme.group(3)!);
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

  // 5) Yıl-Ay-Gün biçimi (ISO standardı, örn: 1974-04-15)
  final DateTime? isoTarih = DateTime.tryParse(temiz);
  if (isoTarih != null) return isoTarih;

  // 6) Metin içinde geçen 4 haneli ilk yılı bulma (örn: "Doğum: 1974", "ULUS 1968")
  final RegExp icindeYilRegex = RegExp(r'\b(19\d{2}|20\d{2})\b');
  final Match? icindeYilEslesme = icindeYilRegex.firstMatch(temiz);
  if (icindeYilEslesme != null) {
    final int? yil = int.tryParse(icindeYilEslesme.group(1)!);
    if (yil != null) {
      return DateTime(yil, 1, 1);
    }
  }

  return null;
}
