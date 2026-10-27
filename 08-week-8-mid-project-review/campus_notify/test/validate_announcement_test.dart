import 'package:campus_notify/core/failures.dart';
import 'package:campus_notify/features/announcements/domain/usecases/validate_announcement.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const validator = ValidateAnnouncement();

  group('ValidateAnnouncement Use Case Unit Tests', () {
    test('mengembalikan null jika seluruh input valid', () {
      final failure = validator(
        title: 'Jadwal Kuliah Pengganti',
        body: 'Kuliah pengganti Pemrograman Mobile diadakan hari Jumat pukul 08.00 WIB.',
        category: 'Perkuliahan',
      );

      expect(failure, isNull);
    });

    test(
      'mengembalikan ValidationFailure jika judul kosong atau hanya spasi',
      () {
        final failure = validator(
          title: '     ',
          body: 'Isi pengumuman yang cukup panjang dan valid.',
          category: 'Akademik',
        );

        expect(failure, isA<ValidationFailure>());
        expect(failure?.message, 'Judul pengumuman tidak boleh kosong');
      },
    );

    test(
      'mengembalikan ValidationFailure jika judul kurang dari 5 karakter',
      () {
        final failure = validator(
          title: 'Info',
          body: 'Isi pengumuman yang cukup panjang dan valid.',
          category: 'Akademik',
        );

        expect(failure, isA<ValidationFailure>());
        expect(failure?.message, 'Judul pengumuman minimal 5 karakter');
      },
    );

    test('mengembalikan ValidationFailure jika body pengumuman kosong', () {
      final failure = validator(
        title: 'Pengumuman Penting',
        body: '',
        category: 'Akademik',
      );

      expect(failure, isA<ValidationFailure>());
      expect(failure?.message, 'Isi pengumuman tidak boleh kosong');
    });

    test(
      'mengembalikan ValidationFailure jika body kurang dari 10 karakter',
      () {
        final failure = validator(
          title: 'Pengumuman Penting',
          body: 'Pendek',
          category: 'Akademik',
        );

        expect(failure, isA<ValidationFailure>());
        expect(failure?.message, 'Isi pengumuman minimal 10 karakter');
      },
    );

    test('mengembalikan ValidationFailure jika kategori di luar daftar yang diizinkan', () {
      final failure = validator(
        title: 'Pengumuman Penting',
        body: 'Isi pengumuman yang cukup panjang dan valid.',
        category: 'Ekstrakurikuler',
      );

      expect(failure, isA<ValidationFailure>());
      expect(failure?.message, contains('tidak valid'));
      expect(failure?.message, contains('Kategori yang diperbolehkan'));
    });
  });
}
