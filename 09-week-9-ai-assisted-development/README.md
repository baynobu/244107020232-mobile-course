# AI-Assisted Development & Vibe Coding (Week 9)

Dokumentasi implementasi fitur **Pencarian Pengumuman Kampus (*Announcement Search*) & Empty State** menggunakan metodologi terstruktur **AI-Assisted Development** pada proyek **Campus Notify**.

---

## 1. Ringkasan Eksekutif & Filosofi AI Workflow

Pengembangan perangkat lunak modern bersama asisten AI memerlukan disiplin teknis agar tidak terjebak dalam fenomena ***vibe coding*** (kecepatan semu di awal yang menghasilkan utang teknis mahal di akhir akibat menerima kode AI mentah-mentah tanpa verifikasi).

Pada modul Week 9 ini, diterapkan siklus workflow 6 langkah:

```text
┌──────────┐     ┌───────────┐     ┌──────────┐     ┌──────────┐     ┌────────────┐     ┌───────────┐
│ 1. PROMPT │ ──> │ 2.GENERATE│ ──> │ 3.VERIFY │ ──> │ 4. TEST  │ ──> │ 5.REFACTOR │ ──> │ 6.EXPLAIN │
└──────────┘     └───────────┘     └──────────┘     └──────────┘     └────────────┘     └───────────┘
 Instruksi 5-     AI mengusul-     Baca teliti,     Test merah       Pindah ke domain    Paham penuh
 slot + batas     kan draft        cek sterilitas   pembukti bug     Clean Arch &        tanpa buka
 arsitektur       kode             domain & API     -> test hijau    Riverpod 3.x        bantuan AI
```

---

## 2. Fitur Baru: Pencarian Pengumuman & Empty State

### 2.1 Deskripsi Fitur
1. **Pencarian Multi-Atribut**: Pengguna dapat mencari pengumuman kampus berdasarkan kata kunci pada **Judul**, **Kategori** (Akademik, Kemahasiswaan, Perkuliahan), maupun **Isi Pengumuman (*Body*)**.
2. **Case-Insensitive & Auto-Trim**: Pencarian tidak terpengaruh oleh perbedaan huruf kapital (`"jadwal"` sama dengan `"JADWAL"`) dan secara otomatis memangkas spasi berlebih (*leading/trailing whitespace*).
3. **Empty State Responsif**: Jika tidak ada data yang cocok dengan kata kunci, antarmuka secara elegan menampilkan ilustrasi empty state informatif (*"Pengumuman Tidak Ditemukan"*) lengkap dengan tombol pintas *"Reset Pencarian"*.
4. **Instant Clear Search**: Kolom pencarian dilengkapi tombol suffix `Icons.clear` untuk mengosongkan query dengan satu ketukan.

### 2.2 Teknologi yang Digunakan
- **Framework**: Flutter 3.x / Dart 3.x
- **State Management**: Flutter Riverpod 3.x (`NotifierProvider`, `Provider`, `AsyncValue`)
- **Arsitektur**: Feature-First Clean Architecture (`presentation` $\rightarrow$ `domain` $\leftarrow$ `data`)
- **Pengujian**: Flutter Test (`testWidgets`, unit test, mock fake repository)

---

## 3. Desain Arsitektur (Clean Architecture & Dependency Rule)

Sesuai aturan emas Clean Architecture (*Dependency Rule*), dependensi hanya mengarah ke dalam. Layer domain steril dari framework (tidak tahu apa pun tentang Flutter, Dio, SQLite, atau Firebase).

