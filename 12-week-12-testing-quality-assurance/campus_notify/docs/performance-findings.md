# Dokumen Temuan Audit Performa (Performance Findings)
**Proyek:** Campus Notify Mobile Application  
**Modul:** Week 11 — Optimasi Performa Flutter  
**Target Platform:** Mobile (Android / iOS / Windows Desktop)  
**Metode Analisis:** Flutter DevTools (CPU Performance Flame Chart, Frame Chart, Memory Heap Snapshot)  

---

## 1. Ringkasan Eksekutif Baseline

Sebelum dilakukan optimasi performa, aplikasi **Campus Notify** diuji dalam mode profile (`flutter run --profile`) menggunakan Flutter DevTools untuk mengukur kinerja rendering, waktu pemrosesan frame (frame budget), dan konsumsi memori.

Skenario pengujian yang dilakukan meliputi:
1. Membuka dashboard utama (`HomePage`).
2. Melakukan *fast scrolling* bolak-balik pada daftar pengumuman kampus.
3. Melakukan *pull-to-refresh* dan simulasi pembaruan refresh token.
4. Berpindah ke layar obrolan (*Campus AI Chat Assistant*), mengirimkan pesan teks, serta memicu respon Gemini/offline fallback.
5. Melakukan navigasi bolak-balik (*push* dan *pop*) antara Dashboard dan Detail Pengumuman sebanyak 5 kali berturut-turut.

### Metrik Baseline (Sebelum Optimasi):
| Parameter Pengukuran | Nilai Baseline | Status Target (< 16.6 ms) |
|---|:---:|:---:|
| **Average UI Thread Frame Time** | **23.4 ms** | ⚠️ Melampaui Frame Budget (Jank) |
| **Max UI Thread Build Peak** | **38.6 ms** | ❌ Frame Merah (Severe Drop) |
| **Dropped Frames (Jank Count per 100 frames)** | **14 frames (14%)** | ⚠️ Terasa stutter saat scrolling cepat |
| **Raster Thread Time (GPU Paint)** | **14.2 ms** | ⚠️ Mendekati batas kritis |
| **Memory Heap Usage (Baseline)** | **42.8 MB** | Normal |
| **Latensi Akses Pengumuman** | **300 ms** (setiap buka/kembali) | ⚠️ Terlalu lama (tanpa cache) |

---

## 2. Temuan Bottleneck Utama (Minimum 3 Masalah Sesuai Codelab)

Berdasarkan analisis visual Flame Chart dan Timeline Events pada DevTools, kami mengidentifikasi **5 bottleneck utama**:

### Masalah 1: Monolithic Build & Rebuild Berlebih pada `HomePage`
- **Lokasi Kode:** `lib/pages/home_page.dart` (sebelumnya 673 baris kode di satu file).
- **Temuan di Flame Chart:**
  - Saat pengguna menekan *"Simulasi Refresh Token"* atau ketika status banner notifikasi berubah (`_statusMessage`), fungsi `_HomePageState.build()` dieksekusi ulang secara penuh dari root widget.
  - Di dalam method build monolitik tersebut, seluruh kartu (Card Asisten AI, Card Autentikasi, Card FCM Status, Card Uji FCM, dan Card Daftar Pengumuman) diinstansiasi ulang secara serempak.
  - Helper method seperti `_buildTokenRow()` dan `_buildAnnouncementTile()` mengembalikan widget baru tanpa `const` constructor dan tanpa siklus hidup widget terpisah, memaksa Flutter membuat instance objek widget baru pada setiap frame rendering.
- **Dampak:** Terjadi lonjakan call stack `ComponentElement.performRebuild` hingga 34 ms pada UI thread, menyebabkan frame merah (jank).

---

### Masalah 2: Paint Thrashing pada Raster Thread (Ketiadaan `RepaintBoundary`)
- **Lokasi Kode:** Seluruh container kartu di `HomePage` dan bubble pesan di `ChatScreen`.
- **Temuan di Flame Chart & Raster Thread:**
  - Ketika terjadi animasi kecil (seperti `LinearProgressIndicator` pada kartu token atau indikator *typing* berkedip pada chat AI), Flutter me-repaint seluruh area layar yang berada dalam layer render yang sama.
  - Tidak ada pembatas layer (`RepaintBoundary`), sehingga GPU dipaksa menggambar ulang elemen statis di sekitarnya (teks pengumuman, ikon, app bar, background).
