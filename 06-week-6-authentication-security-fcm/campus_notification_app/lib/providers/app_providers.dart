import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../messaging/push_service.dart';
import '../pages/announcement_page.dart';
import '../pages/home_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/pengumuman/:id',
        builder: (context, state) => AnnouncementPage(
          id: state.pathParameters['id']!,
        ),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

final pushServiceProvider = Provider<PushService>((ref) {
  final service = PushService(router: ref.watch(routerProvider));
  ref.onDispose(service.dispose);
  return service;
});
