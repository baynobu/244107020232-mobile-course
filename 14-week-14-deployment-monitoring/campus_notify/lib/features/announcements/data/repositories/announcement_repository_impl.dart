import '../../../../core/failures.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../models/announcement_model.dart';

/// Implementasi konkret [AnnouncementRepository] — tinggal di layer data.
///
/// Mengimplementasikan strategi **Stale-While-Revalidate (SWR) Caching**:
/// 1. Tampilkan data dari cache in-memory seketika (0 ms latency).
/// 2. Bila data belum ada, kedaluwarsa (TTL habis), atau [forceRefresh] = true,
///    lakukan pengambilan data segar (simulasi latensi jaringan / remote API).
/// 3. Simpan data terbaru ke cache untuk pembacaan berikutnya.
/// 4. Graceful fallback: Bila terjadi error jaringan, kembalikan data cache yang tersisa.
class AnnouncementRepositoryImpl implements AnnouncementRepository {
  AnnouncementRepositoryImpl({this.cacheTtl = const Duration(minutes: 5)});

  /// Durasi validitas cache (Time-To-Live). Default 5 menit.
  final Duration cacheTtl;

  /// Cache memori lokal untuk daftar pengumuman.
  List<Announcement>? _memoryCache;

  /// Timestamp saat cache terakhir diperbarui.
  DateTime? _lastFetchTime;

  /// Data mock kampus — simulasi response API / database remote.
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

  /// Menghapus cache memori (digunakan untuk testing atau logout).
  void clearCache() {
    _memoryCache = null;
    _lastFetchTime = null;
  }

  /// Mengetahui apakah cache saat ini masih valid (tidak null & belum kedaluwarsa).
  bool get hasValidCache {
    if (_memoryCache == null || _lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < cacheTtl;
  }

  @override
  Future<({List<Announcement> announcements, Failure? failure})>
  fetchAnnouncements({bool forceRefresh = false}) async {
    // 1. Optimasi SWR: Kembalikan cache segera jika valid dan tidak forceRefresh
    if (!forceRefresh && hasValidCache) {
      return (
        announcements: List<Announcement>.from(_memoryCache!),
        failure: null,
      );
    }

    try {
      // 2. Simulasi latensi jaringan bila cache kosong atau forceRefresh
      await Future.delayed(const Duration(milliseconds: 300));
      final freshList = _mockDb
          .map((row) => AnnouncementModel.fromMap(row).toEntity())
          .toList();

      // 3. Simpan ke local cache in-memory
      _memoryCache = freshList;
      _lastFetchTime = DateTime.now();

      return (announcements: List<Announcement>.from(freshList), failure: null);
    } catch (e) {
      // 4. Fallback ke cache yang ada jika request jaringan gagal
      if (_memoryCache != null && _memoryCache!.isNotEmpty) {
        return (
          announcements: List<Announcement>.from(_memoryCache!),
          failure: null,
        );
      }
      return (
        announcements: const <Announcement>[],
        failure: NetworkFailure('Gagal memuat pengumuman: $e'),
      );
    }
  }

  @override
  Future<({Announcement? announcement, Failure? failure})>
  fetchAnnouncementById(String id, {bool forceRefresh = false}) async {
    // 1. Cari dulu di memory cache jika tersedia
    if (!forceRefresh && _memoryCache != null) {
      final cachedItem = _memoryCache!.where((a) => a.id == id).firstOrNull;
      if (cachedItem != null) {
        return (announcement: cachedItem, failure: null);
      }
    }

    try {
      // 2. Fetch dengan simulasi latensi bila tidak ada di cache
      await Future.delayed(const Duration(milliseconds: 150));
      final row = _mockDb.where((r) => r['id'] == id).firstOrNull;
      if (row == null) {
        return (
          announcement: null,
          failure: NetworkFailure('Pengumuman dengan id=$id tidak ditemukan.'),
        );
      }

      final entity = AnnouncementModel.fromMap(row).toEntity();

      // Perbarui atau tambahkan item ini ke memory cache
      if (_memoryCache != null) {
        final existingIdx = _memoryCache!.indexWhere((a) => a.id == id);
        if (existingIdx >= 0) {
          _memoryCache![existingIdx] = entity;
        } else {
          _memoryCache!.add(entity);
        }
      }

      return (announcement: entity, failure: null);
    } catch (e) {
      return (
        announcement: null,
        failure: NetworkFailure('Gagal memuat detail pengumuman: $e'),
      );
    }
  }
}
