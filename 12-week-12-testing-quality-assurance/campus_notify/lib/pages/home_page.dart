import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../messaging/push_service.dart';
import '../providers/auth_provider.dart';
import '../routes.dart';
import 'widgets/ai_assistant_banner_card.dart';
import 'widgets/announcement_section.dart';
import 'widgets/auth_status_card.dart';
import 'widgets/fcm_status_card.dart';
import 'widgets/fcm_testing_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String? _accessToken;
  String? _refreshToken;
  bool _isLoadingTokens = true;
  bool _isSubscribed = true;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _loadSecureTokens();
    _isSubscribed = PushService.instance.isSubscribedToCampus;
  }

  Future<void> _loadSecureTokens() async {
    setState(() => _isLoadingTokens = true);
    final store = ref.read(tokenStoreProvider);
    final access = await store.readAccess();
    final refresh = await store.readRefresh();
    if (mounted) {
      setState(() {
        _accessToken = access;
        _refreshToken = refresh;
        _isLoadingTokens = false;
      });
    }
  }

  Future<void> _handleRefreshTokens() async {
    setState(
      () => _statusMessage = 'Memperbarui access token via refresh token...',
    );
    try {
      final newAccess = await ref
          .read(authStateProvider.notifier)
          .simulateRefreshToken();
      await _loadSecureTokens();
      if (mounted) {
        setState(() {
          _statusMessage =
              'Token berhasil diperbarui! (${maskToken(newAccess)})';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _statusMessage = 'Gagal refresh token: $e');
      }
    }
  }

  Future<void> _toggleTopic() async {
    if (_isSubscribed) {
      await PushService.instance.unsubscribeFromTopic('pengumuman-kampus');
      setState(() {
        _isSubscribed = false;
        _statusMessage = 'Berhenti langganan topik "pengumuman-kampus"';
      });
    } else {
      await PushService.instance.subscribeToTopic('pengumuman-kampus');
      setState(() {
        _isSubscribed = true;
        _statusMessage = 'Berlangganan topik "pengumuman-kampus"';
      });
    }
  }

  Future<void> _triggerSimulatedForegroundNotification() async {
    await PushService.instance.simulateLocalNotification(
      title: 'Jadwal Kuliah Berubah',
      body: 'Kelas Pemrograman Mobile pindah ke Ruang A2 jam 13.00 (Klik untuk buka rute /pengumuman/3)',
      route: AppRoutes.announcementDetail('3'),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Notifikasi lokal foreground dikirim. Ketuk banner di atas!',
          ),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ─── Optimasi Riverpod: select hanya atribut yang dibutuhkan ───────────────
    // Mencegah rebuild HomePage bila properti lain di authState berubah
    final _ = ref.watch(
      authStateProvider.select((s) => s.asData?.value ?? false),
    );

    final maskedAccess = maskToken(_accessToken);
    final maskedRefresh = maskToken(_refreshToken);
    final fcmToken = PushService.instance.lastKnownToken;
    final maskedFcm = maskToken(
      fcmToken ?? 'device-fcm-token-simulated-xyz789',
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Campus Notify Dashboard'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Tanya Asisten AI',
            icon: const Icon(Icons.smart_toy_outlined),
            onPressed: () => context.push(AppRoutes.chat),
          ),
          IconButton(
            tooltip: 'Keluar (Logout)',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Konfirmasi Logout'),
                  content: const Text(
                    'Token di Secure Storage akan dihapus dan Anda akan dialihkan ke halaman login.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await ref.read(authStateProvider.notifier).logout();
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'ai_assistant_fab',
        onPressed: () => context.push(AppRoutes.chat),
        backgroundColor: const Color(0xFF1E3A8A),
        icon: const Icon(Icons.smart_toy_rounded, color: Colors.white),
        label: const Text(
          'Tanya Asisten AI',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadSecureTokens,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Status banner jika ada aksi
            if (_statusMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Color(0xFF1E3A8A),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _statusMessage!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () => setState(() => _statusMessage = null),
                    ),
                  ],
                ),
              ),

            // Card 0: Asisten AI Kampus (const widget & RepaintBoundary)
            const AiAssistantBannerCard(),
            const SizedBox(height: 16),

            // Card 1: Auth & Secure Storage Status
            AuthStatusCard(
              isLoadingTokens: _isLoadingTokens,
              maskedAccess: maskedAccess,
              maskedRefresh: maskedRefresh,
              onRefreshToken: _handleRefreshTokens,
            ),
            const SizedBox(height: 16),

            // Card 2: FCM & Topic Messaging Status
            FcmStatusCard(
              maskedFcm: maskedFcm,
              isSubscribed: _isSubscribed,
              onToggleTopic: _toggleTopic,
            ),
            const SizedBox(height: 16),

            // Card 3: Uji Tiga App State (const callback isolated)
            FcmTestingCard(
              onTriggerForegroundNotification:
                  _triggerSimulatedForegroundNotification,
            ),
            const SizedBox(height: 16),

            // Card 4: Daftar Pengumuman Kampus (const isolated section)
            const AnnouncementSection(),
          ],
        ),
      ),
    );
  }
}
