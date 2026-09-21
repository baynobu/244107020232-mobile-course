import 'package:flutter_test/flutter_test.dart';
import 'package:week4_app/data/models/comment.dart';

void main() {
  group('Comment Model fromJson Unit Tests', () {
    // 1. Menguji kasus saat semua field hilang atau bernilai null pada payload JSON
    test('fromJson berhasil menangani JSON dengan field yang hilang / null tanpa crash', () {
      final jsonWithMissingFields = <String, dynamic>{};

      final comment = Comment.fromJson(jsonWithMissingFields);

      // Verifikasi bahwa nilai default fallback digunakan dengan aman
      expect(comment.postId, 0);
      expect(comment.id, 0);
      expect(comment.name, '');
      expect(comment.email, '');
      expect(comment.body, '');
    });

    // 2. Edge Case: Menguji field yang bernilai null secara eksplisit dan tipe number (double)
    test('fromJson menangani field bernilai null secara eksplisit dan casting num safely', () {
      final jsonWithExplicitNullsAndDouble = <String, dynamic>{
        'postId': 12.0, // dikirim sebagai double bukan int murni
        'id': 45,
        'name': null,
        'email': 'user@example.com',
        'body': null,
      };

      final comment = Comment.fromJson(jsonWithExplicitNullsAndDouble);

      expect(comment.postId, 12);
      expect(comment.id, 45);
      expect(comment.name, ''); // null fallback ke empty string
      expect(comment.email, 'user@example.com');
      expect(comment.body, ''); // null fallback ke empty string
    });

    // 3. Happy Path: Menguji payload normal dan validasi serialisasi toJson()
    test('fromJson dan toJson berhasil memproses payload lengkap dengan benar', () {
      final validJson = <String, dynamic>{
        'postId': 1,
        'id': 101,
        'name': 'id labore ex et quam laborum',
        'email': 'Eliseo@gardner.biz',
        'body': 'laudantium enim quasi est quidem magnam voluptate ipsam eos',
      };

      final comment = Comment.fromJson(validJson);

      expect(comment.postId, 1);
      expect(comment.id, 101);
      expect(comment.name, 'id labore ex et quam laborum');
      expect(comment.email, 'Eliseo@gardner.biz');
      expect(comment.body, contains('laudantium enim'));

      // Uji round-trip toJson
      expect(comment.toJson(), equals(validJson));
    });
  });
}
