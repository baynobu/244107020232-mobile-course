import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week3_navigation/pages/stats_page.dart';

void main() {
  group('StatsNotifier Tests', () {
    test('State awal harusnya AsyncLoading', () {
      // Membuat ProviderContainer sebagai "wadah" terisolasi untuk state provider selama testing
      final container = ProviderContainer();
      
      // Memastikan container di-dispose setelah test selesai agar tidak terjadi memory leak
      addTearDown(container.dispose);

      // Membaca state provider sesaat setelah container dibuat
      final state = container.read(statsProvider);

      // Memeriksa bahwa state awalnya adalah status loading
      expect(state.isLoading, isTrue);
      expect(state, isA<AsyncLoading<TodoStats>>());
    });

    test('Fungsi retry() harus mengubah state menjadi AsyncLoading kembali', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Tambahkan listener agar Riverpod tetap memantau provider ini secara aktif
      // Tanpa listener, state update bisa diabaikan atau future bisa menggantung
      final subscription = container.listen(statsProvider, (_, _) {});

      // 1. Menunggu proses pengambilan data (build) yang pertama kali selesai.
      try {
        await container.read(statsProvider.future);
      } catch (_) {}

      // Setelah Future selesai, pastikan status isLoading adalah false
      expect(subscription.read().isLoading, isFalse);

      // 2. Mengambil instance dari notifier
      final notifier = container.read(statsProvider.notifier);
      
      // 3. Memanggil retry() tapi tidak kita `await` di awal
      final retryFuture = notifier.retry();

      // State harus langsung berubah ke loading
      expect(subscription.read().isLoading, isTrue);

      // Tunggu hingga eksekusi retry() tuntas
      await retryFuture;
    });

    test('Proses pengambilan data (sukses atau gagal) menghasilkan state yang sesuai', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      
      final subscription = container.listen(statsProvider, (_, _) {});

      try {
        await container.read(statsProvider.future);
        
        final state = subscription.read();
        expect(state.hasValue, isTrue);
        expect(state.value, isNotNull);
        expect(state.value!.totalTasks, 0); // Karena default list todo kosong
      } catch (e) {
        final state = subscription.read();
        expect(state.hasError, isTrue);
        expect(state.error.toString(), contains('Gagal mengambil data statistik'));
      }
    });
  });
}
