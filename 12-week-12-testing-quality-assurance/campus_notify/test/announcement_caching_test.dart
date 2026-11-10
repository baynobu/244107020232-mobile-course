import 'package:campus_notify/features/announcements/data/repositories/announcement_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'AnnouncementRepositoryImpl - Stale-While-Revalidate Caching Tests',
    () {
      late AnnouncementRepositoryImpl repository;

      setUp(() {
        repository = AnnouncementRepositoryImpl(
          cacheTtl: const Duration(seconds: 10),
        );
      });

      tearDown(() {
        repository.clearCache();
      });

      test(
        'Panggilan pertama memuat data dan menginisialisasi cache lokal',
        () async {
          expect(repository.hasValidCache, isFalse);

          final stopwatch = Stopwatch()..start();
          final result = await repository.fetchAnnouncements();
          stopwatch.stop();

          expect(result.failure, isNull);
          expect(result.announcements.length, 3);
          expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(250));
          expect(repository.hasValidCache, isTrue);
        },
      );

      test('Panggilan kedua mengembalikan data dari cache secara instan (0 ms latency)', () async {
        // Panggilan 1 (warm up cache)
        await repository.fetchAnnouncements();
        expect(repository.hasValidCache, isTrue);

        // Panggilan 2 (harus dari cache memori)
        final stopwatch = Stopwatch()..start();
        final cachedResult = await repository.fetchAnnouncements();
        stopwatch.stop();

        expect(cachedResult.failure, isNull);
        expect(cachedResult.announcements.length, 3);
        // Dari cache harus jauh lebih cepat dari latensi simulasi 300ms
        expect(stopwatch.elapsedMilliseconds, lessThan(50));
      });

      test(
        'forceRefresh = true mengabaikan cache dan mengambil data segar',
        () async {
          // Warm up cache
          await repository.fetchAnnouncements();
          expect(repository.hasValidCache, isTrue);

          // Panggilan dengan forceRefresh = true
          final stopwatch = Stopwatch()..start();
          final freshResult = await repository.fetchAnnouncements(
            forceRefresh: true,
          );
          stopwatch.stop();

          expect(freshResult.failure, isNull);
          expect(freshResult.announcements.length, 3);
          expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(250));
        },
      );

      test(
        'fetchAnnouncementById memanfaatkan cache memori yang sudah ada',
        () async {
          // Inisialisasi cache
          await repository.fetchAnnouncements();

          final stopwatch = Stopwatch()..start();
          final detailResult = await repository.fetchAnnouncementById('1');
          stopwatch.stop();

          expect(detailResult.failure, isNull);
          expect(detailResult.announcement, isNotNull);
          expect(detailResult.announcement!.id, '1');
          expect(
            detailResult.announcement!.title,
            'Jadwal Kuliah Semester Baru',
          );
          // Karena diambil langsung dari memory cache, tidak ada delay 150ms
          expect(stopwatch.elapsedMilliseconds, lessThan(50));
        },
      );

      test('clearCache menghapus data cache dan memaksa refetch', () async {
        await repository.fetchAnnouncements();
        expect(repository.hasValidCache, isTrue);

        repository.clearCache();
        expect(repository.hasValidCache, isFalse);

        final stopwatch = Stopwatch()..start();
        final result = await repository.fetchAnnouncements();
        stopwatch.stop();

        expect(result.failure, isNull);
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(250));
      });
    },
  );
}
