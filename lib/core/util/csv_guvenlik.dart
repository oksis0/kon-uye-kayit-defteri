/// CSV Formül Enjeksiyonu (CWE-1236 / Formula Injection) koruma fonksiyonu.
///
/// Microsoft Excel, LibreOffice Calc ve benzeri tablo programları,
/// bir hücre içeriği `=`, `+`, `-`, `@`, `\t` veya `\r` ile başladığında
/// bunu hesaplama formülü veya DDE (Dynamic Data Exchange) komutu olarak çalıştırır.
/// OCR okumasından veya kullanıcı girdisinden gelen bu tür karakterlerin
/// başına tek tırnak (`'`) eklenerek Excel'de salt metin olarak açılması garanti edilir.
String csvFormulKorumasi(dynamic deger) {
  if (deger == null) return '';
  final String metin = deger.toString();
  if (metin.isEmpty) return '';

  final String ilkKarakter = metin[0];
  if (ilkKarakter == '=' ||
      ilkKarakter == '+' ||
      ilkKarakter == '-' ||
      ilkKarakter == '@' ||
      ilkKarakter == '\t' ||
      ilkKarakter == '\r') {
    return "'$metin";
  }
  return metin;
}
