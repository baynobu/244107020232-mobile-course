import '../entities/announcement.dart';
import '../../../../core/failures.dart';

/// Kontrak repository pengumuman — tinggal di domain.
/// Implementasi konkret ada di layer data ([AnnouncementRepositoryImpl]).
///
/// Pola return record Dart dipakai agar sukses/gagal eksplisit
/// tanpa melempar exception ke presentation.
abstract class AnnouncementRepository {
  /// Mengambil seluruh pengumuman yang tersedia.
  Future<({List<Announcement> announcements, Failure? failure})>
      fetchAnnouncements();

  /// Mengambil detail satu pengumuman berdasarkan [id].
  Future<({Announcement? announcement, Failure? failure})>
      fetchAnnouncementById(String id);
}
