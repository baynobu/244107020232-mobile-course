# Dokumentasi AI Challenge: Senior Flutter Dev Code Review

**Modul:** Week 8 — Mid Project Review & Code Review  
**Proyek:** `campus_notify`  
**Fitur yang Direview:** Pull Request `feat/announcements-validation` (Validasi Input Pengumuman & Unit Testing)  
**Model AI Reviewer:** Senior Flutter Dev Persona (Gemini / Antigravity AI)  

---

## 1. AI Prompt Challenge

Prompt yang diajukan ke AI Reviewer sesuai panduan modul:

```text
Review PR Flutter ini sebagai senior Flutter dev.
Konteks: feature-first Clean Architecture (presentation -> domain <- data),
Riverpod, GoRouter, SQLite + Dio.
Fokus: kebenaran, arsitektur, dan test. Abaikan style.
Berikan 5 temuan teratas + level (blocker/saran)
+ alasan + usulan potongan kode perbaikan.
```

---

## 2. Lima Temuan Teratas dari AI Reviewer

| No | Temuan AI | Level | Alasan yang Diberikan AI | Usulan Solusi AI |
|:---|:---|:---:|:---|:---|
| **1** | Validasi judul kosong dan kategori belum terlindungi di Domain Layer | **Blocker** | Jika validasi hanya ditaruh di UI form widget, data yang dimasukkan via service lain (misal background sync/API) dapat meloloskan entitas tidak valid. | Buat usecase murni domain `ValidateAnnouncement` yang mengembalikan failure jika tidak memenuhi aturan bisnis. |
| **2** | Kurang pengujian edge-case (karakter spasi putih dan panjang batas) | **Saran** | Judul yang hanya berisi string spasi `"   "` bisa lolos validasi `isNotEmpty` standar jika tidak di-`trim()`. | Tambahkan sanitasi `.trim()` dan test case khusus spasi kosong serta batas panjang minimal. |
| **3** | Gunakan `FormFieldValidator<String>` Flutter langsung di domain use case | **Blocker** | Memudahkan integrasi langsung dengan widget `TextFormField(validator: ...)` tanpa konversi manual di UI. | Tambahkan `import 'package:flutter/widgets.dart'` di use case domain agar mengembalikan tipe Flutter validator bawaan. |
| **4** | Pecah validasi menjadi 3 use case terpisah per field | **Saran** | Single Responsibility Principle: pisahkan `ValidateTitle`, `ValidateBody`, dan `ValidateCategory` menjadi file use case masing-masing. | Buat 3 class use case terpisah di folder `usecases/` dengan 1 method `call()` per file. |
| **5** | Kembalikan tipe `ValidationFailure?` alih-alih melempar exception mentah | **Saran** | Melempar exception untuk kesalahan input pengguna membebani call stack dan menyulitkan penanganan alur UI. | Gunakan return type nullable `ValidationFailure?` di mana `null` menandakan valid. |

---

## 3. AI Verification Checklist & Evaluasi Kritis

Sesuai instruksi modul, setiap saran AI harus diverifikasi secara kritis sebelum diterapkan:

### 3.1 Temuan yang Diterima (Minimal 2 Terbukti Benar dengan Bukti)

