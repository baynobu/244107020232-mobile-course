class AppRoutes {
  static const String login = '/login';
  static const String home = '/';
  static const String announcementDetailPattern = '/pengumuman/:id';

  static String announcementDetail(String id) => '/pengumuman/$id';
}

/// Ekstrak rute tujuan dari data payload RemoteMessage.
/// Mendukung rute dengan atau tanpa awalan '/' serta fallback ke '/' jika kosong.
String routeFromMessage(Map<String, dynamic> data) {
  final rawRoute = data['route']?.toString().trim();
  if (rawRoute == null || rawRoute.isEmpty) {
    // Cek alternatif jika backend mengirimkan 'id' secara terpisah
    final id = data['id']?.toString().trim();
    if (id != null && id.isNotEmpty) {
      return AppRoutes.announcementDetail(id);
    }
    return AppRoutes.home;
  }
  return rawRoute.startsWith('/') ? rawRoute : '/$rawRoute';
}

/// Helper fungsi keamanan: masking token agar tidak ter-log atau ditampilkan penuh.
/// Contoh: "mock-access-for-user@kampus.id" -> "mock-ac...s.id"
String maskToken(String? token) {
  if (token == null || token.isEmpty) return '(tidak ada token)';
  if (token.length <= 10) return '***';
  final start = token.substring(0, 7);
  final end = token.substring(token.length - 4);
  return '$start...$end';
}
