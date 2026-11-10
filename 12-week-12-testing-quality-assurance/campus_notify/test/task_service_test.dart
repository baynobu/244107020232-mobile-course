import 'package:campus_notify/features/tasks/task_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fake implementation dari [TaskRepository] untuk pengujian unit terisolasi.
/// Memungkinkan pengujian mengontrol perilaku sukses maupun error secara deterministik
/// tanpa ketergantungan pada jaringan internet atau basis data fisik.
class FakeTaskRepository implements TaskRepository {
  FakeTaskRepository({this.tasks = const [], this.error});

  final List<String> tasks;
  final Exception? error;

  @override
  Future<List<String>> getTasks() async {
    if (error != null) throw error!;
    return tasks;
  }
}

void main() {
  group('TaskService & FakeTaskRepository Tests (Week 12 Bagian 4)', () {
    // ─── Skenario Sukses ─────────────────────────────────────────────────────
    test('meneruskan data dari repository saat sukses', () async {
      // Arrange
      final fakeRepo = FakeTaskRepository(
        tasks: ['Baca materi Codelab', 'Kerjakan pengujian unit', 'Submit PR'],
      );
      final service = TaskService(fakeRepo);

      // Act
      final result = await service.loadTasks();

      // Assert
      expect(result, [
        'Baca materi Codelab',
        'Kerjakan pengujian unit',
        'Submit PR',
      ]);
      expect(result.length, 3);
      expect(result.first, 'Baca materi Codelab');
    });

    // ─── Skenario Kegagalan (Failure Handling) ──────────────────────────────
    test('melempar exception ketika repository mengalami kegagalan', () async {
      // Arrange
      final fakeRepo = FakeTaskRepository(
        error: Exception('Koneksi database lokal terputus'),
      );
      final service = TaskService(fakeRepo);

      // Act & Assert
      // Memastikan error tidak berubah diam-diam menjadi daftar kosong
      expect(
        () => service.loadTasks(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Koneksi database lokal terputus'),
          ),
        ),
      );
    });

    // ─── Skenario Kasus Tepi (Edge Case: Data Kosong) ────────────────────────
    test(
      'mengembalikan list kosong saat repositori tidak memiliki data',
      () async {
        // Arrange
        final fakeRepo = FakeTaskRepository(tasks: const []);
        final service = TaskService(fakeRepo);

        // Act
        final result = await service.loadTasks();

        // Assert
        expect(result, isEmpty);
        expect(result.length, 0);
      },
    );
  });
}
