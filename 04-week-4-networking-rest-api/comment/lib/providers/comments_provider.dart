import "package:flutter_riverpod/flutter_riverpod.dart";
 
import "../models/comment.dart";
import "../repositories/comment_repository.dart";
 
/// Notifier asinkron per postId (family; argumen tersedia sebagai `arg`).
/// Jika build() melempar exception, Riverpod otomatis mengubah state
/// menjadi AsyncError tanpa try/catch manual.
class CommentsNotifier extends FamilyAsyncNotifier<List<Comment>, int> {
  @override
  Future<List<Comment>> build(int postId) {
    return ref.watch(commentRepositoryProvider).fetchComments(postId);
  }
 
  /// Muat ulang (mis. tombol "Coba lagi" / pull-to-refresh).
  Future<void> refresh() async {
    state = const AsyncLoading();
    // guard() menangkap exception dan menghasilkan AsyncError otomatis.
    state = await AsyncValue.guard(() => build(arg));
  }
}