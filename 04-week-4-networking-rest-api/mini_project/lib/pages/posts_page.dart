import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/network_errors.dart';
import '../data/posts_provider.dart';
import '../widgets/post_tile.dart';

class PostsPage extends ConsumerWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postFeedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Post'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: () => ref.invalidate(postFeedProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: postsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: friendlyErrorMessage(error),
          onRetry: () => ref.invalidate(postFeedProvider),
        ),
        data: (feed) {
          if (feed.posts.isEmpty) {
            return const Center(child: Text('Belum ada post untuk ditampilkan.'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(postFeedProvider),
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.extentAfter < 300 &&
                    feed.hasMore &&
                    !feed.isLoadingMore &&
                    feed.loadMoreError == null) {
                  ref.read(postFeedProvider.notifier).loadNextPage();
                }
                return false;
              },
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: feed.posts.length + (feed.hasMore ? 1 : 0),
                separatorBuilder: (context, index) =>
                    const Divider(height: 1),
                itemBuilder: (context, index) {
                  if (index < feed.posts.length) {
                    return PostTile(post: feed.posts[index]);
                  }
                  if (feed.loadMoreError case final error?) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(friendlyErrorMessage(error)),
                          TextButton(
                            onPressed: () => ref
                                .read(postFeedProvider.notifier)
                                .retryLoadNextPage(),
                            child: const Text('Coba lagi'),
                          ),
                        ],
                      ),
                    );
                  }
                  if (feed.isLoadingMore) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: Text('Gulir untuk memuat post lainnya.')),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Coba lagi')),
          ],
        ),
      ),
    );
  }
}
