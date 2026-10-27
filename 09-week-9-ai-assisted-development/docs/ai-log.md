# Dokumentasi AI Log: AI-Assisted Development (Week 9)

**Proyek:** Campus Notify (`09-week-9-ai-assisted-development`)  
**Modul:** #09 | AI-Assisted Development / Vibe Coding  
**Tools AI:** Antigravity IDE / Gemini Coding Assistant  
**Tanggal:** 27 Oktober 2026  

---

## 1. Konsep & Filosofi AI Workflow

Workflow pengembangan berbasis AI diimplementasikan mengikuti siklus 6 tahap:

```text
1. Prompt   -> Instruksi terstruktur dengan formula 5 slot + konteks arsitektur
2. Generate -> AI mengusulkan draft implementasi awal
3. Verify   -> Membaca kritis tiap baris, cek sterilitas import domain, cek API nyata
4. Test     -> Test merah (pembukti bug awal) -> perbaikan -> test hijau
5. Refactor -> Merapikan kode ke Clean Architecture feature-first & Riverpod 3.x
6. Explain  -> Mampu mempertanggungjawabkan keputusan teknis tanpa bergantung pada AI
```

> **Catatan Pencegahan *Vibe Coding*:** Menghindari menerima kode AI secara mentah. Setiap potongan kode yang di-generate wajib melalui verifikasi statis (`flutter analyze`), pengujian otomatis (`flutter test`), dan isolasi layer.

---

## 2. Praktikum 1: Prompt & Context Engineering

### 2.1 Formula 5 Slot

Penerapan formula 5 slot yang dirancang untuk fitur pencarian pengumuman kampus:

```text
1. Peran  : Senior Flutter Developer & Clean Architecture Architect.
2. Konteks: Fitur 'announcements' pada aplikasi 'campus_notify' dengan Clean Architecture
            feature-first (presentation -> domain <- data), state management Riverpod 3.x,
            entitas Announcement (id, title, category, body, author, publishedAt).
3. Tugas  : Buatkan fitur pencarian judul & isi pengumuman kampus lengkap dengan
            komponen Empty State saat pencarian tidak menemukan hasil.
4. Batas  : Logika pencarian WAJIB berada di layer domain (murni Dart, zero-dependency,
            dilarang import Flutter/Dio/SQLite). State management menggunakan Riverpod.
            Panjang use case di bawah 40 baris. Sertakan unit test dan widget test.
5. Output : Kode usecase domain, provider Riverpod, integrasi widget, dan test penguji.
```

### 2.2 Perbandingan Prompt Buruk vs Prompt Baik

| Karakteristik | Prompt Buruk (*Vibe Coding*) | Prompt Baik (*Context Engineering*) |
|---|---|---|
| **Contoh Prompt** | *"Buatin search pengumuman dong yang ada empty statenya"* | *"Sebagai senior Flutter dev, buatkan use case domain murni `SearchAnnouncements` untuk memfilter List<Announcement> berdasarkan query judul dan body. Wajib case-insensitive dan trim whitespace. Jangan import Flutter/Dio/SQLite di domain. Sediakan Riverpod provider dan empty state widget."* |
| **Kelemahan/Kelebihan** | AI menebak struktur sendiri; biasanya mencampur query langsung di dalam UI widget; rawan method halusinasi. | AI dibatasi oleh arsitektur proyek; kode terisolasi di layer yang benar; mudah diuji dengan unit test. |
| **Hasil Kode** | Stateful widget gemuk > 150 baris dengan logika `setState` dan `List.where` tercampur. | Use case domain murni 30 baris, testable, terpisah dari UI. |

### 2.3 Konteks yang Diberikan vs Rahasia yang Dilindungi
- **Diberikan ke AI:** Struktur folder feature-first, signature kelas entity `Announcement`, versi Flutter & Riverpod dari `pubspec.yaml`.
- **Dilindungi (Tidak Dibagikan):** Token otentikasi JWT, credential Firebase/FCM, endpoint sensitif kampus, dan file konfigurasi lokal.

---

## 3. Praktikum 2: Generate & Verifikasi Fitur Search

### 3.1 Prompt Mentah ke AI
```text
Buatkan fitur search pengumuman kampus untuk aplikasi Flutter campus_notify.
Model data: Announcement(id, title, category, body, author, publishedAt).
Sertakan filter pencarian dan tampilan empty state jika tidak ada data yang cocok.
```

### 3.2 Output Awal AI (Raw Suggestion) & Analisis Kritis
Pada percobaan awal tanpa konteks Clean Architecture yang ketat, AI mengusulkan implementasi filter langsung di dalam UI Widget:

