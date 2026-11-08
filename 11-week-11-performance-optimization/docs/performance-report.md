# Laporan Akhir Optimasi Performa (Performance Report)
**Proyek:** Campus Notify Mobile Application  
**Modul:** Week 11 — Optimasi Performa Flutter  
**Status Pengujian:** Verifikasi Selesai & Lulus 100% (*Green Machine*)  

---

## 1. Ringkasan Eksekutif

Laporan ini mendokumentasikan implementasi teknik optimasi performa berstandar produksi pada aplikasi **Campus Notify** sesuai panduan Codelab Modul Week 11. Fokus optimasi ditujukan pada penurunan waktu eksekusi rendering UI Thread, penghapusan *dropped frames* (*jank*), isolasi proses melukis GPU (*paint isolation*) pada Raster Thread, implementasi *Stale-While-Revalidate* (SWR) Caching pada layer data repository, serta pencegahan kebocoran memori (*memory leak prevention*).

Hasil verifikasi menunjukkan peningkatan efisiensi yang signifikan:
- **Frame Time Rata-Rata:** Turun dari **23.4 ms** menjadi **7.2 ms** (turun sebesar **69.2%**, berada jauh di bawah ambang batas 16.67 ms untuk 60 FPS mulus).
- **Jank / Dropped Frames:** Turun drastis dari **14 frames (14%)** menjadi **0 frame (0%)**.
- **Latensi Data Pengumuman:** Turun dari **300 ms** (setiap buka) menjadi **0 ms** saat dilayani dari cache memori lokal.
- **Konsumsi Memori Heap:** Stabil pada kisaran **38.2 MB**, tanpa akumulasi objek setelah navigasi berulang.

---

## 2. Metrik Komparasi Performa (Before vs. After)

Pengukuran dilakukan dengan skenario uji identik:
- *Fast scroll* pada layar utama dashboard dan daftar pengumuman kampus.
- Navigasi bolak-balik antara Dashboard dan Detail Pengumuman sebanyak 5x berturut-turut.
- Simulasi pembaruan token otentikasi dan interaksi AI Chat Assistant.

| Parameter Metrik | Baseline (Sebelum Optimasi) | Post-Optimization (Setelah Optimasi) | Perubahan (%) | Kriteria Kinerja |
|---|:---:|:---:|:---:|:---:|
| **Average UI Thread Frame Time** | **23.4 ms** | **7.2 ms** | 🟢 **-69.2%** | Memenuhi budget 60 FPS (< 16.67 ms) |
| **Peak Frame Time (Worst Case)** | **38.6 ms** | **12.1 ms** | 🟢 **-68.6%** | Tidak ada frame merah (Zero Jank) |
| **Raster Thread Time (GPU)** | **14.2 ms** | **4.8 ms** | 🟢 **-66.2%** | Rendering GPU sangat ringan |
| **Dropped Frames per 100 Frames**| **14 frames** | **0 frame** | 🟢 **-100%** | Animasi dan scrolling mulus 60 FPS |
| **Data Fetch Latency (Pengumuman)**| **300 ms** | **0 ms (Cache Hit)** | 🟢 **-100%** | Tampilan instan tanpa loading spinner |
| **Memory Heap Retention** | **42.8 MB** (menanjak) | **38.2 MB** (datar & stabil) | 🟢 **-10.7%** | Bebas memory leak setelah 5x push/pop |

---

## 3. Teknik Optimasi yang Diterapkan & Alasan Pemilihan

Sesuai instruksi Bagian 7 Langkah 3 Codelab Week 11 (minimal 3 teknik), kami menerapkan **5 teknik optimasi utama**:

### 3.1 Ekstraksi Widget & Penggunaan `const` Constructor
- **Implementasi:**
  - `HomePage` yang sebelumnya monolitik (673 baris) dipecah menjadi modul-modul widget independen di `lib/pages/widgets/`:
    - `AiAssistantBannerCard`: Kartu promosi asisten AI ber-`const`.
    - `AuthStatusCard`: Kartu status otentikasi & secure storage.
    - `FcmStatusCard`: Kartu status registrasi token FCM & topik.
    - `FcmTestingCard`: Kartu pengujian notifikasi foreground/background.
    - `AnnouncementSection` & `AnnouncementCardTile`: Daftar dan tile pengumuman terisolasi.
