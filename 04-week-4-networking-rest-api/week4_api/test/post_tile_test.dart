import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/post.dart';
import 'package:week4_api/widgets/post_tile.dart';

void main() {
  testWidgets('PostTile menampilkan post dan memanggil onTap', (tester) async {
    var tapped = false;
    const post = Post(userId: 1, id: 7, title: 'Judul post', body: 'Isi post');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PostTile(post: post, onTap: () => tapped = true),
        ),
      ),
    );

    expect(find.text('Judul post'), findsOneWidget);
    expect(find.text('Isi post'), findsOneWidget);
    await tester.tap(find.byType(PostTile));
    expect(tapped, isTrue);
  });
}
