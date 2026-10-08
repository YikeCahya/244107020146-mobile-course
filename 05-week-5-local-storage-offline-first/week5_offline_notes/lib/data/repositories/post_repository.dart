import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';

import '../local/db.dart';
import '../models/post.dart';

class PostRepository {
  PostRepository({
    Dio? dio,
    Future<Database> Function()? openDb,
  })  : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://jsonplaceholder.typicode.com',
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                headers: {'Accept': 'application/json'},
              ),
            ),
        _openDb = openDb ?? openNotesDb;

  final Dio _dio;
  final Future<Database> Function() _openDb;

  Future<List<Post>> readCachedPosts() async {
    final db = await _openDb();
    final rows = await db.query('cached_posts', orderBy: 'id ASC');
    return rows.map((row) {
      final data = jsonDecode(row['payload'] as String);
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Data cache post tidak valid.');
      }
      return Post.fromJson(data);
    }).toList();
  }

  Future<List<Post>> refreshPosts() async {
    final response = await _dio.get<List<dynamic>>('/posts');
    final data = response.data;
    if (data == null) {
      throw const FormatException('Respons API tidak berisi daftar post.');
    }

    final posts = data
        .whereType<Map<String, dynamic>>()
        .map(Post.fromJson)
        .toList();
    final db = await _openDb();
    await db.transaction((txn) async {
      await txn.delete('cached_posts');
      final batch = txn.batch();
      final cachedAt = DateTime.now().toIso8601String();
      for (final post in posts) {
        batch.insert(
          'cached_posts',
          {
            'id': post.id,
            'payload': jsonEncode(post.toJson()),
            'cached_at': cachedAt,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
    return posts;
  }
}
