/// Fungsi-fungsi utilitas pemformatan murni Dart.
/// Dapat diuji tanpa widget atau BuildContext.
///
/// Sesuai Refactoring Challenge §2: formatting tanggal dan parsing rute
/// diekstrak ke sini agar dapat diuji unit tanpa widget.
library;

/// Memformat [DateTime] menjadi string tanggal yang ramah pengguna (Bahasa Indonesia).
/// Contoh: `DateTime(2026, 9, 28)` → `"28 September 2026"`
String formatDate(DateTime date) {
  const months = [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  return '${date.day} ${months[date.month]} ${date.year}';
}

/// Memformat [DateTime] menjadi string tanggal + waktu.
/// Contoh: `DateTime(2026, 9, 28, 8, 30)` → `"28 September 2026, 08.30"`
String formatDateTime(DateTime date) {
  final time = '${date.hour.toString().padLeft(2, '0')}.${date.minute.toString().padLeft(2, '0')}';
  return '${formatDate(date)}, $time';
}

/// Memformat [DateTime] relatif terhadap sekarang.
/// Contoh: "2 hari yang lalu", "Hari ini", dsb.
String formatRelativeDate(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);

  if (diff.inDays == 0) return 'Hari ini';
  if (diff.inDays == 1) return 'Kemarin';
  if (diff.inDays < 7) return '${diff.inDays} hari yang lalu';
  if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} minggu yang lalu';
  return formatDate(date);
}

/// Helper keamanan: masking token agar tidak ter-log atau ditampilkan penuh.
/// Contoh: `"mock-access-for-user@kampus.id"` → `"mock-ac...s.id"`
///
/// Fungsi ini diekstrak dari `routes.dart` ke sini agar dapat diuji secara
/// terisolasi dan konsisten di seluruh codebase.
String maskToken(String? token) {
  if (token == null || token.isEmpty) return '(tidak ada token)';
  if (token.length <= 10) return '***';
  final start = token.substring(0, 7);
  final end = token.substring(token.length - 4);
  return '$start...$end';
}
