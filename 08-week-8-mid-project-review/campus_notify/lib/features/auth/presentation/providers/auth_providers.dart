import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_user.dart';

// ─── Layer Data ───────────────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

// ─── Layer Domain ─────────────────────────────────────────────────────────────

final loginUserProvider = Provider<LoginUser>((ref) {
  return LoginUser(ref.watch(authRepositoryProvider));
});

// ─── Layer Presentation: state login ─────────────────────────────────────────

/// State boolean: true = sudah login, false = belum login.
/// Widget tidak pernah memanggil Secure Storage secara langsung.
final authStateProvider = AsyncNotifierProvider<AuthNotifier, bool>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final token = await ref.watch(authRepositoryProvider).readAccessToken();
    return token != null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(loginUserProvider)
          .call(email: email, password: password);
      if (result.failure != null) {
        throw Exception(result.failure!.message);
      }
      return true;
    });
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).clearSession();
    ref.invalidateSelf();
  }

  /// Simulasi refresh token manual (untuk demonstrasi di dashboard).
  Future<String?> simulateRefreshToken() async {
    final repo = ref.read(authRepositoryProvider);
    final refreshToken = await repo.readRefreshToken();
    if (refreshToken == null) return null;

    final result = await repo.refresh(refreshToken);
    if (result.failure != null) throw Exception(result.failure!.message);

    final newAccess = result.accessToken!;
    // Simpan access token baru ke Secure Storage (refresh token tetap sama)
    await repo.saveSession(
      AuthSession(accessToken: newAccess, refreshToken: refreshToken),
    );
    ref.invalidateSelf();
    return newAccess;
  }
}
