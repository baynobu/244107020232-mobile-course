/// Entity murni domain `Announcement`.
/// Tidak ada import Flutter, Dio, SQLite, ataupun mapping JSON/SQL.
/// Semua transformasi data (toMap/fromMap/toJson) hanya ada di [AnnouncementModel]
/// yang tinggal di layer data.
class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.category,
    required this.body,
    required this.author,
    required this.publishedAt,
  });

  final String id;
  final String title;
  final String category;
  final String body;
  final String author;
  final DateTime publishedAt;
}
