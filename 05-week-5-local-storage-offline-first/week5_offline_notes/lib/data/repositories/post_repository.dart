import 'package:dio/dio.dart';

import '../models/post.dart';

class PostRepository {
  PostRepository({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://jsonplaceholder.typicode.com',
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                headers: {'Accept': 'application/json'},
              ),
            );

  final Dio _dio;

  Future<List<Post>> fetchPosts() async {
    final response = await _dio.get<List<dynamic>>('/posts');
    final data = response.data;
    if (data == null) {
      throw const FormatException('Respons API tidak berisi daftar post.');
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map(Post.fromJson)
        .toList();
  }
}
