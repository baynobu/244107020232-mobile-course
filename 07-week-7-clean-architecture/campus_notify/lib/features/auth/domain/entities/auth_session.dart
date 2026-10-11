/// Entity domain `AuthSession` — representasi sesi login yang berhasil.
/// Murni Dart: tanpa import Flutter, tanpa mapping JSON.
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;
}
