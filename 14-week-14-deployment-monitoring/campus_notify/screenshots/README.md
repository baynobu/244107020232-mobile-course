# Direktori Tangkapan Layar (Screenshots) Week 12: Pengujian dan Jaminan Kualitas

Dokumentasi visual bukti eksekusi pengujian otomatis, analisis statis, cakupan kode (*code coverage*), serta pengujian integrasi aplikasi **Campus Notify**:

1. `01_unit_tests_pass.png`
   - Bukti eksekusi unit testing fungsi validasi (`isValidTaskTitle`, `validateEmail`, `validatePassword`, `validateSearchQuery`) dan fake repository (`TaskService` & `FakeTaskRepository`) menggunakan pola Arrange-Act-Assert (AAA) yang lulus 100%.

2. `02_widget_tests_pass.png`
   - Bukti eksekusi widget testing antarmuka `LoginPage` (pemeriksaan tampilan form awal, validasi masukan kosong, email tanpa `@`, password < 6 karakter, form submission) dan `AnnouncementSection` / `AnnouncementCardTile` yang lulus 100%.

3. `03_all_tests_green.png`
   - Bukti eksekusi seluruh suite pengujian otomatis (`flutter test`) yang mencakup 60 pengujian (unit test, fake repository test, caching test, routing test, widget test) dengan status **All tests passed!**.

4. `04_coverage_report.png`
   - Ringkasan tabel cakupan kode (*code coverage report*) yang dihasilkan melalui `flutter test --coverage` dan `coverage/lcov.info` yang membuktikan cakupan kode hingga 100% pada logika validasi dan komponen UI utama.

5. `05_static_analysis_clean.png`
   - Bukti eksekusi analisis statis Dart/Flutter (`flutter analyze`) dengan hasil **No issues found!** (bebas lint warning maupun error).

6. `06_integration_test_execution.png`
   - Bukti perintah eksekusi pengujian integrasi end-to-end (`integration_test/app_test.dart`) beserta diagnostik perangkat host (identifikasi kebutuhan toolchain desktop C++ MSBuild atau perangkat emulator Android).

7. `07_app_ui_testing_flow.png`
   - Visualisasi alur antarmuka pengguna (UI Test Flow) dari keadaan validasi error pada form login hingga transisi sukses menuju dashboard pengumuman akademik kampus.
