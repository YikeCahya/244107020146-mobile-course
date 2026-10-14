import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/announcements_providers.dart';

class AnnouncementsList extends ConsumerWidget {
  const AnnouncementsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(announcementsProvider);
    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$e'),
            TextButton(
              onPressed: () => ref.invalidate(announcementsProvider),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
      data: (items) => items.isEmpty
          ? const Center(child: Text('Belum ada pengumuman.'))
          : ListView(
              children: [
                for (final a in items)
                  ListTile(
                    title: Text(a.title),
                    subtitle: Text(a.date),
                    onTap: () => context.push('/pengumuman/${a.id}'),
                  ),
              ],
            ),
    );
  }
}