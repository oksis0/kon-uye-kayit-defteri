// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'veritabani.dart';

// ignore_for_file: type=lint
class $OrtaklarTable extends Ortaklar
    with TableInfo<$OrtaklarTable, OrtakSatiri> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrtaklarTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ortakNoMeta = const VerificationMeta(
    'ortakNo',
  );
  @override
  late final GeneratedColumn<String> ortakNo = GeneratedColumn<String>(
    'ortak_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _adSoyadMeta = const VerificationMeta(
    'adSoyad',
  );
  @override
  late final GeneratedColumn<String> adSoyad = GeneratedColumn<String>(
    'ad_soyad',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _babaAdiMeta = const VerificationMeta(
    'babaAdi',
  );
  @override
  late final GeneratedColumn<String> babaAdi = GeneratedColumn<String>(
    'baba_adi',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dogumYeriMeta = const VerificationMeta(
    'dogumYeri',
  );
  @override
  late final GeneratedColumn<String> dogumYeri = GeneratedColumn<String>(
    'dogum_yeri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dogumTarihiHamMeta = const VerificationMeta(
    'dogumTarihiHam',
  );
  @override
  late final GeneratedColumn<String> dogumTarihiHam = GeneratedColumn<String>(
    'dogum_tarihi_ham',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dogumTarihiMeta = const VerificationMeta(
    'dogumTarihi',
  );
  @override
  late final GeneratedColumn<DateTime> dogumTarihi = GeneratedColumn<DateTime>(
    'dogum_tarihi',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _girisTarihiHamMeta = const VerificationMeta(
    'girisTarihiHam',
  );
  @override
  late final GeneratedColumn<String> girisTarihiHam = GeneratedColumn<String>(
    'giris_tarihi_ham',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _girisTarihiMeta = const VerificationMeta(
    'girisTarihi',
  );
  @override
  late final GeneratedColumn<DateTime> girisTarihi = GeneratedColumn<DateTime>(
    'giris_tarihi',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cikisTarihiHamMeta = const VerificationMeta(
    'cikisTarihiHam',
  );
  @override
  late final GeneratedColumn<String> cikisTarihiHam = GeneratedColumn<String>(
    'cikis_tarihi_ham',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cikisTarihiMeta = const VerificationMeta(
    'cikisTarihi',
  );
  @override
  late final GeneratedColumn<DateTime> cikisTarihi = GeneratedColumn<DateTime>(
    'cikis_tarihi',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ikametAdresiMeta = const VerificationMeta(
    'ikametAdresi',
  );
  @override
  late final GeneratedColumn<String> ikametAdresi = GeneratedColumn<String>(
    'ikamet_adresi',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nufusKayitYeriMeta = const VerificationMeta(
    'nufusKayitYeri',
  );
  @override
  late final GeneratedColumn<String> nufusKayitYeri = GeneratedColumn<String>(
    'nufus_kayit_yeri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _aramaAnahtariMeta = const VerificationMeta(
    'aramaAnahtari',
  );
  @override
  late final GeneratedColumn<String> aramaAnahtari = GeneratedColumn<String>(
    'arama_anahtari',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _belgeR2AnahtariMeta = const VerificationMeta(
    'belgeR2Anahtari',
  );
  @override
  late final GeneratedColumn<String> belgeR2Anahtari = GeneratedColumn<String>(
    'belge_r2_anahtari',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ocrGuvenOrtalamaMeta = const VerificationMeta(
    'ocrGuvenOrtalama',
  );
  @override
  late final GeneratedColumn<double> ocrGuvenOrtalama = GeneratedColumn<double>(
    'ocr_guven_ortalama',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _aktifMeta = const VerificationMeta('aktif');
  @override
  late final GeneratedColumn<bool> aktif = GeneratedColumn<bool>(
    'aktif',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("aktif" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _pasifNedeniMeta = const VerificationMeta(
    'pasifNedeni',
  );
  @override
  late final GeneratedColumn<String> pasifNedeni = GeneratedColumn<String>(
    'pasif_nedeni',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pasifTarihiMeta = const VerificationMeta(
    'pasifTarihi',
  );
  @override
  late final GeneratedColumn<DateTime> pasifTarihi = GeneratedColumn<DateTime>(
    'pasif_tarihi',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _olusturmaTarihiMeta = const VerificationMeta(
    'olusturmaTarihi',
  );
  @override
  late final GeneratedColumn<DateTime> olusturmaTarihi =
      GeneratedColumn<DateTime>(
        'olusturma_tarihi',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _guncellemeTarihiMeta = const VerificationMeta(
    'guncellemeTarihi',
  );
  @override
  late final GeneratedColumn<DateTime> guncellemeTarihi =
      GeneratedColumn<DateTime>(
        'guncelleme_tarihi',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  late final GeneratedColumnWithTypeConverter<SenkronDurumu, String>
  senkronDurumu = GeneratedColumn<String>(
    'senkron_durumu',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(SenkronDurumu.beklemede.name),
  ).withConverter<SenkronDurumu>($OrtaklarTable.$convertersenkronDurumu);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ortakNo,
    adSoyad,
    babaAdi,
    dogumYeri,
    dogumTarihiHam,
    dogumTarihi,
    girisTarihiHam,
    girisTarihi,
    cikisTarihiHam,
    cikisTarihi,
    ikametAdresi,
    nufusKayitYeri,
    aramaAnahtari,
    belgeR2Anahtari,
    ocrGuvenOrtalama,
    aktif,
    pasifNedeni,
    pasifTarihi,
    olusturmaTarihi,
    guncellemeTarihi,
    senkronDurumu,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ortaklar';
  @override
  VerificationContext validateIntegrity(
    Insertable<OrtakSatiri> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('ortak_no')) {
      context.handle(
        _ortakNoMeta,
        ortakNo.isAcceptableOrUnknown(data['ortak_no']!, _ortakNoMeta),
      );
    } else if (isInserting) {
      context.missing(_ortakNoMeta);
    }
    if (data.containsKey('ad_soyad')) {
      context.handle(
        _adSoyadMeta,
        adSoyad.isAcceptableOrUnknown(data['ad_soyad']!, _adSoyadMeta),
      );
    } else if (isInserting) {
      context.missing(_adSoyadMeta);
    }
    if (data.containsKey('baba_adi')) {
      context.handle(
        _babaAdiMeta,
        babaAdi.isAcceptableOrUnknown(data['baba_adi']!, _babaAdiMeta),
      );
    }
    if (data.containsKey('dogum_yeri')) {
      context.handle(
        _dogumYeriMeta,
        dogumYeri.isAcceptableOrUnknown(data['dogum_yeri']!, _dogumYeriMeta),
      );
    }
    if (data.containsKey('dogum_tarihi_ham')) {
      context.handle(
        _dogumTarihiHamMeta,
        dogumTarihiHam.isAcceptableOrUnknown(
          data['dogum_tarihi_ham']!,
          _dogumTarihiHamMeta,
        ),
      );
    }
    if (data.containsKey('dogum_tarihi')) {
      context.handle(
        _dogumTarihiMeta,
        dogumTarihi.isAcceptableOrUnknown(
          data['dogum_tarihi']!,
          _dogumTarihiMeta,
        ),
      );
    }
    if (data.containsKey('giris_tarihi_ham')) {
      context.handle(
        _girisTarihiHamMeta,
        girisTarihiHam.isAcceptableOrUnknown(
          data['giris_tarihi_ham']!,
          _girisTarihiHamMeta,
        ),
      );
    }
    if (data.containsKey('giris_tarihi')) {
      context.handle(
        _girisTarihiMeta,
        girisTarihi.isAcceptableOrUnknown(
          data['giris_tarihi']!,
          _girisTarihiMeta,
        ),
      );
    }
    if (data.containsKey('cikis_tarihi_ham')) {
      context.handle(
        _cikisTarihiHamMeta,
        cikisTarihiHam.isAcceptableOrUnknown(
          data['cikis_tarihi_ham']!,
          _cikisTarihiHamMeta,
        ),
      );
    }
    if (data.containsKey('cikis_tarihi')) {
      context.handle(
        _cikisTarihiMeta,
        cikisTarihi.isAcceptableOrUnknown(
          data['cikis_tarihi']!,
          _cikisTarihiMeta,
        ),
      );
    }
    if (data.containsKey('ikamet_adresi')) {
      context.handle(
        _ikametAdresiMeta,
        ikametAdresi.isAcceptableOrUnknown(
          data['ikamet_adresi']!,
          _ikametAdresiMeta,
        ),
      );
    }
    if (data.containsKey('nufus_kayit_yeri')) {
      context.handle(
        _nufusKayitYeriMeta,
        nufusKayitYeri.isAcceptableOrUnknown(
          data['nufus_kayit_yeri']!,
          _nufusKayitYeriMeta,
        ),
      );
    }
    if (data.containsKey('arama_anahtari')) {
      context.handle(
        _aramaAnahtariMeta,
        aramaAnahtari.isAcceptableOrUnknown(
          data['arama_anahtari']!,
          _aramaAnahtariMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_aramaAnahtariMeta);
    }
    if (data.containsKey('belge_r2_anahtari')) {
      context.handle(
        _belgeR2AnahtariMeta,
        belgeR2Anahtari.isAcceptableOrUnknown(
          data['belge_r2_anahtari']!,
          _belgeR2AnahtariMeta,
        ),
      );
    }
    if (data.containsKey('ocr_guven_ortalama')) {
      context.handle(
        _ocrGuvenOrtalamaMeta,
        ocrGuvenOrtalama.isAcceptableOrUnknown(
          data['ocr_guven_ortalama']!,
          _ocrGuvenOrtalamaMeta,
        ),
      );
    }
    if (data.containsKey('aktif')) {
      context.handle(
        _aktifMeta,
        aktif.isAcceptableOrUnknown(data['aktif']!, _aktifMeta),
      );
    }
    if (data.containsKey('pasif_nedeni')) {
      context.handle(
        _pasifNedeniMeta,
        pasifNedeni.isAcceptableOrUnknown(
          data['pasif_nedeni']!,
          _pasifNedeniMeta,
        ),
      );
    }
    if (data.containsKey('pasif_tarihi')) {
      context.handle(
        _pasifTarihiMeta,
        pasifTarihi.isAcceptableOrUnknown(
          data['pasif_tarihi']!,
          _pasifTarihiMeta,
        ),
      );
    }
    if (data.containsKey('olusturma_tarihi')) {
      context.handle(
        _olusturmaTarihiMeta,
        olusturmaTarihi.isAcceptableOrUnknown(
          data['olusturma_tarihi']!,
          _olusturmaTarihiMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_olusturmaTarihiMeta);
    }
    if (data.containsKey('guncelleme_tarihi')) {
      context.handle(
        _guncellemeTarihiMeta,
        guncellemeTarihi.isAcceptableOrUnknown(
          data['guncelleme_tarihi']!,
          _guncellemeTarihiMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_guncellemeTarihiMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrtakSatiri map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrtakSatiri(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ortakNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ortak_no'],
      )!,
      adSoyad: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ad_soyad'],
      )!,
      babaAdi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}baba_adi'],
      ),
      dogumYeri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dogum_yeri'],
      ),
      dogumTarihiHam: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dogum_tarihi_ham'],
      ),
      dogumTarihi: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}dogum_tarihi'],
      ),
      girisTarihiHam: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}giris_tarihi_ham'],
      ),
      girisTarihi: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}giris_tarihi'],
      ),
      cikisTarihiHam: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cikis_tarihi_ham'],
      ),
      cikisTarihi: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cikis_tarihi'],
      ),
      ikametAdresi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ikamet_adresi'],
      ),
      nufusKayitYeri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nufus_kayit_yeri'],
      ),
      aramaAnahtari: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}arama_anahtari'],
      )!,
      belgeR2Anahtari: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}belge_r2_anahtari'],
      ),
      ocrGuvenOrtalama: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ocr_guven_ortalama'],
      ),
      aktif: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}aktif'],
      )!,
      pasifNedeni: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pasif_nedeni'],
      ),
      pasifTarihi: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}pasif_tarihi'],
      ),
      olusturmaTarihi: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}olusturma_tarihi'],
      )!,
      guncellemeTarihi: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}guncelleme_tarihi'],
      )!,
      senkronDurumu: $OrtaklarTable.$convertersenkronDurumu.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}senkron_durumu'],
        )!,
      ),
    );
  }

  @override
  $OrtaklarTable createAlias(String alias) {
    return $OrtaklarTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SenkronDurumu, String, String>
  $convertersenkronDurumu = const EnumNameConverter<SenkronDurumu>(
    SenkronDurumu.values,
  );
}

class OrtakSatiri extends DataClass implements Insertable<OrtakSatiri> {
  final String id;
  final String ortakNo;
  final String adSoyad;
  final String? babaAdi;
  final String? dogumYeri;
  final String? dogumTarihiHam;
  final DateTime? dogumTarihi;
  final String? girisTarihiHam;
  final DateTime? girisTarihi;
  final String? cikisTarihiHam;
  final DateTime? cikisTarihi;
  final String? ikametAdresi;
  final String? nufusKayitYeri;

