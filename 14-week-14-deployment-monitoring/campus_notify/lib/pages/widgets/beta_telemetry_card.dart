import 'package:flutter/material.dart';

import '../../core/telemetry_service.dart';

/// Card interaktif pengujian Telemetry, Analytics, dan Crashlytics untuk penguji rilis beta internal.
class BetaTelemetryCard extends StatefulWidget {
  const BetaTelemetryCard({super.key});

  @override
  State<BetaTelemetryCard> createState() => _BetaTelemetryCardState();
}

class _BetaTelemetryCardState extends State<BetaTelemetryCard> {
  String? _statusLog;
  bool _isLoading = false;

  Future<void> _handleSendFeedback() async {
    setState(() => _isLoading = true);
    await TelemetryService.instance.logBetaFeedbackSent(
      screenName: 'home',
      category: 'beta_internal_eval',
    );
    if (mounted) {
      setState(() {
        _isLoading = false;
        _statusLog = '✓ Event "beta_feedback_sent" berhasil dicatat ke Firebase Analytics.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Feedback beta dikirim (Analytics: beta_feedback_sent)',
          ),
          backgroundColor: Colors.teal,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleTriggerNonFatal() async {
    setState(() => _isLoading = true);
    await TelemetryService.instance.triggerSimulatedNonFatalError();
    if (mounted) {
      setState(() {
        _isLoading = false;
        _statusLog = '✓ Non-fatal error disimulasikan & dicatat ke Firebase Crashlytics.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Non-fatal error dicatat ke Crashlytics.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleShowCrashDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Uji Fatal Crash'),
        content: const Text(
          'Tindakan ini akan memicu fatal crash buatan untuk memverifikasi laporan Crashlytics pada perangkat uji internal. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              TelemetryService.instance.triggerSimulatedFatalCrash();
            },
            child: const Text('Picu Fatal Crash'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.analytics, color: Colors.deepPurple),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Beta Telemetry & Monitoring',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Kandidat Rilis v1.4.0+14 • Track: Internal Testing',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Text(
                    'BETA',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              'Gunakan tombol di bawah untuk menguji sinyal telemetri yang terhubung ke Firebase Crashlytics & Analytics:',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleSendFeedback,
                  icon: const Icon(Icons.feedback_outlined, size: 18),
                  label: const Text('Kirim Feedback (Analytics)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade50,
                    foregroundColor: Colors.teal.shade800,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _handleTriggerNonFatal,
                  icon: const Icon(Icons.bug_report_outlined, size: 18),
                  label: const Text('Uji Non-Fatal Error'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange.shade800,
                  ),
                ),
                TextButton.icon(
                  onPressed: _handleShowCrashDialog,
                  icon: const Icon(Icons.dangerous_outlined, size: 18),
                  label: const Text('Uji Fatal Crash'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                  ),
                ),
              ],
            ),
            if (_statusLog != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  _statusLog!,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
