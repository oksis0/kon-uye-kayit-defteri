import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/config/env.dart';
import '../../data/goruntu/goruntu_hazirlayici.dart';
import '../../data/repository/belge_repository.dart';
import '../../data/repository/kuyruk_repository.dart';
import '../../data/repository/ortak_repository.dart';
import '../../domain/enum/satir_turu.dart';
import '../../domain/model/defter_satiri.dart';
import '../../domain/model/ocr_sonucu.dart';
import '../../domain/model/ortak.dart';
import 'widget/belge_onizleme.dart';
import 'widget/defter_tablosu.dart';

const Uuid _uuid = Uuid();

/// `/ortak/yeni` rotasına içe aktarma kuyruğundan gelindiğinde taşınan
/// parametreler (PLAN.md §8).
///
/// ★ Bu ekran aynı zamanda "İnceleme Ekranı"nın rolünü üstleniyor
/// (PLAN.md §7.3) — ayrı bir dosya açmak yerine bilinçli bir birleştirme:
/// [ocrSonucu] `null` ise Faz 1-2'deki boş elle-doldurma formu, dolu ise
/// OCR ön-doldurmalı inceleme formu olarak çalışır. İki panelli düzen,
/// yinelenen-kayıt kontrolü ve kaydetme akışı ikisinde de birebir aynı —
/// ayrı dosyalarda bu makineyi iki kez yazmak gereksiz kod tekrarı olurdu.
class OrtakYeniParametreleri {
  const OrtakYeniParametreleri({
    required this.iceAktarmaIsiId,
    required this.onizlemeGorselYolu,
    this.ocrSonucu,
  });

  final String iceAktarmaIsiId;
  final String onizlemeGorselYolu;

  /// Dolu ise form OCR sonuçlarıyla ön-doldurulur ve güven skoruna göre
  /// renklendirilir (PLAN.md §7.3). `null` ise (bulut yapılandırılmamışsa)
  /// tamamen boş form — Faz 1-2 davranışı.
  final OcrSonucu? ocrSonucu;
}

/// Ortak kimlik bilgilerini ekleme/düzenleme formu — hem elle giriş
/// (PLAN.md §15 Faz 1) hem OCR onay ekranı (§7.3) olarak çalışır.
class OrtakDuzenleEkrani extends ConsumerStatefulWidget {
  const OrtakDuzenleEkrani({
    this.ortakId,
    this.onizlemeGorselYolu,
    this.iceAktarmaIsiId,
    this.ocrSonucu,
    super.key,
  });

  /// `null` ise yeni ortak ekleme modu.
  final String? ortakId;

  /// İçe aktarma kuyruğundan açıldıysa (PLAN.md §8) — dolu ise ekran
  /// görsel+form iki panelli düzene geçer (PLAN.md §14).
  final String? onizlemeGorselYolu;

  /// Dolu ise, kayıt başarıyla tamamlandığında bu kuyruk öğesi de
  /// otomatik olarak "tamamlandı" işaretlenir.
  final String? iceAktarmaIsiId;

  /// Dolu ise form bu OCR sonucuyla ön-doldurulur (PLAN.md §7.3).
  final OcrSonucu? ocrSonucu;

  @override
  ConsumerState<OrtakDuzenleEkrani> createState() => _OrtakDuzenleEkraniState();
}

