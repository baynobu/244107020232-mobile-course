import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week3_navigation/providers/todo_providers.dart';

// Model untuk menyimpan data statistik To Do
class TodoStats {
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;

  TodoStats({
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
  });
}

// AsyncNotifier untuk mengelola state dan mensimulasikan pengambilan data statistik
class StatsNotifier extends AsyncNotifier<TodoStats> {
  // Fungsi ini dipanggil pertama kali saat provider digunakan
  // Berguna untuk menginisialisasi state awal (loading -> data/error)
  @override
  Future<TodoStats> build() async {
    // Dengan memanggil ref.watch di sini, Riverpod akan otomatis
    // me-rebuild (menjalankan ulang) simulasi pengambilan data ini
    // setiap kali ada perubahan pada daftar tugas (tambah/hapus/centang).
    ref.watch(todoListProvider);
    return _fetchStats();
  }

  // Fungsi internal untuk mensimulasikan proses pengambilan data (misal: dari API)
  Future<TodoStats> _fetchStats() async {
    // Simulasi delay jaringan selama 2 detik
    await Future.delayed(const Duration(seconds: 2));

    // Simulasi probabilitas kegagalan (30% kemungkinan gagal)
    final random = Random();
    if (random.nextDouble() < 0.3) {
      // Jika masuk ke dalam 30%, kita lemparkan exception agar state menjadi AsyncError
      throw Exception('Gagal mengambil data statistik. Silakan coba lagi.');
    }

    // Mengambil data To Do dari provider utama yang sebenarnya
    final todos = ref.read(todoListProvider);

    final total = todos.length;
    final completed = todos.where((todo) => todo.done).length;
    final pending = total - completed;

    // Mengembalikan objek data statistik yang nyata
    return TodoStats(
      totalTasks: total,
      completedTasks: completed,
      pendingTasks: pending,
    );
  }

  // Fungsi untuk memicu pengambilan data ulang ketika terjadi error
  Future<void> retry() async {
    // Ubah state saat ini menjadi loading kembali
    state = const AsyncValue.loading();
    // Jalankan ulang fungsi pengambilan data, AsyncValue.guard akan menangani
    // secara otomatis jika hasilnya sukses (data) atau gagal (error) lagi
    state = await AsyncValue.guard(() => _fetchStats());
  }
}

// Provider global untuk mengakses StatsNotifier di UI
// AsyncNotifierProvider digunakan khusus untuk provider berbasis AsyncNotifier
final statsProvider = AsyncNotifierProvider<StatsNotifier, TodoStats>(() {
  return StatsNotifier();
});

// Halaman UI yang menggunakan ConsumerWidget agar dapat merespons perubahan state Riverpod
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Membaca dan mendengarkan state terkini dari statsProvider (bisa loading, data, atau error)
    final statsAsyncValue = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik To Do'),
      ),
      // .when adalah cara elegan Riverpod untuk menangani 3 kondisi async (data, error, loading)
      body: statsAsyncValue.when(
        data: (stats) {
          // 1. KONDISI SUKSES (Data berhasil didapat)
          // Menampilkan listview dengan 3 item sesuai requirement
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              ListTile(
                leading: const Icon(Icons.list_alt, color: Colors.blue, size: 36),
                title: const Text('Total Tugas'),
                subtitle: const Text('Semua tugas yang pernah dibuat'),
                trailing: Text('${stats.totalTasks}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green, size: 36),
                title: const Text('Tugas Selesai'),
                subtitle: const Text('Tugas yang sudah diselesaikan'),
                trailing: Text('${stats.completedTasks}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.pending_actions, color: Colors.orange, size: 36),
                title: const Text('Tugas Tertunda'),
                subtitle: const Text('Tugas yang masih harus dikerjakan'),
                trailing: Text('${stats.pendingTasks}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
        error: (error, stackTrace) {
          // 2. KONDISI ERROR (Gagal mengambil data)
          // Menampilkan pesan error dan tombol retry
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    // Menghilangkan prefix "Exception:" dari pesan error agar lebih rapi
                    error.toString().replaceAll('Exception: ', ''),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Saat tombol ditekan, panggil metode retry() pada notifier
                      ref.read(statsProvider.notifier).retry();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () {
          // 3. KONDISI LOADING (Sedang mengambil data)
          // Menampilkan spinner indikator proses
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Mengambil data statistik...'),
              ],
            ),
          );
        },
      ),
    );
  }
}
