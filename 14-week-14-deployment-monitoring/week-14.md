# #14 | Deployment dan Monitoring

_access\_time_90 mins remaining

1.  [Selamat datang](#0)
2.  [Memahami alur rilis dan monitoring](#1)
3.  [Menyiapkan kandidat rilis](#2)
4.  [Mendistribusikan melalui pengujian internal](#3)
5.  [Mengumpulkan crash dan event Analytics](#4)
6.  [Menguji telemetry dan mengambil keputusan rilis](#5)
7.  [Tugas, refleksi, dan referensi](#6)

[_bug\_report_ Report a mistake](https://github.com/jti-polinema/flutter-codelab/issues)

[_close_](/)[_menu_](#)

# #14 | Deployment dan Monitoring

_access\_time_90 mins remaining

## 1\. Selamat datang

**Terakhir diperbarui:** 22 November 2026

[Bahasa Indonesia](index.html) | [English](index-en.html)

Pada minggu sebelumnya, Anda mengotomatiskan pemeriksaan dan menghasilkan artefak aplikasi. Sekarang, Anda akan menyiapkan rilis beta terbatas, mengumpulkan umpan balik, dan memantau crash serta penggunaan fitur setelah rilis.

## Tujuan pembelajaran

-   menjelaskan alur kandidat rilis hingga pengujian beta;
-   menyiapkan versi aplikasi dan Android App Bundle (AAB) untuk pengujian internal;
-   mengonfigurasi Firebase Crashlytics dan Analytics untuk pengujian;
-   meninjau sinyal rilis dan menentukan tindak lanjut berdasarkan bukti;
-   menggunakan AI secara bertanggung jawab saat menganalisis log.

## Persiapan

-   Project Flutter yang sudah dapat dibangun dan memiliki test yang lulus.
-   Repository Git dan akses ke pipeline CI dari minggu sebelumnya.
-   Project Firebase untuk Android; siapkan akses Google Play Console jika tersedia.
-   Perangkat Android untuk menguji build beta. Jangan memakai data produksi.

## 2\. Memahami alur rilis dan monitoring

## 1\. Dari CI ke rilis beta

Pipeline CI pada minggu sebelumnya menghasilkan build yang telah diperiksa. Untuk mengujinya dengan pengguna terbatas, buat kandidat rilis yang dapat ditelusuri, distribusikan melalui track pengujian, lalu amati hasil penggunaan.

1.  Pastikan commit kandidat lulus analisis dan test.
2.  Naikkan nomor build, lalu buat AAB release.
3.  Unggah AAB ke track pengujian internal dan undang tester.
4.  Kumpulkan laporan, crash, dan sinyal penggunaan yang relevan.
5.  Reproduksi masalah, perbaiki, dan tentukan apakah rilis dilanjutkan.

## 2\. Track pengujian

Google Play menyediakan track pengujian dengan audiens dan proses yang berbeda. Internal testing sesuai untuk pemeriksaan awal oleh kelompok kecil. Persyaratan akun dan proses Play Console dapat berubah; ikuti petunjuk terbaru di console.

## 3\. Menyiapkan kandidat rilis

## 1\. Catat versi dan commit

Di `pubspec.yaml`, versi seperti `1.0.0+21` menyatakan versi aplikasi `1.0.0` dan build number `21`. Naikkan build number untuk setiap unggahan baru. Kaitkan kandidat dengan commit atau tag Git dan tulis perubahan/batasan pada catatan rilis.

## 2\. Jalankan pemeriksaan dan build

```
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test
flutter build appbundle --release
```

-   Pastikan analisis dan test lulus pada commit yang akan dirilis.
-   Periksa konfigurasi release dan signing sesuai dokumentasi Flutter.
-   AAB biasanya dibuat di `build/app/outputs/bundle/release/`.
-   Simpan AAB dengan catatan commit dan hasil CI; jangan bagikan secara publik.

## 4\. Mendistribusikan melalui pengujian internal

## 1\. Play Console

1.  Buat atau pilih aplikasi di Play Console, lalu buka track **Internal testing**.
2.  Tambahkan tester melalui daftar email atau grup yang diizinkan.
3.  Buat rilis, unggah AAB, isi catatan rilis, lalu tinjau peringatan yang ditampilkan.
4.  Mulai distribusi internal dan bagikan tautan opt-in hanya kepada tester.
5.  Minta tester menginstal aplikasi dan memeriksa alur utama pada perangkatnya.

## 2\. Alternatif distribusi privat

Jika belum memiliki akses Play Console, gunakan Firebase App Distribution atau metode privat yang disetujui pengajar. Pastikan tester dan versi build tercatat. Jalur alternatif ini tetap perlu bukti instalasi dan pengujian.

## 3\. Catat bukti

Untuk setiap laporan, tulis versi/build, jenis perangkat dan OS, langkah reproduksi, hasil yang diharapkan, hasil aktual, serta bukti yang sudah disamarkan. Jangan meminta tester mengirim kredensial atau data pribadi.

## 5\. Mengumpulkan crash dan event Analytics

## 1\. Siapkan Firebase

Ikuti panduan resmi FlutterFire untuk menghubungkan aplikasi ke Firebase. Tambahkan paket berikut dan selesaikan konfigurasi platform sebelum menginisialisasi Firebase:

```
flutter pub add firebase_crashlytics firebase_analytics
flutterfire configure
```

Tambahkan penanganan error setelah `Firebase.initializeApp()` selesai, misalnya pada awal `main()`:

Impor `dart:ui` untuk `PlatformDispatcher`, serta paket Firebase yang digunakan.

```
FlutterError.onError =
    FirebaseCrashlytics.instance.recordFlutterFatalError;
PlatformDispatcher.instance.onError = (error, stack) {
  FirebaseCrashlytics.instance.recordError(
    error, stack, fatal: true,
  );
  return true;
};
```

Ikuti dokumentasi Firebase untuk impor, konfigurasi Gradle, dan langkah platform terbaru. Verifikasi bahwa error uji muncul dengan versi yang benar di dashboard Crashlytics.

## 2\. Catat event yang tidak sensitif

```
await FirebaseAnalytics.instance.logEvent(
  name: 'beta_feedback_sent',
  parameters: {'screen_name': 'home'},
);
```

Catat aksi yang berguna untuk evaluasi, bukan isi formulir, email, token, atau pengenal pribadi. Dokumentasikan arti nama event dan parameter.

## 6\. Menguji telemetry dan mengambil keputusan rilis

## 1\. Verifikasi telemetry

1.  Jalankan build uji dan picu event Analytics non-sensitif yang sudah direncanakan.
2.  Kirim satu error non-fatal buatan untuk memastikan Crashlytics menerima laporan.
3.  Untuk menguji crash fatal, ikuti instruksi uji resmi dan gunakan perangkat uji saja.
4.  Tunggu pemrosesan, lalu periksa event, versi aplikasi, perangkat, serta stack trace.
5.  Pastikan laporan tidak memuat kredensial atau data pribadi.

## 2\. Pantau dan triage

Bandingkan crash-free users/sessions, issue baru, jumlah pengguna terdampak, versi, dan laporan tester. Data agregat adalah sinyal, bukan bukti tunggal akar masalah. Reproduksi bug dan cocokkan dengan stack trace sebelum menyimpulkan.

Jika masalah berdampak pada alur utama atau berisiko bagi pengguna, tahan perluasan distribusi dan ikuti prosedur penghentian/rollback track. Catat alasan, bukti, penanggung jawab, dan versi perbaikan.

## 3\. AI dan log

Sebelum meminta AI menganalisis log, hapus token, email, ID pengguna, URL privat, dan payload sensitif. Minta hipotesis beserta bukti dan langkah reproduksi; verifikasi hasilnya menggunakan kode, test, serta perangkat.

## 7\. Tugas, refleksi, dan referensi

## Tugas

1.  Siapkan kandidat beta dengan versi/build number, commit, AAB, dan hasil pemeriksaan yang tercatat.
2.  Distribusikan ke Internal testing atau Firebase App Distribution dan uji pada perangkat.
3.  Konfigurasikan Crashlytics serta satu event Analytics non-sensitif; verifikasi pada dashboard.
4.  Buat `docs/release-report.md` yang berisi bukti distribusi, hasil uji, temuan, dampak, keputusan, dan langkah berikutnya.
5.  Catat penggunaan AI, konteks log yang disamarkan, dan cara memverifikasi saran AI.

Jika akses layanan tidak tersedia, dokumentasikan demonstrasi alternatif dan keterbatasannya. Jangan membuat bukti dashboard atau distribusi yang tidak benar-benar dilakukan.

## Refleksi

-   Bukti apa yang diperlukan sebelum memperluas distribusi beta?
-   Bagaimana Anda memutuskan untuk menahan atau melanjutkan rilis?
-   Data apa yang tidak perlu dikirim ke layanan monitoring?

## Referensi pendukung

-   [Slide Minggu 14: Deployment dan Monitoring (Indonesia)](../00-slides/Week_14_Deployment_Monitoring.html)
-   [Flutter: Build and release an Android app](https://docs.flutter.dev/deployment/android)
-   [Google Play: Internal testing](https://support.google.com/googleplay/android-developer/answer/9845334)
-   [Firebase Crashlytics for Flutter](https://firebase.google.com/docs/crashlytics/flutter/get-started)
-   [Firebase Analytics for Flutter](https://firebase.google.com/docs/analytics/get-started?platform=flutter)
-   [Firebase App Distribution](https://firebase.google.com/docs/app-distribution)

[Back](# "Previous step")

[Next](# "Next step")[Done](/ "Codelab complete")