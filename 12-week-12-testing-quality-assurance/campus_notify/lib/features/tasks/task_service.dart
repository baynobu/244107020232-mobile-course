/// Kontrak abstraksi sumber data tugas (Sesuai modul Week 12 Bagian 4).
abstract interface class TaskRepository {
  Future<List<String>> getTasks();
}

/// Layanan logika bisnis tugas yang mengonsumsi [TaskRepository] via dependency injection.
class TaskService {
  TaskService(this._repository);

  final TaskRepository _repository;

  /// Memuat daftar tugas dari repositori.
  Future<List<String>> loadTasks() {
    return _repository.getTasks();
  }
}

