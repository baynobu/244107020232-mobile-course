# Integrasi Fitur AI (Week 10)

Dokumentasi implementasi fitur **Campus AI Chat Assistant** berbasis **Google Gemini 1.5 Flash API** dengan penyimpanan aman (*Flutter Secure Storage*), *Offline Fallback Knowledge Base*, serta manajemen state berbasis **Flutter Riverpod** pada proyek **Campus Notify**.

---

## 1. Ringkasan Eksekutif & Deskripsi Fitur

Pada modul Week 10 ini, aplikasi **Campus Notify** ditingkatkan dengan menambahkan asisten cerdas virtual yang terintegrasi langsung dengan Large Language Model (LLM) cloud:

1. **Campus AI Chat Assistant (`ChatScreen`)**:
   - Memungkinkan mahasiswa bertanya secara *real-time* mengenai jadwal perkuliahan, registrasi KRS, prosedur perizinan/izin sakit, info beasiswa, serta kontak bantuan akademik.
   - Menggunakan model **Google Gemini 1.5 Flash** yang cepat dan hemat token.
2. **Penyimpanan Kunci Aman (*Secure Credential Management*)**:
   - Kunci API tidak pernah di-*hardcode* di dalam kode sumber (mencegah kebocoran git).
   - Pengguna dapat memasukkan atau menghapus API Key mereka sendiri melalui dialog pengaturan aman yang disimpan di keystore perangkat menggunakan `flutter_secure_storage`.
3. **Prompt Engineering & System Instruction Mobile**:
   - Menerapkan *System Prompt* ketat untuk membatasi persona asisten kampus, mencegah halusinasi, membatasi panjang respons maksimal 3-4 kalimat (agar pas di layar smartphone), dan melarang penerimaan kredensial/password pengguna.
4. **Offline Fallback & Error Resiliency**:
   - Jika kuota API habis, koneksi internet mati, atau API key belum disetel, aplikasi secara otomatis beralih ke *Local Knowledge Base* kampus tanpa mengalami crash (*graceful degradation*).
5. **Aksesibilitas Cepat (Quick Prompt Chips)**:
   - Tersedia tombol chip pintasan untuk pertanyaan umum kampus agar pengguna dapat berinteraksi dengan satu ketukan.

---

## 2. Arsitektur & Pola Desain (Clean Architecture)

Arsitektur aplikasi tetap mematuhi prinsip *Dependency Rule*:

```text
                       PRESENTATION LAYER
    ┌─────────────────────────────────────────────────────────┐
    │ lib/pages/home_page.dart (Dashboard + Card AI + FAB)    │
    │ lib/features/chat_screen.dart (UI Chat & API Key Dialog)│
    │                          │                              │
    │                          ▼ watch / read                 │
    │ lib/features/ai_chat/presentation/providers/            │
    │   - chatNotifierProvider (ChatNotifier, ChatState)      │
    │   - aiServiceProvider                                   │
    └──────────────────────────┬──────────────────────────────┘
                               │ memanggil
                               ▼
                          DOMAIN LAYER
    ┌─────────────────────────────────────────────────────────┐
    │ lib/features/ai_chat/domain/entities/                   │
    │   - ChatMessage (id, text, isUser, timestamp, fallback) │
    └──────────────────────────▲──────────────────────────────┘
                               │ diimplementasikan oleh
                         AI SERVICE LAYER
    ┌─────────────────────────────────────────────────────────┐
    │ lib/ai/ai_service.dart                                  │
    │   - Google Gemini 1.5 Flash REST Client (http.post)     │
    │   - Secure Storage API Key Reader/Writer                │
    │   - Sanitasi Prompt & System Instruction                │
    │   - Local Knowledge Base (Offline Fallback Handler)     │
    └─────────────────────────────────────────────────────────┘
```

---

## 3. Bukti Mesin Hijau (Verification Evidence)

### 3.1 Static Analysis (`flutter analyze`)
Analisis statis Dart dan Flutter menunjukkan **NOL masalah / isu**:

```text
$ flutter analyze
Analyzing campus_notify...
No issues found! (ran in 16.7s)
```

