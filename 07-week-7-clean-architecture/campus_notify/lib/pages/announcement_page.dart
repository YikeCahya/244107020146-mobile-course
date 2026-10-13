import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/announcements.dart';

class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final item = findAnnouncement(id);

    return Scaffold(
      appBar: AppBar(
        title: Text(item?.title ?? 'Pengumuman $id'),
        // Dari deep link FCM tidak ada halaman sebelumnya, jadi kembali ke Home.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: item == null
            ? const Center(child: Text('Pengumuman tidak ditemukan.'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.date, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 12),
                  Text(item.body),
                ],
              ),
      ),
    );
  }
}