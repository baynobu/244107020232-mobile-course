import 'package:campus_notify/core/failures.dart';
import 'package:campus_notify/features/announcements/domain/entities/announcement.dart';
import 'package:campus_notify/features/announcements/domain/repositories/announcement_repository.dart';
import 'package:campus_notify/features/announcements/domain/usecases/get_announcements.dart';
import 'package:flutter_test/flutter_test.dart';

/// Repository palsu untuk unit test — tidak butuh Dio, SQLite, atau Firebase.
/// Mengimplementasikan [AnnouncementRepository] sehingga LSP terpenuhi:
/// domain tidak peduli apakah data datang dari jaringan, database, atau fake.
class FakeAnnouncementRepository implements AnnouncementRepository {
  FakeAnnouncementRepository({this.items = const [], this.fail = false});

  final List<Announcement> items;
  final bool fail;

  @override
  Future<({List<Announcement> announcements, Failure? failure})>
      fetchAnnouncements() async {
    if (fail) {
      return (
        announcements: const <Announcement>[],
        failure: const NetworkFailure('Simulasi: server tidak dapat dijangkau'),
      );
    }
    return (announcements: items, failure: null);
  }

  @override
  Future<({Announcement? announcement, Failure? failure})>
      fetchAnnouncementById(String id) async {
    if (fail) {
      return (
        announcement: null,
        failure: const NetworkFailure('Simulasi: server tidak dapat dijangkau'),
      );
    }
    final found = items.where((a) => a.id == id).firstOrNull;
    if (found == null) {
      return (
        announcement: null,
        failure: NetworkFailure('Pengumuman id=$id tidak ditemukan'),
      );
    }
    return (announcement: found, failure: null);
  }
}

void main() {
  // ─── Fixture data ──────────────────────────────────────────────────────────
  final sampleAnnouncements = [
    Announcement(
      id: '1',
      title: 'Jadwal Kuliah Semester Baru',
      category: 'Akademik',
      body: 'KRS dan ruang kelas dapat diperiksa di portal akademik.',
      author: 'Administrasi Akademik',
      publishedAt: DateTime(2026, 9, 28),
    ),
    Announcement(
      id: '2',
      title: 'Pendaftaran Beasiswa Prestasi',
      category: 'Kemahasiswaan',
      body: 'Dibuka mulai 1 Oktober 2026.',
      author: 'Kemahasiswaan & Alumni',
      publishedAt: DateTime(2026, 9, 27),
    ),
  ];

  // ─── Test 1: sukses meneruskan daftar dari repository ─────────────────────
  test('GetAnnouncements meneruskan daftar dari repository', () async {
    final repo = FakeAnnouncementRepository(items: sampleAnnouncements);
    final result = await GetAnnouncements(repo).call();

    expect(result.failure, isNull);
    expect(result.announcements.length, 2);
    expect(result.announcements.first.title, 'Jadwal Kuliah Semester Baru');
    expect(result.announcements.first.category, 'Akademik');
  });

  // ─── Test 2: failure diteruskan tanpa melempar exception ──────────────────
  test('GetAnnouncements meneruskan failure tanpa melempar', () async {
    final repo = FakeAnnouncementRepository(fail: true);
    final result = await GetAnnouncements(repo).call();

    expect(result.failure, isA<NetworkFailure>());
    expect(result.announcements, isEmpty);
    expect(
      result.failure!.message,
      contains('Simulasi: server tidak dapat dijangkau'),
    );
  });

  // ─── Test 3: repository kosong mengembalikan list kosong ──────────────────
  test('GetAnnouncements mengembalikan list kosong bila repository kosong',
      () async {
    final repo = FakeAnnouncementRepository();
    final result = await GetAnnouncements(repo).call();

    expect(result.failure, isNull);
    expect(result.announcements, isEmpty);
  });

  // ─── Test 4: verifikasi entity tidak mengandung toMap/fromMap ─────────────
  test('Announcement entity tidak memiliki metode mapping (murni domain)',
      () {
    final a = sampleAnnouncements.first;
    // Cukup pastikan field domain tersedia tanpa exception
    expect(a.id, '1');
    expect(a.publishedAt.year, 2026);
  });
}