### 3.2 Pengujian Otomatis (`flutter test`)
Seluruh 23 pengujian otomatis (unit test service AI, widget test chat, routing FCM, dan auth session) lulus 100%:

```text
$ flutter test
00:00 +0: test/ai_service_test.dart: AiService Unit Tests Pertanyaan kosong melempar Exception
00:00 +1: test/ai_service_test.dart: AiService Unit Tests Tanpa API key dan fallback=true mengembalikan respons offline lokal
00:00 +2: test/ai_service_test.dart: AiService Unit Tests Tanpa API key dan fallback=false melempar Exception
00:00 +3: test/ai_service_test.dart: AiService Unit Tests Simpan dan baca API Key di Secure Storage
00:00 +4: test/ai_service_test.dart: AiService Unit Tests Offline Fallback mendeteksi kata kunci kampus dengan akurat
00:00 +5: test/ai_service_test.dart: AiService Unit Tests Berhasil memanggil Gemini API dan mem-parse respons JSON dengan benar
00:00 +6: test/ai_service_test.dart: AiService Unit Tests Error HTTP dari API memicu offline fallback bila fallbackToLocal=true
00:02 +14: test/chat_screen_widget_test.dart: ChatScreen Widget Tests Menampilkan AppBar, pesan sambutan awal, dan quick prompt chips
00:02 +16: test/chat_screen_widget_test.dart: ChatScreen Widget Tests Tapping tombol pengaturan API Key membuka AlertDialog
00:04 +18: test/chat_screen_widget_test.dart: ChatScreen Widget Tests Mengirim pertanyaan melalui quick prompt chip memperbarui riwayat chat
00:06 +20: test/chat_screen_widget_test.dart: ChatScreen Widget Tests Mereset obrolan mengembalikan pesan ke kondisi sambutan awal
00:08 +23: All tests passed!
```

### 3.3 Format Kode Otomatis (`dart format`)
```text
$ dart format lib test
Formatted 33 files (0 changed) in 0.93 seconds.
```

---

## 4. Tabel Risiko & Mitigasi: Privasi dan Biaya

Sesuai materi Bagian 5 Codelab (*Privasi, Biaya, Error Handling, dan Fallback*), berikut adalah matriks risiko industri beserta langkah mitigasi teknis yang diimplementasikan:

| Kategori Risiko | Deskripsi Risiko | Tingkat Dampak | Langkah Mitigasi Teknis pada Proyek |
|---|---|:---:|---|
| **Privasi Pengguna** | Mahasiswa secara tidak sengaja mengirim data sensitif (*password*, token login, NIK/KTM, data finansial) ke LLM pihak ketiga. | **Tinggi** | 1. *System Instruction* secara eksplisit melarang AI meminta dan memproses data kredensial.<br>2. Banner peringatan privasi dipasang permanen di atas layar obrolan.<br>3. Mekanisme penolakan otomatis (*safety refusal*) jika pengguna memasukkan kata kunci password/kredensial. |
| **Keamanan Kunci API** | Kunci API pengembang bocor ke repositori publik (Git leak) atau diekstraksi dari APK hasil dekompilasi. | **Kritis** | 1. Tidak ada kunci API yang di-*hardcode* di source code Dart.<br>2. Kunci disimpan pada *Android Keystore / iOS Keychain* menggunakan library `flutter_secure_storage`.<br>3. Pengguna memiliki kontrol penuh untuk memasukkan dan menghapus kunci API secara mandiri dari aplikasi. |
| **Biaya & Kuota API** | Lonjakan biaya atau habisnya kuota gratis akibat *spamming* pesan berulang atau *infinite retry loop*. | **Sedang** | 1. Penggunaan model berbiaya rendah dan efisien: `gemini-1.5-flash`.<br>2. Pembatasan token keluaran maksimum (`maxOutputTokens: 500`).<br>3. Tombol kirim dinonaktifkan saat status masih *loading* untuk mencegah *duplicate requests*. |
| **Konektivitas & API Down** | Layanan Google API mengalami gangguan, diblokir firewall jaringan kampus, atau perangkat berada pada mode *airplane*. | **Tinggi** | 1. *Graceful fallback* ke basis data lokal (`getOfflineFallbackResponse`) tanpa memunculkan error merah (*crash*).<br>2. Visual badge `Offline Mode` menginformasikan bahwa data disajikan dari memori lokal perangkat. |
| **Halusinasi LLM** | Model mengarang jadwal perkuliahan atau aturan wisuda fiktif yang merugikan mahasiswa. | **Sedang** | 1. Pembatasan konteks (*context bounding*) pada system instruction.<br>2. Setiap saran akademik krusial selalu menyertakan anjuran verifikasi ke portal resmi SIAKAD dan Dosen Pembina Akademik (DPA). |

