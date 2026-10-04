import 'dart:developer' as developer;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../routes.dart';

/// Top-level background handler wajib dengan anotasi @pragma('vm:entry-point')
/// karena dieksekusi pada isolate background terpisah.
/// PERINGATAN: Jangan pernah mengakses BuildContext atau Riverpod di sini!
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Hanya melakukan pencatatan atau penyimpanan lokal ringan jika diperlukan.
  developer.log(
    'FCM Background message diterima: id=${message.messageId}, title=${message.notification?.title}',
    name: 'PushService',
  );
}

class PushService {
  PushService._();
  static final PushService instance = PushService._();

  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
  String? pendingDeepLink;
  String? lastKnownToken;
  bool isSubscribedToCampus = false;

  // Channel notifikasi dengan prioritas tinggi agar banner Heads-Up selalu muncul di Android 8+
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'campus_announcements_channel',
    'Pengumuman Kampus',
    description: 'Saluran pengumuman resmi akademik kampus',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  /// Registrasi handler background FCM sebelum runApp
  void registerBackgroundHandler() {
    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    } catch (e) {
      developer.log('Peringatan: Gagal mendaftarkan background handler: $e', name: 'PushService');
    }
  }

  /// Meminta izin notifikasi runtime (wajib untuk Android 13+ dan iOS)
  Future<bool> requestNotificationPermission() async {
    try {
      // 1. Izin FCM
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
      );

      // 2. Izin runtime Android 13+ (POST_NOTIFICATIONS)
      final androidPlugin = _local.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final localGranted = await androidPlugin?.requestNotificationsPermission() ?? false;

      final isGranted = settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional ||
          localGranted;
      developer.log('Status izin notifikasi: $isGranted (FCM: ${settings.authorizationStatus}, Local: $localGranted)', name: 'PushService');
      return isGranted;
    } catch (e) {
      developer.log('Gagal meminta izin notifikasi: $e', name: 'PushService');
      return false;
    }
  }

  /// Inisialisasi plugin notifikasi lokal untuk menampilkan banner di foreground
  Future<void> initLocalNotifications(void Function(String route)? onSelectNotification) async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _local.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          pendingDeepLink = payload;
          if (onSelectNotification != null) {
            onSelectNotification(payload);
          }
        }
      },
    );

    // Daftarkan Channel ke sistem Android
    final androidPlugin = _local.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_channel);
  }

  /// Lifecycle token FCM: mengambil token aktif, memantau rotasi, dan subscribe topik default
  Future<void> initFcmToken({
    required Future<void> Function(String token) onToken,
  }) async {
    try {
      // 1. Ambil token saat ini dan kirim ke backend (POST /devices)
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        lastKnownToken = token;
        developer.log(
          'FCM Token berhasil diambil: ${maskToken(token)}',
          name: 'PushService',
        );
        await onToken(token);
      }

      // 2. Listener wajib untuk rotasi token (reinstall, clear cache, update security)
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        lastKnownToken = newToken;
        developer.log(
          'FCM Token diperbarui (onTokenRefresh): ${maskToken(newToken)}',
          name: 'PushService',
        );
        await onToken(newToken);
      });

      // 3. Langganan topik pengumuman massal kampus
      await subscribeToTopic('pengumuman-kampus');
      isSubscribedToCampus = true;
    } catch (e) {
      developer.log('Gagal inisialisasi FCM token: $e', name: 'PushService');
    }
  }

  /// Menangani pesan saat aplikasi berada di Foreground dan saat banner diklik dari Background
  void listenForeground(void Function(String route) go) {
    try {
      // State 1: Foreground -> sistem TIDAK menampilkan banner otomatis,
      // sehingga kita tampilkan manual via flutter_local_notifications
      FirebaseMessaging.onMessage.listen((message) async {
        final route = routeFromMessage(message.data);
        const androidDetails = AndroidNotificationDetails(
          'campus_announcements_channel',
          'Pengumuman Kampus',
          channelDescription: 'Saluran pengumuman resmi akademik kampus',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          icon: '@mipmap/ic_launcher',
        );
        const notificationDetails = NotificationDetails(android: androidDetails);

        await _local.show(
          id: message.hashCode,
          title: message.notification?.title ?? 'Pengumuman Kampus',
          body: message.notification?.body ?? 'Ketuk untuk membuka pengumuman',
          notificationDetails: notificationDetails,
          payload: route,
        );
      });

      // State 2: Background -> aplikasi di-minimize, banner sistem diklik oleh pengguna
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        final route = routeFromMessage(message.data);
        go(route);
      });
    } catch (e) {
      developer.log('Gagal mengaktifkan listener pesan FCM: $e', name: 'PushService');
    }
  }

  /// State 3: Terminated -> aplikasi dimatikan/swipe-close lalu dibuka dari notifikasi
  Future<void> handleTerminated(void Function(String route) go) async {
    try {
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) {
        final route = routeFromMessage(initial.data);
        go(route);
        return;
      }

      if (pendingDeepLink != null) {
        final route = pendingDeepLink!;
        pendingDeepLink = null;
        go(route);
      }
    } catch (e) {
      developer.log('Gagal membaca initial message FCM: $e', name: 'PushService');
    }
  }

  /// Langganan topik broadcast
  Future<void> subscribeToTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      if (topic == 'pengumuman-kampus') isSubscribedToCampus = true;
      developer.log('Berhasil subscribe topik: $topic', name: 'PushService');
    } catch (e) {
      developer.log('Gagal subscribe topik $topic: $e', name: 'PushService');
    }
  }

  /// Berhenti langganan topik broadcast
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      if (topic == 'pengumuman-kampus') isSubscribedToCampus = false;
      developer.log('Berhasil unsubscribe topik: $topic', name: 'PushService');
    } catch (e) {
      developer.log('Gagal unsubscribe topik $topic: $e', name: 'PushService');
    }
  }

  /// Simulasi notifikasi lokal (berguna untuk pengujian foreground tanpa backend aktif)
  Future<void> simulateLocalNotification({
    required String title,
    required String body,
    required String route,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'campus_announcements_channel',
      'Pengumuman Kampus',
      channelDescription: 'Saluran pengumuman resmi akademik kampus',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );
    await _local.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(android: androidDetails),
      payload: route,
    );
  }
}
