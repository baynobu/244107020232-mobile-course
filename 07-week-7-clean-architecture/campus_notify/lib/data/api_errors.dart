import 'package:dio/dio.dart';

/// Pemetaan error DioException dan Exception umum menjadi pesan ramah pengguna.
class ApiErrors {
  static String mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Batas waktu koneksi habis. Silakan periksa jaringan internet Anda.';

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        switch (statusCode) {
          case 400:
            return 'Permintaan tidak valid (400). Mohon periksa kembali data Anda.';
          case 401:
            return 'Sesi Anda telah kedaluwarsa atau token tidak valid (401). Silakan login kembali.';
          case 403:
            return 'Akses ditolak (403). Anda tidak memiliki hak akses ke sumber daya ini.';
          case 404:
            return 'Layanan atau data tidak ditemukan di server kampus (404).';
          case 500:
          case 502:
          case 503:
            return 'Server kampus sedang mengalami gangguan ($statusCode). Silakan coba lagi nanti.';
          default:
            return 'Terjadi kesalahan respons dari server ($statusCode).';
        }

      case DioExceptionType.connectionError:
        return 'Gagal terhubung ke server kampus. Pastikan perangkat Anda terhubung ke internet.';

      case DioExceptionType.cancel:
        return 'Permintaan ke server dibatalkan.';

      case DioExceptionType.badCertificate:
        return 'Sertifikat keamanan server tidak valid.';

      case DioExceptionType.unknown:
      default:
        return error.message ?? 'Terjadi kesalahan jaringan yang tidak terduga.';
    }
  }

  static String toUserFriendlyMessage(Object error) {
    if (error is DioException) {
      return mapDioException(error);
    }
    if (error is Exception) {
      final msg = error.toString();
      return msg.startsWith('Exception: ') ? msg.substring(11) : msg;
    }
    return error.toString();
  }
}
