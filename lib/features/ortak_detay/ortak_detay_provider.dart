import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repository/ortak_repository.dart';
import '../../domain/model/defter_satiri.dart';
import '../../domain/model/ortak.dart';

part 'ortak_detay_provider.g.dart';

@riverpod
Stream<Ortak?> ortakDetay(Ref ref, String id) {
  final OrtakRepository repo = ref.watch(ortakRepositoryProvider);
  return repo.ortakIzle(id);
}

@riverpod
Stream<List<DefterSatiri>> ortakSatirlari(Ref ref, String ortakId) {
  final OrtakRepository repo = ref.watch(ortakRepositoryProvider);
  return repo.satirlariIzle(ortakId);
}