- **Dampak:** Raster Thread time melonjak dari 6 ms menjadi 18–22 ms, menimbulkan stuttering visual pada transisi halaman dan scrolling.

---

### Masalah 3: Latensi Jaringan & Akses Berulang Tanpa Cache (Ketiadaan Caching Repository)
- **Lokasi Kode:** `lib/features/announcements/data/repositories/announcement_repository_impl.dart`.
- **Temuan di DevTools Network / Timeline:**
  - Setiap kali pengguna berpindah ke halaman detail pengumuman (`/pengumuman/:id`) lalu kembali ke beranda, atau memuat ulang pengumuman, repository selalu memicu latensi IO jaringan penuh (`Future.delayed(300ms)` atau request HTTP API).
  - Tidak ada mekanisme caching memori lokal (*in-memory cache*) maupun Time-To-Live (TTL).
  - Data pengumuman kampus yang statis diunduh/dihitung berulang kali secara tidak efisien.
- **Dampak:** Pengguna selalu melihat indikator loading berputar selama 300 ms setiap kali membuka pengumuman yang sama, menghabiskan sumber daya CPU, memori, dan daya baterai.

---

### Masalah 4: Inefficient Riverpod Watching (Tanpa Granular `.select`)
- **Lokasi Kode:** `lib/pages/home_page.dart` dan `lib/features/chat_screen.dart`.
- **Temuan di DevTools Performance:**
  - Penggunaan `ref.watch(authStateProvider)` atau `ref.watch(chatNotifierProvider)` tanpa filter menyebabkan widget me-rebuild dirinya meskipun nilai yang berubah tidak relevan dengan UI yang sedang ditampilkan.
  - Contoh: ketika status login diperiksa, jika state internal lain berubah, seluruh dashboard ikut berkedip dirender ulang.
- **Dampak:** Widget rebuild count meningkat 3x lipat lebih tinggi dari yang semestinya dibutuhkan.

---

### Masalah 5: Potensi Memory Retention pada Controller UI
- **Lokasi Kode:** `ChatScreen` (`_textController`, `_scrollController`).
- **Temuan di DevTools Memory:**
  - Ketika pengguna sering keluar-masuk layar obrolan, jika lifecycle `dispose()` tidak dijaga secara disiplin atau listener stream FCM/Riverpod tidak dibersihkan, instance controller tetap tertahan di heap memory (*object leakage*).
- **Dampak:** Terjadi penumpukan memory allocation (Dart VM heap leakage) secara perlahan.

---

## 3. Rencana Tindakan Optimasi Teknis

Berdasarkan temuan di atas, kami menetapkan 5 langkah optimasi konkret pada kode sumber aplikasi:

1. **Widget Decomposition & Const Standardization:**
   - Memecah `HomePage` menjadi widget-widget terpisah di `lib/pages/widgets/`:
     - `AiAssistantBannerCard`
     - `AuthStatusCard`
     - `FcmStatusCard`
     - `FcmTestingCard`
     - `AnnouncementSection` & `AnnouncementCardTile`
   - Memaksimalkan penggunaan constructor `const` pada seluruh elemen statis.

2. **Isolasi Layer Rendering dengan `RepaintBoundary`:**
   - Membungkus setiap kartu di dashboard dan setiap bubble obrolan di `ChatMessageBubble` dengan `RepaintBoundary` untuk mengisolasi area repaint GPU.

3. **Penerapan Caching Stale-While-Revalidate (SWR):**
   - Menambahkan memory cache dengan TTL 5 menit pada `AnnouncementRepositoryImpl`.
   - Mengembalikan data dari cache secara instan (0 ms latency), dan melakukan revalidasi segar di latar belakang atau melalui parameter `forceRefresh: true`.

4. **Granular Listening dengan Riverpod `.select(...)`:**
   - Menerapkan `ref.watch(authStateProvider.select((s) => s.isLoggedIn))` sehingga dashboard hanya rebuild saat status login benar-benar berganti.

5. **Disposal Lifecycle Sanitization:**
   - Memastikan seluruh controller (`ScrollController`, `TextEditingController`) ter-`dispose` secara deterministik pada method `dispose()`.