```dart
// KODE AWAL AI (Bermasalah & Vibe Coding):
class _AnnouncementListState extends State<AnnouncementList> {
  String _query = '';
  
  List<Announcement> get filteredAnnouncements {
    return widget.announcements.where((a) {
      // ⚠️ BUG 1: Case-sensitive! "jadwal" tidak cocok dengan "Jadwal Kuliah"
      // ⚠️ BUG 2: Tidak ada trim! Spasi di awal/akhir menyebabkan miss
      // ⚠️ BUG 3: Logika filter menempel di widget (melanggar Clean Architecture)
      return a.title.contains(_query);
    }).toList();
  }
  ...
}
```

### 3.3 Verifikasi 6 Langkah

1. **Baca tiap baris:** Mengidentifikasi bahwa filter `contains(_query)` peka huruf besar/kecil (*case-sensitive*), mengabaikan properti `body` dan `category`, serta menempatkan logika bisnis di layer presentasi.
2. **Cek import:** Memastikan bahwa layer `domain` tidak mengimpor `package:flutter/...`, `package:dio/...`, atau `package:flutter_secure_storage/...`.
3. **Cek API nyata:** Memverifikasi penggunaan `NotifierProvider` dan `AsyncValue.whenData` pada Riverpod 3.x dan penanganan widget `Material` untuk `ListTile`.
4. **Jalankan static analysis:** Menjalankan `flutter analyze` hingga menghasilkan **0 issues**.
5. **Test bukti:** Menulis unit test untuk membuktikan case-insensitivity dan widget test untuk empty state.
6. **Uji manual 3 skenario:**
   - Query kosong: menampilkan seluruh 3 pengumuman kampus.
   - Query cocok (`"beasiswa"` / `"JADWAL"`): menampilkan item yang relevan.
   - Query tidak cocok (`"zzz-tak-ada"`): menampilkan ilustrasi empty state dengan pesan ramah dan tombol reset.

---

## 4. Praktikum 3: Debug & Refactoring (Test Merah ke Hijau)

### 4.1 Siklus TDD: Test Merah ke Hijau

```text
[Reproduksi Bug]  -> Query 'jadwal' gagal mencocokkan 'Jadwal Kuliah Semester Baru' karena case-sensitive.
[Test Merah]      -> test/search_announcements_test.dart dijalankan dengan query beda huruf kapital.
[Isolasi Domain]  -> Logika dipindahkan ke use case murni SearchAnnouncements dengan .trim().toLowerCase().
[Test Hijau]      -> Seluruh 5 test case unit lulus (All tests passed!).
[Refactor Layer]  -> Menghubungkan use case ke Riverpod NotifierProvider dan HomePage UI.
```

### 4.2 Pemisahan Layer Bersih (Clean Architecture)

