import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/announcement_repository_impl.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../../domain/usecases/get_announcements.dart';
import '../../domain/usecases/search_announcements.dart';

// ─── Layer Data: penyediaan implementasi repository ───────────────────────────

/// Satu-satunya tempat wiring data → domain.
/// Untuk unit test, provider ini bisa di-override dengan fake repository:
///   container.override([announcementRepositoryProvider].overrideWithValue(FakeRepo()))
final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepositoryImpl();
});

// ─── Layer Domain: use case menerima abstraksi, bukan implementasi ─────────────

final getAnnouncementsProvider = Provider<GetAnnouncements>((ref) {
  return GetAnnouncements(ref.watch(announcementRepositoryProvider));
});

final searchAnnouncementsUseCaseProvider = Provider<SearchAnnouncements>((ref) {
  return const SearchAnnouncements();
});

// ─── Layer Presentation: state untuk UI ───────────────────────────────────────

/// State daftar mentah pengumuman dari repository.
final announcementsProvider = FutureProvider<List<Announcement>>((ref) async {
  final result = await ref.watch(getAnnouncementsProvider).call();
  if (result.failure != null) {
    throw Exception(result.failure!.message);
  }
  return result.announcements;
});

/// Notifier untuk query pencarian pengumuman.
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

/// Provider hasil filter pengumuman berdasarkan query aktif.
/// Menerapkan pemisahan layer: logika filter didelegasikan ke [SearchAnnouncements] use case.
final filteredAnnouncementsProvider = Provider<AsyncValue<List<Announcement>>>((
  ref,
) {
  final announcementsAsync = ref.watch(announcementsProvider);
  final query = ref.watch(searchQueryProvider);
  final searchUseCase = ref.watch(searchAnnouncementsUseCaseProvider);

  return announcementsAsync.whenData((list) {
    return searchUseCase.call(announcements: list, query: query);
  });
});
