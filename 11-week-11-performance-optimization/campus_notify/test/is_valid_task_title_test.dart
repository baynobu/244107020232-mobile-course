import 'package:campus_notify/is_valid_task_title.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isValidTaskTitle', () {
    // ─── Test Skenario Normal ──────────────────────────────────────────────
    test('menerima judul yang berisi teks', () {
      // Arrange
      const title = 'Belajar Flutter';

      // Act
      final result = isValidTaskTitle(title);

      // Assert
      expect(result, isTrue);
    });

    // ─── Test Kasus Tepi / Nilai Batas (Boundary Cases) ─────────────────────
    test('menolak teks kosong atau hanya spasi', () {
      // Arrange & Act & Assert
      expect(isValidTaskTitle(''), isFalse);
      expect(isValidTaskTitle('   '), isFalse);
      expect(isValidTaskTitle('\t\n  \r'), isFalse);
    });

    test('menerima judul dengan spasi di awal dan akhir selama ada teks', () {
      // Arrange & Act & Assert
      expect(isValidTaskTitle('   Tugas Mobile   '), isTrue);
      expect(isValidTaskTitle(' Praktikum Pengujian Kualitas '), isTrue);
    });

    test('menerima judul dengan karakter simbol dan angka', () {
      // Arrange & Act & Assert
      expect(isValidTaskTitle('Tugas #12: Unit Testing 100%'), isTrue);
      expect(isValidTaskTitle('12345'), isTrue);
    });
  });
}

