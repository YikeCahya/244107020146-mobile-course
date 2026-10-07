import "package:dio/dio.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
 
import "../core/api_client.dart";
import "../core/app_exception.dart";
import "../models/comment.dart";
 
/// Repository = satu-satunya lapisan yang boleh memanggil Dio.
/// UI hanya berbicara dengan provider -> repository.
class CommentRepository {
  final Dio _dio;
  const CommentRepository(this._dio);
 
  /// GET /comments?postId={postId}
  /// Timeout 10 detik sudah diatur terpusat di [dioProvider].
  Future<List<Comment>> fetchComments(int postId) async {
    try {
      final response = await _dio.get<dynamic>(
        "/comments",
        queryParameters: {"postId": postId},
      );
 
      final data = response.data;
      // Pastikan bentuk response sesuai harapan (List) sebelum di-parse.
      if (data is! List) {
        throw const AppException("Format data dari server tidak sesuai.");
      }
 
      return data
          .whereType<Map<String, dynamic>>() // lewati item yang bukan objek
          .map(Comment.fromJson)
          .toList();
    } on DioException catch (e) {
      // Ubah error Dio menjadi AppException berisi pesan ramah pengguna.
      throw AppException(friendlyErrorMessage(e), e);
    }
  }
}
 
final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => CommentRepository(ref.watch(dioProvider)),
);