import '../../../../core/failures.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../models/announcement_model.dart';

/// Implementasi konkret [AnnouncementRepository] — tinggal di layer data.
///
/// Mock data digunakan karena backend belum tersedia.
/// Saat backend kampus siap, ganti [_mockDb] dengan panggilan Dio:
///   `final response = await _dio.get('/announcements');`
/// Tidak ada perubahan pada domain atau presentation.
class AnnouncementRepositoryImpl implements AnnouncementRepository {
  /// Data mock kampus — simulasi response API / database lokal.
  static final List<Map<String, dynamic>> _mockDb = [
    {
      'id': '1',
      'title': 'Jadwal Kuliah Semester Baru',
      'category': 'Akademik',
      'body':
          'Jadwal perkuliahan Semester Ganjil 2026/2027 telah dirilis. '
          'Mahasiswa diharapkan memeriksa KRS dan ruang kelas masing-masing melalui portal akademik.',
      'author': 'Bagian Administrasi Akademik',
      'published_at': '2026-09-28T08:00:00.000',
    },
    {
      'id': '2',
      'title': 'Pendaftaran Beasiswa Prestasi',
      'category': 'Kemahasiswaan',
      'body':
          'Pendaftaran beasiswa peningkatan prestasi akademik dibuka mulai tanggal 1 Oktober 2026. '
          'Siapkan transkrip nilai dan sertifikat kejuaraan pendukung.',
      'author': 'Kemahasiswaan & Alumni',
      'published_at': '2026-09-27T09:00:00.000',
    },
    {
      'id': '3',
      'title': 'Jadwal Kuliah Berubah',
      'category': 'Perkuliahan',
      'body':
          'Kelas Pemrograman Mobile pindah ke Ruang A2 jam 13.00 WIB. '
          'Diharapkan mahasiswa hadir tepat waktu dengan membawa laptop.',
      'author': 'Dosen Pengampu Pemrograman Mobile',
      'published_at': '2026-09-28T07:30:00.000',
    },
  ];

  @override
  Future<({List<Announcement> announcements, Failure? failure})>
  fetchAnnouncements() async {
    try {
      // Simulasi latensi jaringan / database
      await Future.delayed(const Duration(milliseconds: 300));
      final announcements = _mockDb
          .map((row) => AnnouncementModel.fromMap(row).toEntity())
          .toList();
      return (announcements: announcements, failure: null);
    } catch (e) {
      return (
        announcements: const <Announcement>[],
        failure: NetworkFailure('Gagal memuat pengumuman: $e'),
      );
    }
  }

  @override
  Future<({Announcement? announcement, Failure? failure})>
  fetchAnnouncementById(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 150));
      final row = _mockDb.where((r) => r['id'] == id).firstOrNull;
      if (row == null) {
        return (
          announcement: null,
          failure: NetworkFailure('Pengumuman dengan id=$id tidak ditemukan.'),
        );
      }
      return (
        announcement: AnnouncementModel.fromMap(row).toEntity(),
        failure: null,
      );
    } catch (e) {
      return (
        announcement: null,
        failure: NetworkFailure('Gagal memuat detail pengumuman: $e'),
      );
    }
  }
}
