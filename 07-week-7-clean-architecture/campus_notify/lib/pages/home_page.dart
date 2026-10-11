import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../messaging/push_service.dart';
import '../providers/auth_provider.dart';
import '../routes.dart';

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
    setState(() => _statusMessage = 'Memperbarui access token via refresh token...');
    try {
      final newAccess = await ref.read(authStateProvider.notifier).simulateRefreshToken();
      await _loadSecureTokens();
      if (mounted) {
        setState(() {
          _statusMessage = 'Token berhasil diperbarui! (${maskToken(newAccess)})';
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
          content: Text('Notifikasi lokal foreground dikirim. Ketuk banner di atas!'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final maskedAccess = maskToken(_accessToken);
    final maskedRefresh = maskToken(_refreshToken);
    final fcmToken = PushService.instance.lastKnownToken;
    final maskedFcm = maskToken(fcmToken ?? 'device-fcm-token-simulated-xyz789');

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Campus Notify Dashboard'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        actions: [
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
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Logout', style: TextStyle(color: Colors.white)),
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
      body: RefreshIndicator(
        onRefresh: _loadSecureTokens,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Status banner jika ada aksi
            if (_statusMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 20, color: Color(0xFF1E3A8A)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _statusMessage!,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF1E3A8A)),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () => setState(() => _statusMessage = null),
                    ),
                  ],
                ),
              ),

            // Card 1: Auth & Secure Storage Status
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.security, color: Color(0xFF1E3A8A)),
                        const SizedBox(width: 8),
                        const Text(
                          'Autentikasi & Secure Storage',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Logged In',
                            style: TextStyle(
                              color: Colors.green.shade800,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    if (_isLoadingTokens) const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: LinearProgressIndicator(),
                    ),
                    _buildTokenRow('Access Token (Masked):', maskedAccess),
                    const SizedBox(height: 6),
                    _buildTokenRow('Refresh Token (Masked):', maskedRefresh),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _handleRefreshTokens,
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Simulasi Refresh Token 1x'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Card 2: FCM & Topic Messaging Status
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.cloud_sync_outlined, color: Colors.deepOrange),
                        const SizedBox(width: 8),
                        const Text(
                          'FCM & Topic Messaging',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    _buildTokenRow('FCM Registration Token:', maskedFcm),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Topik: pengumuman-kampus',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            Text(
                              _isSubscribed ? 'Status: Terdaftar (Subscribed)' : 'Status: Berhenti (Unsubscribed)',
                              style: TextStyle(
                                fontSize: 12,
                                color: _isSubscribed ? Colors.green.shade700 : Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: _toggleTopic,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isSubscribed ? Colors.red.shade50 : Colors.green.shade50,
                            foregroundColor: _isSubscribed ? Colors.red : Colors.green.shade800,
                            elevation: 0,
                            side: BorderSide(
                              color: _isSubscribed ? Colors.red.shade200 : Colors.green.shade300,
                            ),
                          ),
                          child: Text(_isSubscribed ? 'Unsubscribe' : 'Subscribe'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Card 3: Uji Tiga App State
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.science_outlined, color: Colors.teal),
                        const SizedBox(width: 8),
                        const Text(
                          'Uji Tiga App State FCM',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Uji coba penerimaan payload gabungan {notification + data: {"route": "/pengumuman/3"}}:',
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _triggerSimulatedForegroundNotification,
                      icon: const Icon(Icons.notification_add_outlined),
                      label: const Text('Kirim Notifikasi Foreground (Banner Lokal)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(42),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Foreground: Klik banner notifikasi di atas untuk navigasi ke /pengumuman/3.\n'
                      '• Background: Tekan tombol Home Android, kirim push via FCM console, lalu klik banner.\n'
                      '• Terminated: Swipe-close aplikasi, kirim push via FCM console, lalu klik banner.',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade700, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Card 4: Daftar Pengumuman Kampus
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.campaign, color: Color(0xFF1E3A8A)),
                        const SizedBox(width: 8),
                        const Text(
                          'Daftar Pengumuman Kampus',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    _buildAnnouncementTile(
                      id: '1',
                      title: 'Jadwal Kuliah Semester Baru',
                      subtitle: 'Pengecekan KRS dan ruang kelas',
                    ),
                    _buildAnnouncementTile(
                      id: '2',
                      title: 'Pendaftaran Beasiswa Prestasi',
                      subtitle: 'Pendaftaran dibuka mulai 1 Oktober',
                    ),
                    _buildAnnouncementTile(
                      id: '3',
                      title: 'Jadwal Kuliah Berubah (Target FCM)',
                      subtitle: 'Kelas Mobile pindah ke Ruang A2 jam 13.00',
                      isHighlight: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Color(0xFF334155),
                  ),
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.copy, size: 14, color: Colors.grey),
                tooltip: 'Salin nilai terpotong',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nilai token terpotong disalin ke clipboard'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementTile({
    required String id,
    required String title,
    required String subtitle,
    bool isHighlight = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isHighlight ? const Color(0xFFEFF6FF) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isHighlight ? const Color(0xFF93C5FD) : const Color(0xFFE2E8F0),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isHighlight ? const Color(0xFF1E3A8A) : Colors.grey.shade200,
          child: Text(
            id,
            style: TextStyle(
              color: isHighlight ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, size: 18),
        onTap: () => context.go(AppRoutes.announcementDetail(id)),
      ),
    );
  }
}
