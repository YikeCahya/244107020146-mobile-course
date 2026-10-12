import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'pages/announcement_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'providers/auth_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
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

  runApp(UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(routerConfig: router),
  ));
}