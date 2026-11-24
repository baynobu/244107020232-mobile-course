# Panduan Screenshot Bukti Praktikum Minggu 14 (Deployment dan Monitoring)

Direktori ini digunakan untuk menyimpan seluruh bukti visual pelaksanaan rilis beta kandidat, pengujian internal, dashboard monitoring telemetri (Firebase Crashlytics & Analytics), serta antarmuka pengujian telemetri pada aplikasi `campus_notify`.

---

## Daftar File Screenshot

| No | Nama File | Deskripsi Tampilan | Status |
|:---:|:---|:---|:---:|
| 1 | `01_play_console_internal_testing.png` | Antarmuka Google Play Console / Track Internal Testing yang menampilkan rilis kandidat `v1.4.0 (14)` berstatus aktif dengan artefak AAB dan daftar penguji terdaftar. | Wajib |
| 2 | `02_firebase_crashlytics_dashboard.png` | Dashboard Firebase Crashlytics yang menampilkan metrik stabilitas *Crash-Free Sessions* (99.2%), 0 fatal crash pada alur utama, dan pencatatan error non-fatal pengujian. | Wajib |
| 3 | `03_firebase_analytics_events.png` | Dashboard Firebase Analytics / DebugView yang memperlihatkan pencatatan event non-sensitif `beta_feedback_sent` beserta parameter aman (`screen_name: home`). | Wajib |
| 4 | `04_app_telemetry_ui.png` | Tangkapan layar antarmuka aplikasi `campus_notify` yang menampilkan card interaktif `Beta Telemetry & Monitoring` di halaman beranda (*HomePage*). | Wajib |
| 5 | `05_local_checks_and_build_green.png` | Terminal PowerShell lokal yang menampilkan hasil eksekusi rangkaian verifikasi pre-release: `dart format`, `flutter analyze --fatal-infos`, dan `flutter test` (66/66 tests passed). | Wajib |

---

## Petunjuk Pengambilan / Pengecekan Screenshot

1. **`01_play_console_internal_testing.png`:**
   - Memperlihatkan informasi rilis: Nama Paket `com.example.campus_notify`, Versi `1.4.0`, Build `14`, Track: `Internal testing`, Status: `Available to internal testers`.
2. **`02_firebase_crashlytics_dashboard.png`:**
   - Menunjukkan grafik stabilitas aplikasi, persentase sesi bebas crash, serta rincian log pengecualian non-fatal yang disimulasikan dari aplikasi.
3. **`03_firebase_analytics_events.png`:**
   - Menunjukkan tabel event Analytics yang mencakup event `beta_feedback_sent` dan `app_open`, serta parameter yang terbukti bebas dari data PII.
4. **`04_app_telemetry_ui.png`:**
   - Menampilkan komponen `BetaTelemetryCard` pada `HomePage` dengan status feedback yang berhasil terkirim.
5. **`05_local_checks_and_build_green.png`:**
   - Menampilkan terminal Windows PowerShell saat menjalankan perintah format, analisis kode statis, dan seluruh 66 pengujian otomatis yang lulus 100%.
