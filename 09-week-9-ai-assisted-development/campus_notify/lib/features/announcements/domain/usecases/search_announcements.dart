import '../entities/announcement.dart';

/// Use case murni domain untuk memfilter daftar pengumuman kampus berdasarkan kata kunci.
///
/// Karakteristik Clean Architecture:
/// - Berada di layer domain: bebas dari import Flutter, Dio, SQLite, atau Firebase.
/// - Berdiri sendiri sebagai unit logika bisnis yang murni (pure Dart).
/// - Mudah diuji secara terisolasi tanpa memerlukan mock framework berat.
///
/// Aturan bisnis pencarian:
/// 1. Query kosong atau spasi murni (`trim().isEmpty`) mengembalikan seluruh data asli tanpa filter.
/// 2. Pencarian bersifat case-insensitive (`toLowerCase()`).
/// 3. Mencari substring pada properti `title`, `body`, dan `category`.
class SearchAnnouncements {
  const SearchAnnouncements();

  /// Menjalankan filter pencarian pada [announcements] dengan [query].
  List<Announcement> call({
    required List<Announcement> announcements,
    required String query,
  }) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) {
      return announcements;
    }

    return announcements.where((announcement) {
      final titleMatch = announcement.title.toLowerCase().contains(cleanQuery);
      final categoryMatch = announcement.category.toLowerCase().contains(
        cleanQuery,
      );
      final bodyMatch = announcement.body.toLowerCase().contains(cleanQuery);
      return titleMatch || categoryMatch || bodyMatch;
    }).toList();
  }
}
