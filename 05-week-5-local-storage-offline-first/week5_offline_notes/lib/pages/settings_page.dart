import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/prefs.dart';

final prefsRepositoryProvider = Provider<PrefsRepository>((ref) => PrefsRepository());

final darkModeProvider =
    AsyncNotifierProvider<DarkModeNotifier, bool>(DarkModeNotifier.new);

class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() =>
      ref.watch(prefsRepositoryProvider).getDarkMode();

  Future<void> toggle() async {
    final next = !(state.value ?? false);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(prefsRepositoryProvider).setDarkMode(next);
      return next;
    });
  }
}

final lastOpenedProvider = FutureProvider<String?>((ref) async {
  return ref.watch(prefsRepositoryProvider).getLastOpened();
});

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  String _formatTimestamp(String? iso) {
    if (iso == null || iso.isEmpty) return 'Belum pernah dicatat';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    final year = dt.year.toString().padLeft(4, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute:$second';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkModeAsync = ref.watch(darkModeProvider);
    final lastOpenedAsync = ref.watch(lastOpenedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan & Preferensi'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.brightness_6_outlined),
                  title: const Text('Tema Gelap'),
                  subtitle: const Text('Simpan preferensi tema dengan SharedPreferences'),
                  trailing: darkModeAsync.when(
                    data: (isDark) => Switch(
                      value: isDark,
                      onChanged: (_) {
                        ref.read(darkModeProvider.notifier).toggle();
                      },
                    ),
                    loading: () => const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    error: (err, stack) => Switch(
                      value: false,
                      onChanged: (_) {
                        ref.read(darkModeProvider.notifier).toggle();
                      },
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.history_toggle_off_outlined),
                  title: const Text('Waktu Terakhir Dibuka'),
                  subtitle: lastOpenedAsync.when(
                    data: (val) => Text(_formatTimestamp(val)),
                    loading: () => const Text('Memuat data...'),
                    error: (err, _) => Text('Gagal memuat: $err'),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Perbarui Catatan Pembukaan',
                    onPressed: () async {
                      await ref.read(prefsRepositoryProvider).markOpenedNow();
                      ref.invalidate(lastOpenedProvider);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Tentang Penyimpanan Lokal',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'SharedPreferences digunakan khusus untuk pasangan key-value berukuran kecil seperti konfigurasi tema dan timestamp terakhir dibuka.\n\n'
                    'Untuk data terstruktur seperti catatan, SQLite (sqflite) digunakan agar query, indexing, dan transaksi tetap aman dan cepat.',
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
