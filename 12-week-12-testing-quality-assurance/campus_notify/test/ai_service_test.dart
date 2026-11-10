import 'dart:convert';

import 'package:campus_notify/ai/ai_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

class MockHttpClient extends http.BaseClient {
  final http.Response Function(http.Request request) handler;
  MockHttpClient(this.handler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final req = request as http.Request;
    final res = handler(req);
    return http.StreamedResponse(
      Stream.value(utf8.encode(res.body)),
      res.statusCode,
      headers: res.headers,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AiService Unit Tests', () {
    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
    });

    test('Pertanyaan kosong melempar Exception', () async {
      final aiService = AiService();
      expect(
        () => aiService.ask('   ', fallbackToLocal: false),
        throwsA(isA<Exception>()),
      );
    });

    test(
      'Tanpa API key dan fallback=true mengembalikan respons offline lokal',
      () async {
        final aiService = AiService();
        final result = await aiService.ask(
          'kapan jadwal kuliah semester baru?',
        );
        expect(result, contains('jadwal perkuliahan'));
      },
    );

    test('Tanpa API key dan fallback=false melempar Exception', () async {
      final aiService = AiService();
      expect(
        () => aiService.ask('Info KRS', fallbackToLocal: false),
        throwsA(isA<Exception>()),
      );
    });

    test('Simpan dan baca API Key di Secure Storage', () async {
      final aiService = AiService();
      expect(await aiService.hasApiKey(), isFalse);

      await aiService.saveApiKey('AIzaSyDummyTestKey123');
      expect(await aiService.hasApiKey(), isTrue);
      expect(await aiService.getApiKey(), equals('AIzaSyDummyTestKey123'));

      await aiService.clearApiKey();
      expect(await aiService.hasApiKey(), isFalse);
    });

    test('Offline Fallback mendeteksi kata kunci kampus dengan akurat', () {
      final aiService = AiService();

      expect(
        aiService.getOfflineFallbackResponse('jadwal kuliah'),
        contains('SIAKAD'),
      );
      expect(
        aiService.getOfflineFallbackResponse('registrasi KRS'),
        contains('KRS'),
      );
      expect(
        aiService.getOfflineFallbackResponse('surat izin sakit'),
        contains('dokter'),
      );
      expect(
        aiService.getOfflineFallbackResponse('pengajuan beasiswa'),
        contains('beasiswa'),
      );
      expect(
        aiService.getOfflineFallbackResponse('kontak bantuan'),
        contains('admin@polinema.ac.id'),
      );
      expect(
        aiService.getOfflineFallbackResponse('pertanyaan acak'),
        contains('asisten kampus'),
      );
    });

    test(
      'Berhasil memanggil Gemini API dan mem-parse respons JSON dengan benar',
      () async {
        FlutterSecureStorage.setMockInitialValues({
          'ai_api_key': 'AIzaMockKey',
        });

        final mockClient = MockHttpClient((request) {
          expect(request.url.queryParameters['key'], equals('AIzaMockKey'));
          expect(request.headers['Content-Type'], equals('application/json'));

          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(
            body['contents'][0]['parts'][0]['text'],
            equals('Bagaimana cara KRS?'),
          );
          expect(
            body['systemInstruction']['parts'][0]['text'],
            contains('Campus Notify'),
          );

          return http.Response(
            jsonEncode({
              'candidates': [
                {
                  'content': {
                    'parts': [
                      {
                        'text': 'Pengisian KRS dapat dilakukan melalui portal akademik resmi.',
                      },
                    ],
                  },
                },
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final aiService = AiService(client: mockClient);
        final response = await aiService.ask('Bagaimana cara KRS?');

        expect(
          response,
          equals(
            'Pengisian KRS dapat dilakukan melalui portal akademik resmi.',
          ),
        );
      },
    );

    test(
      'Error HTTP dari API memicu offline fallback bila fallbackToLocal=true',
      () async {
        FlutterSecureStorage.setMockInitialValues({
          'ai_api_key': 'AIzaMockKey',
        });

        final mockClient = MockHttpClient((request) {
          return http.Response('Internal Server Error', 500);
        });

        final aiService = AiService(client: mockClient);
        final response = await aiService.ask('jadwal kuliah hari senin');

        expect(response, contains('jadwal perkuliahan'));
        expect(response, contains('Mode Offline Aktif'));
      },
    );
  });
}
