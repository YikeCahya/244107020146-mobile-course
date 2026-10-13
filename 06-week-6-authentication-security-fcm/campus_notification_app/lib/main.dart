import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'messaging/push_service.dart';
import 'providers/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  runApp(const ProviderScope(child: CampusNotificationApp()));
}

class CampusNotificationApp extends ConsumerStatefulWidget {
  const CampusNotificationApp({super.key});

  @override
  ConsumerState<CampusNotificationApp> createState() =>
      _CampusNotificationAppState();
}

class _CampusNotificationAppState extends ConsumerState<CampusNotificationApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pushServiceProvider).initialize().catchError(
        (Object error, StackTrace stackTrace) {
          debugPrint('Push initialization failed: $error\n$stackTrace');
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Campus Notification',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF174A7E)),
        useMaterial3: true,
      ),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