```text
                      PRESENTATION LAYER
   ┌─────────────────────────────────────────────────────────┐
   │ lib/pages/home_page.dart (UI Widget & Empty State)      │
   │                          │                              │
   │                          ▼ watch                        │
   │ lib/features/announcements/presentation/providers/      │
   │   - searchQueryProvider (SearchQueryNotifier)           │
   │   - filteredAnnouncementsProvider (AsyncValue)          │
   └──────────────────────────┬──────────────────────────────┘
                              │ memanggil (pure Dart)
                              ▼
                         DOMAIN LAYER
   ┌─────────────────────────────────────────────────────────┐
   │ lib/features/announcements/domain/usecases/             │
   │   - SearchAnnouncements (Business Rule: Filter, Trim)   │
   │   - GetAnnouncements                                    │
   │                                                         │
   │ lib/features/announcements/domain/entities/             │
   │   - Announcement (Entity murni tanpa toMap/toJson)      │
   └──────────────────────────▲──────────────────────────────┘
                              │ diimplementasikan oleh
                         DATA LAYER
   ┌─────────────────────────────────────────────────────────┐
   │ lib/features/announcements/data/repositories/           │
   │   - AnnouncementRepositoryImpl (Mock API / Dio)         │
   │ lib/features/announcements/data/models/                 │
   │   - AnnouncementModel (Mapping JSON/Map ke Entity)      │
   └─────────────────────────────────────────────────────────┘
```

---

## 4. Prompt Engineering: Formula 5 Slot

Penerapan formula 5 slot yang menghasilkan kode presisi tinggi dari AI:

```text
1. Peran  : Senior Flutter Developer & Clean Architecture Architect.
2. Konteks: Fitur 'announcements' pada aplikasi 'campus_notify' dengan Clean Architecture
            feature-first (presentation -> domain <- data), Riverpod 3.x,
            entitas Announcement (id, title, category, body, author, publishedAt).
3. Tugas  : Tambahkan use case pencarian judul & isi pengumuman kampus lengkap dengan
            komponen Empty State interaktif saat pencarian tidak menemukan hasil.
4. Batas  : Logika pencarian WAJIB berada di layer domain (murni Dart, zero-dependency,
            dilarang import Flutter/Dio/SQLite). State management menggunakan Riverpod.
            Panjang use case di bawah 40 baris. Sertakan unit test dan widget test.
5. Output : Kode use case domain murni, provider Riverpod, integrasi HomePage, dan test.
```

### Buruk vs Baik
- **Prompt Buruk**: *"Buatkan search pengumuman yang ada empty state-nya"* $\rightarrow$ Menghasilkan kode monolitik di dalam widget, filter case-sensitive, dan mencampur urusan UI dengan logika filtering.
- **Prompt Baik**: Mengisi kelima slot di atas $\rightarrow$ Menghasilkan use case terisolasi yang siap diuji unit test tanpa ketergantungan UI.

---

## 5. Bukti Mesin Hijau (Verification Evidence)

### 5.1 Static Analysis (`flutter analyze`)
Analisis statis Dart dan Flutter menunjukkan **NOL peringatan/isu**:

```text
$ flutter analyze
Analyzing campus_notify...                                      
No issues found! (ran in 10.7s)
```

### 5.2 Pengujian Otomatis (`flutter test`)
Seluruh 18 pengujian (unit test domain, routing, otentikasi token, dan widget test search/empty state) lulus 100%:

```text
$ flutter test
00:00 +0: test/auth_push_test.dart
00:00 +7: test/get_announcements_test.dart
00:02 +11: test/search_announcements_test.dart: SearchAnnouncements Domain Use Case filter abaikan huruf besar/kecil (case-insensitive)
00:02 +12: test/search_announcements_test.dart: SearchAnnouncements Domain Use Case query tak cocok kembalikan list kosong
00:02 +13: test/search_announcements_test.dart: SearchAnnouncements Domain Use Case query kosong atau spasi murni kembalikan seluruh daftar
00:02 +14: test/search_announcements_test.dart: SearchAnnouncements Domain Use Case pencarian cocok pada kategori maupun isi (body)
00:02 +15: test/search_announcements_test.dart: SearchAnnouncements Domain Use Case query dengan leading/trailing spasi tetap di-trim dengan benar
00:03 +16: test/search_announcements_widget_test.dart: Search bar memfilter daftar pengumuman dan menampilkan empty state saat tidak cocok
00:07 +18: All tests passed!
```

### 5.3 Format Kode Otomatis (`dart format`)
```text
$ dart format --set-exit-if-changed lib test
Formatted 30 files (0 changed) in 0.34 seconds.
```

