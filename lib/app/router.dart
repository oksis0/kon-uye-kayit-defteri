import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/config/env.dart';
import '../data/uzak/auth_servisi.dart';
import '../features/arama/arama_ekrani.dart';
import '../features/auth/giris_ekrani.dart';
import '../features/ice_aktarma/kuyruk_ekrani.dart';
import '../features/ortak_detay/ortak_detay_ekrani.dart';
import '../features/ortak_detay/ortak_duzenle_ekrani.dart';
import '../features/yedek/yedek_ekrani.dart';

part 'router.g.dart';

/// ★ Auth guard **koşullu**: `env.json` henüz doldurulmadıysa
/// (`Env.bulutYapilandirmasiTamam == false`) giriş ekranı tamamen devre
/// dışı — uygulama Faz 1-2'deki gibi doğrudan arama ekranıyla açılır.
/// Cloudflare/Firebase/Azure hesapları kurulup env.json doldurulduğunda
/// otomatik olarak devreye girer; kod değişikliği gerekmez (PLAN.md §12.5).
@riverpod
GoRouter appRouter(Ref ref) {
  if (!Env.bulutYapilandirmasiTamam) {
    return _routerOlustur(girisliMi: () => true);
  }

  final _GoRouterYenilemeAkisi authDegisimi = _GoRouterYenilemeAkisi(
    ref.watch(authServisiProvider).kullaniciDegisiklikleri,
  );
  ref.onDispose(authDegisimi.dispose);

  return _routerOlustur(
    girisliMi: () => ref.read(authServisiProvider).girisYapilmis,
    yenilemeDinleyicisi: authDegisimi,
  );
}

GoRouter _routerOlustur({
  required bool Function() girisliMi,
  Listenable? yenilemeDinleyicisi,
}) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: yenilemeDinleyicisi,
    redirect: (BuildContext context, GoRouterState state) {
      final bool girisli = girisliMi();
      final bool girisSayfasinda = state.matchedLocation == '/giris';
      if (!girisli && !girisSayfasinda) return '/giris';
      if (girisli && girisSayfasinda) return '/';
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/giris',
        builder: (context, state) => const GirisEkrani(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const AramaEkrani(),
      ),
      GoRoute(
        path: '/ortak/yeni',
        builder: (context, state) {
          final Object? extra = state.extra;
          if (extra is OrtakYeniParametreleri) {
            return OrtakDuzenleEkrani(
              iceAktarmaIsiId: extra.iceAktarmaIsiId,
              onizlemeGorselYolu: extra.onizlemeGorselYolu,
              ocrSonucu: extra.ocrSonucu,
            );
          }
          return const OrtakDuzenleEkrani();
        },
      ),
      GoRoute(
        path: '/ortak/:id',
        builder: (context, state) => OrtakDetayEkrani(ortakId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/ortak/:id/duzenle',
        builder: (context, state) =>
            OrtakDuzenleEkrani(ortakId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/ice-aktarma',
        builder: (context, state) => const KuyrukEkrani(),
      ),
      GoRoute(
        path: '/yedek',
        builder: (context, state) => const YedekEkrani(),
      ),
    ],
  );
}

/// go_router'ın bir Stream'i dinleyebilmesi için Listenable'a çeviren
/// standart köprü (go_router dokümantasyonunun önerdiği desen).
class _GoRouterYenilemeAkisi extends ChangeNotifier {
  _GoRouterYenilemeAkisi(Stream<dynamic> akis) {
    notifyListeners();
    _abonelik = akis.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _abonelik;

  @override
  void dispose() {
    _abonelik.cancel();
    super.dispose();
  }
}
