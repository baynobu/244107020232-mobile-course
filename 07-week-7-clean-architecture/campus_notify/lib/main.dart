import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'messaging/push_service.dart';
import 'pages/announcement_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'providers/auth_provider.dart';
import 'routes.dart';

// Global router key untuk navigasi dari push notifications
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final loggedIn = authState.value ?? false;

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.home,
    redirect: (context, state) {
      // Tunggu hingga status auth selesai dibaca dari secure storage
      if (authState.isLoading) return null;

      final goingLogin = state.matchedLocation == AppRoutes.login;

      // 1. Belum login dan mencoba akses selain /login -> redirect ke /login
      if (!loggedIn && !goingLogin) {
        return AppRoutes.login;
      }

      // 2. Sudah login dan berada di /login -> redirect ke / (home)
      if (loggedIn && goingLogin) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.announcementDetailPattern,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '1';
          return AnnouncementPage(id: id);
        },
      ),
    ],
  );
});

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase secara aman (graceful fallback bila google-services.json belum disematkan)
  try {
    await Firebase.initializeApp();
    PushService.instance.registerBackgroundHandler();
  } catch (e) {
    developer.log(
      'Catatan: Firebase belum terkonfigurasi google-services.json secara lokal. '
      'Aplikasi beralih ke mock push mode: $e',
      name: 'Main',
    );
  }

  runApp(
    const ProviderScope(
      child: CampusNotifyApp(),
    ),
  );
}

class CampusNotifyApp extends ConsumerStatefulWidget {
  const CampusNotifyApp({super.key});

  @override
  ConsumerState<CampusNotifyApp> createState() => _CampusNotifyAppState();
}

class _CampusNotifyAppState extends ConsumerState<CampusNotifyApp> {
  @override
  void initState() {
    super.initState();
    _setupPushNotifications();
  }

  Future<void> _setupPushNotifications() async {
    final router = ref.read(routerProvider);

    // Inisialisasi local notification plugin
    await PushService.instance.initLocalNotifications((route) {
      router.go(route);
    });

    // Minta notification permission runtime
    await PushService.instance.requestNotificationPermission();

    // Inisialisasi FCM Token & kirim ke backend (POST /devices simulasi)
    await PushService.instance.initFcmToken(
      onToken: (token) async {
        // Simulasi POST /devices dengan Dio client
        try {
          final dio = ref.read(apiClientProvider);
          developer.log(
            'Kirim token ke backend: POST ${dio.options.baseUrl}/devices { fcm_token: ${maskToken(token)}, platform: "android" }',
            name: 'DeviceRegistration',
          );
          // Backend simulasi / nyata
          // await dio.post('/devices', data: {'fcm_token': token, 'platform': 'android'});
        } catch (_) {}
      },
    );

    // Aktifkan listener Foreground dan Background
    PushService.instance.listenForeground((route) {
      router.go(route);
    });

    // Periksa Terminated state (dibuka dari notifikasi saat aplikasi mati)
    await PushService.instance.handleTerminated((route) {
      router.go(route);
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Campus Notify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
