import 'package:dio/dio.dart';

import '../models/post.dart';

class PostRepository {
  const PostRepository(this._dio);

  final Dio _dio;

  Future<List<Post>> fetchPostsPage({
    required int page,
    int limit = 10,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/posts',
      queryParameters: {'_page': page, '_limit': limit},
    );
    final data = response.data;
    if (data == null) {
      throw const FormatException('Respons daftar post kosong.');
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(Post.fromJson)
        .toList();
  }
}
