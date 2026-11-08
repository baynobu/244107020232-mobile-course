import 'package:flutter/material.dart';

import 'token_display_tile.dart';

/// Card Status Autentikasi dan Secure Storage.
///
/// Memanfaatkan [RepaintBoundary] sehingga animasi loading bar saat token refresh
/// tidak memicu re-paint kartu lain di layar dashboard.
class AuthStatusCard extends StatelessWidget {
  const AuthStatusCard({
    super.key,
    required this.isLoadingTokens,
    required this.maskedAccess,
    required this.maskedRefresh,
    required this.onRefreshToken,
  });

  final bool isLoadingTokens;
  final String maskedAccess;
  final String maskedRefresh;
  final VoidCallback onRefreshToken;

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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
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
              if (isLoadingTokens)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: LinearProgressIndicator(),
                ),
              TokenDisplayTile(
                label: 'Access Token (Masked):',
                value: maskedAccess,
              ),
              const SizedBox(height: 6),
              TokenDisplayTile(
                label: 'Refresh Token (Masked):',
                value: maskedRefresh,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onRefreshToken,
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
    );
  }
}
