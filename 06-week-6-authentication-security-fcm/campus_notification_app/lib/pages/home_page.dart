import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/app_providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pushService = ref.watch(pushServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Campus Notification')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Icon(Icons.campaign_outlined, size: 64),
          const SizedBox(height: 16),
          Text(
            'Pengumuman Kampus',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<String>(
            valueListenable: pushService.status,
            builder: (context, status, _) =>
                Text(status, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () async {
              try {
                final granted = await pushService.requestPermission();
                if (granted) await pushService.getToken();
              } catch (error) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal mengaktifkan notifikasi: $error'),
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.notifications_active_outlined),
            label: const Text('Minta izin dan daftarkan perangkat'),
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<bool>(
            valueListenable: pushService.isSubscribed,
            builder: (context, isSubscribed, _) => OutlinedButton.icon(
              onPressed: () async {
                try {
                  if (isSubscribed) {
                    await pushService.unsubscribeFromAnnouncements();
                  } else {
                    await pushService.subscribeToAnnouncements();
                  }
                } catch (error) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal mengubah langganan: $error'),
                      ),
                    );
                  }
                }
              },
              icon: Icon(
                isSubscribed
                    ? Icons.notifications_off_outlined
                    : Icons.campaign,
              ),
              label: Text(
                isSubscribed
                    ? 'Berhenti dari pengumuman kampus'
                    : 'Ikuti pengumuman kampus',
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.go('/pengumuman/3'),
            child: const Text('Buka contoh detail pengumuman'),
          ),
        ],
      ),
    );
  }
}