class _OrtakDuzenleEkraniState extends ConsumerState<OrtakDuzenleEkrani> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _ortakNoController = TextEditingController();
  final TextEditingController _adSoyadController = TextEditingController();
  final TextEditingController _babaAdiController = TextEditingController();
  final TextEditingController _dogumYeriController = TextEditingController();
  final TextEditingController _ikametAdresiController = TextEditingController();
  final TextEditingController _nufusKayitYeriController = TextEditingController();

  DateTime? _dogumTarihi;
  DateTime? _girisTarihi;
  DateTime? _cikisTarihi;

  /// OCR'dan gelen veya kullanıcının kuyruk akışında elle eklediği satırlar
  /// — henüz bir `ortakId` olmadığı için Drift'e değil, burada bellekte
  /// tutulur; form kaydedilince tek seferde persist edilir.
  List<DefterSatiri> _sermayeSatirlari = <DefterSatiri>[];
  List<DefterSatiri> _odemeSatirlari = <DefterSatiri>[];

  bool _yukleniyor = true;
  bool _kaydediliyor = false;

  bool get _yeniKayit => widget.ortakId == null;

  @override
  void initState() {
    super.initState();
    if (_yeniKayit) {
      _yukleniyor = false;
      final OcrSonucu? ocr = widget.ocrSonucu;
      if (ocr != null) _ocrIleOnDoldur(ocr);
    } else {
      _mevcutVeriyiYukle();
    }
  }

  @override
  void dispose() {
    _ortakNoController.dispose();
    _adSoyadController.dispose();
    _babaAdiController.dispose();
    _dogumYeriController.dispose();
    _ikametAdresiController.dispose();
    _nufusKayitYeriController.dispose();
    super.dispose();
  }

  Future<void> _mevcutVeriyiYukle() async {
    final Ortak? ortak = await ref.read(ortakRepositoryProvider).idIleGetir(widget.ortakId!);
    if (ortak != null) _formuDoldur(ortak);
    if (mounted) setState(() => _yukleniyor = false);
  }

  void _formuDoldur(Ortak ortak) {
    _ortakNoController.text = ortak.ortakNo;
    _adSoyadController.text = ortak.adSoyad;
    _babaAdiController.text = ortak.babaAdi ?? '';
    _dogumYeriController.text = ortak.dogumYeri ?? '';
    _ikametAdresiController.text = ortak.ikametAdresi ?? '';
    _nufusKayitYeriController.text = ortak.nufusKayitYeri ?? '';
    _dogumTarihi = ortak.dogumTarihi;
    _girisTarihi = ortak.girisTarihi;
    _cikisTarihi = ortak.cikisTarihi;
  }

  /// "İnsan yazar, OCR ön-doldurur" — hiçbir alan zorunlu değil, kullanıcı
  /// her şeyi değiştirebilir (PLAN.md §7.2).
  void _ocrIleOnDoldur(OcrSonucu ocr) {
    _ortakNoController.text = ocr.ortakNo?.metin ?? '';
    _adSoyadController.text = ocr.adSoyad?.metin ?? '';
    _babaAdiController.text = ocr.babaAdi?.metin ?? '';
    _dogumYeriController.text = ocr.dogumYeri?.metin ?? '';
    _ikametAdresiController.text = ocr.ikametAdresi?.metin ?? '';
    _nufusKayitYeriController.text = ocr.nufusKayitYeri?.metin ?? '';
    _sermayeSatirlari = List<DefterSatiri>.of(ocr.sermayeSatirlari);
    _odemeSatirlari = List<DefterSatiri>.of(ocr.odemeSatirlari);
    // Tarih alanları (dogumTarihi vb.) OCR ham metni parse edilmediği için
    // burada boş bırakılıyor — kullanıcı elle seçer. Ham metin ileride bir
    // tarih ayrıştırıcı eklendiğinde (core/util/tarih_ayikla.dart, Faz 10+)
    // buraya bağlanabilir.
  }

  String? _bosIseNull(String metin) => metin.trim().isEmpty ? null : metin.trim();

  Future<void> _kaydet() async {
    if (!_formKey.currentState!.validate()) return;

    final OrtakRepository repo = ref.read(ortakRepositoryProvider);
    final String ortakNo = _ortakNoController.text.trim();

    if (_yeniKayit) {
      final Ortak? mevcut = await repo.ortakNoIleKontrolEt(ortakNo);
      if (mevcut != null && mounted) {
        final bool? devamEt = await _yinelenenOrtakUyarisiGoster(mevcut);
        if (devamEt != true) return;
      }
    }
    if (!mounted) return;

    setState(() => _kaydediliyor = true);

    final DateTime simdi = DateTime.now();
    final Ortak taslak = Ortak(
      id: widget.ortakId ?? '',
      ortakNo: ortakNo,
      adSoyad: _adSoyadController.text.trim(),
      babaAdi: _bosIseNull(_babaAdiController.text),
      dogumYeri: _bosIseNull(_dogumYeriController.text),
      dogumTarihi: _dogumTarihi,
      girisTarihi: _girisTarihi,
      cikisTarihi: _cikisTarihi,
      ikametAdresi: _bosIseNull(_ikametAdresiController.text),
      nufusKayitYeri: _bosIseNull(_nufusKayitYeriController.text),
      aramaAnahtari: '', // repository hesaplar
      olusturmaTarihi: simdi,
      guncellemeTarihi: simdi,
    );

    Ortak kaydedilen = _yeniKayit ? await repo.ekle(taslak) : await repo.guncelle(taslak);

    if (widget.iceAktarmaIsiId != null) {
      for (final DefterSatiri satir in <DefterSatiri>[..._sermayeSatirlari, ..._odemeSatirlari]) {
        await repo.satirEkle(satir.copyWith(ortakId: kaydedilen.id));
      }
      kaydedilen = await _belgeYukleVeGuncelle(kaydedilen) ?? kaydedilen;
      await ref
          .read(kuyrukRepositoryProvider)
          .tamamlandiIsaretle(widget.iceAktarmaIsiId!, kaydedilen.id);
    }

    if (!mounted) return;
    Navigator.of(context).pop(kaydedilen.id);
  }

  /// Görseli R2'ye yükler — kullanıcı ONAYLADIKTAN SONRA (PLAN.md §2.2, §8).
  /// Bulut yapılandırılmamışsa veya görsel yoksa sessizce atlanır (Faz 1-2
  /// davranışı bozulmaz). Yükleme başarısız olsa bile kayıt zaten yerelde
  /// var — kullanıcıya bilgi verilir ama akış durdurulmaz.
  Future<Ortak?> _belgeYukleVeGuncelle(Ortak kaydedilenOrtak) async {
    final String? gorselYolu = widget.onizlemeGorselYolu;
    if (!Env.bulutYapilandirmasiTamam || gorselYolu == null) return null;

    try {
      final HazirlanmisGorsel hazir = await GoruntuHazirlayici().hazirla(gorselYolu);
      final BelgeRepository belgeRepo = ref.read(belgeRepositoryProvider);
      final String anahtar = belgeRepo.anahtarUret(kaydedilenOrtak.id);
      await belgeRepo.yukle(anahtar, hazir.veriler);

      final Ortak guncellenmis = kaydedilenOrtak.copyWith(
        belgeR2Anahtari: anahtar,
        ocrGuvenOrtalama: _ocrGuvenOrtalamasiHesapla(),
      );
      return ref.read(ortakRepositoryProvider).guncelle(guncellenmis);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kayıt yerel olarak kaydedildi ama belge yüklenemedi: $e')),
        );
      }
      return null;
    }
  }

  double? _ocrGuvenOrtalamasiHesapla() {
    final OcrSonucu? ocr = widget.ocrSonucu;
    if (ocr == null) return null;
    final List<double> guvenler = <double>[
      for (final OcrAlan? alan in <OcrAlan?>[
        ocr.ortakNo,
        ocr.adSoyad,
        ocr.babaAdi,
        ocr.dogumYeri,
        ocr.dogumTarihi,
        ocr.girisTarihi,
        ocr.cikisTarihi,
        ocr.ikametAdresi,
        ocr.nufusKayitYeri,
      ])
        if (alan != null) alan.guven,
    ];
    if (guvenler.isEmpty) return null;
    return guvenler.reduce((double a, double b) => a + b) / guvenler.length;
  }

  Future<bool?> _yinelenenOrtakUyarisiGoster(Ortak mevcut) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Bu ortak no zaten kayıtlı'),
        content: Text(
          'Ortak No "${mevcut.ortakNo}" zaten "${mevcut.adSoyad}" adına kayıtlı '
          '(PLAN.md §7.4). Yine de yeni bir kayıt olarak eklemek istiyor musunuz?',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Yine de Ekle'),
          ),
        ],
      ),
    );
  }

  void _satirKaydet(SatirTuru tur, DefterSatiri satir) {
    setState(() {
      final List<DefterSatiri> liste = tur == SatirTuru.sermaye ? _sermayeSatirlari : _odemeSatirlari;
      final DefterSatiri satirIdli = satir.id.isEmpty ? satir.copyWith(id: _uuid.v4()) : satir;
      final int index = liste.indexWhere((DefterSatiri s) => s.id == satirIdli.id);
      if (index == -1) {
        liste.add(satirIdli);
      } else {
        liste[index] = satirIdli;
      }
    });
  }

  void _satirSil(SatirTuru tur, String id) {
    setState(() {
      (tur == SatirTuru.sermaye ? _sermayeSatirlari : _odemeSatirlari)
          .removeWhere((DefterSatiri s) => s.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final String? gorselYolu = widget.onizlemeGorselYolu;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.ocrSonucu != null
              ? 'OCR Sonucunu Onayla'
              : (_yeniKayit ? 'Yeni Ortak' : 'Ortağı Düzenle'),
        ),
      ),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : gorselYolu == null
          ? _form(context)
          : Row(
              children: <Widget>[
                Expanded(child: BelgeOnizleme(dosyaYolu: gorselYolu)),
                VerticalDivider(width: 1, color: context.renkler.border),
                Expanded(child: _form(context)),
              ],
            ),
    );
  }

  InputDecoration _alanDekorasyonu(BuildContext context, String etiket, OcrAlan? alan) {
    if (alan == null) return InputDecoration(labelText: etiket);

    final AppColors renkler = context.renkler;
    final Color renk = alan.guven >= 0.9
        ? renkler.border
        : (alan.guven >= 0.7 ? renkler.warning : renkler.error);

    return InputDecoration(
      labelText: etiket,
      suffixIcon: Tooltip(
        message: 'OCR güveni: %${(alan.guven * 100).round()} — kontrol edin',
        child: Icon(Icons.auto_awesome, size: 16, color: renk),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: renk, width: renk == renkler.border ? 1 : 1.5),
      ),
    );
  }

  Widget _form(BuildContext context) {
    final OcrSonucu? ocr = widget.ocrSonucu;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: <Widget>[
                SizedBox(
                  width: 180,
                  child: TextFormField(
                    controller: _ortakNoController,
                    decoration: _alanDekorasyonu(context, 'Ortak No', ocr?.ortakNo),
                    validator: (String? deger) =>
                        (deger == null || deger.trim().isEmpty) ? 'Zorunlu alan' : null,
                  ),
                ),
                SizedBox(
                  width: 320,
                  child: TextFormField(
                    controller: _adSoyadController,
                    decoration: _alanDekorasyonu(context, 'Adı Soyadı', ocr?.adSoyad),
                    validator: (String? deger) =>
                        (deger == null || deger.trim().isEmpty) ? 'Zorunlu alan' : null,
                  ),
                ),
                SizedBox(
                  width: 260,
                  child: TextFormField(
                    controller: _babaAdiController,
                    decoration: _alanDekorasyonu(context, 'Baba Adı', ocr?.babaAdi),
                  ),
                ),
                SizedBox(
                  width: 260,
                  child: TextFormField(
                    controller: _dogumYeriController,
                    decoration: _alanDekorasyonu(context, 'Doğum Yeri', ocr?.dogumYeri),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: _TarihSecici(
                    etiket: 'Doğum Tarihi',
                    deger: _dogumTarihi,
                    onDegisti: (DateTime? t) => setState(() => _dogumTarihi = t),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: _TarihSecici(
                    etiket: 'Giriş Tarihi',
                    deger: _girisTarihi,
                    onDegisti: (DateTime? t) => setState(() => _girisTarihi = t),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: _TarihSecici(
                    etiket: 'Çıkış Tarihi',
                    deger: _cikisTarihi,
                    onDegisti: (DateTime? t) => setState(() => _cikisTarihi = t),
                  ),
                ),
                SizedBox(
                  width: 420,
                  child: TextFormField(
                    controller: _ikametAdresiController,
                    decoration: _alanDekorasyonu(context, 'İkamet Adresi', ocr?.ikametAdresi),
                    maxLines: 2,
                  ),
                ),
                SizedBox(
                  width: 320,
                  child: TextFormField(
                    controller: _nufusKayitYeriController,
                    decoration: _alanDekorasyonu(
                      context,
                      'Nüfusa Kayıtlı Olduğu Yer',
                      ocr?.nufusKayitYeri,
                    ),
                  ),
                ),
              ],
            ),
            if (widget.iceAktarmaIsiId != null) ...<Widget>[
              const SizedBox(height: AppSpacing.xl),
              DefterTablosu(
                tur: SatirTuru.sermaye,
                satirlar: _sermayeSatirlari,
                onSatirKaydet: (DefterSatiri s) => _satirKaydet(SatirTuru.sermaye, s),
                onSatirSil: (String id) => _satirSil(SatirTuru.sermaye, id),
              ),
              const SizedBox(height: AppSpacing.xl),
              DefterTablosu(
                tur: SatirTuru.odeme,
                satirlar: _odemeSatirlari,
                onSatirKaydet: (DefterSatiri s) => _satirKaydet(SatirTuru.odeme, s),
                onSatirSil: (String id) => _satirSil(SatirTuru.odeme, id),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: _kaydediliyor ? null : _kaydet,
              child: _kaydediliyor
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarihSecici extends StatelessWidget {
  const _TarihSecici({required this.etiket, required this.deger, required this.onDegisti});

  final String etiket;
  final DateTime? deger;
  final ValueChanged<DateTime?> onDegisti;

  @override
  Widget build(BuildContext context) {
    final String metin =
        deger == null ? 'Seçilmedi' : DateFormat('dd.MM.yyyy', 'tr_TR').format(deger!);

    return InkWell(
      onTap: () async {
        final DateTime? secilen = await showDatePicker(
          context: context,
          initialDate: deger ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (secilen != null) onDegisti(secilen);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: etiket,
          suffixIcon: deger != null
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => onDegisti(null),
                )
              : const Icon(Icons.calendar_today_outlined, size: 18),
        ),
        child: Text(metin),
      ),
    );
  }
}
