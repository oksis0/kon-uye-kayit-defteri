import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../data/repository/kuyruk_repository.dart';
import '../../data/repository/ortak_repository.dart';
import '../../domain/model/ortak.dart';
import 'widget/belge_onizleme.dart';

/// `/ortak/yeni` rotasına içe aktarma kuyruğundan gelindiğinde taşınan
/// parametreler — kuyruk öğesini bir görsel önizlemesiyle eşleştirip,
/// form kaydedildiğinde kuyruk öğesini tamamlanmış işaretlemek için
/// (PLAN.md §8).
class OrtakYeniParametreleri {
  const OrtakYeniParametreleri({
    required this.iceAktarmaIsiId,
    required this.onizlemeGorselYolu,
  });

  final String iceAktarmaIsiId;
  final String onizlemeGorselYolu;
}

/// Ortak kimlik bilgilerini elle ekleme/düzenleme formu (PLAN.md §15, Faz 1).
///
/// Sermaye/Ödeme satırları burada YOK — o yönetim detay ekranında
/// (`DefterTablosu`), çünkü satır eklemek için önce bir `ortakId` gerekiyor.
/// Yeni ortakta önce kimlik kaydedilir, sonra detay ekranından satır eklenir.
class OrtakDuzenleEkrani extends ConsumerStatefulWidget {
  const OrtakDuzenleEkrani({
    this.ortakId,
    this.onizlemeGorselYolu,
    this.iceAktarmaIsiId,
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
  final TextEditingController _nufusKayitYeriController =
      TextEditingController();

  DateTime? _dogumTarihi;
  DateTime? _girisTarihi;
  DateTime? _cikisTarihi;

  bool _yukleniyor = true;
  bool _kaydediliyor = false;

  bool get _yeniKayit => widget.ortakId == null;

  @override
  void initState() {
    super.initState();
    if (_yeniKayit) {
      _yukleniyor = false;
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
    final Ortak? ortak = await ref
        .read(ortakRepositoryProvider)
        .idIleGetir(widget.ortakId!);
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

  String? _bosIseNull(String metin) =>
      metin.trim().isEmpty ? null : metin.trim();

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

    final Ortak kaydedilen = _yeniKayit
        ? await repo.ekle(taslak)
        : await repo.guncelle(taslak);

    if (widget.iceAktarmaIsiId != null) {
      await ref
          .read(kuyrukRepositoryProvider)
          .tamamlandiIsaretle(widget.iceAktarmaIsiId!, kaydedilen.id);
    }

    if (!mounted) return;
    Navigator.of(context).pop(kaydedilen.id);
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

  @override
  Widget build(BuildContext context) {
    final String? gorselYolu = widget.onizlemeGorselYolu;

    return Scaffold(
      appBar: AppBar(title: Text(_yeniKayit ? 'Yeni Ortak' : 'Ortağı Düzenle')),
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

  Widget _form(BuildContext context) {
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
                    decoration: const InputDecoration(labelText: 'Ortak No'),
                    validator: (String? deger) =>
                        (deger == null || deger.trim().isEmpty)
                        ? 'Zorunlu alan'
                        : null,
                  ),
                ),
                SizedBox(
                  width: 320,
                  child: TextFormField(
                    controller: _adSoyadController,
                    decoration: const InputDecoration(labelText: 'Adı Soyadı'),
                    validator: (String? deger) =>
                        (deger == null || deger.trim().isEmpty)
                        ? 'Zorunlu alan'
                        : null,
                  ),
                ),
                SizedBox(
                  width: 260,
                  child: TextFormField(
                    controller: _babaAdiController,
                    decoration: const InputDecoration(labelText: 'Baba Adı'),
                  ),
                ),
                SizedBox(
                  width: 260,
                  child: TextFormField(
                    controller: _dogumYeriController,
                    decoration: const InputDecoration(labelText: 'Doğum Yeri'),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: _TarihSecici(
                    etiket: 'Doğum Tarihi',
                    deger: _dogumTarihi,
                    onDegisti: (DateTime? t) =>
                        setState(() => _dogumTarihi = t),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: _TarihSecici(
                    etiket: 'Giriş Tarihi',
                    deger: _girisTarihi,
                    onDegisti: (DateTime? t) =>
                        setState(() => _girisTarihi = t),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: _TarihSecici(
                    etiket: 'Çıkış Tarihi',
                    deger: _cikisTarihi,
                    onDegisti: (DateTime? t) =>
                        setState(() => _cikisTarihi = t),
                  ),
                ),
                SizedBox(
                  width: 420,
                  child: TextFormField(
                    controller: _ikametAdresiController,
                    decoration: const InputDecoration(
                      labelText: 'İkamet Adresi',
                    ),
                    maxLines: 2,
                  ),
                ),
                SizedBox(
                  width: 320,
                  child: TextFormField(
                    controller: _nufusKayitYeriController,
                    decoration: const InputDecoration(
                      labelText: 'Nüfusa Kayıtlı Olduğu Yer',
                    ),
                  ),
                ),
              ],
            ),
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
  const _TarihSecici({
    required this.etiket,
    required this.deger,
    required this.onDegisti,
  });

  final String etiket;
  final DateTime? deger;
  final ValueChanged<DateTime?> onDegisti;

  @override
  Widget build(BuildContext context) {
    final String metin = deger == null
        ? 'Seçilmedi'
        : DateFormat('dd.MM.yyyy', 'tr_TR').format(deger!);

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
