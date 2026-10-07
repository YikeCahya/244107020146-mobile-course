import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'data/models/post.dart';
import 'pages/post_detail_page.dart';
import 'pages/paged_post_page.dart';
import 'pages/post_list_page.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const PagedPostPage(),
    ),
    GoRoute(
      path: '/posts',
      builder: (context, state) => const PostListPage(),
    ),
    GoRoute(
      path: '/post/:id',
      builder: (context, state) {
        final postId = int.tryParse(state.pathParameters['id'] ?? '');
        if (postId == null) {
          return const Scaffold(
            body: Center(child: Text('ID post tidak valid.')),
          );
        }
        final extra = state.extra;
        return PostDetailPage(
          postId: postId,
          initialPost: extra is Post ? extra : null,
        );
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Week 4 - REST API',
        theme: ThemeData(
            colorSchemeSeed: Colors.indigo, useMaterial3: true),
        routerConfig: _router,
      );
}