import 'package:dio/dio.dart';
import '../models/comment.dart';

/// Repository layer untuk abstraksi akses data endpoint comments.
/// Memisahkan logika networking (Dio) dari UI layer.
class CommentRepository {
  /// Menerima instance Dio terpusat (dependency injection).
  CommentRepository(this._dio);

  final Dio _dio;

  /// Mengambil daftar komentar berdasarkan [postId] dari endpoint GET /comments?postId={id}.
  /// Menetapkan timeout 10 detik secara eksplisit via Options,
  /// melengkapi timeout terpusat yang sudah ada di ApiClient.
  Future<List<Comment>> fetchComments(int postId) async {
    final response = await _dio.get<List>(
      '/comments',
      queryParameters: {'postId': postId},
      options: Options(
        connectTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    final data = response.data ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(Comment.fromJson)
        .toList();
  }
}
