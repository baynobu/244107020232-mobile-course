import 'package:flutter/material.dart';

import 'token_display_tile.dart';

/// Card Status FCM & Topic Messaging.
///
/// Mengisolasi repaint tombol subscribe/unsubscribe menggunakan [RepaintBoundary].
class FcmStatusCard extends StatelessWidget {
  const FcmStatusCard({
    super.key,
    required this.maskedFcm,
    required this.isSubscribed,
    required this.onToggleTopic,
  });

  final String maskedFcm;
  final bool isSubscribed;
  final VoidCallback onToggleTopic;

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
                  Icon(Icons.cloud_sync_outlined, color: Colors.deepOrange),
                  SizedBox(width: 8),
                  Text(
                    'FCM & Topic Messaging',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Divider(height: 20),
              TokenDisplayTile(
                label: 'FCM Registration Token:',
                value: maskedFcm,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Topik: pengumuman-kampus',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        isSubscribed
                            ? 'Status: Terdaftar (Subscribed)'
                            : 'Status: Berhenti (Unsubscribed)',
                        style: TextStyle(
                          fontSize: 12,
                          color: isSubscribed
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: onToggleTopic,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSubscribed
                          ? Colors.red.shade50
                          : Colors.green.shade50,
                      foregroundColor: isSubscribed
                          ? Colors.red
                          : Colors.green.shade800,
                      elevation: 0,
                      side: BorderSide(
                        color: isSubscribed
                            ? Colors.red.shade200
                            : Colors.green.shade300,
                      ),
                    ),
                    child: Text(isSubscribed ? 'Unsubscribe' : 'Subscribe'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
