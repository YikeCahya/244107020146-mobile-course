import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pages/posts_page.dart';

void main() {
  runApp(const ProviderScope(child: MiniProjectApp()));
}

class MiniProjectApp extends StatelessWidget {
  const MiniProjectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Post',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const PostsPage(),
    );
  }
}