```text
┌────────────────────────────────────────────────────────────────────────┐
│ UI Layer (lib/pages/home_page.dart)                                    │
│ - TextField dengan onChanged memicu SearchQueryNotifier.setQuery()    │
│ - Menampilkan Empty State (Key: announcement_empty_state)              │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ watch
┌───────────────────────────────────▼────────────────────────────────────┐
│ Presentation State (announcements_providers.dart)                      │
│ - searchQueryProvider: Notifier<String>                                │
│ - filteredAnnouncementsProvider: Provider<AsyncValue<List<Announcement>>>
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ memanggil
┌───────────────────────────────────▼────────────────────────────────────┐
│ Domain Layer (usecases/search_announcements.dart)                      │
│ - Pure Dart: SearchAnnouncements.call({announcements, query})          │
│ - Case-insensitive & trimmed matching                                 │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ membaca entity
┌───────────────────────────────────▼────────────────────────────────────┐
│ Domain Entity (entities/announcement.dart)                             │
│ - Announcement(id, title, category, body, author, publishedAt)        │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 5. AI Challenge: Review Kritis & Evaluasi Senior Developer

Prompt review yang diajukan ke AI:
```text
Review kode search Flutter ini sebagai senior dev.
Konteks: feature-first (presentation -> domain <- data), Riverpod 3.x, clean architecture.
Fokus: kebenaran, arsitektur, testability. Abaikan style formatting.
Beri 3 temuan + level blocker/saran + alasan teknis.
```

### 5.1 Tiga Temuan Review AI

| No | Temuan AI | Level | Keputusan | Alasan Teknis & Bukti |
|:--:|---|:---:|:---:|---|
| **1** | **ListTile Ink Splash Hidden by DecoratedBox**: `ListTile` dibungkus dalam `Container(decoration: BoxDecoration(color: ...))` menyebabkan assertion crash di Flutter 3.27+ karena background menutupi splash canvas Material. | **Blocker** | **Diterima & Diperbaiki** | Terbukti saat menjalankan widget test, Flutter melempar framework exception. Diperbaiki dengan membungkus `ListTile` menggunakan `Material(shape: RoundedRectangleBorder(...))` sehingga ripple effect dan background render sempurna. |
| **2** | **Saran Penambahan Debouncing Stream via RxDart**: AI menyarankan menambahkan package `rxdart` dan `BehaviorSubject` untuk melakukan debounce pada input pencarian (300ms). | **Saran** | **Ditolak** | Data pengumuman saat ini bersumber dari in-memory cache/mock lokal berukuran kecil (< 100 entri). Filter berbasis use case murni dieksekusi dalam sub-milidetik tanpa memicu I/O jaringan. Menambahkan RxDart melanggar prinsip **YAGNI** (*You Aren't Gonna Need It*) dan menambah footprint dependensi tanpa urgensi performa nyata. |
| **3** | **UX Missing Reset Action pada Empty State**: Saat filter tidak menghasilkan data, pengguna tidak memiliki jalan pintas satu klik untuk mengembalikan seluruh daftar pengumuman selain menghapus teks satu per satu. | **Saran** | **Diterima & Diperbaiki** | Menambahkan `OutlinedButton` *"Reset Pencarian"* di card empty state dan suffix icon `IconButton(Icons.clear)` pada search TextField. Meningkatkan efisiensi navigasi pengguna. |

### 5.2 Tabel Keputusan per Berkas

| Berkas | Usulan AI | Keputusan Final | Justifikasi Teknis |
|---|---|---|---|
| `lib/features/announcements/domain/usecases/search_announcements.dart` | Buat usecase domain murni | **Terima + Refactor** | Ditambahkan validasi `trim().isEmpty` dan matching multi-atribut (`title`, `category`, `body`). |
| `lib/features/announcements/presentation/providers/announcements_providers.dart` | Buat provider filter terintegrasi Riverpod | **Terima** | Menggunakan `NotifierProvider<SearchQueryNotifier, String>` dan `filteredAnnouncementsProvider` yang reaktif. |
| `lib/pages/home_page.dart` | Pasang search bar & empty state di dashboard | **Terima + Refactor** | Mengganti DecoratedBox dengan `Material` widget untuk ink splash compliance dan menghubungkan controller. |
| `test/search_announcements_test.dart` | Unit test use case | **Terima** | Menguji case-insensitivity, whitespace trim, empty query, dan non-match query. |
| `test/search_announcements_widget_test.dart` | Widget test UI & empty state | **Terima** | Menjamin interaksi mengetik query dan reset filter terverifikasi otomatis. |

---

## 6. Bukti Verifikasi Mesin

### 6.1 Static Analysis (`flutter analyze`)
```text
$ flutter analyze
Analyzing campus_notify...                                      
No issues found! (ran in 10.7s)
```

### 6.2 Unit & Widget Testing (`flutter test`)
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

### 6.3 Pemeriksaan Sterilitas Layer (Grep Verifikasi)
```powershell
# 1. Domain steril dari Flutter, Dio, Sqflite, Firebase:
Get-ChildItem -Path "lib/features/*/domain","lib/core" -Recurse -Filter "*.dart" |
  Select-String -Pattern "import 'package:flutter|import 'package:dio|import 'package:sqflite|import 'package:firebase"
# Hasil: 0 temuan (Steril 100%)

# 2. Presentation steril dari low-level data access:
Get-ChildItem -Path "lib/features/*/presentation" -Recurse -Filter "*.dart" |
  Select-String -Pattern "Dio\(|openDatabase|FlutterSecureStorage|SharedPreferences|jsonDecode"
# Hasil: 0 temuan (Steril 100%)
```

---

## 7. Checklist Verifikasi Mandiri

- [x] **Prompt 5 Slot + Konteks**: Terdokumentasi lengkap dengan peran, batas, dan kriteria Clean Architecture.
- [x] **Karakteristik Halusinasi Diidentifikasi**: Menandai kelemahan case-sensitive dan logika bocor ke layer UI.
- [x] **Logika Terisolasi di Domain**: `SearchAnnouncements` berdiri sendiri sebagai class Dart murni.
- [x] **State Management Bersih**: Query dan hasil filter dikelola oleh Riverpod (`searchQueryProvider`, `filteredAnnouncementsProvider`).
- [x] **Empty State Terpasang**: Tersedia tampilan ramah pengguna dengan tombol aksi reset saat hasil nihil.
- [x] **Pengujian Lengkap**: 5 test case unit usecase + 1 widget test komprehensif seluruh alur interaksi.
- [x] **Mesin Hijau 100%**: `flutter analyze` 0 issues, `dart format` bersih, `flutter test` lulus 18/18 test.
- [x] **Mampu Menjelaskan Mandiri**: Pengembang memahami alasan setiap layer tanpa perlu merujuk kembali ke AI.
