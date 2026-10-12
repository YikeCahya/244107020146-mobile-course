import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../messaging/push_service.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Notify'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Anda sudah login'),
            ValueListenableBuilder<String>(
              valueListenable: fcmTokenPreview,
              builder: (_, token, _) => Text('FCM token: $token'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go('/pengumuman/3'),
              child: const Text('Buka pengumuman 3'),
            ),
          ],
        ),
      ),
    );
  }
}