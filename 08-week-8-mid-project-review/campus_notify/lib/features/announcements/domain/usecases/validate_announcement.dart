import '../../../../core/failures.dart';

/// Use case murni domain untuk memvalidasi input pengumuman sebelum disimpan atau dipublikasikan.
///
/// Mengikuti prinsip Clean Architecture:
/// - Murni Dart, tanpa dependensi ke Flutter UI, database (SQLite), maupun network (Dio).
/// - Mengembalikan [ValidationFailure] jika ada aturan bisnis yang dilanggar,
///   atau `null` jika data valid.
class ValidateAnnouncement {
  const ValidateAnnouncement();

  /// Kategori pengumuman resmi yang diizinkan di sistem kampus.
  static const List<String> allowedCategories = [
    'Akademik',
    'Kemahasiswaan',
    'Perkuliahan',
    'Umum',
  ];

  /// Memvalidasi data masukan pengumuman.
  ///
  /// Aturan bisnis:
  /// 1. Judul tidak boleh kosong dan minimal 5 karakter.
  /// 2. Isi pengumuman tidak boleh kosong dan minimal 10 karakter.
  /// 3. Kategori harus terdaftar dalam [allowedCategories].
  ValidationFailure? call({
    required String title,
    required String body,
    required String category,
  }) {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      return const ValidationFailure('Judul pengumuman tidak boleh kosong');
    }
    if (trimmedTitle.length < 5) {
      return const ValidationFailure('Judul pengumuman minimal 5 karakter');
    }

    final trimmedBody = body.trim();
    if (trimmedBody.isEmpty) {
      return const ValidationFailure('Isi pengumuman tidak boleh kosong');
    }
    if (trimmedBody.length < 10) {
      return const ValidationFailure('Isi pengumuman minimal 10 karakter');
    }

    final trimmedCategory = category.trim();
    if (!allowedCategories.contains(trimmedCategory)) {
      return ValidationFailure(
        'Kategori "$trimmedCategory" tidak valid. Kategori yang diperbolehkan: ${allowedCategories.join(', ')}',
      );
    }

    return null;
  }
}
