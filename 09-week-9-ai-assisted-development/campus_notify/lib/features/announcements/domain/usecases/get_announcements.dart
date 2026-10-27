import '../../../../core/failures.dart';
import '../entities/announcement.dart';
import '../repositories/announcement_repository.dart';

/// Use case: mengambil seluruh daftar pengumuman.
///
/// Use case ini benar-benar dibutuhkan karena operasi fetchAnnouncements
/// akan berkembang (paginasi, filter kategori, cache strategy) — bukan
/// sekadar CRUD satu-baris. Untuk operasi satu-baris sederhana, repository
/// dapat dipanggil langsung oleh notifier.
class GetAnnouncements {
  const GetAnnouncements(this._repository);

  final AnnouncementRepository _repository;

  Future<({List<Announcement> announcements, Failure? failure})> call() {
    return _repository.fetchAnnouncements();
  }
}
