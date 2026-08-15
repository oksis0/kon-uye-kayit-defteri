import 'package:go_router/go_router.dart';

import '../features/arama/arama_ekrani.dart';
import '../features/ice_aktarma/kuyruk_ekrani.dart';
import '../features/ortak_detay/ortak_detay_ekrani.dart';
import '../features/ortak_detay/ortak_duzenle_ekrani.dart';

/// Faz 1-2 rotaları — auth koruması yok (Firebase Auth henüz devrede değil,
/// Faz 4'te eklenecek — PLAN.md §15).
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
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
  ],
);
