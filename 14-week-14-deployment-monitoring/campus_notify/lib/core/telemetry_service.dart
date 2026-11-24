import 'dart:developer' as developer;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Service telemetri terpusat untuk memantau stabilitas aplikasi (Crashlytics)
/// dan pola penggunaan fitur beta (Analytics) dengan kepatuhan privasi (PII Protection).
class TelemetryService {
  TelemetryService._();
  static final TelemetryService instance = TelemetryService._();

  bool _isFirebaseAvailable = false;
  bool get isFirebaseAvailable => _isFirebaseAvailable;

  /// Daftar kata kunci sensitif yang dilarang dikirimkan ke telemetry (PII Protection)
  static const List<String> sensitiveKeywords = [
    'password',
    'token',
    'secret',
    'auth',
    'credential',
    'email',
    'nim',
    'phone',
    'nik',
    'pin',
    'bearer',
  ];

  /// Inisialisasi telemetry service dengan deteksi ketersediaan Firebase
  Future<void> initialize() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        _isFirebaseAvailable = true;

        // Atur pengumpulan Crashlytics di mode release atau debug terarah
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
          !kDebugMode,
        );

        developer.log(
          'TelemetryService: Firebase Crashlytics & Analytics aktif.',
          name: 'TelemetryService',
        );
      } else {
        _isFirebaseAvailable = false;
        developer.log(
          'TelemetryService: Firebase apps kosong, beralih ke local mock logging.',
          name: 'TelemetryService',
        );
      }
    } catch (e) {
      _isFirebaseAvailable = false;
      developer.log(
        'TelemetryService: Inisialisasi telemetry fallback ke mock: $e',
        name: 'TelemetryService',
      );
    }
  }

  /// Memfilter parameter agar terbebas dari Personally Identifiable Information (PII)
  Map<String, Object> sanitizeParameters(Map<String, Object>? rawParams) {
    if (rawParams == null || rawParams.isEmpty) {
      return {};
    }

    final sanitized = <String, Object>{};
    for (final entry in rawParams.entries) {
      final keyLower = entry.key.toLowerCase();
      final isSensitiveKey = sensitiveKeywords.any(
        (kw) => keyLower.contains(kw),
      );

      if (isSensitiveKey) {
        sanitized[entry.key] = '[REDACTED_PII]';
      } else {
        final valStr = entry.value.toString().toLowerCase();
        final containsSensitiveValue = sensitiveKeywords.any(
          (kw) => valStr.contains(kw),
        );
        if (containsSensitiveValue) {
          sanitized[entry.key] = '[REDACTED_PII]';
        } else {
          sanitized[entry.key] = entry.value;
        }
      }
    }
    return sanitized;
  }

  /// Mencatat event Analytics non-sensitif ke Firebase Analytics
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    final cleanParams = sanitizeParameters(parameters);

    developer.log(
      'Analytics Event: "$name" -> $cleanParams',
      name: 'TelemetryService',
    );

    if (_isFirebaseAvailable) {
      try {
        await FirebaseAnalytics.instance.logEvent(
          name: name,
          parameters: cleanParams,
        );
      } catch (e) {
        developer.log(
          'Gagal mencatat Analytics event: $e',
          name: 'TelemetryService',
        );
      }
    }
  }

  /// Event khusus feedback beta sesuai modul minggu 14
  Future<void> logBetaFeedbackSent({
    required String screenName,
    String? category,
  }) async {
    await logEvent(
      name: 'beta_feedback_sent',
      parameters: {
        'screen_name': screenName,
        'category': category ?? 'general_feedback',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Mencatat error non-fatal ke Firebase Crashlytics
  Future<void> recordNonFatalError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
  }) async {
    developer.log(
      'Crashlytics Non-Fatal: $exception (Reason: $reason)',
      name: 'TelemetryService',
      error: exception,
      stackTrace: stack,
    );

    if (_isFirebaseAvailable) {
      try {
        await FirebaseCrashlytics.instance.recordError(
          exception,
          stack,
          fatal: false,
          reason: reason,
        );
      } catch (e) {
        developer.log(
          'Gagal mengirim ke Crashlytics: $e',
          name: 'TelemetryService',
        );
      }
    }
  }

  /// Mencatat error fatal (unhandled) ke Firebase Crashlytics
  Future<void> recordFatalError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
  }) async {
    developer.log(
      'Crashlytics FATAL: $exception (Reason: $reason)',
      name: 'TelemetryService',
      error: exception,
      stackTrace: stack,
    );

    if (_isFirebaseAvailable) {
      try {
        await FirebaseCrashlytics.instance.recordError(
          exception,
          stack,
          fatal: true,
          reason: reason,
        );
      } catch (e) {
        developer.log(
          'Gagal mengirim fatal error ke Crashlytics: $e',
          name: 'TelemetryService',
        );
      }
    }
  }

  /// Memicu simulasi error non-fatal untuk menguji konektivitas dashboard telemetry
  Future<void> triggerSimulatedNonFatalError() async {
    await recordNonFatalError(
      Exception('Uji telemetry non-fatal dari tester internal'),
      StackTrace.current,
      reason: 'Pengujian integrasi Crashlytics kandidat rilis v1.4.0',
    );
  }

  /// Memicu simulasi fatal crash untuk pengujian perangkat uji (jangan pakai di produksi)
  void triggerSimulatedFatalCrash() {
    if (_isFirebaseAvailable) {
      FirebaseCrashlytics.instance.crash();
    } else {
      throw StateError('Simulasi Fatal Crash untuk verifikasi Crashlytics');
    }
  }
}
