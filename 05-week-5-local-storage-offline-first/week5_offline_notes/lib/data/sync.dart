import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'local/db.dart';
import 'repositories/note_repository.dart';

final forceOfflineProvider = NotifierProvider<ForceOfflineNotifier, bool>(
  ForceOfflineNotifier.new,
);

class ForceOfflineNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void setOffline(bool value) => state = value;
}

class PostItem {
  const PostItem({
    required this.id,
    required this.title,
    required this.body,
    this.cachedAt,
  });

  final int id;
  final String title;
  final String body;
  final DateTime? cachedAt;

  factory PostItem.fromJson(Map<String, dynamic> json, [DateTime? cachedAt]) {
    return PostItem(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      cachedAt: cachedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
      };
}

class SyncService {
  SyncService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<int> syncNotes(NoteRepository repo, {bool forceOffline = false}) async {
    if (forceOffline) {
      throw Exception('Mode offline aktif: tidak dapat menyinkronkan data.');
    }

    final dirtyCount = await repo.countDirty();
    if (dirtyCount == 0) return 0;

    // Simulasi delay sinkronisasi ke server (REST API)
    await Future.delayed(const Duration(seconds: 1));

    // Setelah server menerima data dengan sukses, bersihkan dirty flag
    await repo.markAllSynced();
    return dirtyCount;
  }

  Future<List<PostItem>> readCachedPosts() async {
    final db = await openNotesDb();
    final rows = await db.query('cached_posts', orderBy: 'id ASC');
    return rows.map((row) {
      final payload = jsonDecode(row['payload'] as String) as Map<String, dynamic>;
      final cachedAt = DateTime.tryParse(row['cached_at'] as String? ?? '');
      return PostItem.fromJson(payload, cachedAt);
    }).toList();
  }

  Future<void> saveCachedPosts(List<PostItem> posts) async {
    final db = await openNotesDb();
    final batch = db.batch();
    batch.delete('cached_posts');
    final nowStr = DateTime.now().toIso8601String();
    for (final post in posts) {
      batch.insert('cached_posts', {
        'id': post.id,
        'payload': jsonEncode(post.toJson()),
        'cached_at': nowStr,
      });
    }
    await batch.commit(noResult: true);
  }

  Future<List<PostItem>> fetchRemotePosts() async {
    final response = await _dio.get<List<dynamic>>(
      'https://jsonplaceholder.typicode.com/posts',
      queryParameters: {'_limit': 15},
      options: Options(receiveTimeout: const Duration(seconds: 5)),
    );

    final data = response.data ?? [];
    return data.map((item) => PostItem.fromJson(item as Map<String, dynamic>)).toList();
  }
}

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService();
});

/// Provider cache-first:
/// Mengembalikan data lokal dari SQLite seketika.
/// Jika online (forceOffline == false), memicu pembaruan background.
final cachedPostsProvider =
    AsyncNotifierProvider<CachedPostsNotifier, List<PostItem>>(
  CachedPostsNotifier.new,
);

class CachedPostsNotifier extends AsyncNotifier<List<PostItem>> {
  @override
  Future<List<PostItem>> build() async {
    final syncService = ref.watch(syncServiceProvider);
    final cached = await syncService.readCachedPosts();

    final isOffline = ref.watch(forceOfflineProvider);
    if (!isOffline) {
      // Jalankan background refresh tanpa memblokir pembacaan awal
      _refreshInBackground();
    }

    return cached;
  }

  Future<void> _refreshInBackground() async {
    try {
      final syncService = ref.read(syncServiceProvider);
      final remotePosts = await syncService.fetchRemotePosts();
      await syncService.saveCachedPosts(remotePosts);
      // Update state dengan post terbaru tanpa memicu infinite loop
      state = AsyncData(remotePosts);
    } catch (_) {
      // Background refresh gagal (misal koneksi terputus), biarkan cache lokal tetap tampil
    }
  }

  Future<void> manualRefresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final isOffline = ref.read(forceOfflineProvider);
      final syncService = ref.read(syncServiceProvider);
      if (isOffline) {
        return syncService.readCachedPosts();
      }
      try {
        final remote = await syncService.fetchRemotePosts();
        await syncService.saveCachedPosts(remote);
        return remote;
      } catch (e) {
        final cached = await syncService.readCachedPosts();
        if (cached.isNotEmpty) return cached;
        rethrow;
      }
    });
  }
}
