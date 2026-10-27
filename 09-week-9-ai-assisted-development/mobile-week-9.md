# #09 | AI-Assisted Development / Vibe Coding

_access\_time_125 mins remaining

1.  [Selamat datang](#0)
2.  [Konsep workflow AI dan halusinasi](#1)
3.  [Praktikum 1: Prompt dan context engineering](#2)
4.  [Praktikum 2: Generate dan verifikasi search](#3)
5.  [Praktikum 3: Debug dan refactor](#4)
6.  [AI Challenge](#5)
7.  [Refactoring, testing, dan error umum](#6)
8.  [Tugas, refleksi, dan referensi](#7)

[_bug\_report_ Report a mistake](https://github.com/jti-polinema/flutter-codelab/issues)

[_close_](/)[_menu_](#)

# #09 | AI-Assisted Development / Vibe Coding

_access\_time_125 mins remaining

## 1\. Selamat datang

**Terakhir diperbarui:** 18 Oktober 2026  

[Bahasa Indonesia](index.html) | [English](index-en.html)

## Tujuan pembelajaran

Setelah menyelesaikan codelab ini, mahasiswa mampu:

-   menjelaskan workflow AI-assisted development (prompt, generate, verify, test, refactor, explain);
-   menulis prompt dan konteks yang efektif untuk fitur Flutter kecil;
-   mengenali halusinasi dan keterbatasan AI pada kode Flutter;
-   melakukan debugging dan refactoring kode hasil AI ke Clean Architecture;
-   menguji kode hasil AI dengan `flutter analyze` dan test;
-   mendokumentasikan prompt, hasil AI, keputusan terima/tolak, dan bukti uji di `docs/ai-log.md`.

## Persiapan

-   Laptop/PC dan project Minggu 5-8 yang sudah lolos review (mis. `week5_offline_notes` atau `campus_notify` hasil refactor Minggu 7). Codelab ini menambah satu fitur kecil dengan AI, bukan membuat project baru.
-   Flutter SDK, VS Code (ekstensi Flutter/Dart), Git, dan satu AI coding assistant (GitHub Copilot / Cursor / Claude Code / setara).
-   Pemahaman Riverpod, repository pattern, dan dependency rule Minggu 7.

## 2\. Konsep workflow AI dan halusinasi

## 1\. Siklus generate sampai explain

AI mengusulkan, developer memutuskan:

```
1. Prompt -> instruksi + konteks proyek
2. Generate -> AI mengusulkan kode
3. Verify -> baca, grep, cek API nyata
4. Test -> analyze + unit/widget test
5. Refactor -> rapikan ke Clean Architecture
6. Explain -> jelaskan tanpa buka AI
```

Gagal di langkah 3-6 berarti _vibe coding_: cepat di awal, mahal di akhir.

## 2\. Yang AI kuasai dan tidak

Area

Contoh

Sikap

Kuat

Boilerplate, pola umum, draft test, docs

Manfaatkan, tetap uji

Lemah

API baru, versi package, logika bisnis khusus

Verifikasi ekstra

Berbahaya

Token auth, query SQL, aturan keamanan

Jangan tempel secret; tulis manual

## 3\. Tiga pola halusinasi Flutter

-   **Method fiktif:** mis. `controller.searchFuzzy()` yang tidak ada. Cek via autocomplete IDE dan `pub.dev`.
-   **Package kadaluarsa:** AI memakai API v1 padahal `pubspec` memakai v3. Cek `pubspec.lock` dan CHANGELOG.
-   **Logika yakin tapi salah:** mis. filter case-sensitive yang meloloskan bug. Buktikan dengan satu test kecil.

## 3\. Praktikum 1: Prompt dan context engineering

## 1\. Formula 5 slot

Satu prompt baik mengisi lima slot secara singkat:

```
Peran: senior Flutter dev
Konteks: feature-first, Riverpod, SQLite+Dio
Tugas: tambah search judul notes + empty state
Batas: jangan ubah arsitektur, maks 80 baris
Output: kode + 3 test case + cara uji
```

## 2\. Buruk vs baik

```
buruk: "buatkan search notes yang keren"
baik: "Tambah search judul notes.
  Arsitektur: presentation->domain<-data.
  Jangan panggil SQLite dari widget.
  Sertakan empty state + 1 widget test."
```

Prompt kabur menghasilkan kode kabur yang sulit diuji.

## 3\. Beri konteks, bukan secret

-   Sertakan: struktur folder, satu file kontrak repository/use case, dan versi package dari `pubspec.yaml`.
-   Jangan sertakan: token, API key, password, atau seluruh repo 500 file.
-   Tempel potongan kode relevan, bukan screenshot kabur. Sebutkan yang TIDAK boleh diubah.

## 4\. Praktikum 2: Generate dan verifikasi search

## 1\. Generate satu fitur kecil

Minta AI membuat **pencarian judul notes** lengkap dengan empty state. Batasi satu fitur agar mudah diverifikasi. Simpan prompt mentah dan output awal AI ke `docs/ai-log.md`.

## 2\. Verifikasi 6 langkah

-   Baca tiap baris dan tandai yang belum dipahami.
-   Cek import: pastikan `domain/` bebas dari Flutter/Dio/SQLite.
-   Cek API: pastikan tiap method benar ada (autocomplete + pub.dev).
-   Jalankan `flutter analyze` sampai nol warning.
-   Tulis minimal 1 test sukses dan 1 test gagal untuk search.
-   Uji manual: query kosong, cocok, dan tak cocok (empty state).

## 3\. Contoh test bukti

```
test('filter abaikan huruf besar/kecil', () {
  expect(filterNotes(list, 'belanja'), hasLength(2));
});
test('query tak cocok kembalikan kosong', () {
  expect(filterNotes(list, 'zzz-tak-ada'), isEmpty);
});
```

## 5\. Praktikum 3: Debug dan refactor

## 1\. Debug dengan test merah

```
1. Reproduksi: langkah + input pemicu bug
2. Isolasi: pindah filter ke use case murni
3. Test merah: buat test gagal pembukti bug
4. Perbaiki kecil, jalankan test + analyze
5. Catat akar masalah di docs/ai-log.md
```

Jangan mengulang prompt `fix dong` tanpa bukti error atau test gagal.

## 2\. Refactor ke layer yang benar

```
widget (UI saja)
  -> notifier (state saja)
  -> use case (aturan filter/search)
  -> repository (SQLite / Dio)
```

Pecah fungsi di atas 40 baris dan pastikan tidak ada panggilan database dari widget.

## 3\. Verifikasi akhir

```
flutter analyze
dart format --set-exit-if-changed .
flutter test
```

## 6\. AI Challenge

## Peran AI pada codelab ini

AI boleh menjadi generator dan reviewer awal yang cepat, tetapi **Anda yang memutuskan** mana yang diterima, ditolak, atau disederhanakan.

## AI Prompt Challenge

Minta AI mereview kode search Anda:

```
Review kode search Flutter ini sebagai senior dev.
Konteks: feature-first (presentation->domain<-data),
Riverpod, SQLite + Dio.
Fokus: kebenaran, arsitektur, test. Abaikan style.
Beri 3 temuan + level blocker/saran + alasan.
```

## AI Verification Checklist

-   Minimal 1 temuan AI terbukti benar (bukti grep/test) lalu diperbaiki.
-   Minimal 1 temuan AI ditolak dengan alasan teknis tertulis.
-   Keputusan tiap file: terima, terima + refactor, atau tolak + tulis manual.
-   Mampu menjelaskan tiap keputusan tanpa membuka AI.

## 7\. Refactoring, testing, dan error umum

## Refactoring Challenge

1.  Perkecil hasil AI di atas 80 baris menjadi fungsi/use case kecil yang bisa diuji.
2.  Pindahkan filter/search dari widget ke use case domain yang murni.
3.  Hapus import lintas layer dan pastikan analyze tetap bersih.

## Testing

```
flutter test test/search_filter_test.dart
# + 1 widget test untuk empty state
# + uji manual 3 query + screenshot
```

## Error umum dan solusinya

Gejala

Penyebab umum

Solusi

Method tidak ada

Halusinasi API

Cek pub.dev + autocomplete

Import lintas layer

Konteks kurang

Tegaskan batas + refactor

Semua test merah

Prompt terlalu besar

Minta 1 fitur kecil + 1 test

Prompt diulang terus

Tanpa reproduksi

Tulis langkah + test merah

Tak bisa menjelaskan

Terima mentah

Baca ulang + sederhanakan

## Checklist verifikasi mandiri

-   Prompt 5 slot + konteks di `docs/ai-log.md`.
-   `flutter analyze` bersih, `flutter test` hijau.
-   1 temuan AI dibuktikan benar + 1 ditolak beralasan.
-   Mampu menjelaskan tanpa membuka AI.

## 8\. Tugas, refleksi, dan referensi

## Mini project / Industry Challenge

1.  Tambahkan satu fitur kecil dengan AI (search/filter/sort) + empty state.
2.  Sertakan prompt inti, konteks ditempel, dan output awal AI di `docs/ai-log.md`.
3.  Bukti mesin hijau: `flutter analyze` + `flutter test` di README.
4.  Tabel terima/tolak saran AI + alasan teknis + bukti grep/test.
5.  Push ke `09-week-9-ai-assisted-development/` berisi `docs/`, `README.md`, `screenshots/`. README menjelaskan fitur, prompt, stack, cara jalan, dan hasil.

## Refleksi

-   Satu halusinasi AI apa yang Anda temukan dan bagaimana membuktikannya?
-   Prompt mana yang paling membantu dan apa yang Anda ubah?
-   Satu refactor apa yang Anda lakukan pada kode AI?
-   Keputusan terima/tolak mana yang paling sulit?

## Referensi pendukung

-   [Slide Week 9: AI-Assisted Development / Vibe Coding](../00-slides/Week_09_AI_Assisted_Development_Vibe_Coding.html)
-   [Flutter: Using IDEs and static analysis](https://docs.flutter.dev/tools/using-ide)
-   [Dart: Linter rules](https://dart.dev/tools/linter-rules)
-   [Riverpod: Getting started](https://riverpod.dev/docs/introduction/getting_started)
-   [GitHub Copilot: Best practices](https://docs.github.com/en/copilot/using-github-copilot/best-practices)
-   [Learn Dart in Y Minutes](https://learnxinyminutes.com/dart/)
-   [Dart Language Tour](https://dart.dev/guides/language/language-tour)

[Back](# "Previous step")

[Next](# "Next step")[Done](/ "Codelab complete")