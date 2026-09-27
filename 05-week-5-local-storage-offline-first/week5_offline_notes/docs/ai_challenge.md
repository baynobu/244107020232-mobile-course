# Dokumentasi AI Challenge: Analisis & Pemilihan Storage Flutter Offline-First

Dokumen ini mendokumentasikan pelaksanaan **AI Challenge** sesuai modul Minggu 5: *Local Storage & Offline First*.

---

## 1. AI Prompt Challenge

Berikut adalah prompt yang digunakan untuk mengevaluasi opsi penyimpanan lokal pada aplikasi Flutter Offline Notes:

```text
Aplikasi Flutter Offline Notes: CRUD catatan + preferensi tema.
Bandingkan SharedPreferences, Hive, sqflite (SQLite), dan Drift untuk dua kebutuhan ini. 
Requirements:
- Kriteria: kompleksitas query, kebutuhan relasi, reaktivitas (stream), type-safety, ukuran boilerplate, dan kemudahan testing.
- Beri rekomendasi final: mana untuk preferensi, mana untuk catatan, beserta alasannya dalam 1 tabel.
- Tunjukkan skema tabel/kotak untuk 1000+ catatan.
Jelaskan trade-off setiap pilihan.
```

---

## 2. Tabel Perbandingan Opsi Storage

| Kriteria | SharedPreferences | Hive | sqflite (SQLite) | Drift (Moor) |
| :--- | :--- | :--- | :--- | :--- |
| **Model Data** | Key-Value sederhana (String, int, double, bool, List\<String\>) | NoSQL Key-Value / Document Box (binary format) | Relasional (SQL Tables, Rows, Columns) | Relasional Type-safe (SQL di atas SQLite) |
| **Kompleksitas Query** | Sangat Terbatas (hanya lookup `get(key)`) | Terbatas (filter list di memori via Dart, tidak ada SQL engine) | Sangat Tinggi (Full SQL: WHERE, ORDER BY, JOIN, GROUP BY, Indexing) | Sangat Tinggi (Fluent Dart API + Full SQL + Compile-time verification) |
| **Kebutuhan Relasi** | Tidak mendukung relasi antardata | Tidak mendukung relasi native (harus manual manual ID linking) | Mendukung penuh (Foreign Keys, JOIN, Cascades) | Mendukung penuh (Type-safe Relations & Joined Queries) |
| **Reaktivitas (Stream)** | Tidak ada stream bawaan (perlu polling atau state wrapper manual) | Mendukung `watch()` pada box/key | Tidak ada stream native (perlu Riverpod/Bloc invalidation) | Mendukung native `watch()` queries menghasilkan `Stream<List<T>>` |
| **Type-Safety** | Lemah (runtime type casting) | Menengah (butuh TypeAdapter manual / build_runner) | Rendah (Map\<String, Object?\>, raw SQL strings) | Sangat Tinggi (Generated Dart classes, compile-time SQL verification) |
| **Ukuran Boilerplate** | Sangat Rendah (langsung pakai tanpa generator) | Rendah–Menengah (TypeAdapters + TypeIds) | Menengah (Helper DB, raw SQL schema, toMap/fromMap) | Tinggi (Code generator, `build_runner`, file table definition) |
| **Kemudahan Testing** | Sangat Mudah (Mock/Fake in-memory Map) | Mudah (in-memory box atau mock) | Mudah dengan Fake Repository / `sqflite_common_ffi` | Menengah (butuh generate code & in-memory sqlite) |

---

## 3. Skema Penyimpanan untuk Skala 1000+ Catatan

Untuk menjaga performa aplikasi tetap cepat (responsif dalam hitungan milidetik) saat menangani 1000+ catatan, skema harus memiliki **Index** pada field yang sering di-filter dan diurutkan (`updated_at` dan `dirty`).

### A. Skema SQLite (`sqflite`) - Pendekatan Terpilih

```sql
CREATE TABLE notes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  body TEXT NOT NULL DEFAULT '',
  updated_at TEXT NOT NULL,
  dirty INTEGER NOT NULL DEFAULT 0
);

-- Index penting untuk sorting daftar catatan terbaru (1000+ data)
CREATE INDEX idx_notes_updated_at ON notes(updated_at DESC);

-- Index penting untuk query antrean sync (SELECT WHERE dirty = 1)
CREATE INDEX idx_notes_dirty ON notes(dirty);

-- Tabel Cache untuk data bacaan jarak jauh (Cache-First Read API)
CREATE TABLE cached_posts (
  id INTEGER PRIMARY KEY,
  payload TEXT NOT NULL,
  cached_at TEXT NOT NULL
);
CREATE INDEX idx_cached_posts_cached_at ON cached_posts(cached_at DESC);
```

