import 'package:flutter/material.dart';

/// Card Uji Tiga App State FCM.
///
/// Komponen sebagian besar statis dengan callback terisolasi,
/// dibungkus [RepaintBoundary] untuk efisiensi pipeline rendering.
class FcmTestingCard extends StatelessWidget {
  const FcmTestingCard({
    super.key,
    required this.onTriggerForegroundNotification,
  });

  final VoidCallback onTriggerForegroundNotification;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.science_outlined, color: Colors.teal),
                  SizedBox(width: 8),
                  Text(
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
                onPressed: onTriggerForegroundNotification,
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
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
