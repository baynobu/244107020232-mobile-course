import '../../../../core/failures.dart';
import '../entities/auth_session.dart';

/// Kontrak repository autentikasi — tinggal di domain.
/// Implementasi ada di layer data ([AuthRepositoryImpl]).
abstract class AuthRepository {
  /// Login dengan email dan password.
  Future<({AuthSession? session, Failure? failure})> login({
    required String email,
    required String password,
  });

  /// Memperbarui access token menggunakan refresh token.
  Future<({String? accessToken, Failure? failure})> refresh(
    String refreshToken,
  );

  /// Membaca access token aktif dari penyimpanan aman.
  Future<String?> readAccessToken();

  /// Membaca refresh token dari penyimpanan aman.
  Future<String?> readRefreshToken();

  /// Menyimpan sesi ke penyimpanan aman.
  Future<void> saveSession(AuthSession session);

  /// Menghapus seluruh data sesi (logout).
  Future<void> clearSession();
}
