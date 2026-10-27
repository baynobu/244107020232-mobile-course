import 'package:campus_notify/features/announcements/domain/entities/announcement.dart';
import 'package:campus_notify/features/announcements/domain/usecases/search_announcements.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late SearchAnnouncements usecase;
  late List<Announcement> sampleAnnouncements;

  setUp(() {
    usecase = const SearchAnnouncements();
    sampleAnnouncements = [
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
        body: 'Pendaftaran beasiswa peningkatan prestasi dibuka mulai Oktober.',
        author: 'Kemahasiswaan & Alumni',
        publishedAt: DateTime(2026, 9, 27),
      ),
      Announcement(
        id: '3',
        title: 'Jadwal Kuliah Berubah',
        category: 'Perkuliahan',
        body: 'Kelas Pemrograman Mobile pindah ke Ruang A2 jam 13.00.',
        author: 'Dosen Mobile',
        publishedAt: DateTime(2026, 9, 28),
      ),
    ];
  });

  group('SearchAnnouncements Domain Use Case', () {
    test('filter abaikan huruf besar/kecil (case-insensitive)', () {
      final resultLowercase = usecase(
        announcements: sampleAnnouncements,
        query: 'jadwal',
      );
      final resultUppercase = usecase(
        announcements: sampleAnnouncements,
        query: 'JADWAL',
      );

      expect(resultLowercase, hasLength(2));
      expect(resultUppercase, hasLength(2));
      expect(resultLowercase.map((e) => e.id), containsAll(['1', '3']));
    });

    test('query tak cocok kembalikan list kosong', () {
      final result = usecase(
        announcements: sampleAnnouncements,
        query: 'zzz-tak-ada-di-kampus',
      );

      expect(result, isEmpty);
    });

    test('query kosong atau spasi murni kembalikan seluruh daftar', () {
      final emptyResult = usecase(
        announcements: sampleAnnouncements,
        query: '',
      );
      final whitespaceResult = usecase(
        announcements: sampleAnnouncements,
        query: '    ',
      );

      expect(emptyResult, hasLength(3));
      expect(whitespaceResult, hasLength(3));
      expect(emptyResult, equals(sampleAnnouncements));
    });

    test('pencarian cocok pada kategori maupun isi (body)', () {
      // Cocok pada kategori "Kemahasiswaan"
      final byCategory = usecase(
        announcements: sampleAnnouncements,
        query: 'kemahasiswaan',
      );
      expect(byCategory, hasLength(1));
      expect(byCategory.first.id, '2');

      // Cocok pada kata dalam body "Ruang A2"
      final byBody = usecase(
        announcements: sampleAnnouncements,
        query: 'Ruang A2',
      );
      expect(byBody, hasLength(1));
      expect(byBody.first.id, '3');
    });

    test('query dengan leading/trailing spasi tetap di-trim dengan benar', () {
      final result = usecase(
        announcements: sampleAnnouncements,
        query: '   beasiswa   ',
      );

      expect(result, hasLength(1));
      expect(result.first.id, '2');
    });
  });
}