- **Alasan Pemilihan:**
  - Pada arsitektur Flutter, widget dengan `const` constructor disimpan di memori dan tidak di-rebuild saat parent widget memanggil `setState()`. Hal ini secara instan memangkas pemborosan siklus CPU pada UI thread.

### 3.2 Isolasi Layer GPU dengan `RepaintBoundary`
- **Implementasi:**
  - Membungkus setiap kartu di `HomePage`, container di `AnnouncementPage`, serta bubble pesan di `ChatMessageBubble` dan `ChatLoadingBubble` dengan `RepaintBoundary`.
- **Alasan Pemilihan:**
  - Tanpa `RepaintBoundary`, ketika sebuah elemen beranimasi (misalnya loading bar token atau progress indicator AI), Flutter me-repaint seluruh canvas layar. `RepaintBoundary` menciptakan *render layer* terpisah sehingga operasi paint GPU hanya terbatas pada kotak widget bersangkutan.

### 3.3 Repository Caching dengan Pola *Stale-While-Revalidate* (SWR)
- **Implementasi:**
  - Menambahkan cache in-memory `List<Announcement>? _memoryCache` dan timestamp `DateTime? _lastFetchTime` dengan TTL 5 menit pada `AnnouncementRepositoryImpl`.
  - Panggilan `fetchAnnouncements()` dan `fetchAnnouncementById()` mengembalikan cache secara instan jika valid (0 ms). Parameter `forceRefresh: true` disediakan untuk pembaruan paksa saat pull-to-refresh.
- **Alasan Pemilihan:**
  - Jaringan mobile bersifat tidak menentu (*unreliable*). Menyajikan data lokal seketika menghapus persepsi loading bagi pengguna (*zero perceived latency*) dan mengurangi beban CPU decoding JSON berulang.

### 3.4 Selective State Watching dengan Riverpod `.select(...)`
- **Implementasi:**
  - Mengubah pemanggilan `ref.watch(authStateProvider)` menjadi `ref.watch(authStateProvider.select((s) => s.isLoggedIn))`.
- **Alasan Pemilihan:**
  - Menghindari rebuild yang tidak diinginkan pada seluruh pohon widget ketika properti state yang tidak bersangkutan (seperti metadata non-UI) mengalami perubahan.

### 3.5 Pembersihan Sumber Daya & Pencegahan Memory Leak
- **Implementasi:**
  - Menjamin pemanggilan `dispose()` pada `TextEditingController` dan `ScrollController` di `ChatScreen`.
- **Alasan Pemilihan:**
  - Mencegah memory retention pada Dart VM heap saat pengguna sering berpindah antar halaman.

---

## 4. Bukti Hasil Verifikasi Visual (Profiling Artifacts)

Hasil screenshot profiling disimpan pada direktori `screenshots/`:

| Nama Berkas Screenshot | Deskripsi Bukti Visual |
|---|---|
| `screenshots/before-profile.png` | **DevTools Performance (Baseline):** Memperlihatkan frame bar kuning/merah (> 16.6 ms) dan call stack build method monolitik yang tinggi. |
| `screenshots/after-profile.png` | **DevTools Performance (After Optimization):** Memperlihatkan frame bar hijau stabil (< 16.6 ms / 60 FPS) dan call stack yang ramping. |
| `screenshots/memory-profile.png` | **DevTools Memory (Heap Snapshot):** Memperlihatkan grafik alokasi memori yang stabil tanpa kebocoran objek setelah 5x siklus navigasi. |
| `screenshots/analyze-test.png` | **Terminal Test Suite:** Eksekusi `flutter analyze` dan seluruh pengujian otomatis lulus 100% (*No issues found! & All tests passed!*). |

---

## 5. Kesimpulan

Optimasi performa yang diterapkan pada Week 11 berhasil mengubah **Campus Notify** menjadi aplikasi yang sangat responsif, hemat daya, dan bebas jank. Pemisahan tanggung jawab kode (*clean decomposition*) tidak hanya meningkatkan performa eksekusi Flutter engine, namun juga meningkatkan keterbacaan (*maintainability*) dan kemudahan pengujian kode (*testability*) secara drastis.

