# Dokumentasi AI Challenge: Clean Architecture — Campus Notify

## 1. AI Tools yang Digunakan
- **Model / Tools**: Gemini Coding Assistant (Antigravity IDE)
- **Tujuan**: Mengusulkan reorganisasi folder ke Clean Architecture feature-first untuk fitur `auth` dan `announcements`.

---

## 2. Prompt yang Digunakan

```text
Project Flutter saya: campus_notify (auth + FCM + daftar pengumuman).
Kondisi kini: folder lib/{data, providers, pages, messaging},
repository tercampur dengan implementasi, widget memanggil Dio langsung.
Tugas:
1. Usulkan struktur feature-first Clean Architecture
   (presentation/domain/data) untuk fitur auth + announcements.
2. Untuk tiap file lama, sebutkan tujuan barunya (pindah/pecah/hapus).
3. Tandai bagian yang over-engineering bila diterapkan ke CRUD sederhana,
   dan kapan use case benar-benar dibutuhkan vs repository langsung.
4. Tunjukkan wiring DI dengan Riverpod (tanpa package DI tambahan).
Jelaskan trade-off setiap keputusan.
```

---

## 3. Usulan AI vs Keputusan Final

| File Lama | Usulan AI | Keputusan Final | Alasan |
|-----------|-----------|-----------------|--------|
| `data/auth_repository.dart` | Pecah menjadi `auth/domain/entities/auth_session.dart` + `auth/domain/repositories/auth_repository.dart` (interface) + `auth/data/repositories/auth_repository_impl.dart` (impl) | **Diterima** | Interface harus di domain agar domain steril dari implementasi. |
| `data/token_store.dart` | Pindah ke `auth/data/datasources/token_store.dart` | **Disederhanakan** | Diintegrasikan langsung ke `AuthRepositoryImpl` karena token store bukan sumber data independen — tidak perlu abstraksi terpisah. |
| `data/api_client.dart` | Pindah ke `core/network/api_client.dart` | **Diterima** | Dio client adalah detail infrastruktur lintas fitur, bukan milik satu fitur. |
| `data/api_errors.dart` | Hapus, ganti dengan `core/failures.dart` | **Diterima sebagian** — `api_errors.dart` dipertahankan untuk mapping Dio ke Failure, `failures.dart` ditambah | `api_errors.dart` dibutuhkan karena memetakan `DioException` spesifik. Kedua file koeksistensi. |
| `providers/auth_provider.dart` | Pindah ke `auth/presentation/providers/auth_providers.dart` | **Diterima** | Provider wiring harus per fitur agar fitur dapat dipahami/dihapus secara mandiri. |
| `pages/home_page.dart` | Tetap di `presentation/pages` atau `auth/presentation/pages/` | **Tetap dipertahankan** di `pages/` | Home page adalah "orkestrator" dashboard yang menggunakan banyak fitur; memindahkannya ke satu fitur malah menciptakan dependensi antar-fitur. |
| `pages/announcement_page.dart` | Pindah ke `announcements/presentation/pages/` | **Diterima sebagian** | Halaman dipertahankan di `pages/` agar GoRouter di `main.dart` tidak perlu banyak perubahan. |

---

## 4. Evaluasi AI Verification Checklist

| Kriteria | Status | Catatan |
|----------|--------|---------|
| Interface repository di `domain`, implementasi di `data` | ✅ Terpenuhi | `AnnouncementRepository` (domain), `AnnouncementRepositoryImpl` (data) |
| `domain` steril dari Flutter/Dio/SQLite/Firebase | ✅ Terpenuhi | Diverifikasi dengan grep (NOL hasil) |
| Use case per CRUD satu-baris (over-engineering)? | ⚠️ Dievaluasi — sebagian | `GetAnnouncements` dipertahankan karena akan berkembang (paginasi, filter). `fetchAnnouncementById` dipanggil langsung di provider tanpa use case terpisah. |
| Entity bebas mapping (`toMap/fromMap` hanya di model) | ✅ Terpenuhi | `Announcement` entity murni; mapping hanya di `AnnouncementModel` |
| Wiring DI terpusat di provider | ✅ Terpenuhi | Widget tidak pernah `new Repository()` sendiri |

---

## 5. Bagian yang Ditolak / Disederhanakan dari Saran AI

### 5.1 Use Case per CRUD Satu-Baris

**Usulan AI**: Membuat use case `FetchAnnouncementById`, `AddAnnouncement`, `DeleteAnnouncement` masing-masing satu file.

**Keputusan Final**: Hanya `GetAnnouncements` dibuat sebagai use case.  
**Alasan teknis**: `fetchAnnouncementById` adalah satu-baris sederhana yang tidak memiliki logika bisnis tambahan. Menambahkan use case terpisah hanya memperbanyak file boilerplate tanpa nilai nyata. Sesuai prinsip YAGNI (*You Aren't Gonna Need It*) — use case dibenarkan hanya bila ada logika bisnis tambahan (validasi, transformasi, orchestration) atau bila operasi melibatkan >1 repository.

### 5.2 Abstract Token Store

**Usulan AI**: Membuat `ITokenStore` interface terpisah.

**Keputusan Final**: Tidak dibuat.  
**Alasan teknis**: `TokenStore` hanya digunakan oleh `AuthRepositoryImpl`. Membuat interface `ITokenStore` dan implementasinya hanya untuk `AuthRepository` adalah over-engineering untuk tim kecil. Dependensi `FlutterSecureStorage` terkurung di layer data dan tidak pernah menembus domain.

### 5.3 Global Providers File

**Usulan AI**: Membuat `lib/core/providers.dart` global untuk semua provider.

**Keputusan Final**: Provider diletakkan per fitur.  
**Alasan teknis**: Satu file global untuk semua provider menciptakan ketergantungan keseluruhan (semua fitur harus di-import bersama). Feature-first mensyaratkan setiap fitur dapat dipahami, diuji, dan dihapus secara mandiri.

---

## 6. Trade-off yang Didiskusikan

| Keputusan | Pro | Kontra |
|-----------|-----|--------|
| Feature-first vs Layer-first | Setiap fitur mandiri, mudah skala | Lebih banyak folder; kurva belajar awal lebih curam |
| Use case hanya bila perlu | YAGNI — kode lebih ringkas | Bila kebutuhan bertambah, perlu tambah use case belakangan |
| Mock data di repository impl | Backend tidak diperlukan untuk develop/test | Mock harus disingkirkan saat backend tersedia |
| Record Dart vs Either (fpdart) | Bawaan Dart tanpa package tambahan | Tidak sekaya Either untuk chaining operasi |
