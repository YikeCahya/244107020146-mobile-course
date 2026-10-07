import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';
import 'models/post.dart';
import 'repositories/post_repository.dart';

const postsPageSize = 10;

final dioProvider = Provider<Dio>((ref) => createDio());

final postRepositoryProvider = Provider<PostRepository>(
  (ref) => PostRepository(ref.watch(dioProvider)),
);

class PostFeedState {
  const PostFeedState({
    this.posts = const [],
    this.page = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  final List<Post> posts;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final Object? loadMoreError;

  PostFeedState copyWith({
    List<Post>? posts,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    Object? loadMoreError,
    bool clearLoadMoreError = false,
  }) {
    return PostFeedState(
      posts: posts ?? this.posts,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreError:
          clearLoadMoreError ? null : loadMoreError ?? this.loadMoreError,
    );
  }
}

class PostFeedNotifier extends AsyncNotifier<PostFeedState> {
  @override
  Future<PostFeedState> build() async {
    final posts = await ref
        .watch(postRepositoryProvider)
        .fetchPostsPage(page: 1, limit: postsPageSize);
    return PostFeedState(
      posts: posts,
      hasMore: posts.length == postsPageSize,
    );
  }

  Future<void> loadNextPage() async {
    final current = state.asData?.value;
    if (current == null ||
        current.isLoadingMore ||
        !current.hasMore ||
        current.loadMoreError != null) {
      return;
    }

    state = AsyncData(
      current.copyWith(isLoadingMore: true, clearLoadMoreError: true),
    );
    try {
      final nextPage = current.page + 1;
      final posts = await ref
          .read(postRepositoryProvider)
          .fetchPostsPage(page: nextPage, limit: postsPageSize);
      state = AsyncData(
        current.copyWith(
          posts: [...current.posts, ...posts],
          page: nextPage,
          hasMore: posts.length == postsPageSize,
          isLoadingMore: false,
          clearLoadMoreError: true,
        ),
      );
    } catch (error) {
      state = AsyncData(current.copyWith(loadMoreError: error));
    }
  }

  Future<void> retryLoadNextPage() async {
    final current = state.asData?.value;
    if (current == null || current.isLoadingMore || !current.hasMore) return;

    state = AsyncData(current.copyWith(clearLoadMoreError: true));
    await loadNextPage();
  }
}

final postFeedProvider =
    AsyncNotifierProvider<PostFeedNotifier, PostFeedState>(
  PostFeedNotifier.new,
  retry: (retryCount, error) => null,
);
