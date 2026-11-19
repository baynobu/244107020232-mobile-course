# Panduan Screenshot Bukti Praktikum Minggu 13 (CI/CD dan Otomatisasi)

Direktori ini digunakan untuk menyimpan seluruh bukti visual eksekusi pipeline CI/CD GitHub Actions, artefak build, dan verifikasi lokal project Flutter `campus_notify`.

---

## Daftar File Screenshot yang Harus Diambil

| No | Nama File | Deskripsi Tampilan | Status |
|:---:|:---|:---|:---:|
| 1 | `01_github_actions_pipeline_overview.png` | Halaman tab **Actions** di GitHub yang menampilkan pipeline "Flutter CI" berjalan sukses (tanda centang hijau) pada branch `main`. | Wajib |
| 2 | `02_workflow_steps_details.png` | Tampilan rincian step di dalam job `Test and Build Android` (Checkout, Java 17, Flutter Setup, pub get, format, analyze, test, build apk, build appbundle, upload-artifact) semua berstatus centang hijau. | Wajib |
| 3 | `03_artifacts_download_summary.png` | Halaman ringkasan run yang memperlihatkan section **Artifacts** dengan nama `android-builds` (berisi `app-release.apk` dan `app-release.aab`). | Wajib |
| 4 | `04_git_commit_push_log.png` | Terminal lokal yang memperlihatkan eksekusi `git add`, `git commit`, pembuatan git tag `v1.3.0`, dan `git push origin main --tags`. | Wajib |
| 5 | `05_local_checks_green.png` | Terminal lokal yang memperlihatkan hasil eksekusi 3 perintah lokal: `dart format`, `flutter analyze --fatal-infos`, dan `flutter test --coverage` yang 100% lulus. | Wajib |

---

## Petunjuk Pengambilan Screenshot

### 1. `01_github_actions_pipeline_overview.png`
1. Buka browser dan arahkan ke repository GitHub Anda: `https://github.com/baynobu/244107020232-mobile-course`.
2. Klik tab **Actions** di bilah navigasi atas.
3. Pastikan daftar alur kerja (workflow run) menampilkan run terbaru bertajuk commit Anda dengan icon centang hijau (**Success**).
4. Ambil screenshot layar yang mencakup URL repository, nama workflow "Flutter CI", status centang hijau, branch `main`, dan commit SHA.
5. Simpan dengan nama `01_github_actions_pipeline_overview.png` di folder ini.

### 2. `02_workflow_steps_details.png`
1. Pada tab **Actions**, klik workflow run yang baru saja selesai.
2. Klik job **Test and Build Android** di diagram alur kiri.
3. Perluas (expand) step-step penting:
   - `Check code formatting`
   - `Static code analysis`
   - `Run unit & widget tests`
   - `Build Android APK`
   - `Build Android App Bundle (AAB)`
   - `Upload Android Build Artifacts`
4. Ambil screenshot yang memperlihatkan seluruh langkah sukses bertanda centang hijau.
5. Simpan dengan nama `02_workflow_steps_details.png` di folder ini.

### 3. `03_artifacts_download_summary.png`
1. Kembali ke halaman ringkasan run workflow (klik nama run di breadcrumb atas).
2. Gulir ke bagian bawah halaman hingga menemukan bagian **Artifacts**.
3. Pastikan artefak `android-builds` terlihat dengan ukuran file (sekitar puluhan megabyte) dan masa retensi (7 hari).
4. Unduh file zip `android-builds.zip` tersebut dan buka untuk memperlihatkan file `app-release.apk` dan `app-release.aab`.
5. Ambil screenshot halaman GitHub Actions yang menampilkan section Artifacts atau folder hasil ekstraksinya.
6. Simpan dengan nama `03_artifacts_download_summary.png` di folder ini.

### 4. `04_git_commit_push_log.png`
1. Buka terminal (PowerShell atau Bash) di direktori repository root.
2. Jalankan perintah:
   ```powershell
   git status
   git log -1 --stat
   git tag -n
   ```
3. Pastikan informasi commit message, tag `v1.3.0`, dan remote push terlihat jelas.
4. Ambil screenshot terminal tersebut dan simpan sebagai `04_git_commit_push_log.png`.

### 5. `05_local_checks_green.png`
1. Buka terminal di direktori `13-week-13-ci-cd-automation/campus_notify`.
2. Jalankan rangkaian perintah verifikasi:
   ```powershell
   dart format --output=none --set-exit-if-changed .
   flutter analyze --fatal-infos
   flutter test --coverage
   ```
3. Pastikan terminal menampilkan `0 changed`, `No issues found!`, dan `All tests passed! (60/60 tests)`.
4. Ambil screenshot terminal dan simpan sebagai `05_local_checks_green.png`.

