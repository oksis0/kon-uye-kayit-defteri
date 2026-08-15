import 'package:freezed_annotation/freezed_annotation.dart';

import '../enum/satir_turu.dart';

part 'defter_satiri.freezed.dart';

/// Sermaye Yüklenmeleri ve Ödemeler tablolarının tek ortak satır modeli.
///
/// ★ Para alanları `double` değil `int` (kuruş) — `0.1 + 0.2 == 0.30000...4`
/// gibi ikili kayan nokta hatalarının bir muhasebe defterinde toplamları
/// bozmasını önlemek için (PLAN.md §4.2).
@freezed
abstract class DefterSatiri with _$DefterSatiri {
  const factory DefterSatiri({
    required String id,
    required String ortakId,
    required SatirTuru tur,
    required int siraNo,
    String? tarihHam,
    DateTime? tarih,
    String? no,
    String? madde,
    String? aciklama,
    @Default(0) int miktarKurus,
    @Default(0) int yekunKurus,
    String? miktarHam,
    String? yekunHam,
  }) = _DefterSatiri;
}
