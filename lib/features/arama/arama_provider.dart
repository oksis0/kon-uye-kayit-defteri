import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repository/ortak_repository.dart';
import '../../domain/model/ortak.dart';

part 'arama_provider.g.dart';

@riverpod
class AramaSorgusu extends _$AramaSorgusu {
  @override
  String build() => '';

  void guncelle(String yeniSorgu) => state = yeniSorgu;
}

@riverpod
class PasifleriDeGoster extends _$PasifleriDeGoster {
  @override
  bool build() => false;

  void degistir(bool deger) => state = deger;
}

/// ★ Debounce yok — dataset küçük (≈2.000 kayıt), SQL sorgusu <5ms sürüyor.
/// Erken optimizasyon yapılmıyor (PLAN.md §5).
@riverpod
Stream<List<Ortak>> aramaSonuclari(Ref ref) {
  final String sorgu = ref.watch(aramaSorgusuProvider);
  final bool pasifleriDeGoster = ref.watch(pasifleriDeGosterProvider);
  final OrtakRepository repo = ref.watch(ortakRepositoryProvider);
  return repo.ara(sorgu, pasifleriDeGoster: pasifleriDeGoster);
}

/// Geniş ekranda (masaüstü) ana-detay yan yana düzeni için seçili kayıt
/// (PLAN.md §14).
@riverpod
class SeciliOrtakId extends _$SeciliOrtakId {
  @override
  String? build() => null;

  void sec(String? id) => state = id;
}
