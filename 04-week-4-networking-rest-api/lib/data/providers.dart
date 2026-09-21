import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'api_client.dart';
import 'models/post.dart';
import 'paged_posts.dart';
import 'repositories/post_repository.dart';

export 'network_errors.dart';

final dioProvider = Provider<Dio>((ref) => createDio());

final postRepositoryProvider = Provider<PostRepository>(
  (ref) => PostRepository(ref.watch(dioProvider)),
);

class PostListNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    // Exception dari repository otomatis menjadi AsyncError.
    // Inilah ekuivalen deklaratif dari AsyncValue.guard di versi lama.
    final repository = ref.watch(postRepositoryProvider);
    return repository.fetchPosts();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(postRepositoryProvider);
      state = AsyncData(await repository.fetchPosts());
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final postListProvider =
    AsyncNotifierProvider<PostListNotifier, List<Post>>(
        PostListNotifier.new,
        // Nonaktifkan retry otomatis Riverpod 3 agar error langsung
        // final dan mudah diuji (tanpa ini, future provider di-test
        // akan me-retry dan menggantung).
        retry: (retryCount, error) => null);

/// Helper khusus testing (letakkan di providers.dart): membaca state
/// pertama yang bukan loading lewat listener + completer, sehingga
/// test tidak menunggu retry dan tidak melakukan HTTP sungguhan.
Future<List<Post>> readPostsOnce(ProviderContainer container) {
  final completer = Completer<List<Post>>();
  final sub = container.listen<AsyncValue<List<Post>>>(
    postListProvider,
    (previous, next) {
      if (next.isLoading || completer.isCompleted) return;
      next.whenData(completer.complete);
      if (next.hasError) {
        completer.completeError(
          next.error ?? StateError('unknown error'),
          next.stackTrace ?? StackTrace.empty,
        );
      }
    },
    fireImmediately: true,
  );
  return completer.future.whenComplete(sub.close);
}

Future<Object?> readPostsErrorOnce(ProviderContainer container) {
  final completer = Completer<Object?>();
  final sub = container.listen<AsyncValue<List<Post>>>(
    postListProvider,
    (previous, next) {
      if (next.isLoading || completer.isCompleted) return;
      completer.complete(next.error);
    },
    fireImmediately: true,
  );
  return completer.future.whenComplete(sub.close);
}

/// Provider untuk detail Post berdasarkan [id].
/// Memeriksa list post yang sudah dimuat terlebih dahulu (dari postListProvider maupun pagedPostsProvider).
/// Jika belum tersedia (misal dibuka langsung via deep-link GoRouter /post/:id),
/// maka akan mengambil data langsung dari repository (fetchPost).
final postDetailProvider = FutureProvider.family<Post, int>((ref, id) async {
  // 1. Cek dari postListProvider jika sudah termuat
  final postListState = ref.watch(postListProvider);
  final postFromList =
      postListState.value?.where((p) => p.id == id).firstOrNull;
  if (postFromList != null) return postFromList;

  // 2. Cek dari pagedPostsProvider jika sudah termuat
  final pagedPostsState = ref.watch(pagedPostsProvider);
  final postFromPaged =
      pagedPostsState.items.where((p) => p.id == id).firstOrNull;
  if (postFromPaged != null) return postFromPaged;

  // 3. Jika belum dimuat di list, ambil dari server melalui repository
  final repository = ref.watch(postRepositoryProvider);
  return repository.fetchPost(id);
});