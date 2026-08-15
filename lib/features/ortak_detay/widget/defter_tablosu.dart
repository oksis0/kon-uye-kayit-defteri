import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../domain/enum/satir_turu.dart';
import '../../../domain/model/defter_satiri.dart';

/// Sermaye Yüklenmeleri / Ödemeler tablosu. Satır ekleme/düzenleme/silme
/// burada — inceleme (OCR onay) ekranındaki iki panelli tam sürüm Faz 6'da
/// gelecek; bu, elle veri girişi için yalın sürüm (PLAN.md §15, Faz 1).
class DefterTablosu extends StatelessWidget {
  const DefterTablosu({
    required this.tur,
    required this.satirlar,
    required this.onSatirKaydet,
    required this.onSatirSil,
    super.key,
  });

  final SatirTuru tur;
  final List<DefterSatiri> satirlar;
  final ValueChanged<DefterSatiri> onSatirKaydet;
  final ValueChanged<String> onSatirSil;

  static final NumberFormat _paraFormat = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 2,
  );

  static String paraGoster(int kurus) => _paraFormat.format(kurus / 100);

  @override
  Widget build(BuildContext context) {
    final AppColors renkler = context.renkler;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(tur.etiket, style: AppTypography.title.copyWith(color: renkler.textPrimary)),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _satirDialoguAc(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Satır Ekle'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (satirlar.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Text(
              'Henüz satır eklenmedi.',
              style: AppTypography.caption.copyWith(color: renkler.textSecondary),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: renkler.border),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: DataTable(
                headingRowColor: WidgetStatePropertyAll<Color>(renkler.surfaceContainer),
                columns: const <DataColumn>[
                  DataColumn(label: Text('Tarih')),
                  DataColumn(label: Text('No')),
                  DataColumn(label: Text('Mad.')),
                  DataColumn(label: Text('Açıklama')),
                  DataColumn(label: Text('Miktar'), numeric: true),
                  DataColumn(label: Text('Yekün'), numeric: true),
                  DataColumn(label: Text('')),
                ],
                rows: <DataRow>[
                  for (final DefterSatiri satir in satirlar)
                    DataRow(
                      cells: <DataCell>[
                        DataCell(Text(satir.tarihHam ?? '—')),
                        DataCell(Text(satir.no ?? '—')),
                        DataCell(Text(satir.madde ?? '—')),
                        DataCell(Text(satir.aciklama ?? '—')),
                        DataCell(Text(paraGoster(satir.miktarKurus), style: AppTypography.sayisalTablo.copyWith(color: renkler.textPrimary))),
                        DataCell(Text(paraGoster(satir.yekunKurus), style: AppTypography.sayisalTablo.copyWith(color: renkler.textPrimary))),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                onPressed: () => _satirDialoguAc(context, mevcutSatir: satir),
                                tooltip: 'Düzenle',
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_outline, size: 18, color: renkler.error),
                                onPressed: () => onSatirSil(satir.id),
                                tooltip: 'Sil',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _satirDialoguAc(BuildContext context, {DefterSatiri? mevcutSatir}) async {
    final DefterSatiri? sonuc = await showDialog<DefterSatiri>(
      context: context,
      builder: (BuildContext context) => _SatirDuzenleDialogu(
        tur: tur,
        siraNo: mevcutSatir?.siraNo ?? satirlar.length,
        mevcutSatir: mevcutSatir,
      ),
    );
    if (sonuc != null) onSatirKaydet(sonuc);
  }
}

class _SatirDuzenleDialogu extends StatefulWidget {
  const _SatirDuzenleDialogu({
    required this.tur,
    required this.siraNo,
    this.mevcutSatir,
  });

  final SatirTuru tur;
  final int siraNo;
  final DefterSatiri? mevcutSatir;

  @override
  State<_SatirDuzenleDialogu> createState() => _SatirDuzenleDialoguState();
}

class _SatirDuzenleDialoguState extends State<_SatirDuzenleDialogu> {
  late final TextEditingController _tarihController;
  late final TextEditingController _noController;
  late final TextEditingController _maddeController;
  late final TextEditingController _aciklamaController;
  late final TextEditingController _miktarController;
  late final TextEditingController _yekunController;

  @override
  void initState() {
    super.initState();
    final DefterSatiri? s = widget.mevcutSatir;
    _tarihController = TextEditingController(text: s?.tarihHam ?? '');
    _noController = TextEditingController(text: s?.no ?? '');
    _maddeController = TextEditingController(text: s?.madde ?? '');
    _aciklamaController = TextEditingController(text: s?.aciklama ?? '');
    _miktarController = TextEditingController(text: s == null ? '' : (s.miktarKurus / 100).toString());
    _yekunController = TextEditingController(text: s == null ? '' : (s.yekunKurus / 100).toString());
  }

  @override
  void dispose() {
    _tarihController.dispose();
    _noController.dispose();
    _maddeController.dispose();
    _aciklamaController.dispose();
    _miktarController.dispose();
    _yekunController.dispose();
    super.dispose();
  }

  int _tlToKurus(String metin) {
    final double? deger = double.tryParse(metin.replaceAll(',', '.'));
    if (deger == null) return 0;
    return (deger * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.mevcutSatir == null ? 'Satır Ekle' : 'Satırı Düzenle'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(controller: _tarihController, decoration: const InputDecoration(labelText: 'Tarih')),
            const SizedBox(height: AppSpacing.sm),
            TextField(controller: _noController, decoration: const InputDecoration(labelText: 'No')),
            const SizedBox(height: AppSpacing.sm),
            TextField(controller: _maddeController, decoration: const InputDecoration(labelText: 'Madde')),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _aciklamaController,
              decoration: const InputDecoration(labelText: 'Açıklama'),
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _miktarController,
                    decoration: const InputDecoration(labelText: 'Miktar (₺)'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: _yekunController,
                    decoration: const InputDecoration(labelText: 'Yekün (₺)'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('İptal')),
        FilledButton(
          onPressed: () {
            final DefterSatiri satir = DefterSatiri(
              id: widget.mevcutSatir?.id ?? '',
              ortakId: widget.mevcutSatir?.ortakId ?? '',
              tur: widget.tur,
              siraNo: widget.siraNo,
              tarihHam: _tarihController.text.trim().isEmpty ? null : _tarihController.text.trim(),
              no: _noController.text.trim().isEmpty ? null : _noController.text.trim(),
              madde: _maddeController.text.trim().isEmpty ? null : _maddeController.text.trim(),
              aciklama: _aciklamaController.text.trim().isEmpty ? null : _aciklamaController.text.trim(),
              miktarKurus: _tlToKurus(_miktarController.text),
              yekunKurus: _tlToKurus(_yekunController.text),
            );
            Navigator.of(context).pop(satir);
          },
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}
