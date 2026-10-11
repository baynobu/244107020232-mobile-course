import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/announcement_repository_impl.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../../domain/usecases/get_announcements.dart';

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

// ─── Layer Presentation: state untuk UI ───────────────────────────────────────

/// State daftar pengumuman — widget hanya membaca ini.
/// Tidak ada SQL, Dio, atau JSON di dalam widget.
final announcementsProvider =
    FutureProvider<List<Announcement>>((ref) async {
  final result = await ref.watch(getAnnouncementsProvider).call();
  if (result.failure != null) {
    throw Exception(result.failure!.message);
  }
  return result.announcements;
});
