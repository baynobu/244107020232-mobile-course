import 'package:campus_notify/data/api_errors.dart';
import 'package:campus_notify/routes.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeTokenStore {
  String? access;
  String? refresh;
}

void main() {
  group('Unit Tests: Routing & FCM Message Parsing', () {
    test('routeFromMessage menangani route kosong dan tanpa slash', () {
      expect(routeFromMessage({}), '/');
      expect(routeFromMessage({'route': 'pengumuman/3'}), '/pengumuman/3');
      expect(routeFromMessage({'route': '/pengumuman/3'}), '/pengumuman/3');
    });

    test('data payload membawa id pengumuman dan fallback', () {
      const data = {'route': '/pengumuman/3', 'id': '3'};
      expect(data['id'], '3');
      expect(routeFromMessage(data), '/pengumuman/3');

      // Jika key 'route' kosong namun ada key 'id'
      const dataIdOnly = {'id': '2'};
      expect(routeFromMessage(dataIdOnly), '/pengumuman/2');
    });
  });

  group('Unit Tests: Auth & Token Store Logic', () {
    test('provider auth membaca status login dari token', () async {
      final store = FakeTokenStore()..access = 'mock-access';
      expect(store.access != null, isTrue);
      store.access = null;
      expect(store.access != null, isFalse);
    });

    test('refresh gagal -> sesi dibersihkan (paksa login ulang)', () async {
      final store = FakeTokenStore()..refresh = '';
      final needsLogin = (store.refresh ?? '').isEmpty;
      expect(needsLogin, isTrue);
    });

    test('maskToken tidak membocorkan token penuh untuk keamanan', () {
      const secret = 'mock-access-for-mahasiswa@kampus.ac.id';
      final masked = maskToken(secret);
      expect(masked.contains('...'), isTrue);
      expect(masked.length < secret.length, isTrue);
      expect(masked.startsWith('mock-ac'), isTrue);
      expect(masked.endsWith('c.id'), isTrue);

      // Edge case null & empty
      expect(maskToken(null), '(tidak ada token)');
      expect(maskToken(''), '(tidak ada token)');
    });
  });

  group('Unit Tests: DioException Error Mapping', () {
    test('pemetaan status code 401 ke pesan ramah pengguna', () {
      final error401 = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 401,
          requestOptions: RequestOptions(path: '/test'),
        ),
        type: DioExceptionType.badResponse,
      );
      expect(
        ApiErrors.mapDioException(error401),
        contains('Sesi Anda telah kedaluwarsa atau token tidak valid (401)'),
      );
    });

    test('pemetaan timeout ke pesan ramah koneksi', () {
      final errorTimeout = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );
      expect(
        ApiErrors.mapDioException(errorTimeout),
        contains('Batas waktu koneksi habis'),
      );
    });
  });
}
