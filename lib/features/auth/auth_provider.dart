import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/uzak/auth_servisi.dart';

part 'auth_provider.g.dart';

/// Giriş ekranındaki buton/form durumu (yükleniyor/hata) — [AuthServisi]'nin
/// kendisinden ayrı tutuluyor çünkü bu tamamen UI'a özgü, geçici bir durum.
@riverpod
class GirisIslemi extends _$GirisIslemi {
  @override
  AsyncValue<void> build() => const AsyncValue<void>.data(null);

  Future<void> girisYap({required String ePosta, required String sifre}) async {
    state = const AsyncValue<void>.loading();
    state = await AsyncValue.guard(
      () => ref.read(authServisiProvider).girisYap(ePosta: ePosta, sifre: sifre),
    );
  }
}
