import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/failures.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';

/// Implementasi [AuthRepository] — tinggal di layer data.
///
/// Bertanggung jawab untuk:
/// - Simulasi autentikasi JWT (plug-and-play dengan Firebase Auth / REST API)
/// - Penyimpanan token di FlutterSecureStorage (Keystore/Keychain)
///
/// Widget tidak pernah tahu kelas ini ada; hanya melihat [AuthRepository].
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  @override
  Future<({AuthSession? session, Failure? failure})> login({
    required String email,
    required String password,
  }) async {
    try {
      // Simulasi JWT — ganti dengan FirebaseAuth atau REST API backend kampus.
      await Future.delayed(const Duration(milliseconds: 500));
      if (!email.contains('@') || password.length < 6) {
        return (
          session: null,
          failure: const ValidationFailure(
            'Email tidak valid atau kata sandi kurang dari 6 karakter',
          ),
        );
      }
      final session = AuthSession(
        accessToken: 'mock-access-for-$email',
        refreshToken: 'mock-refresh-for-$email',
      );
      await saveSession(session);
      return (session: session, failure: null);
    } catch (e) {
      return (session: null, failure: NetworkFailure('Gagal login: $e'));
    }
  }

  @override
  Future<({String? accessToken, Failure? failure})> refresh(
    String refreshToken,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      if (refreshToken.isEmpty) {
        return (
          accessToken: null,
          failure: const ValidationFailure(
            'Refresh token hilang atau tidak valid',
          ),
        );
      }
      final newAccess =
          'mock-access-renewed-${DateTime.now().millisecondsSinceEpoch}';
      return (accessToken: newAccess, failure: null);
    } catch (e) {
      return (
        accessToken: null,
        failure: NetworkFailure('Gagal refresh token: $e'),
      );
    }
  }

  @override
  Future<String?> readAccessToken() => _storage.read(key: _accessKey);

  @override
  Future<String?> readRefreshToken() => _storage.read(key: _refreshKey);

  @override
  Future<void> saveSession(AuthSession session) async {
    await _storage.write(key: _accessKey, value: session.accessToken);
    await _storage.write(key: _refreshKey, value: session.refreshToken);
  }

  @override
  Future<void> clearSession() => _storage.deleteAll();
}