---

## 5. Panduan Menjalankan Aplikasi & Pengujian

### 5.1 Menjalankan Pengujian Otomatis (Green Machine)
Masuk ke direktori `campus_notify`:
```bash
cd campus_notify

# Jalankan seluruh test suite (23 pengujian)
flutter test

# Jalankan unit test AI Service & fallback saja
flutter test test/ai_service_test.dart

# Jalankan widget test UI ChatScreen saja
flutter test test/chat_screen_widget_test.dart
```

### 5.2 Menjalankan Analisis Statis Kode
```bash
flutter analyze
```

### 5.3 Menjalankan Aplikasi pada Emulator / HP
```bash
flutter run
```
*Langkah Interaksi:*
1. Login dengan email demo kampus: `mahasiswa@polinema.ac.id` (password bebas min. 6 karakter).
2. Di halaman Dashboard, ketuk kartu **"Asisten AI Kampus"** atau tombol **Floating Action Button** di pojok kanan bawah.
3. Di layar chat, ketuk ikon kunci di AppBar untuk memasukkan Gemini API Key Anda (dapat diperoleh gratis dari [aistudio.google.com](https://aistudio.google.com/)).
4. Ajukan pertanyaan seputar kampus atau ketuk salah satu chip pintasan yang tersedia.

---

## 6. Jawaban Refleksi Pembelajaran Modul

### 1. Fitur AI mana yang Anda integrasikan dan mengapa?
> **Jawaban:**  
> Saya mengintegrasikan **Campus AI Chat Assistant** berbasis model **Google Gemini 1.5 Flash**.  
> **Alasannya:** Pada aplikasi pengumuman kampus (*Campus Notify*), mahasiswa kerap kali memerlukan informasi cepat dan dinamis yang tersebar di banyak pengumuman (seperti prosedur revisi KRS, jadwal penggantian kuliah, atau syarat beasiswa). Membaca satu per satu dokumen pengumuman memakan waktu. Dengan mengintegrasikan asisten percakapan cerdas yang dilengkapi *system instruction* khusus akademik kampus, mahasiswa dapat memperoleh jawaban ringkas dalam hitungan detik langsung dari aplikasi mobile mereka.

### 2. Bagaimana Anda melindungi privasi pengguna saat menggunakan AI API?
> **Jawaban:**  
> Perlindungan privasi diterapkan pada 3 lapisan (*defense in depth*):
> 1. **Penyimpanan Kunci Terenkripsi:** API Key tidak di-*hardcode*, melainkan disimpan di *hardware-backed storage* (`flutter_secure_storage`) yang terisolasi di perangkat pengguna.
> 2. **Instruksi Batasan Sistem (*System Prompt Guardrails*):** AI diprogram secara ketat untuk menolak permintaan pengolahan kredensial, password, atau nomor rekening pribadi.
> 3. **Edukasi & Banner UI:** Menampilkan disclaimer privasi di bagian atas chat room yang mengingatkan mahasiswa untuk tidak pernah membagikan informasi sensitif ke dalam obrolan AI.

### 3. Fallback apa yang Anda sediakan jika layanan AI error?
> **Jawaban:**  
> Kami menyediakan **Local Knowledge Base Fallback (`getOfflineFallbackResponse`)**.  
> Apabila jaringan internet terputus, API key belum disetel, atau API server Google mengembalikan status error/rate-limit, sistem secara otomatis menangkap *exception* tersebut dan mengarahkan pencarian kata kunci ke basis pengetahuan offline lokal (mencakup topik umum: KRS, jadwal kuliah, izin sakit, beasiswa, dan kontak akademik). Pengguna tetap mendapatkan jawaban solutif disertai label lencana **`Offline Mode`** tanpa mengalami kegagalan aplikasi (*no crashes*).

### 4. Satu hal yang Anda pelajari tentang UX fitur AI di mobile?
> **Jawaban:**  
> Hal terpenting yang saya pelajari adalah bahwa **latensi dan kepastian feedback visual adalah kunci kenyamanan UX AI pada perangkat bergerak**.  
> Model AI memerlukan waktu beberapa ratus milidetik hingga beberapa detik untuk menghasilkan respons (*inference time*). Tanpa indikator *typing/loading* yang jelas, pengguna akan mengira aplikasi mengalami *freeze* atau ketukan tombol mereka gagal. Selain itu, layar smartphone yang terbatas menuntut respons AI yang **ringkas, terstruktur, dan tidak bertele-tele** (dibatasi 3-4 kalimat), serta kehadiran tombol pintas (*quick prompt chips*) yang meminimalkan keharusan mengetik kalimat panjang di keyboard virtual ponsel.

---

## 7. Titik Pengambilan Screenshot (Bukti Visual)

Simpan hasil tangkapan layar di direktori `screenshots/` sesuai penamaan berikut:

1. `01_home_ai_entry.png`: Tampilan layar utama (`HomePage`) yang memperlihatkan kartu sorotan *"Asisten AI Kampus"* dan Floating Action Button baru.
2. `02_api_key_dialog.png`: Tampilan dialog input dan pengaturan Gemini API Key yang aman.
3. `03_chat_active_conversation.png`: Tampilan layar chat (`ChatScreen`) saat berinteraksi dengan AI dan menerima jawaban cerdas seputar kampus.
4. `04_chat_loading_state.png`: Tampilan indikator *typing* / *loading* (*"Asisten AI sedang berpikir..."*) saat memproses pertanyaan.
5. `05_error_or_fallback.png`: Tampilan saat fitur AI berjalan dalam mode fallback offline (menampilkan label `Offline Mode` / banner informatif).
6. `06_terminal_green_check.png`: Tangkapan layar terminal yang mengeksekusi `flutter analyze` dan `flutter test` dengan hasil 100% lulus.

---

## 8. Struktur Berkas Week 10

```text
10-week-10-ai-feature-integration/
├── README.md                                  # Dokumentasi utama modul Week 10
├── mobile-week-10.md                           # Modul panduan codelab
├── docs/
│   └── ai-log.md                              # Log prompt engineering, contoh interaksi, & mitigasi
├── screenshots/                               # Tempat menyimpan bukti tangkapan layar aplikasi
└── campus_notify/
    ├── lib/
    │   ├── ai/
    │   │   └── ai_service.dart                # [BARU] Layanan integrasi Gemini API, secure storage, & fallback
    │   ├── features/
    │   │   ├── ai_chat/
    │   │   │   ├── domain/
    │   │   │   │   └── entities/chat_message.dart      # [BARU] Entitas pesan obrolan
    │   │   │   └── presentation/
    │   │   │       └── providers/chat_providers.dart   # [BARU] Riverpod StateNotifier untuk chat & API key
    │   │   └── chat_screen.dart               # [BARU] UI interaktif Chat AI, bubble, chips, & dialog key
    │   ├── pages/
    │   │   └── home_page.dart                 # [UPDATE] Akses navigasi AI Card & Floating Action Button
    │   ├── routes.dart                        # [UPDATE] Penambahan rute /chat
    │   └── main.dart                          # [UPDATE] Registrasi GoRoute ChatScreen
    └── test/
        ├── ai_service_test.dart               # [BARU] 7 unit test AiService, HTTP mocking, & offline fallback
        └── chat_screen_widget_test.dart       # [BARU] 4 widget test UI ChatScreen, dialog, & chips
```

