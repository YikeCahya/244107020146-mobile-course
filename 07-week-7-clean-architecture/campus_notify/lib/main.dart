import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/announcements/presentation/pages/announcement_page.dart';
import 'pages/home_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'messaging/push_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initLocalNotifications();

  final container = ProviderContainer();
  final authChanged = ValueNotifier<int>(0);
  container.listen(authStateProvider, (_, _) => authChanged.value++);

  final router = GoRouter(
    refreshListenable: authChanged,
    redirect: (context, state) {
      final loggedIn = container.read(authStateProvider).value ?? false;
      final goingLogin = state.matchedLocation == '/login';
      if (!loggedIn && !goingLogin) return '/login';
      if (loggedIn && goingLogin) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
      GoRoute(path: '/', builder: (_, _) => const HomePage()),
      GoRoute(
        path: '/pengumuman/:id',
        builder: (_, s) =>
            AnnouncementPage(id: s.pathParameters['id'] ?? ''),
      ),
    ],
  );

  registerBackgroundHandler();

  runApp(UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(routerConfig: router),
  ));

  requestNotificationPermission().then((granted) {
    if (!granted) return;
    initFcmToken(onToken: (token) async {
      fcmTokenPreview.value = '${token.substring(0, 12)}...';
      // Nanti, saat backend ada:
      // await dio.post('/devices', data: {'fcm_token': token, 'platform': 'android'});
    });
  });

  await container.read(authStateProvider.future);
  listenForeground(router.go);
  await handleTerminated(router.go);

}