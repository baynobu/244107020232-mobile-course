import 'package:campus_notify/core/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Unit Tests: Core Validators (Arrange - Act - Assert)', () {
    // ─── 1. Group Validasi Email ───────────────────────────────────────────────
    group('validateEmail', () {
      test('menerima format email institusi kampus yang valid', () {
        // Arrange
        const validEmail = 'mahasiswa@kampus.ac.id';

        // Act
        final result = validateEmail(validEmail);

        // Assert
        expect(result, isNull);
      });

      test('menerima format email umum yang valid', () {
        // Arrange & Act & Assert
        expect(validateEmail('hanif@polinema.ac.id'), isNull);
        expect(validateEmail('student.mobile@gmail.com'), isNull);
      });

      test('kasus kegagalan: menolak nilai null atau string kosong', () {
        // Arrange & Act & Assert
        expect(validateEmail(null), 'Email tidak boleh kosong');
        expect(validateEmail(''), 'Email tidak boleh kosong');
        expect(validateEmail('    '), 'Email tidak boleh kosong');
      });

      test('kasus kegagalan: menolak format tanpa karakter @', () {
        // Arrange & Act & Assert
        expect(
          validateEmail('mahasiswakampus.ac.id'),
          'Format email tidak valid (harus mengandung @)',
        );
      });

      test('kasus tepi: menolak spasi di tengah email', () {
        // Arrange & Act & Assert
        expect(
          validateEmail('maha siswa@kampus.ac.id'),
          'Email tidak boleh mengandung spasi',
        );
      });

      test('kasus tepi: menolak simbol @ di awal atau di akhir', () {
        // Arrange & Act & Assert
        expect(
          validateEmail('@kampus.ac.id'),
          'Format alamat email tidak lengkap',
        );
        expect(
          validateEmail('mahasiswa@'),
          'Format alamat email tidak lengkap',
        );
      });

      test('kasus tepi: menolak email tanpa ekstensi domain dot', () {
        // Arrange & Act & Assert
        expect(
          validateEmail('user@localhost'),
          'Format domain email tidak valid (harus memiliki domain seperti .ac.id)',
        );
      });
    });

    // ─── 2. Group Validasi Kata Sandi (Password) ──────────────────────────────
    group('validatePassword', () {
      test('menerima kata sandi yang memenuhi syarat (>= 6 karakter)', () {
        // Arrange
        const validPass = 'rahasia123';

        // Act
        final result = validatePassword(validPass);

        // Assert
        expect(result, isNull);
      });

      test(
        'kasus batas: menerima kata sandi dengan panjang tepat 6 karakter',
        () {
          // Arrange & Act & Assert
          expect(validatePassword('123456'), isNull);
        },
      );

      test('kasus kegagalan: menolak kata sandi kosong atau null', () {
        // Arrange & Act & Assert
        expect(validatePassword(null), 'Kata sandi tidak boleh kosong');
        expect(validatePassword(''), 'Kata sandi tidak boleh kosong');
      });

      test(
        'kasus tepi: menolak kata sandi di bawah batas minimum (< 6 karakter)',
        () {
          // Arrange & Act & Assert
          expect(validatePassword('12345'), 'Kata sandi minimal 6 karakter');
          expect(validatePassword('a'), 'Kata sandi minimal 6 karakter');
        },
      );

      test(
        'kasus tepi: menolak kata sandi melebihi 64 karakter (Buffer Guard)',
        () {
          // Arrange
          final overlyLongPassword = 'A' * 65;

          // Act
          final result = validatePassword(overlyLongPassword);

          // Assert
          expect(result, 'Kata sandi maksimal 64 karakter');
        },
      );
    });

    // ─── 3. Group Validasi Kata Kunci Pencarian ───────────────────────────────
    group('validateSearchQuery', () {
      test('menerima kata kunci pencarian valid', () {
        // Arrange & Act & Assert
        expect(validateSearchQuery('Jadwal Kuliah'), isNull);
        expect(validateSearchQuery('KRS'), isNull);
      });

      test('kasus kegagalan: menolak pencarian kosong atau spasi saja', () {
        // Arrange & Act & Assert
        expect(
          validateSearchQuery(''),
          'Kata kunci pencarian tidak boleh kosong',
        );
        expect(
          validateSearchQuery('   '),
          'Kata kunci pencarian tidak boleh kosong',
        );
        expect(
          validateSearchQuery(null),
          'Kata kunci pencarian tidak boleh kosong',
        );
      });

      test('kasus tepi: menolak pencarian 1 karakter', () {
        // Arrange & Act & Assert
        expect(
          validateSearchQuery('a'),
          'Kata kunci pencarian minimal 2 karakter',
        );
      });
    });
  });
}
