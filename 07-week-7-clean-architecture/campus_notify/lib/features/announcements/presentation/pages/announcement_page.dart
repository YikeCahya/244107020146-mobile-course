import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/announcements_providers.dart';

class AnnouncementPage extends ConsumerWidget {
  const AnnouncementPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(announcementByIdProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: Text(state.value?.title ?? 'Pengumuman $id'),
        // Dari deep link FCM tidak ada halaman sebelumnya, jadi kembali ke Home.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (item) => item == null
              ? const Center(child: Text('Pengumuman tidak ditemukan.'))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.date,
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 12),
                    Text(item.body),
                  ],
                ),
        ),
      ),
    );
  }
}