/// Hierarki Failure domain — murni Dart, tanpa import Flutter/Dio/SQLite.
/// Setiap error yang melintas batas data → presentation harus dibungkus
/// menjadi salah satu subclass Failure ini agar UI hanya menerima [message].
sealed class Failure {
  const Failure(this.message);
  final String message;
}

/// Kesalahan yang berasal dari penyimpanan lokal (SQLite, Secure Storage, dst.).
class LocalFailure extends Failure {
  const LocalFailure(super.message);
}

/// Kesalahan yang berasal dari jaringan (Dio, HTTP, Firebase, dst.).
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Kesalahan validasi bisnis murni (tidak bergantung pada I/O).
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
