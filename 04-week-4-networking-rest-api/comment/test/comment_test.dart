import 'package:flutter_test/flutter_test.dart';
import 'package:comment/models/comment.dart';
 
void main() {
  test('Comment.fromJson tidak crash saat field hilang', () {
    // Hanya `id` yang ada; postId, name, email, body hilang.
    final comment = Comment.fromJson({'id': 7});
 
    expect(comment.id, 7);
    expect(comment.postId, 0); // default int
    expect(comment.name, ''); // default String
    expect(comment.email, '');
    expect(comment.body, '');
  });
}