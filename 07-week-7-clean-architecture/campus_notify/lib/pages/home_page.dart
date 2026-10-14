import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:go_router/go_router.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../messaging/push_service.dart';
import '../features/announcements/presentation/pages/announcements_list.dart';

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
      body: Column(
        children: [
          const SizedBox(height: 16),
          const Text('Anda sudah login'),
          ValueListenableBuilder<String>(
            valueListenable: fcmTokenPreview,
            builder: (_, token, _) => Text('FCM token: $token'),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: topicSubscribed,
            builder: (_, on, _) => SwitchListTile(
              title: const Text('Pengumuman kampus'),
              value: on,
              onChanged: setTopicSubscription,
            ),
          ),
          const Divider(),
          const Expanded(child: AnnouncementsList()),
        ],
      ),
    );
  }
}