### 5.4 Pembuktian Sterilitas Layer (Grep Test)
```powershell
# 1. Domain steril dari Flutter, Dio, SQLite, Firebase (harus NOL hasil):
Get-ChildItem -Path "lib/features/*/domain","lib/core" -Recurse -Filter "*.dart" |
  Select-String -Pattern "import 'package:flutter|import 'package:dio|import 'package:sqflite|import 'package:firebase"
# Hasil: NOL temuan ✅

# 2. Presentation steril dari direct database/network access (harus NOL hasil):
Get-ChildItem -Path "lib/features/*/presentation" -Recurse -Filter "*.dart" |
  Select-String -Pattern "Dio\(|openDatabase|FlutterSecureStorage|SharedPreferences|jsonDecode"
# Hasil: NOL temuan ✅
```

---

## 6. AI Challenge: Evaluasi Kritis Reviewer AI

Sebagai bagian dari tantangan AI (*AI Prompt Challenge*), kode di-review dengan perspektif arsitektur senior. Berikut adalah 3 temuan yang dievaluasi:

| No | Temuan AI | Severity | Keputusan | Bukti Teknis & Rasionalisasi |
|:--:|---|:---:|:---:|---|
| **1** | **ListTile Ink Splash Assertion Crash**: `ListTile` yang ditaruh di dalam `Container(decoration: BoxDecoration(color: ...))` menyebabkan assertion error pada Flutter 3.27+ karena background DecoratedBox menutupi ink splash material. | **Blocker** | **Diterima & Diperbaiki** | Dibuktikan dengan kegagalan framework saat eksekusi widget test. Diperbaiki dengan membungkus `ListTile` menggunakan `Material(shape: RoundedRectangleBorder(...))` sehingga background dan efek riak (*ripple*) ter-render secara benar sesuai spesifikasi Material Design 3. |
| **2** | **Saran Stream Debouncing via RxDart**: AI menyarankan menambahkan dependensi package eksternal `rxdart` dan `PublishSubject` untuk mendebounce input ketikan user 300ms. | **Saran** | **Ditolak** | Sumber data saat ini adalah in-memory cache lokal berukuran ringan (< 100 entri). Use case murni dieksekusi instan (< 1 ms) tanpa memicu request HTTP. Menambah `rxdart` melanggar prinsip **YAGNI** (*You Aren't Gonna Need It*) dan menambah kompleksitas asynchronous yang tidak perlu. |
| **3** | **Ketiadaan Tombol Reset pada Empty State**: Saat pengguna memasukkan query yang tidak cocok, tidak tersedia aksi cepat untuk mengembalikan tampilan ke daftar awal selain menghapus huruf satu per satu. | **Saran** | **Diterima & Diperbaiki** | Ditambahkan tombol `OutlinedButton` *"Reset Pencarian"* di kartu empty state dan suffix icon `IconButton(Icons.clear)` di textfield pencarian. |

---

## 7. Cara Menjalankan Aplikasi & Pengujian

### 7.1 Menjalankan Pengujian Otomatis
Masuk ke direktori `campus_notify`:
```bash
cd campus_notify

# Jalankan seluruh test suite
flutter test

# Jalankan unit test pencarian domain saja
flutter test test/search_announcements_test.dart

# Jalankan widget test UI & empty state saja
flutter test test/search_announcements_widget_test.dart
```

### 7.2 Menjalankan Analisis Statis
```bash
flutter analyze
```

### 7.3 Menjalankan Aplikasi
```bash
flutter run
```
*Gunakan akun demo kampus: email `mahasiswa@polinema.ac.id` / password bebas (min. 6 karakter).*

---

## 8. Refleksi Pembelajaran (Jawaban Modul)

### 1. Satu halusinasi / kelemahan AI apa yang Anda temukan dan bagaimana membuktikannya?
> **Jawaban:**  
> Kelemahan AI paling nyata yang ditemukan adalah **asumsi logika filter yang terlalu sederhana (case-sensitive)** dan **assertion konflik styling Material Flutter 3.27+**.  
> Saat pertama kali diminta membuat filter, AI menghasilkan `item.title.contains(query)`. Kelemahan ini dibuktikan dengan membuat **test merah** di mana query huruf kecil `"jadwal"` gagal mencocokkan `"Jadwal Kuliah Semester Baru"`. Selain itu, AI membungkus `ListTile` langsung di dalam `Container(decoration: BoxDecoration(color: ...))` yang memicu assertion crash pada Flutter engine karena background menimpa kanvas ink splash `ListTile`. Hal ini dibuktikan melalui assertion framework saat widget test dijalankan, dan diselesaikan dengan mengganti kontainer menjadi widget `Material`.

### 2. Prompt mana yang paling membantu dan apa yang Anda ubah?
> **Jawaban:**  
> Prompt yang paling membantu adalah penerapan **Formula 5 Slot dengan batasan arsitektur eksplisit**.  
> Pada awalnya, prompt umum menghasilkan kode di mana logika filter ditaruh di dalam fungsi `onChanged` dari `StatefulWidget`. Yang saya ubah adalah menambahkan batas tegas: *"Logika pencarian WAJIB berada di layer domain murni Dart tanpa dependensi Flutter/Dio/SQLite, panjang di bawah 40 baris, dan state diikat dengan Riverpod Provider"*. Batasan ini secara drastis mengubah kualitas output AI dari kode monolitik menjadi komponen use case yang modular dan mudah diuji.

### 3. Satu refactor apa yang Anda lakukan pada kode AI?
> **Jawaban:**  
> Refactoring utama yang dilakukan adalah **memisahkan logika pencarian dari layer UI presentasi ke Use Case murni Domain `SearchAnnouncements`**.  
> AI awalnya menempatkan kalkulasi filter langsung di dalam `build()` widget. Kami merefaktornya menjadi use case murni dengan aturan: trimming spasi, matching multi-atribut (`title`, `category`, `body`), dan case-insensitivity (`toLowerCase()`). Kemudian, use case ini di-wire ke presentation layer melalui `filteredAnnouncementsProvider` di Riverpod, sehingga widget `HomePage` hanya bertugas murni merender antarmuka tanpa tahu cara komputasi pencarian bekerja.

### 4. Keputusan terima/tolak mana yang paling sulit?
> **Jawaban:**  
> Keputusan paling sulit adalah **menolak saran AI untuk menambahkan Stream Debouncing dengan package `rxdart`**.  
> Secara teori industri, debouncing 300ms adalah *best practice* untuk pencarian autocomplete jaringan (API backend). Namun, setelah menimbang arsitektur aplikasi `campus_notify` saat ini di mana data sudah berada di memori lokal (*in-memory repository*), penambahan Stream Controller / RxDart hanya akan menciptakan over-engineering, menambah dependensi baru di `pubspec.yaml`, dan memperumit kode asynchronous tanpa memberikan peningkatan performa yang dapat dirasakan pengguna (*premature optimization*). Prinsip **KISS** (*Keep It Simple, Stupid*) dan **YAGNI** diputuskan menjadi prioritas utama.

---

## 9. Struktur Berkas Week 9

```text
09-week-9-ai-assisted-development/
├── README.md                                  # Dokumentasi utama modul Week 9
├── mobile-week-9.md                           # Panduan codelab modul
├── docs/
│   └── ai-log.md                              # Log lengkap prompt 5 slot, respons mentah, & verifikasi
├── screenshots/                               # Bukti visual pengujian UI & terminal
└── campus_notify/
    ├── lib/
    │   ├── features/
    │   │   └── announcements/
    │   │       ├── domain/
    │   │       │   ├── entities/announcement.dart
    │   │       │   └── usecases/
    │   │       │       ├── get_announcements.dart
    │   │       │       └── search_announcements.dart       # [BARU] Use Case domain murni
    │   │       └── presentation/
    │   │           └── providers/
    │   │               └── announcements_providers.dart    # [BARU] Search Notifier & Filter Provider
    │   └── pages/
    │       └── home_page.dart                              # [UPDATE] Search bar, Material fix, & Empty State
    └── test/
        ├── search_announcements_test.dart                  # [BARU] 5 unit test use case domain
        └── search_announcements_widget_test.dart           # [BARU] Widget test interaksi & empty state
```
