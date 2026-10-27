# Checklist Review & Kesiapan Paruh Semester (Mid-Project Review)

**Repository:** `244107020232-mobile-course / 08-week-8-mid-project-review`  
**Fitur Proyek:** `campus_notify` (Clean Architecture + FCM + Auth + Announcements)  
**Tanggal:** 27 Oktober 2026  

---

## 1. Praktikum 1: Hygiene Branch & Perbaikan Commit Buruk

### 1.1 Audit Riwayat Git
Hasil audit `git log --oneline -15`:
```text
8043910 feat(week-7): clean architecture
8acb9f7 Update .gitignore
697fc98 feat(week-6): authentication-security-fcm
bbe0d92 feat(week-5): local storage & offline first
89032f1 feat(week-4): app
432cbd0 feat(week-3): navigation
299f8a1 Delete PCVK_Week2.ipynb
409fa46 feat(P2): pengolahan dan citra visi komputer
78ed51b docs(readme)
9548d91 feat(week-2): responsive design
```

**Temuan Audit:**
- Sebagian commit masa lalu menggabungkan terlalu banyak perubahan dalam satu commit mingguan (misal `feat(week-4): app` dan `Update .gitignore`).
- Belum ada pemisahan branch kerja fitur (`feat/*`) dan integrasi mingguan (`develop`) sebelum merge ke `main`.
- Beberapa deskripsi commit belum mengikuti standar Conventional Commits `tipe(scope): deskripsi`.

---

### 1.2 Simulasi Perbaikan Pesan Commit Buruk

Berdasarkan Praktikum 1 §3, berikut penulisan ulang 3 contoh commit masa lalu yang kurang deskriptif menjadi format Conventional Commits beserta alasan teknisnya:

| No | Commit Lama (Buruk) | Commit Baru (Conventional) | Alasan & Dampak |
|:---|:--------------------|:---------------------------|:----------------|
| 1 | `fix bug` | `fix(notes): cegah simpan judul kosong + test` | **Jelas apa, di mana, dan buktinya.** Memberi tahu modul yang diperbaiki (`notes`), akar masalah yang dicegah (judul kosong), dan bahwa perbaikan disertai unit test. |
| 2 | `feat(week-4): app` | `feat(announcements): integrasi list pengumuman dengan repository mock` | **Spesifik per fitur.** Tidak mengaburkan apa yang sebenarnya dibangun. Mempermudah *git bisect* dan *changelog generation*. |
| 3 | `Update .gitignore` | `chore(git): abaikan file build flutter dan kredensial ide` | **Jelas tujuannya.** Menggunakan tipe `chore` dengan scope `git`, menjelaskan file apa yang di-ignore sehingga reviewer tahu tidak ada perubahan kode logika. |

---

## 2. Praktikum 2: Standar Pull Request & Peer Review

### 2.1 Format PR yang Diterapkan
Setiap PR wajib memuat:
- **Judul**: `tipe(scope): ringkasan singkat`
- **Masalah**: Deskripsi masalah yang dihadapi pengguna/sistem.
- **Solusi**: Pendekatan teknis yang diambil.
- **Cara Uji**: Langkah manual & perintah test mesin (`flutter test`).
- **Issue Tracker**: Referensi otomatis penutup issue (`Closes #...`).
- **Ukuran**: < 300 baris perubahan agar dapat direview < 15 menit.

### 2.2 Aturan Peer Code Review
Komentar review menggunakan pola **Observasi → Dampak → Usulan Konkret**:
```text
Observasi : Validasi form di announcement_page dilakukan langsung di widget dengan setState.
Dampak    : Logika validasi tidak bisa di-unit test secara terisolasi tanpa engine widget.
Usulan    : Pindahkan validasi ke domain use case `ValidateAnnouncement` di lib/features/announcements/domain/usecases/.
```

---

## 3. Praktikum 3: Checklist Kesiapan Paruh Semester

| Kriteria Evaluasi | Status | Bukti / Catatan |
|:---|:---:|:---|
| **1. Struktur Feature-First Clean Architecture** | ✅ LULUS | Folder terorganisir per fitur (`features/auth/`, `features/announcements/`) dengan subfolder `domain`, `data`, `presentation`. |
| **2. Sterilitas Presentation dari Data Mentah** | ✅ LULUS | Grep `Dio(\|openDatabase\|FlutterSecureStorage\|SharedPreferences` pada `presentation` menghasilkan **0 temuan**. |
| **3. Sterilitas Domain dari Framework & Package** | ✅ LULUS | Grep `import 'package:flutter\|dio\|sqflite\|firebase` pada `domain` menghasilkan **0 temuan**. Domain murni Dart. |
| **4. Static Analysis Bersih** | ✅ LULUS | `flutter analyze` menghasilkan `No issues found! (0 warnings, 0 errors)`. |
| **5. Format Kode Rapi** | ✅ LULUS | `dart format --set-exit-if-changed .` menghasilkan exit code 0 (seluruh file terformat rapi). |
| **6. Unit & Smoke Tests Hijau** | ✅ LULUS | `flutter test` lulus 100% (18 test passed, mencakup use case, formatting, failure mapping, fake repository, dan widget smoke test). |
| **7. Automasi CI (GitHub Actions)** | ✅ LULUS | Tersedia `.github/workflows/ci.yml` yang menjalankan verify analyze, format, dan test secara otomatis. |
| **8. Disiplin Ukuran Commit & PR** | ✅ LULUS | PR fitur baru (`feat/announcements-validation`) berukuran ringkas (< 150 baris), mudah direview. |
| **9. Kelengkapan Dokumentasi & README** | ✅ LULUS | Terdapat `README.md`, panduan menjalankan, arsitektur, dan refleksi mid-project review. |

---

## 4. Kesimpulan Kesiapan Mid-Project

Proyek `campus_notify` memiliki **fondasi arsitektur yang solid dan dapat dipercaya** untuk melangkah ke paruh kedua semester (AI Integration & Advanced Features). Pemisahan tanggung jawab (*Separation of Concerns*) dan kepatuhan terhadap *Dependency Rule* menjamin kode mudah diuji, diperluas, dan dikolaborasikan dalam tim.
