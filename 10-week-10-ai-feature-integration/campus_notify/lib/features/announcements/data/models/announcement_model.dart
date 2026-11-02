import '../../domain/entities/announcement.dart';

/// Model data `Announcement` — tinggal di layer data.
///
/// Mengextend entity [Announcement] agar substitusi Liskov (LSP) terpenuhi:
/// di mana pun [Announcement] diharapkan, [AnnouncementModel] dapat menggantikannya.
/// Mapping ke/dari representasi luar (JSON / mock map) hanya ada di sini,
/// bukan di entity domain.
class AnnouncementModel extends Announcement {
  const AnnouncementModel({
    required super.id,
    required super.title,
    required super.category,
    required super.body,
    required super.author,
    required super.publishedAt,
  });

  /// Membuat [AnnouncementModel] dari map (JSON / SQLite row / mock data).
  factory AnnouncementModel.fromMap(Map<String, dynamic> map) {
    return AnnouncementModel(
      id: map['id']?.toString() ?? '',
      title: map['title'] as String? ?? '',
      category: map['category'] as String? ?? 'Umum',
      body: map['body'] as String? ?? '',
      author: map['author'] as String? ?? '',
      publishedAt: map['published_at'] != null
          ? DateTime.tryParse(map['published_at'] as String) ??
                DateTime.fromMillisecondsSinceEpoch(0)
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  /// Mengekspor model ke Map (untuk penyimpanan lokal / request API).
  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'category': category,
    'body': body,
    'author': author,
    'published_at': publishedAt.toIso8601String(),
  };

  /// Konversi ke entity murni domain — dipakai di batas data → domain.
  Announcement toEntity() => Announcement(
    id: id,
    title: title,
    category: category,
    body: body,
    author: author,
    publishedAt: publishedAt,
  );
}
