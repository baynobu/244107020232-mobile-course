import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/comment.dart';
import 'providers.dart';
import 'repositories/comment_repository.dart';

/// Provider untuk [CommentRepository] yang memanfaatkan instance Dio terpusat (dioProvider).
final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => CommentRepository(ref.watch(dioProvider)),
);

/// Notifier untuk mengelola state asynchronous dari daftar komentar.
/// Exception dari repository otomatis ditangkap Riverpod dan diubah menjadi [AsyncError].
class CommentListNotifier extends AsyncNotifier<List<Comment>> {
  int _currentPostId = 1;

  @override
  Future<List<Comment>> build() async {
    // Membaca repository terpusat dan memanggil endpoint GET /comments?postId={id}
    final repository = ref.watch(commentRepositoryProvider);
    return repository.fetchComments(_currentPostId);
  }

  /// Mengambil komentar berdasarkan [postId] baru
  Future<void> fetchByPostId(int postId) async {
    _currentPostId = postId;
    state = const AsyncLoading();
    try {
      final repository = ref.read(commentRepositoryProvider);
      state = AsyncData(await repository.fetchComments(postId));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Memperbarui data komentar saat ini (misalnya pada pull-to-refresh)
  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(commentRepositoryProvider);
      state = AsyncData(await repository.fetchComments(_currentPostId));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

/// AsyncNotifierProvider untuk komentar.
/// Nonaktifkan retry otomatis Riverpod 3 agar status error langsung final dan mudah diuji.
final commentListProvider =
    AsyncNotifierProvider<CommentListNotifier, List<Comment>>(
  CommentListNotifier.new,
  retry: (retryCount, error) => null,
);

/// Provider berbasis FutureProvider.family jika ingin langsung query komentar per postId secara spesifik.
final commentsByPostIdProvider =
    FutureProvider.family<List<Comment>, int>((ref, postId) {
  final repository = ref.watch(commentRepositoryProvider);
  return repository.fetchComments(postId);
});

/// Fungsi penerjemah error yang memetakan DioException ke pesan ramah pengguna.
/// Menangani timeout, connection error, status code 404, 500, dan lainnya.
String friendlyCommentErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi timeout (melebihi 10 detik). Periksa internet Anda lalu coba lagi.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 404) {
          return 'Data komentar tidak ditemukan (Error 404).';
        }
        if (statusCode == 500) {
          return 'Terjadi kesalahan pada server (Error 500). Silakan coba lagi nanti.';
        }
        return 'Server bermasalah ($statusCode). Coba beberapa saat lagi.';
      default:
        return 'Terjadi gangguan jaringan. Coba lagi.';
    }
  }
  return 'Terjadi kesalahan tak terduga: $error';
}
