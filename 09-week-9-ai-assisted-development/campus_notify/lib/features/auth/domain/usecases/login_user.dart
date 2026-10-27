import '../../../../core/failures.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

/// Use case: login pengguna.
///
/// Use case ini memisahkan logika validasi bisnis dari presentasi.
/// Widget hanya memanggil `LoginUser(repo).call(email, password)` tanpa
/// tahu cara auth diimplementasikan (mock, Firebase, atau REST API).
class LoginUser {
  const LoginUser(this._repository);

  final AuthRepository _repository;

  Future<({AuthSession? session, Failure? failure})> call({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }
}
