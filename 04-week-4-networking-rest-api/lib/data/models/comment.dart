/// Model data untuk Comment dari JSONPlaceholder.
/// Semua field bersifat immutable (final) dan memiliki konstruktor const.
class Comment {
  const Comment({
    required this.postId,
    required this.id,
    required this.name,
    required this.email,
    required this.body,
  });

  final int postId;
  final int id;
  final String name;
  final String email;
  final String body;

  /// Factory constructor yang aman terhadap nilai null dan tipe data tidak terduga.
  /// Menggunakan safe casting (`as num?`, `as String?`) dan fallback nilai default
  /// sehingga tidak terjadi crash (misal TypeError) saat ada field yang hilang / bernilai null.
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      postId: (json['postId'] as num?)?.toInt() ?? 0,
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );
  }

  /// Mengonversi object Comment kembali ke format Map (JSON).
  Map<String, dynamic> toJson() => {
        'postId': postId,
        'id': id,
        'name': name,
        'email': email,
        'body': body,
      };
}
