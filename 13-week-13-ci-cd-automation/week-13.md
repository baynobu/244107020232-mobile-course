# #13 | CI/CD dan Otomatisasi

_access\_time_70 mins remaining

1.  [Selamat datang](#0)
2.  [Memahami CI/CD dan alur kerja](#1)
3.  [Membuat workflow CI Flutter](#2)
4.  [Membangun dan menyimpan APK/AAB](#3)
5.  [Versi, secrets, dan keamanan](#4)
6.  [Menjalankan dan mengevaluasi pipeline](#5)

[_bug\_report_ Report a mistake](https://github.com/jti-polinema/flutter-codelab/issues)

[_close_](/)[_menu_](#)

# #13 | CI/CD dan Otomatisasi

_access\_time_70 mins remaining

## 1\. Selamat datang

**Terakhir diperbarui:** 13 November 2026

[Bahasa Indonesia](index.html) | [English](index-en.html)

Pemeriksaan manual yang berulang mudah terlewat dan sulit direproduksi. Pada codelab ini, Anda akan menyiapkan pipeline CI/CD untuk menjalankan pemeriksaan, pengujian, dan build Flutter secara konsisten menggunakan GitHub Actions.

## Tujuan pembelajaran

-   menjelaskan alur CI/CD dari commit hingga artefak aplikasi;
-   membuat workflow untuk format, analisis, test, dan build Android;
-   menyimpan APK/AAB sebagai artefak yang dapat ditinjau;
-   menggunakan versioning dan memahami batasan penyimpanan secret.

## Persiapan

-   Project Flutter dengan minimal satu test yang berjalan di lokal.
-   Git dan akun GitHub; project sudah di-push ke repository.
-   Flutter SDK, Dart, serta pemahaman dasar YAML dan branch Git.

## 2\. Memahami CI/CD dan alur kerja

## 1\. CI dan CD

**Continuous integration (CI)** menjalankan pemeriksaan otomatis saat perubahan diajukan atau di-push. **Continuous delivery/deployment (CD)** mengotomatiskan penyiapan atau pengiriman rilis. Pipeline yang baik membuat langkah penting berulang dan hasilnya dapat ditinjau.

1.  Commit atau pull request memicu workflow.
2.  Runner mengambil source code dan menyiapkan Flutter.
3.  Format, analisis statis, dan test dijalankan.
4.  Jika pemeriksaan lulus, aplikasi dibangun dan artefak disimpan.

## 2\. Event dan permission

Gunakan `pull_request` untuk memeriksa perubahan sebelum merge dan `push` untuk memeriksa branch utama. Berikan permission minimum. Pull request dari fork tidak mendapat akses ke GitHub Secrets repository.

## 3\. Membuat workflow CI Flutter

## 1\. Tambahkan file workflow

Di root project, buat `.github/workflows/flutter-ci.yml`. Sesuaikan nama branch jika branch utama Anda bukan `main`.

```
name: Flutter CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  test-and-build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
      - run: flutter pub get
      - run: dart format --output=none --set-exit-if-changed .
      - run: flutter analyze --fatal-infos
      - run: flutter test --coverage
```

## 2\. Periksa secara lokal

Sebelum push, jalankan perintah format, analisis, dan test yang sama pada project Anda. Perbaiki kegagalan; jangan menghapus pemeriksaan agar workflow terlihat hijau.

## 4\. Membangun dan menyimpan APK/AAB

## 1\. Tambahkan langkah build

Setelah test lulus, tambahkan perintah berikut sebagai step di job yang sama:

```
      - run: flutter build apk --release
      - run: flutter build appbundle --release
      - uses: actions/upload-artifact@v4
        with:
          name: android-builds
          path: |
            build/app/outputs/flutter-apk/app-release.apk
            build/app/outputs/bundle/release/app-release.aab
          if-no-files-found: error
          retention-days: 7
```

-   APK praktis untuk instalasi dan uji internal.
-   AAB adalah format distribusi untuk alur Google Play.
-   Artefak dapat diunduh dari halaman run workflow pada tab **Actions**.

## 5\. Versi, secrets, dan keamanan

## 1\. Versioning

Di `pubspec.yaml`, versi seperti `1.2.0+15` berarti versi aplikasi `1.2.0` dan build number `15`. Ikuti semantic versioning: major untuk perubahan tidak kompatibel, minor untuk fitur kompatibel, dan patch untuk perbaikan. Naikkan build number untuk setiap unggahan baru.

Gunakan tag seperti `v1.2.0` untuk menghubungkan source, log pipeline, dan artefak. Pastikan tag menunjuk pada commit yang sudah lolos pemeriksaan.

## 2\. Rahasia dan konfigurasi

-   Simpan token privat, password, atau material signing melalui GitHub Actions Secrets, bukan di repository.
-   Jangan mencetak secret ke log atau mengirimkannya ke proses yang tidak dipercaya.
-   URL API dan nama environment biasanya konfigurasi publik, bukan credential.
-   Nilai yang diteruskan lewat `--dart-define` dapat diekstrak dari aplikasi klien.

Untuk rilis bertanda tangan, ikuti panduan resmi Flutter untuk signing dan injeksikan material sensitif hanya pada workflow rilis yang dibatasi. Jangan menaruh keystore produksi pada workflow pull request.

## 6\. Menjalankan dan mengevaluasi pipeline

## 1\. Jalankan workflow

1.  Commit file workflow dan push ke GitHub.
2.  Buka tab **Actions** dan pilih run yang sesuai.
3.  Tinjau tiap step. Pastikan kegagalan test membuat job gagal.
4.  Unduh artefak dan catat commit yang menghasilkan file tersebut.

## 2\. Tugas

1.  Tambahkan workflow CI ke project Flutter Anda dengan format, analisis, dan test.
2.  Bangun APK dan AAB serta simpan keduanya sebagai artefak.
3.  Jalankan workflow melalui pull request atau push ke branch utama; sertakan bukti hasil serta commit.
4.  Dokumentasikan versi berikutnya, pemeriksaan yang dijalankan, dan risiko keamanan yang masih perlu ditangani.

## Refleksi

-   Masalah apa yang ditemukan otomatis sebelum perubahan di-merge?
-   Informasi apa yang Anda butuhkan untuk menyelidiki build yang gagal?
-   Bagian mana yang masih perlu persetujuan atau pemeriksaan manual sebelum rilis?

## Referensi pendukung

-   [Slide Minggu 13: CI/CD dan Otomatisasi](../00-slides/Week_13_CICD_Automation.html)
-   [GitHub Actions documentation](https://docs.github.com/actions)
-   [Continuous delivery with Flutter](https://docs.flutter.dev/deployment/cd)
-   [Build and release an Android app](https://docs.flutter.dev/deployment/android)
-   [Using secrets in GitHub Actions](https://docs.github.com/actions/security-guides/using-secrets-in-github-actions)
-   [Semantic Versioning](https://semver.org/)

[Back](# "Previous step")

[Next](# "Next step")[Done](/ "Codelab complete")