#### ✅ Temuan 1: Validasi Masuk ke Domain Layer (Diterima)
- **Bukti & Verifikasi**: Pengumuman kampus memiliki integritas bisnis (judul min. 5 karakter, isi min. 10 karakter, dan kategori resmi). Menempatkan validasi di domain menjamin data valid di manapun data tersebut dibuat.
- **Implementasi**: Dibuat file [validate_announcement.dart](file:///c:/Users/HAMI/Downloads/College/Semester%205/Pemrograman%20Mobile/244107020232-mobile-course/08-week-8-mid-project-review/campus_notify/lib/features/announcements/domain/usecases/validate_announcement.dart) di domain layer.

#### ✅ Temuan 2: Pengujian Edge Case Spasi Putih & Boundary (Diterima)
- **Bukti & Verifikasi**: String `'     '` memiliki `length == 5` dan `isNotEmpty == true`. Tanpa `.trim()`, judul kosong spasi akan lolos validasi.
- **Implementasi**: Diterapkan sanitasi `.trim()` pada judul, isi, dan kategori. Dibuat 6 test case lengkap di [validate_announcement_test.dart](file:///c:/Users/HAMI/Downloads/College/Semester%205/Pemrograman%20Mobile/244107020232-mobile-course/08-week-8-mid-project-review/campus_notify/test/validate_announcement_test.dart) dan semuanya lulus (`All tests passed!`).

#### ✅ Temuan 5: Kembalikan `ValidationFailure?` Tanpa Melempar Exception (Diterima)
- **Bukti & Verifikasi**: Mengembalikan `ValidationFailure?` selaras dengan hierarki domain `Failure` di `lib/core/failures.dart`. UI cukup memeriksa `if (failure != null)` untuk menampilkan pesan kesalahan.

---

### 3.2 Temuan yang Ditolak (Minimal 1 Ditolak dengan Alasan Tertulis)

#### ❌ Temuan 3: Mengimpor `package:flutter/widgets.dart` ke Domain (DITOLAK)
- **Status**: **Ditolak Keras (Rejected)**
- **Alasan Teknis**: Usulan AI ini secara fatal **melanggar Aturan Emas Clean Architecture (*Dependency Rule*)**. 
  - Lapisan `domain` harus 100% murni Dart dan steril dari framework UI (`Flutter`).
  - Bila domain mengimpor Flutter, use case tidak dapat dijalankan di CLI murni, memperlambat eksekusi unit test, dan merusak portabilitas logika bisnis.
  - UI presentation layer-lah yang bertanggung jawab membungkus domain failure menjadi pesan error form widget.

#### ❌ Temuan 4: Memecah Menjadi 3 File Use Case Terpisah (DITOLAK)
- **Status**: **Ditolak (Rejected - Over-engineering)**
- **Alasan Teknis**: Form pengumuman adalah satu kesatuan input transaksi. Memecah validasi satu formulir kecil menjadi 3 file use case terpisah (`ValidateTitle`, `ValidateBody`, `ValidateCategory`) melanggar prinsip **YAGNI (*You Aren't Gonna Need It*)** dan menambah boilerplate tanpa manfaat arsitektural nyata. Satu use case `ValidateAnnouncement` dengan 3 parameter sudah sangat kohesif dan mudah diuji.

---

## 4. Tabel Rangkuman Usulan AI vs Keputusan Final

| Saran AI | Keputusan Final | Bukti / Dasar Keputusan |
|:---|:---:|:---|
| Validasi dibuat di domain layer | **Diterima** | Dibuat `ValidateAnnouncement` use case di domain. |
| Sanitasi `.trim()` dan test case spasi | **Diterima** | Diverifikasi dengan 6 unit test di `validate_announcement_test.dart`. |
| Import `package:flutter` ke domain | **DITOLAK** | Pelanggaran fatal Dependency Rule Clean Architecture. Domain wajib steril dari Flutter. |
| Pecah jadi 3 file use case | **DITOLAK** | Over-engineering, melanggar prinsip YAGNI. |
| Return nullable `ValidationFailure?` | **Diterima** | Selaras dengan `Failure` sealed class di `lib/core/failures.dart`. |

---

## 5. Kesimpulan Refleksi Terhadap AI Reviewer

AI sangat tajam dalam mendeteksi **edge-case logika** (seperti string kosong yang terisi spasi) dan menyarankan standarisasi error handling. Namun, AI memiliki kecenderungan:
1. **Menyarankan over-engineering** (membuat terlalu banyak class use case kecil untuk fungsi sederhana).
2. **Mengorbankan batasan arsitektur demi kemudahan instan** (seperti mengusulkan import Flutter ke layer domain agar form widget lebih praktis).

Oleh karena itu, peran software engineer sebagai pengambil keputusan (*human-in-the-loop*) tetap mutlak untuk menjaga kemurnian arsitektur dan kepraktisan kode.