  /// Türkçe normalize edilmiş, tüm metin alanlarının birleşimi.
  /// Arama bu sütun üzerinden yapılır (PLAN.md §5).
  final String aramaAnahtari;
  final String? belgeR2Anahtari;
  final double? ocrGuvenOrtalama;
  final bool aktif;
  final String? pasifNedeni;
  final DateTime? pasifTarihi;
  final DateTime olusturmaTarihi;
  final DateTime guncellemeTarihi;
  final SenkronDurumu senkronDurumu;
  const OrtakSatiri({
    required this.id,
    required this.ortakNo,
    required this.adSoyad,
    this.babaAdi,
    this.dogumYeri,
    this.dogumTarihiHam,
    this.dogumTarihi,
    this.girisTarihiHam,
    this.girisTarihi,
    this.cikisTarihiHam,
    this.cikisTarihi,
    this.ikametAdresi,
    this.nufusKayitYeri,
    required this.aramaAnahtari,
    this.belgeR2Anahtari,
    this.ocrGuvenOrtalama,
    required this.aktif,
    this.pasifNedeni,
    this.pasifTarihi,
    required this.olusturmaTarihi,
    required this.guncellemeTarihi,
    required this.senkronDurumu,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['ortak_no'] = Variable<String>(ortakNo);
    map['ad_soyad'] = Variable<String>(adSoyad);
    if (!nullToAbsent || babaAdi != null) {
      map['baba_adi'] = Variable<String>(babaAdi);
    }
    if (!nullToAbsent || dogumYeri != null) {
      map['dogum_yeri'] = Variable<String>(dogumYeri);
    }
    if (!nullToAbsent || dogumTarihiHam != null) {
      map['dogum_tarihi_ham'] = Variable<String>(dogumTarihiHam);
    }
    if (!nullToAbsent || dogumTarihi != null) {
      map['dogum_tarihi'] = Variable<DateTime>(dogumTarihi);
    }
    if (!nullToAbsent || girisTarihiHam != null) {
      map['giris_tarihi_ham'] = Variable<String>(girisTarihiHam);
    }
    if (!nullToAbsent || girisTarihi != null) {
      map['giris_tarihi'] = Variable<DateTime>(girisTarihi);
    }
    if (!nullToAbsent || cikisTarihiHam != null) {
      map['cikis_tarihi_ham'] = Variable<String>(cikisTarihiHam);
    }
    if (!nullToAbsent || cikisTarihi != null) {
      map['cikis_tarihi'] = Variable<DateTime>(cikisTarihi);
    }
    if (!nullToAbsent || ikametAdresi != null) {
      map['ikamet_adresi'] = Variable<String>(ikametAdresi);
    }
    if (!nullToAbsent || nufusKayitYeri != null) {
      map['nufus_kayit_yeri'] = Variable<String>(nufusKayitYeri);
    }
    map['arama_anahtari'] = Variable<String>(aramaAnahtari);
    if (!nullToAbsent || belgeR2Anahtari != null) {
      map['belge_r2_anahtari'] = Variable<String>(belgeR2Anahtari);
    }
    if (!nullToAbsent || ocrGuvenOrtalama != null) {
      map['ocr_guven_ortalama'] = Variable<double>(ocrGuvenOrtalama);
    }
    map['aktif'] = Variable<bool>(aktif);
    if (!nullToAbsent || pasifNedeni != null) {
      map['pasif_nedeni'] = Variable<String>(pasifNedeni);
    }
    if (!nullToAbsent || pasifTarihi != null) {
      map['pasif_tarihi'] = Variable<DateTime>(pasifTarihi);
    }
    map['olusturma_tarihi'] = Variable<DateTime>(olusturmaTarihi);
    map['guncelleme_tarihi'] = Variable<DateTime>(guncellemeTarihi);
    {
      map['senkron_durumu'] = Variable<String>(
        $OrtaklarTable.$convertersenkronDurumu.toSql(senkronDurumu),
      );
    }
    return map;
  }

  OrtaklarCompanion toCompanion(bool nullToAbsent) {
    return OrtaklarCompanion(
      id: Value(id),
      ortakNo: Value(ortakNo),
      adSoyad: Value(adSoyad),
      babaAdi: babaAdi == null && nullToAbsent
          ? const Value.absent()
          : Value(babaAdi),
      dogumYeri: dogumYeri == null && nullToAbsent
          ? const Value.absent()
          : Value(dogumYeri),
      dogumTarihiHam: dogumTarihiHam == null && nullToAbsent
          ? const Value.absent()
          : Value(dogumTarihiHam),
      dogumTarihi: dogumTarihi == null && nullToAbsent
          ? const Value.absent()
          : Value(dogumTarihi),
      girisTarihiHam: girisTarihiHam == null && nullToAbsent
          ? const Value.absent()
          : Value(girisTarihiHam),
      girisTarihi: girisTarihi == null && nullToAbsent
          ? const Value.absent()
          : Value(girisTarihi),
      cikisTarihiHam: cikisTarihiHam == null && nullToAbsent
          ? const Value.absent()
          : Value(cikisTarihiHam),
      cikisTarihi: cikisTarihi == null && nullToAbsent
          ? const Value.absent()
          : Value(cikisTarihi),
      ikametAdresi: ikametAdresi == null && nullToAbsent
          ? const Value.absent()
          : Value(ikametAdresi),
      nufusKayitYeri: nufusKayitYeri == null && nullToAbsent
          ? const Value.absent()
          : Value(nufusKayitYeri),
      aramaAnahtari: Value(aramaAnahtari),
      belgeR2Anahtari: belgeR2Anahtari == null && nullToAbsent
          ? const Value.absent()
          : Value(belgeR2Anahtari),
      ocrGuvenOrtalama: ocrGuvenOrtalama == null && nullToAbsent
          ? const Value.absent()
          : Value(ocrGuvenOrtalama),
      aktif: Value(aktif),
      pasifNedeni: pasifNedeni == null && nullToAbsent
          ? const Value.absent()
          : Value(pasifNedeni),
      pasifTarihi: pasifTarihi == null && nullToAbsent
          ? const Value.absent()
          : Value(pasifTarihi),
      olusturmaTarihi: Value(olusturmaTarihi),
      guncellemeTarihi: Value(guncellemeTarihi),
      senkronDurumu: Value(senkronDurumu),
    );
  }

  factory OrtakSatiri.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrtakSatiri(
      id: serializer.fromJson<String>(json['id']),
      ortakNo: serializer.fromJson<String>(json['ortakNo']),
      adSoyad: serializer.fromJson<String>(json['adSoyad']),
      babaAdi: serializer.fromJson<String?>(json['babaAdi']),
      dogumYeri: serializer.fromJson<String?>(json['dogumYeri']),
      dogumTarihiHam: serializer.fromJson<String?>(json['dogumTarihiHam']),
      dogumTarihi: serializer.fromJson<DateTime?>(json['dogumTarihi']),
      girisTarihiHam: serializer.fromJson<String?>(json['girisTarihiHam']),
      girisTarihi: serializer.fromJson<DateTime?>(json['girisTarihi']),
      cikisTarihiHam: serializer.fromJson<String?>(json['cikisTarihiHam']),
      cikisTarihi: serializer.fromJson<DateTime?>(json['cikisTarihi']),
      ikametAdresi: serializer.fromJson<String?>(json['ikametAdresi']),
      nufusKayitYeri: serializer.fromJson<String?>(json['nufusKayitYeri']),
      aramaAnahtari: serializer.fromJson<String>(json['aramaAnahtari']),
      belgeR2Anahtari: serializer.fromJson<String?>(json['belgeR2Anahtari']),
      ocrGuvenOrtalama: serializer.fromJson<double?>(json['ocrGuvenOrtalama']),
      aktif: serializer.fromJson<bool>(json['aktif']),
      pasifNedeni: serializer.fromJson<String?>(json['pasifNedeni']),
      pasifTarihi: serializer.fromJson<DateTime?>(json['pasifTarihi']),
      olusturmaTarihi: serializer.fromJson<DateTime>(json['olusturmaTarihi']),
      guncellemeTarihi: serializer.fromJson<DateTime>(json['guncellemeTarihi']),
      senkronDurumu: $OrtaklarTable.$convertersenkronDurumu.fromJson(
        serializer.fromJson<String>(json['senkronDurumu']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ortakNo': serializer.toJson<String>(ortakNo),
      'adSoyad': serializer.toJson<String>(adSoyad),
      'babaAdi': serializer.toJson<String?>(babaAdi),
      'dogumYeri': serializer.toJson<String?>(dogumYeri),
      'dogumTarihiHam': serializer.toJson<String?>(dogumTarihiHam),
      'dogumTarihi': serializer.toJson<DateTime?>(dogumTarihi),
      'girisTarihiHam': serializer.toJson<String?>(girisTarihiHam),
      'girisTarihi': serializer.toJson<DateTime?>(girisTarihi),
      'cikisTarihiHam': serializer.toJson<String?>(cikisTarihiHam),
      'cikisTarihi': serializer.toJson<DateTime?>(cikisTarihi),
      'ikametAdresi': serializer.toJson<String?>(ikametAdresi),
      'nufusKayitYeri': serializer.toJson<String?>(nufusKayitYeri),
      'aramaAnahtari': serializer.toJson<String>(aramaAnahtari),
      'belgeR2Anahtari': serializer.toJson<String?>(belgeR2Anahtari),
      'ocrGuvenOrtalama': serializer.toJson<double?>(ocrGuvenOrtalama),
      'aktif': serializer.toJson<bool>(aktif),
      'pasifNedeni': serializer.toJson<String?>(pasifNedeni),
      'pasifTarihi': serializer.toJson<DateTime?>(pasifTarihi),
      'olusturmaTarihi': serializer.toJson<DateTime>(olusturmaTarihi),
      'guncellemeTarihi': serializer.toJson<DateTime>(guncellemeTarihi),
      'senkronDurumu': serializer.toJson<String>(
        $OrtaklarTable.$convertersenkronDurumu.toJson(senkronDurumu),
      ),
    };
  }

  OrtakSatiri copyWith({
    String? id,
    String? ortakNo,
    String? adSoyad,
    Value<String?> babaAdi = const Value.absent(),
    Value<String?> dogumYeri = const Value.absent(),
    Value<String?> dogumTarihiHam = const Value.absent(),
    Value<DateTime?> dogumTarihi = const Value.absent(),
    Value<String?> girisTarihiHam = const Value.absent(),
    Value<DateTime?> girisTarihi = const Value.absent(),
    Value<String?> cikisTarihiHam = const Value.absent(),
    Value<DateTime?> cikisTarihi = const Value.absent(),
    Value<String?> ikametAdresi = const Value.absent(),
    Value<String?> nufusKayitYeri = const Value.absent(),
    String? aramaAnahtari,
    Value<String?> belgeR2Anahtari = const Value.absent(),
    Value<double?> ocrGuvenOrtalama = const Value.absent(),
    bool? aktif,
    Value<String?> pasifNedeni = const Value.absent(),
    Value<DateTime?> pasifTarihi = const Value.absent(),
    DateTime? olusturmaTarihi,
    DateTime? guncellemeTarihi,
    SenkronDurumu? senkronDurumu,
  }) => OrtakSatiri(
    id: id ?? this.id,
    ortakNo: ortakNo ?? this.ortakNo,
    adSoyad: adSoyad ?? this.adSoyad,
    babaAdi: babaAdi.present ? babaAdi.value : this.babaAdi,
    dogumYeri: dogumYeri.present ? dogumYeri.value : this.dogumYeri,
    dogumTarihiHam: dogumTarihiHam.present
        ? dogumTarihiHam.value
        : this.dogumTarihiHam,
    dogumTarihi: dogumTarihi.present ? dogumTarihi.value : this.dogumTarihi,
    girisTarihiHam: girisTarihiHam.present
        ? girisTarihiHam.value
        : this.girisTarihiHam,
    girisTarihi: girisTarihi.present ? girisTarihi.value : this.girisTarihi,
    cikisTarihiHam: cikisTarihiHam.present
        ? cikisTarihiHam.value
        : this.cikisTarihiHam,
    cikisTarihi: cikisTarihi.present ? cikisTarihi.value : this.cikisTarihi,
    ikametAdresi: ikametAdresi.present ? ikametAdresi.value : this.ikametAdresi,
    nufusKayitYeri: nufusKayitYeri.present
        ? nufusKayitYeri.value
        : this.nufusKayitYeri,
    aramaAnahtari: aramaAnahtari ?? this.aramaAnahtari,
    belgeR2Anahtari: belgeR2Anahtari.present
        ? belgeR2Anahtari.value
        : this.belgeR2Anahtari,
    ocrGuvenOrtalama: ocrGuvenOrtalama.present
        ? ocrGuvenOrtalama.value
        : this.ocrGuvenOrtalama,
    aktif: aktif ?? this.aktif,
    pasifNedeni: pasifNedeni.present ? pasifNedeni.value : this.pasifNedeni,
    pasifTarihi: pasifTarihi.present ? pasifTarihi.value : this.pasifTarihi,
    olusturmaTarihi: olusturmaTarihi ?? this.olusturmaTarihi,
    guncellemeTarihi: guncellemeTarihi ?? this.guncellemeTarihi,
    senkronDurumu: senkronDurumu ?? this.senkronDurumu,
  );
  OrtakSatiri copyWithCompanion(OrtaklarCompanion data) {
    return OrtakSatiri(
      id: data.id.present ? data.id.value : this.id,
      ortakNo: data.ortakNo.present ? data.ortakNo.value : this.ortakNo,
      adSoyad: data.adSoyad.present ? data.adSoyad.value : this.adSoyad,
      babaAdi: data.babaAdi.present ? data.babaAdi.value : this.babaAdi,
      dogumYeri: data.dogumYeri.present ? data.dogumYeri.value : this.dogumYeri,
      dogumTarihiHam: data.dogumTarihiHam.present
          ? data.dogumTarihiHam.value
          : this.dogumTarihiHam,
      dogumTarihi: data.dogumTarihi.present
          ? data.dogumTarihi.value
          : this.dogumTarihi,
      girisTarihiHam: data.girisTarihiHam.present
          ? data.girisTarihiHam.value
          : this.girisTarihiHam,
      girisTarihi: data.girisTarihi.present
          ? data.girisTarihi.value
          : this.girisTarihi,
      cikisTarihiHam: data.cikisTarihiHam.present
          ? data.cikisTarihiHam.value
          : this.cikisTarihiHam,
      cikisTarihi: data.cikisTarihi.present
          ? data.cikisTarihi.value
          : this.cikisTarihi,
      ikametAdresi: data.ikametAdresi.present
          ? data.ikametAdresi.value
          : this.ikametAdresi,
      nufusKayitYeri: data.nufusKayitYeri.present
          ? data.nufusKayitYeri.value
          : this.nufusKayitYeri,
      aramaAnahtari: data.aramaAnahtari.present
          ? data.aramaAnahtari.value
          : this.aramaAnahtari,
      belgeR2Anahtari: data.belgeR2Anahtari.present
          ? data.belgeR2Anahtari.value
          : this.belgeR2Anahtari,
      ocrGuvenOrtalama: data.ocrGuvenOrtalama.present
          ? data.ocrGuvenOrtalama.value
          : this.ocrGuvenOrtalama,
      aktif: data.aktif.present ? data.aktif.value : this.aktif,
      pasifNedeni: data.pasifNedeni.present
          ? data.pasifNedeni.value
          : this.pasifNedeni,
      pasifTarihi: data.pasifTarihi.present
          ? data.pasifTarihi.value
          : this.pasifTarihi,
      olusturmaTarihi: data.olusturmaTarihi.present
          ? data.olusturmaTarihi.value
          : this.olusturmaTarihi,
      guncellemeTarihi: data.guncellemeTarihi.present
          ? data.guncellemeTarihi.value
          : this.guncellemeTarihi,
      senkronDurumu: data.senkronDurumu.present
          ? data.senkronDurumu.value
          : this.senkronDurumu,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrtakSatiri(')
          ..write('id: $id, ')
          ..write('ortakNo: $ortakNo, ')
          ..write('adSoyad: $adSoyad, ')
          ..write('babaAdi: $babaAdi, ')
          ..write('dogumYeri: $dogumYeri, ')
          ..write('dogumTarihiHam: $dogumTarihiHam, ')
          ..write('dogumTarihi: $dogumTarihi, ')
          ..write('girisTarihiHam: $girisTarihiHam, ')
          ..write('girisTarihi: $girisTarihi, ')
          ..write('cikisTarihiHam: $cikisTarihiHam, ')
          ..write('cikisTarihi: $cikisTarihi, ')
          ..write('ikametAdresi: $ikametAdresi, ')
          ..write('nufusKayitYeri: $nufusKayitYeri, ')
          ..write('aramaAnahtari: $aramaAnahtari, ')
          ..write('belgeR2Anahtari: $belgeR2Anahtari, ')
          ..write('ocrGuvenOrtalama: $ocrGuvenOrtalama, ')
          ..write('aktif: $aktif, ')
          ..write('pasifNedeni: $pasifNedeni, ')
          ..write('pasifTarihi: $pasifTarihi, ')
          ..write('olusturmaTarihi: $olusturmaTarihi, ')
          ..write('guncellemeTarihi: $guncellemeTarihi, ')
          ..write('senkronDurumu: $senkronDurumu')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    ortakNo,
    adSoyad,
    babaAdi,
    dogumYeri,
    dogumTarihiHam,
    dogumTarihi,
    girisTarihiHam,
    girisTarihi,
    cikisTarihiHam,
    cikisTarihi,
    ikametAdresi,
    nufusKayitYeri,
    aramaAnahtari,
    belgeR2Anahtari,
    ocrGuvenOrtalama,
    aktif,
    pasifNedeni,
    pasifTarihi,
    olusturmaTarihi,
    guncellemeTarihi,
    senkronDurumu,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrtakSatiri &&
          other.id == this.id &&
          other.ortakNo == this.ortakNo &&
          other.adSoyad == this.adSoyad &&
          other.babaAdi == this.babaAdi &&
          other.dogumYeri == this.dogumYeri &&
          other.dogumTarihiHam == this.dogumTarihiHam &&
          other.dogumTarihi == this.dogumTarihi &&
          other.girisTarihiHam == this.girisTarihiHam &&
          other.girisTarihi == this.girisTarihi &&
          other.cikisTarihiHam == this.cikisTarihiHam &&
          other.cikisTarihi == this.cikisTarihi &&
          other.ikametAdresi == this.ikametAdresi &&
          other.nufusKayitYeri == this.nufusKayitYeri &&
          other.aramaAnahtari == this.aramaAnahtari &&
          other.belgeR2Anahtari == this.belgeR2Anahtari &&
          other.ocrGuvenOrtalama == this.ocrGuvenOrtalama &&
          other.aktif == this.aktif &&
          other.pasifNedeni == this.pasifNedeni &&
          other.pasifTarihi == this.pasifTarihi &&
          other.olusturmaTarihi == this.olusturmaTarihi &&
          other.guncellemeTarihi == this.guncellemeTarihi &&
          other.senkronDurumu == this.senkronDurumu);
}

class OrtaklarCompanion extends UpdateCompanion<OrtakSatiri> {
  final Value<String> id;
  final Value<String> ortakNo;
  final Value<String> adSoyad;
  final Value<String?> babaAdi;
  final Value<String?> dogumYeri;
  final Value<String?> dogumTarihiHam;
  final Value<DateTime?> dogumTarihi;
  final Value<String?> girisTarihiHam;
  final Value<DateTime?> girisTarihi;
  final Value<String?> cikisTarihiHam;
  final Value<DateTime?> cikisTarihi;
  final Value<String?> ikametAdresi;
  final Value<String?> nufusKayitYeri;
  final Value<String> aramaAnahtari;
  final Value<String?> belgeR2Anahtari;
  final Value<double?> ocrGuvenOrtalama;
  final Value<bool> aktif;
  final Value<String?> pasifNedeni;
  final Value<DateTime?> pasifTarihi;
  final Value<DateTime> olusturmaTarihi;
  final Value<DateTime> guncellemeTarihi;
  final Value<SenkronDurumu> senkronDurumu;
  final Value<int> rowid;
  const OrtaklarCompanion({
    this.id = const Value.absent(),
    this.ortakNo = const Value.absent(),
    this.adSoyad = const Value.absent(),
    this.babaAdi = const Value.absent(),
    this.dogumYeri = const Value.absent(),
    this.dogumTarihiHam = const Value.absent(),
    this.dogumTarihi = const Value.absent(),
    this.girisTarihiHam = const Value.absent(),
    this.girisTarihi = const Value.absent(),
    this.cikisTarihiHam = const Value.absent(),
    this.cikisTarihi = const Value.absent(),
    this.ikametAdresi = const Value.absent(),
    this.nufusKayitYeri = const Value.absent(),
    this.aramaAnahtari = const Value.absent(),
    this.belgeR2Anahtari = const Value.absent(),
    this.ocrGuvenOrtalama = const Value.absent(),
    this.aktif = const Value.absent(),
    this.pasifNedeni = const Value.absent(),
    this.pasifTarihi = const Value.absent(),
    this.olusturmaTarihi = const Value.absent(),
    this.guncellemeTarihi = const Value.absent(),
    this.senkronDurumu = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrtaklarCompanion.insert({
    required String id,
    required String ortakNo,
    required String adSoyad,
    this.babaAdi = const Value.absent(),
    this.dogumYeri = const Value.absent(),
    this.dogumTarihiHam = const Value.absent(),
    this.dogumTarihi = const Value.absent(),
    this.girisTarihiHam = const Value.absent(),
    this.girisTarihi = const Value.absent(),
    this.cikisTarihiHam = const Value.absent(),
    this.cikisTarihi = const Value.absent(),
    this.ikametAdresi = const Value.absent(),
    this.nufusKayitYeri = const Value.absent(),
    required String aramaAnahtari,
    this.belgeR2Anahtari = const Value.absent(),
    this.ocrGuvenOrtalama = const Value.absent(),
    this.aktif = const Value.absent(),
    this.pasifNedeni = const Value.absent(),
    this.pasifTarihi = const Value.absent(),
    required DateTime olusturmaTarihi,
    required DateTime guncellemeTarihi,
    this.senkronDurumu = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ortakNo = Value(ortakNo),
       adSoyad = Value(adSoyad),
       aramaAnahtari = Value(aramaAnahtari),
       olusturmaTarihi = Value(olusturmaTarihi),
       guncellemeTarihi = Value(guncellemeTarihi);
  static Insertable<OrtakSatiri> custom({
    Expression<String>? id,
    Expression<String>? ortakNo,
    Expression<String>? adSoyad,
    Expression<String>? babaAdi,
    Expression<String>? dogumYeri,
    Expression<String>? dogumTarihiHam,
    Expression<DateTime>? dogumTarihi,
    Expression<String>? girisTarihiHam,
    Expression<DateTime>? girisTarihi,
    Expression<String>? cikisTarihiHam,
    Expression<DateTime>? cikisTarihi,
    Expression<String>? ikametAdresi,
    Expression<String>? nufusKayitYeri,
    Expression<String>? aramaAnahtari,
    Expression<String>? belgeR2Anahtari,
    Expression<double>? ocrGuvenOrtalama,
    Expression<bool>? aktif,
    Expression<String>? pasifNedeni,
    Expression<DateTime>? pasifTarihi,
    Expression<DateTime>? olusturmaTarihi,
    Expression<DateTime>? guncellemeTarihi,
    Expression<String>? senkronDurumu,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ortakNo != null) 'ortak_no': ortakNo,
      if (adSoyad != null) 'ad_soyad': adSoyad,
      if (babaAdi != null) 'baba_adi': babaAdi,
      if (dogumYeri != null) 'dogum_yeri': dogumYeri,
      if (dogumTarihiHam != null) 'dogum_tarihi_ham': dogumTarihiHam,
      if (dogumTarihi != null) 'dogum_tarihi': dogumTarihi,
      if (girisTarihiHam != null) 'giris_tarihi_ham': girisTarihiHam,
      if (girisTarihi != null) 'giris_tarihi': girisTarihi,
      if (cikisTarihiHam != null) 'cikis_tarihi_ham': cikisTarihiHam,
      if (cikisTarihi != null) 'cikis_tarihi': cikisTarihi,
      if (ikametAdresi != null) 'ikamet_adresi': ikametAdresi,
      if (nufusKayitYeri != null) 'nufus_kayit_yeri': nufusKayitYeri,
      if (aramaAnahtari != null) 'arama_anahtari': aramaAnahtari,
      if (belgeR2Anahtari != null) 'belge_r2_anahtari': belgeR2Anahtari,
      if (ocrGuvenOrtalama != null) 'ocr_guven_ortalama': ocrGuvenOrtalama,
      if (aktif != null) 'aktif': aktif,
      if (pasifNedeni != null) 'pasif_nedeni': pasifNedeni,
      if (pasifTarihi != null) 'pasif_tarihi': pasifTarihi,
      if (olusturmaTarihi != null) 'olusturma_tarihi': olusturmaTarihi,
      if (guncellemeTarihi != null) 'guncelleme_tarihi': guncellemeTarihi,
      if (senkronDurumu != null) 'senkron_durumu': senkronDurumu,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrtaklarCompanion copyWith({
    Value<String>? id,
    Value<String>? ortakNo,
    Value<String>? adSoyad,
    Value<String?>? babaAdi,
    Value<String?>? dogumYeri,
    Value<String?>? dogumTarihiHam,
    Value<DateTime?>? dogumTarihi,
    Value<String?>? girisTarihiHam,
    Value<DateTime?>? girisTarihi,
    Value<String?>? cikisTarihiHam,
    Value<DateTime?>? cikisTarihi,
    Value<String?>? ikametAdresi,
    Value<String?>? nufusKayitYeri,
    Value<String>? aramaAnahtari,
    Value<String?>? belgeR2Anahtari,
    Value<double?>? ocrGuvenOrtalama,
    Value<bool>? aktif,
    Value<String?>? pasifNedeni,
    Value<DateTime?>? pasifTarihi,
    Value<DateTime>? olusturmaTarihi,
    Value<DateTime>? guncellemeTarihi,
    Value<SenkronDurumu>? senkronDurumu,
    Value<int>? rowid,
  }) {
    return OrtaklarCompanion(
      id: id ?? this.id,
      ortakNo: ortakNo ?? this.ortakNo,
      adSoyad: adSoyad ?? this.adSoyad,
      babaAdi: babaAdi ?? this.babaAdi,
      dogumYeri: dogumYeri ?? this.dogumYeri,
      dogumTarihiHam: dogumTarihiHam ?? this.dogumTarihiHam,
      dogumTarihi: dogumTarihi ?? this.dogumTarihi,
      girisTarihiHam: girisTarihiHam ?? this.girisTarihiHam,
      girisTarihi: girisTarihi ?? this.girisTarihi,
      cikisTarihiHam: cikisTarihiHam ?? this.cikisTarihiHam,
      cikisTarihi: cikisTarihi ?? this.cikisTarihi,
      ikametAdresi: ikametAdresi ?? this.ikametAdresi,
      nufusKayitYeri: nufusKayitYeri ?? this.nufusKayitYeri,
      aramaAnahtari: aramaAnahtari ?? this.aramaAnahtari,
      belgeR2Anahtari: belgeR2Anahtari ?? this.belgeR2Anahtari,
      ocrGuvenOrtalama: ocrGuvenOrtalama ?? this.ocrGuvenOrtalama,
      aktif: aktif ?? this.aktif,
      pasifNedeni: pasifNedeni ?? this.pasifNedeni,
      pasifTarihi: pasifTarihi ?? this.pasifTarihi,
      olusturmaTarihi: olusturmaTarihi ?? this.olusturmaTarihi,
      guncellemeTarihi: guncellemeTarihi ?? this.guncellemeTarihi,
      senkronDurumu: senkronDurumu ?? this.senkronDurumu,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ortakNo.present) {
      map['ortak_no'] = Variable<String>(ortakNo.value);
    }
    if (adSoyad.present) {
      map['ad_soyad'] = Variable<String>(adSoyad.value);
    }
    if (babaAdi.present) {
      map['baba_adi'] = Variable<String>(babaAdi.value);
    }
    if (dogumYeri.present) {
      map['dogum_yeri'] = Variable<String>(dogumYeri.value);
    }
    if (dogumTarihiHam.present) {
      map['dogum_tarihi_ham'] = Variable<String>(dogumTarihiHam.value);
    }
    if (dogumTarihi.present) {
      map['dogum_tarihi'] = Variable<DateTime>(dogumTarihi.value);
    }
    if (girisTarihiHam.present) {
      map['giris_tarihi_ham'] = Variable<String>(girisTarihiHam.value);
    }
    if (girisTarihi.present) {
      map['giris_tarihi'] = Variable<DateTime>(girisTarihi.value);
    }
    if (cikisTarihiHam.present) {
      map['cikis_tarihi_ham'] = Variable<String>(cikisTarihiHam.value);
    }
    if (cikisTarihi.present) {
      map['cikis_tarihi'] = Variable<DateTime>(cikisTarihi.value);
    }
    if (ikametAdresi.present) {
      map['ikamet_adresi'] = Variable<String>(ikametAdresi.value);
    }
    if (nufusKayitYeri.present) {
      map['nufus_kayit_yeri'] = Variable<String>(nufusKayitYeri.value);
    }
    if (aramaAnahtari.present) {
      map['arama_anahtari'] = Variable<String>(aramaAnahtari.value);
    }
    if (belgeR2Anahtari.present) {
      map['belge_r2_anahtari'] = Variable<String>(belgeR2Anahtari.value);
    }
    if (ocrGuvenOrtalama.present) {
      map['ocr_guven_ortalama'] = Variable<double>(ocrGuvenOrtalama.value);
    }
    if (aktif.present) {
      map['aktif'] = Variable<bool>(aktif.value);
    }
    if (pasifNedeni.present) {
      map['pasif_nedeni'] = Variable<String>(pasifNedeni.value);
    }
    if (pasifTarihi.present) {
      map['pasif_tarihi'] = Variable<DateTime>(pasifTarihi.value);
    }
    if (olusturmaTarihi.present) {
      map['olusturma_tarihi'] = Variable<DateTime>(olusturmaTarihi.value);
    }
    if (guncellemeTarihi.present) {
      map['guncelleme_tarihi'] = Variable<DateTime>(guncellemeTarihi.value);
    }
    if (senkronDurumu.present) {
      map['senkron_durumu'] = Variable<String>(
        $OrtaklarTable.$convertersenkronDurumu.toSql(senkronDurumu.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrtaklarCompanion(')
          ..write('id: $id, ')
          ..write('ortakNo: $ortakNo, ')
          ..write('adSoyad: $adSoyad, ')
          ..write('babaAdi: $babaAdi, ')
          ..write('dogumYeri: $dogumYeri, ')
          ..write('dogumTarihiHam: $dogumTarihiHam, ')
          ..write('dogumTarihi: $dogumTarihi, ')
          ..write('girisTarihiHam: $girisTarihiHam, ')
          ..write('girisTarihi: $girisTarihi, ')
          ..write('cikisTarihiHam: $cikisTarihiHam, ')
          ..write('cikisTarihi: $cikisTarihi, ')
          ..write('ikametAdresi: $ikametAdresi, ')
          ..write('nufusKayitYeri: $nufusKayitYeri, ')
          ..write('aramaAnahtari: $aramaAnahtari, ')
          ..write('belgeR2Anahtari: $belgeR2Anahtari, ')
          ..write('ocrGuvenOrtalama: $ocrGuvenOrtalama, ')
          ..write('aktif: $aktif, ')
          ..write('pasifNedeni: $pasifNedeni, ')
          ..write('pasifTarihi: $pasifTarihi, ')
          ..write('olusturmaTarihi: $olusturmaTarihi, ')
          ..write('guncellemeTarihi: $guncellemeTarihi, ')
          ..write('senkronDurumu: $senkronDurumu, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DefterSatirlariTable extends DefterSatirlari
    with TableInfo<$DefterSatirlariTable, DefterSatiriSatiri> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DefterSatirlariTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ortakIdMeta = const VerificationMeta(
    'ortakId',
  );
  @override
  late final GeneratedColumn<String> ortakId = GeneratedColumn<String>(
    'ortak_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ortaklar (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<SatirTuru, String> tur =
      GeneratedColumn<String>(
        'tur',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SatirTuru>($DefterSatirlariTable.$convertertur);
  static const VerificationMeta _siraNoMeta = const VerificationMeta('siraNo');
  @override
  late final GeneratedColumn<int> siraNo = GeneratedColumn<int>(
    'sira_no',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tarihHamMeta = const VerificationMeta(
    'tarihHam',
  );
  @override
  late final GeneratedColumn<String> tarihHam = GeneratedColumn<String>(
    'tarih_ham',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tarihMeta = const VerificationMeta('tarih');
  @override
  late final GeneratedColumn<DateTime> tarih = GeneratedColumn<DateTime>(
    'tarih',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noMeta = const VerificationMeta('no');
  @override
  late final GeneratedColumn<String> no = GeneratedColumn<String>(
    'no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maddeMeta = const VerificationMeta('madde');
  @override
  late final GeneratedColumn<String> madde = GeneratedColumn<String>(
    'madde',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _aciklamaMeta = const VerificationMeta(
    'aciklama',
  );
  @override
  late final GeneratedColumn<String> aciklama = GeneratedColumn<String>(
    'aciklama',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _miktarKurusMeta = const VerificationMeta(
    'miktarKurus',
  );
  @override
  late final GeneratedColumn<int> miktarKurus = GeneratedColumn<int>(
    'miktar_kurus',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _yekunKurusMeta = const VerificationMeta(
    'yekunKurus',
  );
  @override
  late final GeneratedColumn<int> yekunKurus = GeneratedColumn<int>(
    'yekun_kurus',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _miktarHamMeta = const VerificationMeta(
    'miktarHam',
  );
  @override
  late final GeneratedColumn<String> miktarHam = GeneratedColumn<String>(
    'miktar_ham',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yekunHamMeta = const VerificationMeta(
    'yekunHam',
  );
  @override
  late final GeneratedColumn<String> yekunHam = GeneratedColumn<String>(
    'yekun_ham',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ortakId,
    tur,
    siraNo,
    tarihHam,
    tarih,
    no,
    madde,
    aciklama,
    miktarKurus,
    yekunKurus,
    miktarHam,
    yekunHam,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'defter_satirlari';
  @override
  VerificationContext validateIntegrity(
    Insertable<DefterSatiriSatiri> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('ortak_id')) {
      context.handle(
        _ortakIdMeta,
        ortakId.isAcceptableOrUnknown(data['ortak_id']!, _ortakIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ortakIdMeta);
    }
    if (data.containsKey('sira_no')) {
      context.handle(
        _siraNoMeta,
        siraNo.isAcceptableOrUnknown(data['sira_no']!, _siraNoMeta),
      );
    } else if (isInserting) {
      context.missing(_siraNoMeta);
    }
    if (data.containsKey('tarih_ham')) {
      context.handle(
        _tarihHamMeta,
        tarihHam.isAcceptableOrUnknown(data['tarih_ham']!, _tarihHamMeta),
      );
    }
    if (data.containsKey('tarih')) {
      context.handle(
        _tarihMeta,
        tarih.isAcceptableOrUnknown(data['tarih']!, _tarihMeta),
      );
    }
    if (data.containsKey('no')) {
      context.handle(_noMeta, no.isAcceptableOrUnknown(data['no']!, _noMeta));
    }
    if (data.containsKey('madde')) {
      context.handle(
        _maddeMeta,
        madde.isAcceptableOrUnknown(data['madde']!, _maddeMeta),
      );
    }
    if (data.containsKey('aciklama')) {
      context.handle(
        _aciklamaMeta,
        aciklama.isAcceptableOrUnknown(data['aciklama']!, _aciklamaMeta),
      );
    }
    if (data.containsKey('miktar_kurus')) {
      context.handle(
        _miktarKurusMeta,
        miktarKurus.isAcceptableOrUnknown(
          data['miktar_kurus']!,
          _miktarKurusMeta,
        ),
      );
    }
    if (data.containsKey('yekun_kurus')) {
      context.handle(
        _yekunKurusMeta,
        yekunKurus.isAcceptableOrUnknown(data['yekun_kurus']!, _yekunKurusMeta),
      );
    }
    if (data.containsKey('miktar_ham')) {
      context.handle(
        _miktarHamMeta,
        miktarHam.isAcceptableOrUnknown(data['miktar_ham']!, _miktarHamMeta),
      );
    }
    if (data.containsKey('yekun_ham')) {
      context.handle(
        _yekunHamMeta,
        yekunHam.isAcceptableOrUnknown(data['yekun_ham']!, _yekunHamMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DefterSatiriSatiri map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DefterSatiriSatiri(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ortakId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ortak_id'],
      )!,
      tur: $DefterSatirlariTable.$convertertur.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tur'],
        )!,
      ),
      siraNo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sira_no'],
      )!,
      tarihHam: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tarih_ham'],
      ),
      tarih: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}tarih'],
      ),
      no: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}no'],
      ),
      madde: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}madde'],
      ),
      aciklama: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aciklama'],
      ),
      miktarKurus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}miktar_kurus'],
      )!,
      yekunKurus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}yekun_kurus'],
      )!,
      miktarHam: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}miktar_ham'],
      ),
      yekunHam: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}yekun_ham'],
      ),
    );
  }

  @override
  $DefterSatirlariTable createAlias(String alias) {
    return $DefterSatirlariTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SatirTuru, String, String> $convertertur =
      const EnumNameConverter<SatirTuru>(SatirTuru.values);
}

class DefterSatiriSatiri extends DataClass
    implements Insertable<DefterSatiriSatiri> {
  final String id;
  final String ortakId;
  final SatirTuru tur;
  final int siraNo;
  final String? tarihHam;
  final DateTime? tarih;
  final String? no;
  final String? madde;
  final String? aciklama;

  /// ★ Kuruş cinsinden tam sayı — `double` kullanılmıyor.
  /// Bkz. `defter_satiri.dart` içindeki gerekçe (PLAN.md §4.2).
  final int miktarKurus;
  final int yekunKurus;
  final String? miktarHam;
  final String? yekunHam;
  const DefterSatiriSatiri({
    required this.id,
    required this.ortakId,
    required this.tur,
    required this.siraNo,
    this.tarihHam,
    this.tarih,
    this.no,
    this.madde,
    this.aciklama,
    required this.miktarKurus,
    required this.yekunKurus,
    this.miktarHam,
    this.yekunHam,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['ortak_id'] = Variable<String>(ortakId);
    {
      map['tur'] = Variable<String>(
        $DefterSatirlariTable.$convertertur.toSql(tur),
      );
    }
    map['sira_no'] = Variable<int>(siraNo);
    if (!nullToAbsent || tarihHam != null) {
      map['tarih_ham'] = Variable<String>(tarihHam);
    }
    if (!nullToAbsent || tarih != null) {
      map['tarih'] = Variable<DateTime>(tarih);
    }
    if (!nullToAbsent || no != null) {
      map['no'] = Variable<String>(no);
    }
    if (!nullToAbsent || madde != null) {
      map['madde'] = Variable<String>(madde);
    }
    if (!nullToAbsent || aciklama != null) {
      map['aciklama'] = Variable<String>(aciklama);
    }
    map['miktar_kurus'] = Variable<int>(miktarKurus);
    map['yekun_kurus'] = Variable<int>(yekunKurus);
    if (!nullToAbsent || miktarHam != null) {
      map['miktar_ham'] = Variable<String>(miktarHam);
    }
    if (!nullToAbsent || yekunHam != null) {
      map['yekun_ham'] = Variable<String>(yekunHam);
    }
    return map;
  }

  DefterSatirlariCompanion toCompanion(bool nullToAbsent) {
    return DefterSatirlariCompanion(
      id: Value(id),
      ortakId: Value(ortakId),
      tur: Value(tur),
      siraNo: Value(siraNo),
      tarihHam: tarihHam == null && nullToAbsent
          ? const Value.absent()
          : Value(tarihHam),
      tarih: tarih == null && nullToAbsent
          ? const Value.absent()
          : Value(tarih),
      no: no == null && nullToAbsent ? const Value.absent() : Value(no),
      madde: madde == null && nullToAbsent
          ? const Value.absent()
          : Value(madde),
      aciklama: aciklama == null && nullToAbsent
          ? const Value.absent()
          : Value(aciklama),
      miktarKurus: Value(miktarKurus),
      yekunKurus: Value(yekunKurus),
      miktarHam: miktarHam == null && nullToAbsent
          ? const Value.absent()
          : Value(miktarHam),
      yekunHam: yekunHam == null && nullToAbsent
          ? const Value.absent()
          : Value(yekunHam),
    );
  }

  factory DefterSatiriSatiri.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DefterSatiriSatiri(
      id: serializer.fromJson<String>(json['id']),
      ortakId: serializer.fromJson<String>(json['ortakId']),
      tur: $DefterSatirlariTable.$convertertur.fromJson(
        serializer.fromJson<String>(json['tur']),
      ),
      siraNo: serializer.fromJson<int>(json['siraNo']),
      tarihHam: serializer.fromJson<String?>(json['tarihHam']),
      tarih: serializer.fromJson<DateTime?>(json['tarih']),
      no: serializer.fromJson<String?>(json['no']),
      madde: serializer.fromJson<String?>(json['madde']),
      aciklama: serializer.fromJson<String?>(json['aciklama']),
      miktarKurus: serializer.fromJson<int>(json['miktarKurus']),
      yekunKurus: serializer.fromJson<int>(json['yekunKurus']),
      miktarHam: serializer.fromJson<String?>(json['miktarHam']),
      yekunHam: serializer.fromJson<String?>(json['yekunHam']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ortakId': serializer.toJson<String>(ortakId),
      'tur': serializer.toJson<String>(
        $DefterSatirlariTable.$convertertur.toJson(tur),
      ),
      'siraNo': serializer.toJson<int>(siraNo),
      'tarihHam': serializer.toJson<String?>(tarihHam),
      'tarih': serializer.toJson<DateTime?>(tarih),
      'no': serializer.toJson<String?>(no),
      'madde': serializer.toJson<String?>(madde),
      'aciklama': serializer.toJson<String?>(aciklama),
      'miktarKurus': serializer.toJson<int>(miktarKurus),
      'yekunKurus': serializer.toJson<int>(yekunKurus),
      'miktarHam': serializer.toJson<String?>(miktarHam),
      'yekunHam': serializer.toJson<String?>(yekunHam),
    };
  }

  DefterSatiriSatiri copyWith({
    String? id,
    String? ortakId,
    SatirTuru? tur,
    int? siraNo,
    Value<String?> tarihHam = const Value.absent(),
    Value<DateTime?> tarih = const Value.absent(),
    Value<String?> no = const Value.absent(),
    Value<String?> madde = const Value.absent(),
    Value<String?> aciklama = const Value.absent(),
    int? miktarKurus,
    int? yekunKurus,
    Value<String?> miktarHam = const Value.absent(),
    Value<String?> yekunHam = const Value.absent(),
  }) => DefterSatiriSatiri(
    id: id ?? this.id,
    ortakId: ortakId ?? this.ortakId,
    tur: tur ?? this.tur,
    siraNo: siraNo ?? this.siraNo,
    tarihHam: tarihHam.present ? tarihHam.value : this.tarihHam,
    tarih: tarih.present ? tarih.value : this.tarih,
    no: no.present ? no.value : this.no,
    madde: madde.present ? madde.value : this.madde,
    aciklama: aciklama.present ? aciklama.value : this.aciklama,
    miktarKurus: miktarKurus ?? this.miktarKurus,
    yekunKurus: yekunKurus ?? this.yekunKurus,
    miktarHam: miktarHam.present ? miktarHam.value : this.miktarHam,
    yekunHam: yekunHam.present ? yekunHam.value : this.yekunHam,
  );
  DefterSatiriSatiri copyWithCompanion(DefterSatirlariCompanion data) {
    return DefterSatiriSatiri(
      id: data.id.present ? data.id.value : this.id,
      ortakId: data.ortakId.present ? data.ortakId.value : this.ortakId,
      tur: data.tur.present ? data.tur.value : this.tur,
      siraNo: data.siraNo.present ? data.siraNo.value : this.siraNo,
      tarihHam: data.tarihHam.present ? data.tarihHam.value : this.tarihHam,
      tarih: data.tarih.present ? data.tarih.value : this.tarih,
      no: data.no.present ? data.no.value : this.no,
      madde: data.madde.present ? data.madde.value : this.madde,
      aciklama: data.aciklama.present ? data.aciklama.value : this.aciklama,
      miktarKurus: data.miktarKurus.present
          ? data.miktarKurus.value
          : this.miktarKurus,
      yekunKurus: data.yekunKurus.present
          ? data.yekunKurus.value
          : this.yekunKurus,
      miktarHam: data.miktarHam.present ? data.miktarHam.value : this.miktarHam,
      yekunHam: data.yekunHam.present ? data.yekunHam.value : this.yekunHam,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DefterSatiriSatiri(')
          ..write('id: $id, ')
          ..write('ortakId: $ortakId, ')
          ..write('tur: $tur, ')
          ..write('siraNo: $siraNo, ')
          ..write('tarihHam: $tarihHam, ')
          ..write('tarih: $tarih, ')
          ..write('no: $no, ')
          ..write('madde: $madde, ')
          ..write('aciklama: $aciklama, ')
          ..write('miktarKurus: $miktarKurus, ')
          ..write('yekunKurus: $yekunKurus, ')
          ..write('miktarHam: $miktarHam, ')
          ..write('yekunHam: $yekunHam')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ortakId,
    tur,
    siraNo,
    tarihHam,
    tarih,
    no,
    madde,
    aciklama,
    miktarKurus,
    yekunKurus,
    miktarHam,
    yekunHam,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DefterSatiriSatiri &&
          other.id == this.id &&
          other.ortakId == this.ortakId &&
          other.tur == this.tur &&
          other.siraNo == this.siraNo &&
          other.tarihHam == this.tarihHam &&
          other.tarih == this.tarih &&
          other.no == this.no &&
          other.madde == this.madde &&
          other.aciklama == this.aciklama &&
          other.miktarKurus == this.miktarKurus &&
          other.yekunKurus == this.yekunKurus &&
          other.miktarHam == this.miktarHam &&
          other.yekunHam == this.yekunHam);
}

class DefterSatirlariCompanion extends UpdateCompanion<DefterSatiriSatiri> {
  final Value<String> id;
  final Value<String> ortakId;
  final Value<SatirTuru> tur;
  final Value<int> siraNo;
  final Value<String?> tarihHam;
  final Value<DateTime?> tarih;
  final Value<String?> no;
  final Value<String?> madde;
  final Value<String?> aciklama;
  final Value<int> miktarKurus;
  final Value<int> yekunKurus;
  final Value<String?> miktarHam;
  final Value<String?> yekunHam;
  final Value<int> rowid;
  const DefterSatirlariCompanion({
    this.id = const Value.absent(),
    this.ortakId = const Value.absent(),
    this.tur = const Value.absent(),
    this.siraNo = const Value.absent(),
    this.tarihHam = const Value.absent(),
    this.tarih = const Value.absent(),
    this.no = const Value.absent(),
    this.madde = const Value.absent(),
    this.aciklama = const Value.absent(),
    this.miktarKurus = const Value.absent(),
    this.yekunKurus = const Value.absent(),
    this.miktarHam = const Value.absent(),
    this.yekunHam = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DefterSatirlariCompanion.insert({
    required String id,
    required String ortakId,
    required SatirTuru tur,
    required int siraNo,
    this.tarihHam = const Value.absent(),
    this.tarih = const Value.absent(),
    this.no = const Value.absent(),
    this.madde = const Value.absent(),
    this.aciklama = const Value.absent(),
    this.miktarKurus = const Value.absent(),
    this.yekunKurus = const Value.absent(),
    this.miktarHam = const Value.absent(),
    this.yekunHam = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ortakId = Value(ortakId),
       tur = Value(tur),
       siraNo = Value(siraNo);
  static Insertable<DefterSatiriSatiri> custom({
    Expression<String>? id,
    Expression<String>? ortakId,
    Expression<String>? tur,
    Expression<int>? siraNo,
    Expression<String>? tarihHam,
    Expression<DateTime>? tarih,
    Expression<String>? no,
    Expression<String>? madde,
    Expression<String>? aciklama,
    Expression<int>? miktarKurus,
    Expression<int>? yekunKurus,
    Expression<String>? miktarHam,
    Expression<String>? yekunHam,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ortakId != null) 'ortak_id': ortakId,
      if (tur != null) 'tur': tur,
      if (siraNo != null) 'sira_no': siraNo,
      if (tarihHam != null) 'tarih_ham': tarihHam,
      if (tarih != null) 'tarih': tarih,
      if (no != null) 'no': no,
      if (madde != null) 'madde': madde,
      if (aciklama != null) 'aciklama': aciklama,
      if (miktarKurus != null) 'miktar_kurus': miktarKurus,
      if (yekunKurus != null) 'yekun_kurus': yekunKurus,
      if (miktarHam != null) 'miktar_ham': miktarHam,
      if (yekunHam != null) 'yekun_ham': yekunHam,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DefterSatirlariCompanion copyWith({
    Value<String>? id,
    Value<String>? ortakId,
    Value<SatirTuru>? tur,
    Value<int>? siraNo,
    Value<String?>? tarihHam,
    Value<DateTime?>? tarih,
    Value<String?>? no,
    Value<String?>? madde,
    Value<String?>? aciklama,
    Value<int>? miktarKurus,
    Value<int>? yekunKurus,
    Value<String?>? miktarHam,
    Value<String?>? yekunHam,
    Value<int>? rowid,
  }) {
    return DefterSatirlariCompanion(
      id: id ?? this.id,
      ortakId: ortakId ?? this.ortakId,
      tur: tur ?? this.tur,
      siraNo: siraNo ?? this.siraNo,
      tarihHam: tarihHam ?? this.tarihHam,
      tarih: tarih ?? this.tarih,
      no: no ?? this.no,
      madde: madde ?? this.madde,
      aciklama: aciklama ?? this.aciklama,
      miktarKurus: miktarKurus ?? this.miktarKurus,
      yekunKurus: yekunKurus ?? this.yekunKurus,
      miktarHam: miktarHam ?? this.miktarHam,
      yekunHam: yekunHam ?? this.yekunHam,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ortakId.present) {
      map['ortak_id'] = Variable<String>(ortakId.value);
    }
    if (tur.present) {
      map['tur'] = Variable<String>(
        $DefterSatirlariTable.$convertertur.toSql(tur.value),
      );
    }
    if (siraNo.present) {
      map['sira_no'] = Variable<int>(siraNo.value);
    }
    if (tarihHam.present) {
      map['tarih_ham'] = Variable<String>(tarihHam.value);
    }
    if (tarih.present) {
      map['tarih'] = Variable<DateTime>(tarih.value);
    }
    if (no.present) {
      map['no'] = Variable<String>(no.value);
    }
    if (madde.present) {
      map['madde'] = Variable<String>(madde.value);
    }
    if (aciklama.present) {
      map['aciklama'] = Variable<String>(aciklama.value);
    }
    if (miktarKurus.present) {
      map['miktar_kurus'] = Variable<int>(miktarKurus.value);
    }
    if (yekunKurus.present) {
      map['yekun_kurus'] = Variable<int>(yekunKurus.value);
    }
    if (miktarHam.present) {
      map['miktar_ham'] = Variable<String>(miktarHam.value);
    }
    if (yekunHam.present) {
      map['yekun_ham'] = Variable<String>(yekunHam.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DefterSatirlariCompanion(')
          ..write('id: $id, ')
          ..write('ortakId: $ortakId, ')
          ..write('tur: $tur, ')
          ..write('siraNo: $siraNo, ')
          ..write('tarihHam: $tarihHam, ')
          ..write('tarih: $tarih, ')
          ..write('no: $no, ')
          ..write('madde: $madde, ')
          ..write('aciklama: $aciklama, ')
          ..write('miktarKurus: $miktarKurus, ')
          ..write('yekunKurus: $yekunKurus, ')
          ..write('miktarHam: $miktarHam, ')
          ..write('yekunHam: $yekunHam, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IceAktarmaKuyruguTable extends IceAktarmaKuyrugu
    with TableInfo<$IceAktarmaKuyruguTable, IceAktarmaIsiSatiri> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IceAktarmaKuyruguTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dosyaYoluMeta = const VerificationMeta(
    'dosyaYolu',
  );
  @override
  late final GeneratedColumn<String> dosyaYolu = GeneratedColumn<String>(
    'dosya_yolu',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dosyaAdiMeta = const VerificationMeta(
    'dosyaAdi',
  );
  @override
  late final GeneratedColumn<String> dosyaAdi = GeneratedColumn<String>(
    'dosya_adi',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dosyaHashMeta = const VerificationMeta(
    'dosyaHash',
  );
  @override
  late final GeneratedColumn<String> dosyaHash = GeneratedColumn<String>(
    'dosya_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<KuyrukDurumu, String> durum =
      GeneratedColumn<String>(
        'durum',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(KuyrukDurumu.bekliyor.name),
      ).withConverter<KuyrukDurumu>($IceAktarmaKuyruguTable.$converterdurum);
  static const VerificationMeta _islendiMeta = const VerificationMeta(
    'islendi',
  );
  @override
  late final GeneratedColumn<bool> islendi = GeneratedColumn<bool>(
    'islendi',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("islendi" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hataMesajiMeta = const VerificationMeta(
    'hataMesaji',
  );
  @override
  late final GeneratedColumn<String> hataMesaji = GeneratedColumn<String>(
    'hata_mesaji',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _denemeSayisiMeta = const VerificationMeta(
    'denemeSayisi',
  );
  @override
  late final GeneratedColumn<int> denemeSayisi = GeneratedColumn<int>(
    'deneme_sayisi',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _olusanOrtakIdMeta = const VerificationMeta(
    'olusanOrtakId',
  );
  @override
  late final GeneratedColumn<String> olusanOrtakId = GeneratedColumn<String>(
    'olusan_ortak_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ocrHamJsonMeta = const VerificationMeta(
    'ocrHamJson',
  );
  @override
  late final GeneratedColumn<String> ocrHamJson = GeneratedColumn<String>(
    'ocr_ham_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eklenmeTarihiMeta = const VerificationMeta(
    'eklenmeTarihi',
  );
  @override
  late final GeneratedColumn<DateTime> eklenmeTarihi =
      GeneratedColumn<DateTime>(
        'eklenme_tarihi',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dosyaYolu,
    dosyaAdi,
    dosyaHash,
    durum,
    islendi,
    hataMesaji,
    denemeSayisi,
    olusanOrtakId,
    ocrHamJson,
    eklenmeTarihi,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ice_aktarma_kuyrugu';
  @override
  VerificationContext validateIntegrity(
    Insertable<IceAktarmaIsiSatiri> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('dosya_yolu')) {
      context.handle(
        _dosyaYoluMeta,
        dosyaYolu.isAcceptableOrUnknown(data['dosya_yolu']!, _dosyaYoluMeta),
      );
    } else if (isInserting) {
      context.missing(_dosyaYoluMeta);
    }
    if (data.containsKey('dosya_adi')) {
      context.handle(
        _dosyaAdiMeta,
        dosyaAdi.isAcceptableOrUnknown(data['dosya_adi']!, _dosyaAdiMeta),
      );
    } else if (isInserting) {
      context.missing(_dosyaAdiMeta);
    }
    if (data.containsKey('dosya_hash')) {
      context.handle(
        _dosyaHashMeta,
        dosyaHash.isAcceptableOrUnknown(data['dosya_hash']!, _dosyaHashMeta),
      );
    } else if (isInserting) {
      context.missing(_dosyaHashMeta);
    }
    if (data.containsKey('islendi')) {
      context.handle(
        _islendiMeta,
        islendi.isAcceptableOrUnknown(data['islendi']!, _islendiMeta),
      );
    }
    if (data.containsKey('hata_mesaji')) {
      context.handle(
        _hataMesajiMeta,
        hataMesaji.isAcceptableOrUnknown(data['hata_mesaji']!, _hataMesajiMeta),
      );
    }
    if (data.containsKey('deneme_sayisi')) {
      context.handle(
        _denemeSayisiMeta,
        denemeSayisi.isAcceptableOrUnknown(
          data['deneme_sayisi']!,
          _denemeSayisiMeta,
        ),
      );
    }
    if (data.containsKey('olusan_ortak_id')) {
      context.handle(
        _olusanOrtakIdMeta,
        olusanOrtakId.isAcceptableOrUnknown(
          data['olusan_ortak_id']!,
          _olusanOrtakIdMeta,
        ),
      );
    }
    if (data.containsKey('ocr_ham_json')) {
      context.handle(
        _ocrHamJsonMeta,
        ocrHamJson.isAcceptableOrUnknown(
          data['ocr_ham_json']!,
          _ocrHamJsonMeta,
        ),
      );
    }
    if (data.containsKey('eklenme_tarihi')) {
      context.handle(
        _eklenmeTarihiMeta,
        eklenmeTarihi.isAcceptableOrUnknown(
          data['eklenme_tarihi']!,
          _eklenmeTarihiMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_eklenmeTarihiMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IceAktarmaIsiSatiri map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IceAktarmaIsiSatiri(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      dosyaYolu: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dosya_yolu'],
      )!,
      dosyaAdi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dosya_adi'],
      )!,
      dosyaHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dosya_hash'],
      )!,
      durum: $IceAktarmaKuyruguTable.$converterdurum.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}durum'],
        )!,
      ),
      islendi: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}islendi'],
      )!,
      hataMesaji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hata_mesaji'],
      ),
      denemeSayisi: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deneme_sayisi'],
      )!,
      olusanOrtakId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}olusan_ortak_id'],
      ),
      ocrHamJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ocr_ham_json'],
      ),
      eklenmeTarihi: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}eklenme_tarihi'],
      )!,
    );
  }

  @override
  $IceAktarmaKuyruguTable createAlias(String alias) {
    return $IceAktarmaKuyruguTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<KuyrukDurumu, String, String> $converterdurum =
      const EnumNameConverter<KuyrukDurumu>(KuyrukDurumu.values);
}

class IceAktarmaIsiSatiri extends DataClass
    implements Insertable<IceAktarmaIsiSatiri> {
  final String id;
  final String dosyaYolu;
  final String dosyaAdi;

  /// ★ Aynı dosyanın iki kez kuyruğa girmesini önler (PLAN.md §8).
  final String dosyaHash;
  final KuyrukDurumu durum;

  /// İstenen `processed` alanı — dosya taşıma/silme değil, bu alanla takip.
  final bool islendi;
  final String? hataMesaji;
  final int denemeSayisi;
  final String? olusanOrtakId;
  final String? ocrHamJson;
  final DateTime eklenmeTarihi;
  const IceAktarmaIsiSatiri({
    required this.id,
    required this.dosyaYolu,
    required this.dosyaAdi,
    required this.dosyaHash,
    required this.durum,
    required this.islendi,
    this.hataMesaji,
    required this.denemeSayisi,
    this.olusanOrtakId,
    this.ocrHamJson,
    required this.eklenmeTarihi,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['dosya_yolu'] = Variable<String>(dosyaYolu);
    map['dosya_adi'] = Variable<String>(dosyaAdi);
    map['dosya_hash'] = Variable<String>(dosyaHash);
    {
      map['durum'] = Variable<String>(
        $IceAktarmaKuyruguTable.$converterdurum.toSql(durum),
      );
    }
    map['islendi'] = Variable<bool>(islendi);
    if (!nullToAbsent || hataMesaji != null) {
      map['hata_mesaji'] = Variable<String>(hataMesaji);
    }
    map['deneme_sayisi'] = Variable<int>(denemeSayisi);
    if (!nullToAbsent || olusanOrtakId != null) {
      map['olusan_ortak_id'] = Variable<String>(olusanOrtakId);
    }
    if (!nullToAbsent || ocrHamJson != null) {
      map['ocr_ham_json'] = Variable<String>(ocrHamJson);
    }
    map['eklenme_tarihi'] = Variable<DateTime>(eklenmeTarihi);
    return map;
  }

  IceAktarmaKuyruguCompanion toCompanion(bool nullToAbsent) {
    return IceAktarmaKuyruguCompanion(
      id: Value(id),
      dosyaYolu: Value(dosyaYolu),
      dosyaAdi: Value(dosyaAdi),
      dosyaHash: Value(dosyaHash),
      durum: Value(durum),
      islendi: Value(islendi),
      hataMesaji: hataMesaji == null && nullToAbsent
          ? const Value.absent()
          : Value(hataMesaji),
      denemeSayisi: Value(denemeSayisi),
      olusanOrtakId: olusanOrtakId == null && nullToAbsent
          ? const Value.absent()
          : Value(olusanOrtakId),
      ocrHamJson: ocrHamJson == null && nullToAbsent
          ? const Value.absent()
          : Value(ocrHamJson),
      eklenmeTarihi: Value(eklenmeTarihi),
    );
  }

  factory IceAktarmaIsiSatiri.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IceAktarmaIsiSatiri(
      id: serializer.fromJson<String>(json['id']),
      dosyaYolu: serializer.fromJson<String>(json['dosyaYolu']),
      dosyaAdi: serializer.fromJson<String>(json['dosyaAdi']),
      dosyaHash: serializer.fromJson<String>(json['dosyaHash']),
      durum: $IceAktarmaKuyruguTable.$converterdurum.fromJson(
        serializer.fromJson<String>(json['durum']),
      ),
      islendi: serializer.fromJson<bool>(json['islendi']),
      hataMesaji: serializer.fromJson<String?>(json['hataMesaji']),
      denemeSayisi: serializer.fromJson<int>(json['denemeSayisi']),
      olusanOrtakId: serializer.fromJson<String?>(json['olusanOrtakId']),
      ocrHamJson: serializer.fromJson<String?>(json['ocrHamJson']),
      eklenmeTarihi: serializer.fromJson<DateTime>(json['eklenmeTarihi']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dosyaYolu': serializer.toJson<String>(dosyaYolu),
      'dosyaAdi': serializer.toJson<String>(dosyaAdi),
      'dosyaHash': serializer.toJson<String>(dosyaHash),
      'durum': serializer.toJson<String>(
        $IceAktarmaKuyruguTable.$converterdurum.toJson(durum),
      ),
      'islendi': serializer.toJson<bool>(islendi),
      'hataMesaji': serializer.toJson<String?>(hataMesaji),
      'denemeSayisi': serializer.toJson<int>(denemeSayisi),
      'olusanOrtakId': serializer.toJson<String?>(olusanOrtakId),
      'ocrHamJson': serializer.toJson<String?>(ocrHamJson),
      'eklenmeTarihi': serializer.toJson<DateTime>(eklenmeTarihi),
    };
  }

  IceAktarmaIsiSatiri copyWith({
    String? id,
    String? dosyaYolu,
    String? dosyaAdi,
    String? dosyaHash,
    KuyrukDurumu? durum,
    bool? islendi,
    Value<String?> hataMesaji = const Value.absent(),
    int? denemeSayisi,
    Value<String?> olusanOrtakId = const Value.absent(),
    Value<String?> ocrHamJson = const Value.absent(),
    DateTime? eklenmeTarihi,
  }) => IceAktarmaIsiSatiri(
    id: id ?? this.id,
    dosyaYolu: dosyaYolu ?? this.dosyaYolu,
    dosyaAdi: dosyaAdi ?? this.dosyaAdi,
    dosyaHash: dosyaHash ?? this.dosyaHash,
    durum: durum ?? this.durum,
    islendi: islendi ?? this.islendi,
    hataMesaji: hataMesaji.present ? hataMesaji.value : this.hataMesaji,
    denemeSayisi: denemeSayisi ?? this.denemeSayisi,
    olusanOrtakId: olusanOrtakId.present
        ? olusanOrtakId.value
        : this.olusanOrtakId,
    ocrHamJson: ocrHamJson.present ? ocrHamJson.value : this.ocrHamJson,
    eklenmeTarihi: eklenmeTarihi ?? this.eklenmeTarihi,
  );
  IceAktarmaIsiSatiri copyWithCompanion(IceAktarmaKuyruguCompanion data) {
    return IceAktarmaIsiSatiri(
      id: data.id.present ? data.id.value : this.id,
      dosyaYolu: data.dosyaYolu.present ? data.dosyaYolu.value : this.dosyaYolu,
      dosyaAdi: data.dosyaAdi.present ? data.dosyaAdi.value : this.dosyaAdi,
      dosyaHash: data.dosyaHash.present ? data.dosyaHash.value : this.dosyaHash,
      durum: data.durum.present ? data.durum.value : this.durum,
      islendi: data.islendi.present ? data.islendi.value : this.islendi,
      hataMesaji: data.hataMesaji.present
          ? data.hataMesaji.value
          : this.hataMesaji,
      denemeSayisi: data.denemeSayisi.present
          ? data.denemeSayisi.value
          : this.denemeSayisi,
      olusanOrtakId: data.olusanOrtakId.present
          ? data.olusanOrtakId.value
          : this.olusanOrtakId,
      ocrHamJson: data.ocrHamJson.present
          ? data.ocrHamJson.value
          : this.ocrHamJson,
      eklenmeTarihi: data.eklenmeTarihi.present
          ? data.eklenmeTarihi.value
          : this.eklenmeTarihi,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IceAktarmaIsiSatiri(')
          ..write('id: $id, ')
          ..write('dosyaYolu: $dosyaYolu, ')
          ..write('dosyaAdi: $dosyaAdi, ')
          ..write('dosyaHash: $dosyaHash, ')
          ..write('durum: $durum, ')
          ..write('islendi: $islendi, ')
          ..write('hataMesaji: $hataMesaji, ')
          ..write('denemeSayisi: $denemeSayisi, ')
          ..write('olusanOrtakId: $olusanOrtakId, ')
          ..write('ocrHamJson: $ocrHamJson, ')
          ..write('eklenmeTarihi: $eklenmeTarihi')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    dosyaYolu,
    dosyaAdi,
    dosyaHash,
    durum,
    islendi,
    hataMesaji,
    denemeSayisi,
    olusanOrtakId,
    ocrHamJson,
    eklenmeTarihi,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IceAktarmaIsiSatiri &&
          other.id == this.id &&
          other.dosyaYolu == this.dosyaYolu &&
          other.dosyaAdi == this.dosyaAdi &&
          other.dosyaHash == this.dosyaHash &&
          other.durum == this.durum &&
          other.islendi == this.islendi &&
          other.hataMesaji == this.hataMesaji &&
          other.denemeSayisi == this.denemeSayisi &&
          other.olusanOrtakId == this.olusanOrtakId &&
          other.ocrHamJson == this.ocrHamJson &&
          other.eklenmeTarihi == this.eklenmeTarihi);
}

class IceAktarmaKuyruguCompanion extends UpdateCompanion<IceAktarmaIsiSatiri> {
  final Value<String> id;
  final Value<String> dosyaYolu;
  final Value<String> dosyaAdi;
  final Value<String> dosyaHash;
  final Value<KuyrukDurumu> durum;
  final Value<bool> islendi;
  final Value<String?> hataMesaji;
  final Value<int> denemeSayisi;
  final Value<String?> olusanOrtakId;
  final Value<String?> ocrHamJson;
  final Value<DateTime> eklenmeTarihi;
  final Value<int> rowid;
  const IceAktarmaKuyruguCompanion({
    this.id = const Value.absent(),
    this.dosyaYolu = const Value.absent(),
    this.dosyaAdi = const Value.absent(),
    this.dosyaHash = const Value.absent(),
    this.durum = const Value.absent(),
    this.islendi = const Value.absent(),
    this.hataMesaji = const Value.absent(),
    this.denemeSayisi = const Value.absent(),
    this.olusanOrtakId = const Value.absent(),
    this.ocrHamJson = const Value.absent(),
    this.eklenmeTarihi = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IceAktarmaKuyruguCompanion.insert({
    required String id,
    required String dosyaYolu,
    required String dosyaAdi,
    required String dosyaHash,
    this.durum = const Value.absent(),
    this.islendi = const Value.absent(),
    this.hataMesaji = const Value.absent(),
    this.denemeSayisi = const Value.absent(),
    this.olusanOrtakId = const Value.absent(),
    this.ocrHamJson = const Value.absent(),
    required DateTime eklenmeTarihi,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       dosyaYolu = Value(dosyaYolu),
       dosyaAdi = Value(dosyaAdi),
       dosyaHash = Value(dosyaHash),
       eklenmeTarihi = Value(eklenmeTarihi);
  static Insertable<IceAktarmaIsiSatiri> custom({
    Expression<String>? id,
    Expression<String>? dosyaYolu,
    Expression<String>? dosyaAdi,
    Expression<String>? dosyaHash,
    Expression<String>? durum,
    Expression<bool>? islendi,
    Expression<String>? hataMesaji,
    Expression<int>? denemeSayisi,
    Expression<String>? olusanOrtakId,
    Expression<String>? ocrHamJson,
    Expression<DateTime>? eklenmeTarihi,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dosyaYolu != null) 'dosya_yolu': dosyaYolu,
      if (dosyaAdi != null) 'dosya_adi': dosyaAdi,
      if (dosyaHash != null) 'dosya_hash': dosyaHash,
      if (durum != null) 'durum': durum,
      if (islendi != null) 'islendi': islendi,
      if (hataMesaji != null) 'hata_mesaji': hataMesaji,
      if (denemeSayisi != null) 'deneme_sayisi': denemeSayisi,
      if (olusanOrtakId != null) 'olusan_ortak_id': olusanOrtakId,
      if (ocrHamJson != null) 'ocr_ham_json': ocrHamJson,
      if (eklenmeTarihi != null) 'eklenme_tarihi': eklenmeTarihi,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IceAktarmaKuyruguCompanion copyWith({
    Value<String>? id,
    Value<String>? dosyaYolu,
    Value<String>? dosyaAdi,
    Value<String>? dosyaHash,
    Value<KuyrukDurumu>? durum,
    Value<bool>? islendi,
    Value<String?>? hataMesaji,
    Value<int>? denemeSayisi,
    Value<String?>? olusanOrtakId,
    Value<String?>? ocrHamJson,
    Value<DateTime>? eklenmeTarihi,
    Value<int>? rowid,
  }) {
    return IceAktarmaKuyruguCompanion(
      id: id ?? this.id,
      dosyaYolu: dosyaYolu ?? this.dosyaYolu,
      dosyaAdi: dosyaAdi ?? this.dosyaAdi,
      dosyaHash: dosyaHash ?? this.dosyaHash,
      durum: durum ?? this.durum,
      islendi: islendi ?? this.islendi,
      hataMesaji: hataMesaji ?? this.hataMesaji,
      denemeSayisi: denemeSayisi ?? this.denemeSayisi,
      olusanOrtakId: olusanOrtakId ?? this.olusanOrtakId,
      ocrHamJson: ocrHamJson ?? this.ocrHamJson,
      eklenmeTarihi: eklenmeTarihi ?? this.eklenmeTarihi,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dosyaYolu.present) {
      map['dosya_yolu'] = Variable<String>(dosyaYolu.value);
    }
    if (dosyaAdi.present) {
      map['dosya_adi'] = Variable<String>(dosyaAdi.value);
    }
    if (dosyaHash.present) {
      map['dosya_hash'] = Variable<String>(dosyaHash.value);
    }
    if (durum.present) {
      map['durum'] = Variable<String>(
        $IceAktarmaKuyruguTable.$converterdurum.toSql(durum.value),
      );
    }
    if (islendi.present) {
      map['islendi'] = Variable<bool>(islendi.value);
    }
    if (hataMesaji.present) {
      map['hata_mesaji'] = Variable<String>(hataMesaji.value);
    }
    if (denemeSayisi.present) {
      map['deneme_sayisi'] = Variable<int>(denemeSayisi.value);
    }
    if (olusanOrtakId.present) {
      map['olusan_ortak_id'] = Variable<String>(olusanOrtakId.value);
    }
    if (ocrHamJson.present) {
      map['ocr_ham_json'] = Variable<String>(ocrHamJson.value);
    }
    if (eklenmeTarihi.present) {
      map['eklenme_tarihi'] = Variable<DateTime>(eklenmeTarihi.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IceAktarmaKuyruguCompanion(')
          ..write('id: $id, ')
          ..write('dosyaYolu: $dosyaYolu, ')
          ..write('dosyaAdi: $dosyaAdi, ')
          ..write('dosyaHash: $dosyaHash, ')
          ..write('durum: $durum, ')
          ..write('islendi: $islendi, ')
          ..write('hataMesaji: $hataMesaji, ')
          ..write('denemeSayisi: $denemeSayisi, ')
          ..write('olusanOrtakId: $olusanOrtakId, ')
          ..write('ocrHamJson: $ocrHamJson, ')
          ..write('eklenmeTarihi: $eklenmeTarihi, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppVeritabani extends GeneratedDatabase {
  _$AppVeritabani(QueryExecutor e) : super(e);
  $AppVeritabaniManager get managers => $AppVeritabaniManager(this);
  late final $OrtaklarTable ortaklar = $OrtaklarTable(this);
  late final $DefterSatirlariTable defterSatirlari = $DefterSatirlariTable(
    this,
  );
  late final $IceAktarmaKuyruguTable iceAktarmaKuyrugu =
      $IceAktarmaKuyruguTable(this);
  late final OrtakDao ortakDao = OrtakDao(this as AppVeritabani);
  late final DefterSatiriDao defterSatiriDao = DefterSatiriDao(
    this as AppVeritabani,
  );
  late final KuyrukDao kuyrukDao = KuyrukDao(this as AppVeritabani);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    ortaklar,
    defterSatirlari,
    iceAktarmaKuyrugu,
  ];
}

typedef $$OrtaklarTableCreateCompanionBuilder =
    OrtaklarCompanion Function({
      required String id,
      required String ortakNo,
      required String adSoyad,
      Value<String?> babaAdi,
      Value<String?> dogumYeri,
      Value<String?> dogumTarihiHam,
      Value<DateTime?> dogumTarihi,
      Value<String?> girisTarihiHam,
      Value<DateTime?> girisTarihi,
      Value<String?> cikisTarihiHam,
      Value<DateTime?> cikisTarihi,
      Value<String?> ikametAdresi,
      Value<String?> nufusKayitYeri,
      required String aramaAnahtari,
      Value<String?> belgeR2Anahtari,
      Value<double?> ocrGuvenOrtalama,
      Value<bool> aktif,
      Value<String?> pasifNedeni,
      Value<DateTime?> pasifTarihi,
      required DateTime olusturmaTarihi,
      required DateTime guncellemeTarihi,
      Value<SenkronDurumu> senkronDurumu,
      Value<int> rowid,
    });
typedef $$OrtaklarTableUpdateCompanionBuilder =
    OrtaklarCompanion Function({
      Value<String> id,
      Value<String> ortakNo,
      Value<String> adSoyad,
      Value<String?> babaAdi,
      Value<String?> dogumYeri,
      Value<String?> dogumTarihiHam,
      Value<DateTime?> dogumTarihi,
      Value<String?> girisTarihiHam,
      Value<DateTime?> girisTarihi,
      Value<String?> cikisTarihiHam,
      Value<DateTime?> cikisTarihi,
      Value<String?> ikametAdresi,
      Value<String?> nufusKayitYeri,
      Value<String> aramaAnahtari,
      Value<String?> belgeR2Anahtari,
      Value<double?> ocrGuvenOrtalama,
      Value<bool> aktif,
      Value<String?> pasifNedeni,
      Value<DateTime?> pasifTarihi,
      Value<DateTime> olusturmaTarihi,
      Value<DateTime> guncellemeTarihi,
      Value<SenkronDurumu> senkronDurumu,
      Value<int> rowid,
    });

final class $$OrtaklarTableReferences
    extends BaseReferences<_$AppVeritabani, $OrtaklarTable, OrtakSatiri> {
  $$OrtaklarTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DefterSatirlariTable, List<DefterSatiriSatiri>>
  _defterSatirlariRefsTable(_$AppVeritabani db) =>
      MultiTypedResultKey.fromTable(
        db.defterSatirlari,
        aliasName: $_aliasNameGenerator(
          db.ortaklar.id,
          db.defterSatirlari.ortakId,
        ),
      );

  $$DefterSatirlariTableProcessedTableManager get defterSatirlariRefs {
    final manager = $$DefterSatirlariTableTableManager(
      $_db,
      $_db.defterSatirlari,
    ).filter((f) => f.ortakId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _defterSatirlariRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$OrtaklarTableFilterComposer
    extends Composer<_$AppVeritabani, $OrtaklarTable> {
  $$OrtaklarTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ortakNo => $composableBuilder(
    column: $table.ortakNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get adSoyad => $composableBuilder(
    column: $table.adSoyad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get babaAdi => $composableBuilder(
    column: $table.babaAdi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dogumYeri => $composableBuilder(
    column: $table.dogumYeri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dogumTarihiHam => $composableBuilder(
    column: $table.dogumTarihiHam,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dogumTarihi => $composableBuilder(
    column: $table.dogumTarihi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get girisTarihiHam => $composableBuilder(
    column: $table.girisTarihiHam,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get girisTarihi => $composableBuilder(
    column: $table.girisTarihi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cikisTarihiHam => $composableBuilder(
    column: $table.cikisTarihiHam,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cikisTarihi => $composableBuilder(
    column: $table.cikisTarihi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ikametAdresi => $composableBuilder(
    column: $table.ikametAdresi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nufusKayitYeri => $composableBuilder(
    column: $table.nufusKayitYeri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aramaAnahtari => $composableBuilder(
    column: $table.aramaAnahtari,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get belgeR2Anahtari => $composableBuilder(
    column: $table.belgeR2Anahtari,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ocrGuvenOrtalama => $composableBuilder(
    column: $table.ocrGuvenOrtalama,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get aktif => $composableBuilder(
    column: $table.aktif,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pasifNedeni => $composableBuilder(
    column: $table.pasifNedeni,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get pasifTarihi => $composableBuilder(
    column: $table.pasifTarihi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get olusturmaTarihi => $composableBuilder(
    column: $table.olusturmaTarihi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get guncellemeTarihi => $composableBuilder(
    column: $table.guncellemeTarihi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SenkronDurumu, SenkronDurumu, String>
  get senkronDurumu => $composableBuilder(
    column: $table.senkronDurumu,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  Expression<bool> defterSatirlariRefs(
    Expression<bool> Function($$DefterSatirlariTableFilterComposer f) f,
  ) {
    final $$DefterSatirlariTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.defterSatirlari,
      getReferencedColumn: (t) => t.ortakId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DefterSatirlariTableFilterComposer(
            $db: $db,
            $table: $db.defterSatirlari,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OrtaklarTableOrderingComposer
    extends Composer<_$AppVeritabani, $OrtaklarTable> {
  $$OrtaklarTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ortakNo => $composableBuilder(
    column: $table.ortakNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get adSoyad => $composableBuilder(
    column: $table.adSoyad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get babaAdi => $composableBuilder(
    column: $table.babaAdi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dogumYeri => $composableBuilder(
    column: $table.dogumYeri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dogumTarihiHam => $composableBuilder(
    column: $table.dogumTarihiHam,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dogumTarihi => $composableBuilder(
    column: $table.dogumTarihi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get girisTarihiHam => $composableBuilder(
    column: $table.girisTarihiHam,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get girisTarihi => $composableBuilder(
    column: $table.girisTarihi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cikisTarihiHam => $composableBuilder(
    column: $table.cikisTarihiHam,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cikisTarihi => $composableBuilder(
    column: $table.cikisTarihi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ikametAdresi => $composableBuilder(
    column: $table.ikametAdresi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nufusKayitYeri => $composableBuilder(
    column: $table.nufusKayitYeri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aramaAnahtari => $composableBuilder(
    column: $table.aramaAnahtari,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get belgeR2Anahtari => $composableBuilder(
    column: $table.belgeR2Anahtari,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ocrGuvenOrtalama => $composableBuilder(
    column: $table.ocrGuvenOrtalama,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get aktif => $composableBuilder(
    column: $table.aktif,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pasifNedeni => $composableBuilder(
    column: $table.pasifNedeni,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get pasifTarihi => $composableBuilder(
    column: $table.pasifTarihi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get olusturmaTarihi => $composableBuilder(
    column: $table.olusturmaTarihi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get guncellemeTarihi => $composableBuilder(
    column: $table.guncellemeTarihi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senkronDurumu => $composableBuilder(
    column: $table.senkronDurumu,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OrtaklarTableAnnotationComposer
    extends Composer<_$AppVeritabani, $OrtaklarTable> {
  $$OrtaklarTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ortakNo =>
      $composableBuilder(column: $table.ortakNo, builder: (column) => column);

  GeneratedColumn<String> get adSoyad =>
      $composableBuilder(column: $table.adSoyad, builder: (column) => column);

  GeneratedColumn<String> get babaAdi =>
      $composableBuilder(column: $table.babaAdi, builder: (column) => column);

  GeneratedColumn<String> get dogumYeri =>
      $composableBuilder(column: $table.dogumYeri, builder: (column) => column);

  GeneratedColumn<String> get dogumTarihiHam => $composableBuilder(
    column: $table.dogumTarihiHam,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dogumTarihi => $composableBuilder(
    column: $table.dogumTarihi,
    builder: (column) => column,
  );

  GeneratedColumn<String> get girisTarihiHam => $composableBuilder(
    column: $table.girisTarihiHam,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get girisTarihi => $composableBuilder(
    column: $table.girisTarihi,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cikisTarihiHam => $composableBuilder(
    column: $table.cikisTarihiHam,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cikisTarihi => $composableBuilder(
    column: $table.cikisTarihi,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ikametAdresi => $composableBuilder(
    column: $table.ikametAdresi,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nufusKayitYeri => $composableBuilder(
    column: $table.nufusKayitYeri,
    builder: (column) => column,
  );

  GeneratedColumn<String> get aramaAnahtari => $composableBuilder(
    column: $table.aramaAnahtari,
    builder: (column) => column,
  );

  GeneratedColumn<String> get belgeR2Anahtari => $composableBuilder(
    column: $table.belgeR2Anahtari,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ocrGuvenOrtalama => $composableBuilder(
    column: $table.ocrGuvenOrtalama,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get aktif =>
      $composableBuilder(column: $table.aktif, builder: (column) => column);

  GeneratedColumn<String> get pasifNedeni => $composableBuilder(
    column: $table.pasifNedeni,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get pasifTarihi => $composableBuilder(
    column: $table.pasifTarihi,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get olusturmaTarihi => $composableBuilder(
    column: $table.olusturmaTarihi,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get guncellemeTarihi => $composableBuilder(
    column: $table.guncellemeTarihi,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SenkronDurumu, String> get senkronDurumu =>
      $composableBuilder(
        column: $table.senkronDurumu,
        builder: (column) => column,
      );

  Expression<T> defterSatirlariRefs<T extends Object>(
    Expression<T> Function($$DefterSatirlariTableAnnotationComposer a) f,
  ) {
    final $$DefterSatirlariTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.defterSatirlari,
      getReferencedColumn: (t) => t.ortakId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DefterSatirlariTableAnnotationComposer(
            $db: $db,
            $table: $db.defterSatirlari,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OrtaklarTableTableManager
    extends
        RootTableManager<
          _$AppVeritabani,
          $OrtaklarTable,
          OrtakSatiri,
          $$OrtaklarTableFilterComposer,
          $$OrtaklarTableOrderingComposer,
          $$OrtaklarTableAnnotationComposer,
          $$OrtaklarTableCreateCompanionBuilder,
          $$OrtaklarTableUpdateCompanionBuilder,
          (OrtakSatiri, $$OrtaklarTableReferences),
          OrtakSatiri,
          PrefetchHooks Function({bool defterSatirlariRefs})
        > {
  $$OrtaklarTableTableManager(_$AppVeritabani db, $OrtaklarTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrtaklarTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrtaklarTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrtaklarTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ortakNo = const Value.absent(),
                Value<String> adSoyad = const Value.absent(),
                Value<String?> babaAdi = const Value.absent(),
                Value<String?> dogumYeri = const Value.absent(),
                Value<String?> dogumTarihiHam = const Value.absent(),
                Value<DateTime?> dogumTarihi = const Value.absent(),
                Value<String?> girisTarihiHam = const Value.absent(),
                Value<DateTime?> girisTarihi = const Value.absent(),
                Value<String?> cikisTarihiHam = const Value.absent(),
                Value<DateTime?> cikisTarihi = const Value.absent(),
                Value<String?> ikametAdresi = const Value.absent(),
                Value<String?> nufusKayitYeri = const Value.absent(),
                Value<String> aramaAnahtari = const Value.absent(),
                Value<String?> belgeR2Anahtari = const Value.absent(),
                Value<double?> ocrGuvenOrtalama = const Value.absent(),
                Value<bool> aktif = const Value.absent(),
                Value<String?> pasifNedeni = const Value.absent(),
                Value<DateTime?> pasifTarihi = const Value.absent(),
                Value<DateTime> olusturmaTarihi = const Value.absent(),
                Value<DateTime> guncellemeTarihi = const Value.absent(),
                Value<SenkronDurumu> senkronDurumu = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrtaklarCompanion(
                id: id,
                ortakNo: ortakNo,
                adSoyad: adSoyad,
                babaAdi: babaAdi,
                dogumYeri: dogumYeri,
                dogumTarihiHam: dogumTarihiHam,
                dogumTarihi: dogumTarihi,
                girisTarihiHam: girisTarihiHam,
                girisTarihi: girisTarihi,
                cikisTarihiHam: cikisTarihiHam,
                cikisTarihi: cikisTarihi,
                ikametAdresi: ikametAdresi,
                nufusKayitYeri: nufusKayitYeri,
                aramaAnahtari: aramaAnahtari,
                belgeR2Anahtari: belgeR2Anahtari,
                ocrGuvenOrtalama: ocrGuvenOrtalama,
                aktif: aktif,
                pasifNedeni: pasifNedeni,
                pasifTarihi: pasifTarihi,
                olusturmaTarihi: olusturmaTarihi,
                guncellemeTarihi: guncellemeTarihi,
                senkronDurumu: senkronDurumu,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ortakNo,
                required String adSoyad,
                Value<String?> babaAdi = const Value.absent(),
                Value<String?> dogumYeri = const Value.absent(),
                Value<String?> dogumTarihiHam = const Value.absent(),
                Value<DateTime?> dogumTarihi = const Value.absent(),
                Value<String?> girisTarihiHam = const Value.absent(),
                Value<DateTime?> girisTarihi = const Value.absent(),
                Value<String?> cikisTarihiHam = const Value.absent(),
                Value<DateTime?> cikisTarihi = const Value.absent(),
                Value<String?> ikametAdresi = const Value.absent(),
                Value<String?> nufusKayitYeri = const Value.absent(),
                required String aramaAnahtari,
                Value<String?> belgeR2Anahtari = const Value.absent(),
                Value<double?> ocrGuvenOrtalama = const Value.absent(),
                Value<bool> aktif = const Value.absent(),
                Value<String?> pasifNedeni = const Value.absent(),
                Value<DateTime?> pasifTarihi = const Value.absent(),
                required DateTime olusturmaTarihi,
                required DateTime guncellemeTarihi,
                Value<SenkronDurumu> senkronDurumu = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrtaklarCompanion.insert(
                id: id,
                ortakNo: ortakNo,
                adSoyad: adSoyad,
                babaAdi: babaAdi,
                dogumYeri: dogumYeri,
                dogumTarihiHam: dogumTarihiHam,
                dogumTarihi: dogumTarihi,
                girisTarihiHam: girisTarihiHam,
                girisTarihi: girisTarihi,
                cikisTarihiHam: cikisTarihiHam,
                cikisTarihi: cikisTarihi,
                ikametAdresi: ikametAdresi,
                nufusKayitYeri: nufusKayitYeri,
                aramaAnahtari: aramaAnahtari,
                belgeR2Anahtari: belgeR2Anahtari,
                ocrGuvenOrtalama: ocrGuvenOrtalama,
                aktif: aktif,
                pasifNedeni: pasifNedeni,
                pasifTarihi: pasifTarihi,
                olusturmaTarihi: olusturmaTarihi,
                guncellemeTarihi: guncellemeTarihi,
                senkronDurumu: senkronDurumu,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$OrtaklarTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({defterSatirlariRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (defterSatirlariRefs) db.defterSatirlari,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (defterSatirlariRefs)
                    await $_getPrefetchedData<
                      OrtakSatiri,
                      $OrtaklarTable,
                      DefterSatiriSatiri
                    >(
                      currentTable: table,
                      referencedTable: $$OrtaklarTableReferences
                          ._defterSatirlariRefsTable(db),
                      managerFromTypedResult: (p0) => $$OrtaklarTableReferences(
                        db,
                        table,
                        p0,
                      ).defterSatirlariRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.ortakId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$OrtaklarTableProcessedTableManager =
    ProcessedTableManager<
      _$AppVeritabani,
      $OrtaklarTable,
      OrtakSatiri,
      $$OrtaklarTableFilterComposer,
      $$OrtaklarTableOrderingComposer,
      $$OrtaklarTableAnnotationComposer,
      $$OrtaklarTableCreateCompanionBuilder,
      $$OrtaklarTableUpdateCompanionBuilder,
      (OrtakSatiri, $$OrtaklarTableReferences),
      OrtakSatiri,
      PrefetchHooks Function({bool defterSatirlariRefs})
    >;
typedef $$DefterSatirlariTableCreateCompanionBuilder =
    DefterSatirlariCompanion Function({
      required String id,
      required String ortakId,
      required SatirTuru tur,
      required int siraNo,
      Value<String?> tarihHam,
      Value<DateTime?> tarih,
      Value<String?> no,
      Value<String?> madde,
      Value<String?> aciklama,
      Value<int> miktarKurus,
      Value<int> yekunKurus,
      Value<String?> miktarHam,
      Value<String?> yekunHam,
      Value<int> rowid,
    });
typedef $$DefterSatirlariTableUpdateCompanionBuilder =
    DefterSatirlariCompanion Function({
      Value<String> id,
      Value<String> ortakId,
      Value<SatirTuru> tur,
      Value<int> siraNo,
      Value<String?> tarihHam,
      Value<DateTime?> tarih,
      Value<String?> no,
      Value<String?> madde,
      Value<String?> aciklama,
      Value<int> miktarKurus,
      Value<int> yekunKurus,
      Value<String?> miktarHam,
      Value<String?> yekunHam,
      Value<int> rowid,
    });

final class $$DefterSatirlariTableReferences
    extends
        BaseReferences<
          _$AppVeritabani,
          $DefterSatirlariTable,
          DefterSatiriSatiri
        > {
  $$DefterSatirlariTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $OrtaklarTable _ortakIdTable(_$AppVeritabani db) =>
      db.ortaklar.createAlias(
        $_aliasNameGenerator(db.defterSatirlari.ortakId, db.ortaklar.id),
      );

  $$OrtaklarTableProcessedTableManager get ortakId {
    final $_column = $_itemColumn<String>('ortak_id')!;

    final manager = $$OrtaklarTableTableManager(
      $_db,
      $_db.ortaklar,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ortakIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DefterSatirlariTableFilterComposer
    extends Composer<_$AppVeritabani, $DefterSatirlariTable> {
  $$DefterSatirlariTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SatirTuru, SatirTuru, String> get tur =>
      $composableBuilder(
        column: $table.tur,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get siraNo => $composableBuilder(
    column: $table.siraNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tarihHam => $composableBuilder(
    column: $table.tarihHam,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get tarih => $composableBuilder(
    column: $table.tarih,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get no => $composableBuilder(
    column: $table.no,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get madde => $composableBuilder(
    column: $table.madde,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aciklama => $composableBuilder(
    column: $table.aciklama,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get miktarKurus => $composableBuilder(
    column: $table.miktarKurus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get yekunKurus => $composableBuilder(
    column: $table.yekunKurus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get miktarHam => $composableBuilder(
    column: $table.miktarHam,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get yekunHam => $composableBuilder(
    column: $table.yekunHam,
    builder: (column) => ColumnFilters(column),
  );

  $$OrtaklarTableFilterComposer get ortakId {
    final $$OrtaklarTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ortakId,
      referencedTable: $db.ortaklar,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrtaklarTableFilterComposer(
            $db: $db,
            $table: $db.ortaklar,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DefterSatirlariTableOrderingComposer
    extends Composer<_$AppVeritabani, $DefterSatirlariTable> {
  $$DefterSatirlariTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tur => $composableBuilder(
    column: $table.tur,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get siraNo => $composableBuilder(
    column: $table.siraNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tarihHam => $composableBuilder(
    column: $table.tarihHam,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get tarih => $composableBuilder(
    column: $table.tarih,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get no => $composableBuilder(
    column: $table.no,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get madde => $composableBuilder(
    column: $table.madde,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aciklama => $composableBuilder(
    column: $table.aciklama,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get miktarKurus => $composableBuilder(
    column: $table.miktarKurus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get yekunKurus => $composableBuilder(
    column: $table.yekunKurus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get miktarHam => $composableBuilder(
    column: $table.miktarHam,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get yekunHam => $composableBuilder(
    column: $table.yekunHam,
    builder: (column) => ColumnOrderings(column),
  );

  $$OrtaklarTableOrderingComposer get ortakId {
    final $$OrtaklarTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ortakId,
      referencedTable: $db.ortaklar,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrtaklarTableOrderingComposer(
            $db: $db,
            $table: $db.ortaklar,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DefterSatirlariTableAnnotationComposer
    extends Composer<_$AppVeritabani, $DefterSatirlariTable> {
  $$DefterSatirlariTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SatirTuru, String> get tur =>
      $composableBuilder(column: $table.tur, builder: (column) => column);

  GeneratedColumn<int> get siraNo =>
      $composableBuilder(column: $table.siraNo, builder: (column) => column);

  GeneratedColumn<String> get tarihHam =>
      $composableBuilder(column: $table.tarihHam, builder: (column) => column);

  GeneratedColumn<DateTime> get tarih =>
      $composableBuilder(column: $table.tarih, builder: (column) => column);

  GeneratedColumn<String> get no =>
      $composableBuilder(column: $table.no, builder: (column) => column);

  GeneratedColumn<String> get madde =>
      $composableBuilder(column: $table.madde, builder: (column) => column);

  GeneratedColumn<String> get aciklama =>
      $composableBuilder(column: $table.aciklama, builder: (column) => column);

  GeneratedColumn<int> get miktarKurus => $composableBuilder(
    column: $table.miktarKurus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get yekunKurus => $composableBuilder(
    column: $table.yekunKurus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get miktarHam =>
      $composableBuilder(column: $table.miktarHam, builder: (column) => column);

  GeneratedColumn<String> get yekunHam =>
      $composableBuilder(column: $table.yekunHam, builder: (column) => column);

  $$OrtaklarTableAnnotationComposer get ortakId {
    final $$OrtaklarTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ortakId,
      referencedTable: $db.ortaklar,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrtaklarTableAnnotationComposer(
            $db: $db,
            $table: $db.ortaklar,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DefterSatirlariTableTableManager
    extends
        RootTableManager<
          _$AppVeritabani,
          $DefterSatirlariTable,
          DefterSatiriSatiri,
          $$DefterSatirlariTableFilterComposer,
          $$DefterSatirlariTableOrderingComposer,
          $$DefterSatirlariTableAnnotationComposer,
          $$DefterSatirlariTableCreateCompanionBuilder,
          $$DefterSatirlariTableUpdateCompanionBuilder,
          (DefterSatiriSatiri, $$DefterSatirlariTableReferences),
          DefterSatiriSatiri,
          PrefetchHooks Function({bool ortakId})
        > {
  $$DefterSatirlariTableTableManager(
    _$AppVeritabani db,
    $DefterSatirlariTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DefterSatirlariTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DefterSatirlariTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DefterSatirlariTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ortakId = const Value.absent(),
                Value<SatirTuru> tur = const Value.absent(),
                Value<int> siraNo = const Value.absent(),
                Value<String?> tarihHam = const Value.absent(),
                Value<DateTime?> tarih = const Value.absent(),
                Value<String?> no = const Value.absent(),
                Value<String?> madde = const Value.absent(),
                Value<String?> aciklama = const Value.absent(),
                Value<int> miktarKurus = const Value.absent(),
                Value<int> yekunKurus = const Value.absent(),
                Value<String?> miktarHam = const Value.absent(),
                Value<String?> yekunHam = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DefterSatirlariCompanion(
                id: id,
                ortakId: ortakId,
                tur: tur,
                siraNo: siraNo,
                tarihHam: tarihHam,
                tarih: tarih,
                no: no,
                madde: madde,
                aciklama: aciklama,
                miktarKurus: miktarKurus,
                yekunKurus: yekunKurus,
                miktarHam: miktarHam,
                yekunHam: yekunHam,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ortakId,
                required SatirTuru tur,
                required int siraNo,
                Value<String?> tarihHam = const Value.absent(),
                Value<DateTime?> tarih = const Value.absent(),
                Value<String?> no = const Value.absent(),
                Value<String?> madde = const Value.absent(),
                Value<String?> aciklama = const Value.absent(),
                Value<int> miktarKurus = const Value.absent(),
                Value<int> yekunKurus = const Value.absent(),
                Value<String?> miktarHam = const Value.absent(),
                Value<String?> yekunHam = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DefterSatirlariCompanion.insert(
                id: id,
                ortakId: ortakId,
                tur: tur,
                siraNo: siraNo,
                tarihHam: tarihHam,
                tarih: tarih,
                no: no,
                madde: madde,
                aciklama: aciklama,
                miktarKurus: miktarKurus,
                yekunKurus: yekunKurus,
                miktarHam: miktarHam,
                yekunHam: yekunHam,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DefterSatirlariTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ortakId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (ortakId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.ortakId,
                                referencedTable:
                                    $$DefterSatirlariTableReferences
                                        ._ortakIdTable(db),
                                referencedColumn:
                                    $$DefterSatirlariTableReferences
                                        ._ortakIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DefterSatirlariTableProcessedTableManager =
    ProcessedTableManager<
      _$AppVeritabani,
      $DefterSatirlariTable,
      DefterSatiriSatiri,
      $$DefterSatirlariTableFilterComposer,
      $$DefterSatirlariTableOrderingComposer,
      $$DefterSatirlariTableAnnotationComposer,
      $$DefterSatirlariTableCreateCompanionBuilder,
      $$DefterSatirlariTableUpdateCompanionBuilder,
      (DefterSatiriSatiri, $$DefterSatirlariTableReferences),
      DefterSatiriSatiri,
      PrefetchHooks Function({bool ortakId})
    >;
typedef $$IceAktarmaKuyruguTableCreateCompanionBuilder =
    IceAktarmaKuyruguCompanion Function({
      required String id,
      required String dosyaYolu,
      required String dosyaAdi,
      required String dosyaHash,
      Value<KuyrukDurumu> durum,
      Value<bool> islendi,
      Value<String?> hataMesaji,
      Value<int> denemeSayisi,
      Value<String?> olusanOrtakId,
      Value<String?> ocrHamJson,
      required DateTime eklenmeTarihi,
      Value<int> rowid,
    });
typedef $$IceAktarmaKuyruguTableUpdateCompanionBuilder =
    IceAktarmaKuyruguCompanion Function({
      Value<String> id,
      Value<String> dosyaYolu,
      Value<String> dosyaAdi,
      Value<String> dosyaHash,
      Value<KuyrukDurumu> durum,
      Value<bool> islendi,
      Value<String?> hataMesaji,
      Value<int> denemeSayisi,
      Value<String?> olusanOrtakId,
      Value<String?> ocrHamJson,
      Value<DateTime> eklenmeTarihi,
      Value<int> rowid,
    });

class $$IceAktarmaKuyruguTableFilterComposer
    extends Composer<_$AppVeritabani, $IceAktarmaKuyruguTable> {
  $$IceAktarmaKuyruguTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dosyaYolu => $composableBuilder(
    column: $table.dosyaYolu,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dosyaAdi => $composableBuilder(
    column: $table.dosyaAdi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dosyaHash => $composableBuilder(
    column: $table.dosyaHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<KuyrukDurumu, KuyrukDurumu, String>
  get durum => $composableBuilder(
    column: $table.durum,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get islendi => $composableBuilder(
    column: $table.islendi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hataMesaji => $composableBuilder(
    column: $table.hataMesaji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get denemeSayisi => $composableBuilder(
    column: $table.denemeSayisi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get olusanOrtakId => $composableBuilder(
    column: $table.olusanOrtakId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ocrHamJson => $composableBuilder(
    column: $table.ocrHamJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get eklenmeTarihi => $composableBuilder(
    column: $table.eklenmeTarihi,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IceAktarmaKuyruguTableOrderingComposer
    extends Composer<_$AppVeritabani, $IceAktarmaKuyruguTable> {
  $$IceAktarmaKuyruguTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dosyaYolu => $composableBuilder(
    column: $table.dosyaYolu,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dosyaAdi => $composableBuilder(
    column: $table.dosyaAdi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dosyaHash => $composableBuilder(
    column: $table.dosyaHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get durum => $composableBuilder(
    column: $table.durum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get islendi => $composableBuilder(
    column: $table.islendi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hataMesaji => $composableBuilder(
    column: $table.hataMesaji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get denemeSayisi => $composableBuilder(
    column: $table.denemeSayisi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get olusanOrtakId => $composableBuilder(
    column: $table.olusanOrtakId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ocrHamJson => $composableBuilder(
    column: $table.ocrHamJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get eklenmeTarihi => $composableBuilder(
    column: $table.eklenmeTarihi,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IceAktarmaKuyruguTableAnnotationComposer
    extends Composer<_$AppVeritabani, $IceAktarmaKuyruguTable> {
  $$IceAktarmaKuyruguTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dosyaYolu =>
      $composableBuilder(column: $table.dosyaYolu, builder: (column) => column);

  GeneratedColumn<String> get dosyaAdi =>
      $composableBuilder(column: $table.dosyaAdi, builder: (column) => column);

  GeneratedColumn<String> get dosyaHash =>
      $composableBuilder(column: $table.dosyaHash, builder: (column) => column);

  GeneratedColumnWithTypeConverter<KuyrukDurumu, String> get durum =>
      $composableBuilder(column: $table.durum, builder: (column) => column);

  GeneratedColumn<bool> get islendi =>
      $composableBuilder(column: $table.islendi, builder: (column) => column);

  GeneratedColumn<String> get hataMesaji => $composableBuilder(
    column: $table.hataMesaji,
    builder: (column) => column,
  );

  GeneratedColumn<int> get denemeSayisi => $composableBuilder(
    column: $table.denemeSayisi,
    builder: (column) => column,
  );

  GeneratedColumn<String> get olusanOrtakId => $composableBuilder(
    column: $table.olusanOrtakId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ocrHamJson => $composableBuilder(
    column: $table.ocrHamJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get eklenmeTarihi => $composableBuilder(
    column: $table.eklenmeTarihi,
    builder: (column) => column,
  );
}

class $$IceAktarmaKuyruguTableTableManager
    extends
        RootTableManager<
          _$AppVeritabani,
          $IceAktarmaKuyruguTable,
          IceAktarmaIsiSatiri,
          $$IceAktarmaKuyruguTableFilterComposer,
          $$IceAktarmaKuyruguTableOrderingComposer,
          $$IceAktarmaKuyruguTableAnnotationComposer,
          $$IceAktarmaKuyruguTableCreateCompanionBuilder,
          $$IceAktarmaKuyruguTableUpdateCompanionBuilder,
          (
            IceAktarmaIsiSatiri,
            BaseReferences<
              _$AppVeritabani,
              $IceAktarmaKuyruguTable,
              IceAktarmaIsiSatiri
            >,
          ),
          IceAktarmaIsiSatiri,
          PrefetchHooks Function()
        > {
  $$IceAktarmaKuyruguTableTableManager(
    _$AppVeritabani db,
    $IceAktarmaKuyruguTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IceAktarmaKuyruguTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IceAktarmaKuyruguTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IceAktarmaKuyruguTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> dosyaYolu = const Value.absent(),
                Value<String> dosyaAdi = const Value.absent(),
                Value<String> dosyaHash = const Value.absent(),
                Value<KuyrukDurumu> durum = const Value.absent(),
                Value<bool> islendi = const Value.absent(),
                Value<String?> hataMesaji = const Value.absent(),
                Value<int> denemeSayisi = const Value.absent(),
                Value<String?> olusanOrtakId = const Value.absent(),
                Value<String?> ocrHamJson = const Value.absent(),
                Value<DateTime> eklenmeTarihi = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IceAktarmaKuyruguCompanion(
                id: id,
                dosyaYolu: dosyaYolu,
                dosyaAdi: dosyaAdi,
                dosyaHash: dosyaHash,
                durum: durum,
                islendi: islendi,
                hataMesaji: hataMesaji,
                denemeSayisi: denemeSayisi,
                olusanOrtakId: olusanOrtakId,
                ocrHamJson: ocrHamJson,
                eklenmeTarihi: eklenmeTarihi,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String dosyaYolu,
                required String dosyaAdi,
                required String dosyaHash,
                Value<KuyrukDurumu> durum = const Value.absent(),
                Value<bool> islendi = const Value.absent(),
                Value<String?> hataMesaji = const Value.absent(),
                Value<int> denemeSayisi = const Value.absent(),
                Value<String?> olusanOrtakId = const Value.absent(),
                Value<String?> ocrHamJson = const Value.absent(),
                required DateTime eklenmeTarihi,
                Value<int> rowid = const Value.absent(),
              }) => IceAktarmaKuyruguCompanion.insert(
                id: id,
                dosyaYolu: dosyaYolu,
                dosyaAdi: dosyaAdi,
                dosyaHash: dosyaHash,
                durum: durum,
                islendi: islendi,
                hataMesaji: hataMesaji,
                denemeSayisi: denemeSayisi,
                olusanOrtakId: olusanOrtakId,
                ocrHamJson: ocrHamJson,
                eklenmeTarihi: eklenmeTarihi,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IceAktarmaKuyruguTableProcessedTableManager =
    ProcessedTableManager<
      _$AppVeritabani,
      $IceAktarmaKuyruguTable,
      IceAktarmaIsiSatiri,
      $$IceAktarmaKuyruguTableFilterComposer,
      $$IceAktarmaKuyruguTableOrderingComposer,
      $$IceAktarmaKuyruguTableAnnotationComposer,
      $$IceAktarmaKuyruguTableCreateCompanionBuilder,
      $$IceAktarmaKuyruguTableUpdateCompanionBuilder,
      (
        IceAktarmaIsiSatiri,
        BaseReferences<
          _$AppVeritabani,
          $IceAktarmaKuyruguTable,
          IceAktarmaIsiSatiri
        >,
      ),
      IceAktarmaIsiSatiri,
      PrefetchHooks Function()
    >;

class $AppVeritabaniManager {
  final _$AppVeritabani _db;
  $AppVeritabaniManager(this._db);
  $$OrtaklarTableTableManager get ortaklar =>
      $$OrtaklarTableTableManager(_db, _db.ortaklar);
  $$DefterSatirlariTableTableManager get defterSatirlari =>
      $$DefterSatirlariTableTableManager(_db, _db.defterSatirlari);
  $$IceAktarmaKuyruguTableTableManager get iceAktarmaKuyrugu =>
      $$IceAktarmaKuyruguTableTableManager(_db, _db.iceAktarmaKuyrugu);
}
