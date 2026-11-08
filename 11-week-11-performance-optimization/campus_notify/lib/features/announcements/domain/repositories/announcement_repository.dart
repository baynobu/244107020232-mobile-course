import '../../../../core/failures.dart';
import '../entities/announcement.dart';

/// Kontrak repository pengumuman — tinggal di domain.
/// Implementasi konkret ada di layer data ([AnnouncementRepositoryImpl]).
///
/// Pola return record Dart dipakai agar sukses/gagal eksplisit
/// tanpa melempar exception ke presentation.
abstract class AnnouncementRepository {
  /// Mengambil seluruh pengumuman yang tersedia.
  /// [forceRefresh] diset true untuk mengabaikan cache lokal dan memuat data segar.
  Future<({List<Announcement> announcements, Failure? failure})>
  fetchAnnouncements({bool forceRefresh = false});

  /// Mengambil detail satu pengumuman berdasarkan [id].
  /// [forceRefresh] diset true untuk mengabaikan cache lokal.
  Future<({Announcement? announcement, Failure? failure})>
  fetchAnnouncementById(String id, {bool forceRefresh = false});
}
