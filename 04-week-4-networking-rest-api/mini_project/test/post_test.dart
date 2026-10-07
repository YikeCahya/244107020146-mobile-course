import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_project/data/models/post.dart';
import 'package:mini_project/data/network_errors.dart';
import 'package:mini_project/data/posts_provider.dart';
import 'package:mini_project/data/repositories/post_repository.dart';

class FakePostRepository extends PostRepository {
  FakePostRepository({this.items = const [], this.error}) : super(Dio());

  final List<Post> items;
  final Object? error;
  final requestedPages = <int>[];
  final requestedLimits = <int>[];

  @override
  Future<List<Post>> fetchPostsPage({
    required int page,
    int limit = postsPageSize,
  }) async {
    requestedPages.add(page);
    requestedLimits.add(limit);
    if (error case final error?) throw error;
    return items;
  }
}

void main() {
  test('Post.fromJson aman untuk nilai null dan tipe yang salah', () {
    final post = Post.fromJson({
      'id': 7,
      'userId': null,
      'title': 123,
      'body': null,
    });

    expect(post.id, 7);
    expect(post.userId, 0);
    expect(post.title, '');
    expect(post.body, '');
  });

  test('friendlyErrorMessage memetakan connection error', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/posts'),
      type: DioExceptionType.connectionError,
    );

    expect(friendlyErrorMessage(error), contains('terhubung'));
  });

  test(
    'provider menggunakan repository palsu tanpa request jaringan',
    () async {
      final fakeRepository = FakePostRepository(
        items: const [
          Post(userId: 1, id: 1, title: 'Post palsu', body: 'Isi post'),
        ],
      );
      final container = ProviderContainer(
        overrides: [postRepositoryProvider.overrideWithValue(fakeRepository)],
      );
      addTearDown(container.dispose);

      final feed = await container.read(postFeedProvider.future);

      expect(feed.posts.single.title, 'Post palsu');
      expect(fakeRepository.requestedPages, [1]);
      expect(fakeRepository.requestedLimits, [postsPageSize]);
    },
  );

  test('pagination memakai 10 item dan mengabaikan request ganda', () async {
    final fakeRepository = FakePostRepository(
      items: List.generate(
        postsPageSize,
        (index) => Post(
          userId: 1,
          id: index + 1,
          title: 'Post ${index + 1}',
          body: 'Isi',
        ),
      ),
    );
    final container = ProviderContainer(
      overrides: [postRepositoryProvider.overrideWithValue(fakeRepository)],
    );
    addTearDown(container.dispose);
    final notifier = container.read(postFeedProvider.notifier);
    await container.read(postFeedProvider.future);

    await Future.wait([notifier.loadNextPage(), notifier.loadNextPage()]);

    expect(fakeRepository.requestedPages, [1, 2]);
    expect(fakeRepository.requestedLimits, [postsPageSize, postsPageSize]);
    expect(container.read(postFeedProvider).requireValue.posts, hasLength(20));
  });
}