### B. Alternatif Skema Box NoSQL (`Hive`)

```dart
@HiveType(typeId: 0)
class NoteHive extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String body;

  @HiveField(3)
  late DateTime updatedAt;

  @HiveField(4)
  late bool dirty;
}
// Box: Box<NoteHive> notesBox = Hive.box<NoteHive>('notes');
```
*Catatan:* Pada Hive, pengurutan dan pencarian 1000+ catatan dilakukan di memori (RAM), sehingga tidak efisien jika catatan berukuran besar dan membutuhkan pagination.

---

## 4. Rekomendasi Final

| Kebutuhan | Storage Terpilih | Alasan Utama |
| :--- | :--- | :--- |
| **Preferensi Tema & Waktu Buka** | `SharedPreferences` | Data hanya bernilai primitif (boolean `dark_mode` dan ISO String `last_opened_at`). Overhead minimal, tidak butuh struktur tabel, dan eksekusi instan tanpa konfigurasi engine database. |
| **Daftar Catatan & Cache Post** | `sqflite` (SQLite) | Membutuhkan operasi CRUD terstruktur, pengurutan `updated_at DESC`, penghitungan flag `dirty = 1` dengan `COUNT(*)`, transaksi ACID, serta dukungan indexing saat catatan bertambah ribuan. |

---

## 5. AI Verification Checklist

Berikut adalah verifikasi kritis terhadap rekomendasi yang diajukan AI:

- [x] **Apakah AI menempatkan daftar catatan di SharedPreferences?**  
  **Jawaban & Keputusan:** **TIDAK/DITOLAK**. Menyimpan daftar catatan di `SharedPreferences` (misalnya dengan men-serialize seluruh list catatan ke satu JSON string raksasa) adalah anti-pattern fatal. Seluruh file XML/plist preferensi akan dimuat ke memori setiap kali ada akses, dan satu kesalahan penulisan dapat merusak seluruh data (*data corruption*). SharedPreferences hanya untuk data preferensi atomik.

- [x] **Apakah skema AI mendukung antrean sync (dirty flag / updated_at) atau hanya CRUD polos?**  
  **Jawaban & Keputusan:** Skema awal AI sering kali hanya menyertakan CRUD polos (`id, title, content`). Skema **wajib dilengkapi field `dirty` (INTEGER 0/1) dan `updated_at` (TEXT/DATETIME)** agar mendukung mekanisme offline-first, pelacakan perubahan tertunda, dan penyelesaian konflik *last-write-wins*.

- [x] **Apakah klaim "real-time" AI didukung stream (Drift/watch) atau hanya asumsi?**  
  **Jawaban & Keputusan:** Pada `sqflite`, operasi database bersifat pasif (Future-based). Klaim reaktivitas "real-time" pada sqflite dalam praktiknya dicapai melalui state management (Riverpod `ref.invalidate()` atau StreamController pada repository), bukan stream native database. Jika reaktivitas query level database tanpa invalidasi manual dibutuhkan, `Drift` adalah pilihan yang tepat.

- [x] **Apakah estimasi boilerplate AI masuk akal setelah Anda mencoba instalasinya?**  
  **Jawaban & Keputusan:** Estimasi boilerplate AI untuk `Drift` sering diremehkan. Drift membutuhkan dependensi tambahan (`drift`, `sqlite3_flutter_libs`, `drift_dev`, `build_runner`), waktu compile generasi kode tambahan, dan setup migrasi yang ketat. Untuk skala offline notes tugas ini, kombinasi `sqflite` + `Riverpod` memberikan rasio kesederhanaan dan kontrol yang optimal.

- [x] **Keputusan Final:**  
  Menggunakan **`SharedPreferences` untuk preferensi aplikasi** dan **`sqflite` untuk repository catatan lokal dan cache API**. Arsitektur dilindungi oleh **Repository Pattern**, sehingga jika di kemudian hari tim memutuskan bermigrasi ke Drift atau Hive, lapisan UI (Widget) tidak perlu diubah sama sekali.
