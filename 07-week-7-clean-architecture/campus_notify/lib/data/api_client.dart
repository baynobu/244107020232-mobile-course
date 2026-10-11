import 'package:dio/dio.dart';
import 'auth_repository.dart';
import 'token_store.dart';

Dio buildApiClient(
  TokenStore store,
  AuthRepository auth, {
  void Function()? onForceLogout,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://example-campus-api.test',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final access = await store.readAccess();
        if (access != null) {
          options.headers['Authorization'] = 'Bearer $access';
        }
        handler.next(options);
      },
      onError: (e, handler) async {
        // Cek jika error adalah 401 Unauthorized dan belum pernah dicoba ulang (retry)
        final isRetry = e.requestOptions.extra['isRetry'] == true;
        if (e.response?.statusCode == 401 && !isRetry) {
          final refresh = await store.readRefresh();
          if (refresh == null) {
            await store.clear();
            onForceLogout?.call();
            return handler.next(e);
          }

          try {
            // Mencoba merefresh token 1x
            final renewed = await auth.refresh(refresh);
            await store.save(access: renewed, refresh: refresh);

            // Ulangi request 1x dengan token baru
            final requestOptions = e.requestOptions;
            requestOptions.headers['Authorization'] = 'Bearer $renewed';
            requestOptions.extra['isRetry'] = true;

            final retryResponse = await dio.fetch(requestOptions);
            return handler.resolve(retryResponse);
          } catch (_) {
            // Refresh token gagal/kedaluwarsa -> bersihkan secure storage dan logout
            await store.clear();
            onForceLogout?.call();
          }
        }
        handler.next(e);
      },
    ),
  );

  return dio;
}
