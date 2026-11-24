# Campus Notify — Pengujian dan Jaminan Kualitas (Week 12)

Dokumentasi lengkap dan laporan mini project pengujian dan jaminan kualitas (*Testing & Quality Assurance*) tersedia di:
- [README.md Utama Week 12](../README.md)
- [Direktori Tangkapan Layar](../screenshots/README.md)

Seluruh implementasi pengujian:
- `lib/is_valid_task_title.dart` & `lib/core/validators.dart` (Logika Bisnis & Validasi Input)
- `lib/features/tasks/task_service.dart` (Abstraksi Kontrak & Layanan Tugas)
- `test/is_valid_task_title_test.dart` (Unit Test Kasus Tepi Judul Tugas)
- `test/validators_test.dart` (Unit Test Validasi Email, Password, Search Query)
- `test/task_service_test.dart` (Unit Test Dependensi Asinkron & Fake Repository)
- `test/login_page_widget_test.dart` (Widget Test Form Login & State Validasi Error)
- `test/announcement_widget_test.dart` (Widget Test Tampilan Daftar Pengumuman & Tile)
- `integration_test/app_test.dart` (End-to-End Integration Test Alur Login ke Dashboard)
- `test/announcement_caching_test.dart` (Unit Test Caching SWR)
- `test/ai_service_test.dart` & `test/chat_screen_widget_test.dart` (Pengujian AI & UI Chat)
