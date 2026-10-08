import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'local/db.dart';
import 'models/post.dart';
import 'repositories/post_repository.dart';

class SyncService {
  SyncService({
    PostRepository? postRepository,
    Future<Database> Function()? openDb,
  })  : _postRepository = postRepository ?? PostRepository(),
        _openDb = openDb ?? openNotesDb;

  final PostRepository _postRepository;
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
    final posts = await _postRepository.fetchPosts();
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

  Future<int> syncNotes() async {
    final db = await _openDb();
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM notes WHERE dirty = 1',
    );
    final dirtyCount = (rows.first['c'] as num?)?.toInt() ?? 0;
    if (dirtyCount == 0) return 0;

    await Future<void>.delayed(const Duration(seconds: 1));
    await db.update('notes', {'dirty': 0}, where: 'dirty = 1');
    return dirtyCount;
  }
}
