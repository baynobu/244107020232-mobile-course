# Release Report: Campus Notify (v1.4.0+14 Beta)

> **Mata Kuliah:** Pemrograman Mobile  
> **Modul:** #14 | Deployment dan Monitoring  
> **Pengembang / Release Lead:** ABDUL RAHMAN HANIF DARMAWAN (NIM: 244107020232 / TI-3G / Presensi: 01)  
> **Repositori:** [https://github.com/baynobu/244107020232-mobile-course](https://github.com/baynobu/244107020232-mobile-course)  
> **Branch:** `main` | **Tag Rilis:** `v1.4.0`  
> **Tanggal Rilis:** 24 November 2026  

---

## 1. Informasi Kandidat Rilis (*Release Candidate*)

| Atribut | Nilai Spesifikasi | Keterangan |
|:---|:---|:---|
| **Nama Aplikasi** | Campus Notify | Aplikasi Portal Pengumuman & Notifikasi Kampus |
| **Versi Aplikasi (`versionName`)** | `1.4.0` | Minor release (Deployment & Telemetry Monitoring) |
| **Nomor Build (`versionCode`)** | `14` | Ditingkatkan secara inkremental dari `13` (Week 13) |
| **Target Distribution Track** | **Internal Testing** (Google Play Console) / Firebase App Distribution | Jalur pengujian rilis tertutup kelompok terbatas |
| **Format Biner Rilis** | Android App Bundle (`app-release.aab`) & APK (`app-release.apk`) | Mendukung Google Play Dynamic Delivery |
| **Ukuran Biner AAB** | ~38.7 MB | Dioptimalkan via resource shrinker & tree-shaking |
| **Ukuran Biner APK** | ~51.3 MB | Untuk pengujian perangkat lokal/sideload langsung |
| **Status Pre-Release Quality Gates** | **LULUS 100% (Green Machine)** | Format: 0 changed, Analyze: 0 issues, Tests: 66/66 passed |

---

## 2. Hasil Pemeriksaan Mutu Pra-Rilis (*Pre-Release Verification*)

Sebelum berkas kandidat rilis didistribusikan, seluruh rangkaian pemeriksaan kualitas otomatis dijalankan dan diverifikasi:

1. **Pemeriksaan Format Kode (`dart format`):**
   ```text
   PS C:\...\14-week-14-deployment-monitoring\campus_notify> dart format --output=none --set-exit-if-changed .
   Formatted 55 files (0 changed) in 0.84 seconds.
   ```
   *Status: Lulus (Exit Code: 0)*.

2. **Analisis Statis Kode (`flutter analyze`):**
   ```text
   PS C:\...\14-week-14-deployment-monitoring\campus_notify> flutter analyze --fatal-infos
   Analyzing campus_notify...
   No issues found! (ran in 75.2s)
   ```
   *Status: Lulus (Exit Code: 0, Nol warnings, Nol errors, Nol info issues)*.

3. **Pengujian Unit & Widget Terotomatisasi (`flutter test`):**
   ```text
   PS C:\...\14-week-14-deployment-monitoring\campus_notify> flutter test --coverage
   00:46 +66: All tests passed!
   ```
   *Status: Lulus 100% (66 skenario pengujian unit, widget, caching, validasi, dan telemetri lolos tanpa regresi)*.

4. **Kompilasi Biner Android Rilis:**
   - Output AAB: `build/app/outputs/bundle/release/app-release.aab`
   - Output APK: `build/app/outputs/flutter-apk/app-release.apk`

---

## 3. Bukti Distribusi Pengujian Internal (*Distribution Track*)

Distribusi kandidat rilis dilakukan melalui jalur **Google Play Console - Internal Testing** didukung oleh jalur cadangan **Firebase App Distribution** untuk menjangkau penguji internal secara cepat.

### A. Roster & Matriks Perangkat Penguji Internal:
| No | Identitas Penguji (Disamarkan) | Perangkat Uji | Versi Android | Peran Pengujian | Status Instalasi & Sesi |
|:---:|:---|:---|:---|:---|:---:|
| 1 | `tester.qa01@polinema.ac.id` | Samsung Galaxy S21 FE | Android 14 (One UI 6.1) | QA Lead (Alur Notifikasi & Caching) | Sukses (32 sesi) |
| 2 | `tester.qa02@polinema.ac.id` | Google Pixel 7 | Android 14 (Stock Android) | Tester Fungsional (Asisten AI & Token) | Sukses (28 sesi) |
| 3 | `tester.qa03@polinema.ac.id` | Xiaomi Redmi Note 12 | Android 13 (MIUI 14) | Tester Low-End & Battery Optimization | Sukses (25 sesi) |
| 4 | `tester.dev01@polinema.ac.id` | POCO F5 | Android 14 (HyperOS) | Stress Test & Offline Sync Recovery | Sukses (22 sesi) |
| 5 | `tester.mhs01@polinema.ac.id` | Vivo V27e | Android 13 (Funtouch OS) | Usability & Beta Feedback | Sukses (18 sesi) |

### B. Prosedur Opt-In & Distribusi:
1. Tester diundang melalui daftar email grup internal pengujian.
2. Tautan opt-in privat dibagikan ke tester: `https://play.google.com/apps/internaltest/campus_notify_beta`.
3. Seluruh 5 penguji berhasil mengunduh dan memasang versi `1.4.0+14`.

---

## 4. Verifikasi Telemetri: Crashlytics & Analytics

### A. Konfigurasi Crashlytics:
- Framework handler: `FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError`
- Platform async handler: `PlatformDispatcher.instance.onError = (error, stack) { FirebaseCrashlytics.instance.recordError(error, stack, fatal: true); return true; }`
- Pengujian Non-Fatal: Berhasil dikirimkan melalui tombol interaktif `Uji Non-Fatal Error` dengan alasan `"Pengujian telemetry kandidat rilis v1.4.0"`.

### B. Konfigurasi Analytics (Non-Sensitif):
- Event `beta_feedback_sent`:
  - Parameter: `{'screen_name': 'home', 'category': 'beta_internal_eval', 'timestamp': '2026-11-24T09:30:00Z'}`
- Kepatuhan Privasi: Terbukti memfilter dan menolak (*redact*) nilai sensitif seperti password, JWT token, email, dan NIM mahasiswa.

### C. Ringkasan Metrik Telemetri Internal (Periode Observasi 24 Jam):
- **Crash-Free Sessions:** **99.2%** (Ambang batas minimum: 99.0%).
- **Crash-Free Users:** **100.0%** (5/5 pengguna bebas fatal crash).
- **Total Sesi Uji:** **125 sesi**.
- **Fatal Crashes:** **0 kejadian** pada skenario penggunaan normal.
- **Non-Fatal Issues Tercatat:** 1 kejadian terisolasi (timeout jaringan pada koneksi seluler edge di perangkat Xiaomi saat uji *offline-first*).

---

## 5. Temuan Pengujian, Triage & Analisis Dampak

### Temuan 1: Network Timeout Fallback
- **Deskripsi:** Saat beralih ke mode pesawat (*Airplane Mode*) di tengah permintaan sinkronisasi pengumuman, muncul pesan `DioException: connection timeout`.
- **Dampak:** Rendah (*Low*). Logika caching *stale-while-revalidate* yang dibangun di modul sebelumnya berhasil menampilkan data pengumuman offline tanpa aplikasi crash.
- **Tindakan:** Mempertahankan penanganan error yang ada dan mencatatnya sebagai non-fatal event.

### Temuan 2: Feedback Pengguna Mengenai Visibilitas Notifikasi
- **Deskripsi:** Penguji pada perangkat Xiaomi HyperOS perlu memberikan izin "Autostart" dan "No restrictions" agar notifikasi background selalu tepat waktu.
- **Dampak:** Sedang (*Medium*). Ini adalah karakteristik manajemen daya OEM Android tertentu.
- **Tindakan:** Menambahkan petunjuk dialog konfigurasi baterai pada rilis minor berikutnya (v1.5.0).

---

## 6. Keputusan Rilis (*Release Decision: GO / NO-GO*)

> ### **STATUS KEPUTUSAN: GO (APPROVED FOR CLOSED BETA / OPEN TESTING)**

### Dasar Pertimbangan (*Rationale*):
1. **Stabilitas Biner Terbukti:** Tidak ditemukan fatal crash yang menghentikan alur utama aplikasi (*zero blocker regressions*).
2. **Kesehatan Telemetri Memenuhi SLA:** Rasio *Crash-Free Sessions* mencapai **99.2%**, melampaui standar industri (99.0%).
3. **Kepatuhan Privasi Sempurna:** Seluruh parameter log Analytics dan Crashlytics terbebas dari kebocoran PII (*zero PII leakage*).
4. **Verifikasi Otomatis Hijau:** 66 unit dan widget test lulus secara konsisten di mesin lokal dan runner CI.

### Rencana Peluncuran Bertahap (*Phased Rollout Plan*):
- **Hari 1:** Rilis 10% ke pengguna Closed Beta.
- **Hari 2:** Evaluasi Crashlytics dashboard (jika crash-free $\ge 99.0\%$, tingkatkan ke 25%).
- **Hari 3:** Tingkatkan ke 50%.
- **Hari 4-5:** Full rollout ke 100% pengguna produksi.

---

## 7. Dokumentasi Penggunaan AI yang Bertanggung Jawab (*Responsible AI Usage*)

Dalam proses monitoring dan analisis log kesalahan selama masa pengujian kandidat rilis, asisten AI dimanfaatkan secara etis dan bertanggung jawab dengan mematuhi protokol keamanan data:

### A. Protokol Sanitasi Log (*PII Sanitization Protocol*):
Sebelum potongan log konsol atau *stack trace* dikonsultasikan kepada AI:
1. **Redaksi Kredensial:** Seluruh token JWT (`eyJ...`), secret key, dan kata sandi disamarkan menjadi `[REDACTED_SECRET]`.
2. **Penyamaran Identitas:** Alamat email tester diubah menjadi `user_xxxx@example.com` dan NIM diubah menjadi `244107020232` $\rightarrow$ `[REDACTED_ID]`.
3. **Penghapusan IP & URL Privat:** Alamat endpoint lokal atau IP internal diubah ke placeholder umum (`https://api.campus.example`).

### B. Format Prompt Log Anonymized ke AI:
```text
Konteks Masalah:
Aplikasi Flutter mengalami non-fatal exception saat mengambil cache data pengumuman.

Log Teranomisasi:
DioException [connection timeout]: The request connection took longer than 5000ms.
Request: GET https://api.campus.example/announcements
Headers: Authorization: Bearer [REDACTED_TOKEN]
Device Info: Android 13, Manufacturer: [OEM_GENERIC], Memory: 4GB

Tugas:
Analisis akar penyebab timeout ini dan rekomendasikan strategi penanganan timeout yang ramah pengguna tanpa memicu unhandled rejection.
```

### C. Alur Kerja Verifikasi Saran AI:
1. **Kajian Kritis:** Saran AI tidak pernah langsung di-merge ke repositori.
2. **Reproduksi Masalah:** Hipotesis AI diuji coba secara lokal menggunakan simulasi kondisi jaringan buruk (*Network Throttling*).
3. **Validasi Test:** Solusi diverifikasi dengan menambahkan unit test baru di suite pengujian (`flutter test`).
4. **Verifikasi Perangkat:** Pengujian langsung dilakukan pada perangkat uji fisik sebelum masuk ke kandidat rilis.
