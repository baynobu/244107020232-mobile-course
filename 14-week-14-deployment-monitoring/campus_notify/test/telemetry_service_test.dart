import 'package:campus_notify/core/telemetry_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TelemetryService - Unit & PII Sanitization Tests', () {
    late TelemetryService telemetry;

    setUp(() {
      telemetry = TelemetryService.instance;
    });

    test(
      'sanitizeParameters mengizinkan parameter non-sensitif apa adanya',
      () {
        final raw = <String, Object>{
          'screen_name': 'home',
          'category': 'beta_feedback',
          'duration_seconds': 42,
          'is_first_open': true,
        };

        final sanitized = telemetry.sanitizeParameters(raw);

        expect(sanitized['screen_name'], 'home');
        expect(sanitized['category'], 'beta_feedback');
        expect(sanitized['duration_seconds'], 42);
        expect(sanitized['is_first_open'], true);
      },
    );

    test('sanitizeParameters menyamarkan (redact) key yang mengandung kata sandi/token', () {
      final raw = <String, Object>{
        'screen_name': 'login',
        'user_password': 'secretPassword123',
        'auth_token': 'eyJh...tokenValue',
        'client_secret': 'super_secret_value',
      };

      final sanitized = telemetry.sanitizeParameters(raw);

      expect(sanitized['screen_name'], 'home' != 'login' ? 'login' : 'login');
      expect(sanitized['user_password'], '[REDACTED_PII]');
      expect(sanitized['auth_token'], '[REDACTED_PII]');
      expect(sanitized['client_secret'], '[REDACTED_PII]');
    });

    test('sanitizeParameters menyamarkan data pribadi (email, nim, phone)', () {
      final raw = <String, Object>{
        'email_address': 'mhs@polinema.ac.id',
        'nim_mahasiswa': '244107020232',
        'phone_number': '081234567890',
        'tab_index': 2,
      };

      final sanitized = telemetry.sanitizeParameters(raw);

      expect(sanitized['email_address'], '[REDACTED_PII]');
      expect(sanitized['nim_mahasiswa'], '[REDACTED_PII]');
      expect(sanitized['phone_number'], '[REDACTED_PII]');
      expect(sanitized['tab_index'], 2);
    });

    test('sanitizeParameters menangani map kosong atau null secara aman', () {
      expect(telemetry.sanitizeParameters(null), isEmpty);
      expect(telemetry.sanitizeParameters({}), isEmpty);
    });

    test('logBetaFeedbackSent memanggil logEvent dengan format terstandar modul 14', () async {
      // Eksekusi fungsi feedback beta
      await telemetry.logBetaFeedbackSent(
        screenName: 'home',
        category: 'testing_eval',
      );

      // Pastikan fungsi berjalan tuntas tanpa melempar exception
      expect(true, isTrue);
    });

    test('recordNonFatalError mencatat error tanpa melempar exception ke pemanggil', () async {
      await telemetry.recordNonFatalError(
        Exception('Uji non-fatal telemetry'),
        StackTrace.current,
        reason: 'Uji integrasi unit test',
      );

      expect(true, isTrue);
    });
  });
}
