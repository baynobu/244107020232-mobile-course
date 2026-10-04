# Campus Notify: Authentication, Security & Firebase Cloud Messaging (FCM)

Aplikasi mobile berbasis Flutter untuk sistem notifikasi dan pengumuman akademik kampus dengan perlindungan autentikasi berbasis secure storage, rotasi token otomatis via Dio interceptor, serta integrasi push notification Firebase Cloud Messaging (FCM) yang mendukung penanganan 3 app state (Foreground, Background, Terminated) dan Topic Messaging.

---

## 1. Deskripsi Aplikasi & Pola Login

### A. Deskripsi Aplikasi
**Campus Notify** adalah aplikasi portal notifikasi kampus yang dirancang untuk menyampaikan pengumuman akademik secara real-time dan aman kepada mahasiswa. Fitur-fitur utama meliputi:
- **Autentikasi Terproteksi**: Guard route menggunakan GoRouter yang memastikan pengguna yang belum login selalu diarahkan ke `/login`.
- **Penyimpanan Kredensial Aman**: Access token dan Refresh token hanya disimpan di **Flutter Secure Storage** (Keychain di iOS / EncryptedSharedPreferences di Android), tidak pernah disimpan di SharedPreferences biasa.
- **Auto Refresh Token 1x & Retry**: Dio HTTP client dilengkapi interceptor yang secara otomatis menangani respons HTTP 401 Unauthorized dengan menukar refresh token menjadi access token baru, lalu mengulang request asal tepat satu kali. Jika refresh token kedaluwarsa, seluruh sesi dibersihkan dan pengguna diarahkan kembali ke layar login.
- **Lifecycle Push Notification FCM**: Meminta runtime permission (Android 13+ & iOS), mengambil registration token, memantau rotasi token via `onTokenRefresh`, serta mendukung deep link rute tujuan (`/pengumuman/:id`) pada ketiga kondisi status aplikasi.
- **Topic vs Device Messaging**: Menyediakan langganan topik massal (`pengumuman-kampus`) untuk broadcast publik serta registrasi token individual untuk notifikasi privat mahasiswa.

### B. Pola Login yang Digunakan
Pada modul ini diterapkan pola **JWT + Refresh Token Simulation (Mock Auth Repository)** yang disiapkan khusus sebagai arsitektur plug-and-play untuk **Firebase Auth** / REST API Backend Kampus.
- **ID Token / Access Token**: Berumur pendek, disisipkan pada header `Authorization: Bearer <access_token>`.
- **Refresh Token**: Berumur panjang, tersimpan di secure storage, digunakan untuk meminta access token baru tanpa mengharuskan pengguna login ulang.
- **Alur Login**:
  ```text
  [User Input Form] ---> AuthRepository.login()
                              |
                              v
                  [Return: Access + Refresh Token]
                              |
                              v
              [Simpan ke FlutterSecureStorage]
                              |
                              v
            [GoRouter Guard membaca authState -> Redirect ke /]
  ```

---

## 2. Token Terpotong (Bukan Penuh / Masked Token)

Sesuai prinsip keamanan dasar aplikasi mobile (OWASP Mobile Top 10): **Token atau kredensial rahasia tidak boleh di-hardcode, tidak boleh di-log penuh, dan tidak boleh ditampilkan secara utuh pada UI atau screenshot.**

Dalam aplikasi ini diterapkan mekanisme pemotongan (masking) token melalui helper `maskToken()`:

| Jenis Token | Format Terpotong (Masked) | Tempat Penyimpanan |
|-------------|---------------------------|---------------------|
| Access Token | `mock-ac...c.id` | Flutter Secure Storage |
| Refresh Token | `mock-re...c.id` | Flutter Secure Storage |
| FCM Device Token | `device-...yz789` / `e3K9xP...a8B1` | Firebase Messaging / Memory |

---

## 3. Matriks Pengujian Wajib: Tiga App State FCM

Pengujian dilakukan dengan mengirimkan payload gabungan `notification + data`:
```json
{
  "message": {
    "topic": "pengumuman-kampus",
    "notification": {
      "title": "Jadwal kuliah berubah",
      "body": "Kelas Mobile pindah ke Ruang A2 jam 13.00"
    },
    "data": {
      "route": "/pengumuman/3",
      "id": "3"
    }
  }
}
```

### Tabel Hasil Pengujian Tiga App State:

| App State | Kondisi Aplikasi | Handler yang Bekerja | Perilaku yang Diharapkan | Hasil Pengujian | Bukti Tangkapan Layar |
|-----------|------------------|----------------------|--------------------------|-----------------|------------------------|
| **Foreground** | Aplikasi sedang dibuka aktif di layar pengguna. | `FirebaseMessaging.onMessage` + `FlutterLocalNotificationsPlugin.show()` | Sistem tidak membuat banner otomatis, aplikasi menampilkan banner notifikasi lokal manual. Ketika banner diklik, pengguna diarahkan ke `/pengumuman/3`. | **BERHASIL** | `screenshots/foreground.jpeg` |
| **Background** | Aplikasi di-minimize (tombol Home ditekan, berjalan di latar belakang). | Sistem OS Android / iOS + `FirebaseMessaging.onMessageOpenedApp` | Banner notifikasi bawaan sistem muncul di tray status bar. Ketika banner diklik, aplikasi kembali ke layar depan dan otomatis melakukan navigasi deep link ke `/pengumuman/3`. | **BERHASIL** | `screenshots/background.jpeg` |
| **Terminated** | Aplikasi ditutup paksa / dimatikan total (swipe close dari recent apps). | `FirebaseMessaging.instance.getInitialMessage()` saat startup | Banner sistem muncul di status bar. Ketika diklik, OS meluncurkan aplikasi dari awal, membaca data payload pada initial message, dan langsung mengarahkan pengguna ke `/pengumuman/3`. | **BERHASIL** | `screenshots/terminated.jpeg` |

---

## 4. Cara Menjalankan Aplikasi

### A. Prasyarat
- Flutter SDK 3.13+ (Dart 3.x)
- Android Studio / VS Code dengan ekstensi Flutter & Dart
- Emulator Android (disarankan Google Play Services aktif) atau Perangkat Fisik Android

### B. Langkah Instalasi & Menjalankan
1. Clone / buka direktori project:
   ```bash
   cd campus_notify
   ```
2. Ambil seluruh dependencies:
   ```bash
   flutter pub get
   ```
3. Jalankan pengujian otomatis (Unit & Widget Test):
   ```bash
   flutter test
   ```
4. Jalankan analisis kode:
   ```bash
   flutter analyze
   ```
5. Jalankan aplikasi di emulator atau perangkat fisik:
   ```bash
   flutter run
   ```

### C. Kredensial Login Percobaan
- **Email Kampus**: `mahasiswa@kampus.ac.id` (atau sembarang email valid yang mengandung `@`)
- **Kata Sandi**: `rahasia123` (minimal 6 karakter)

---

## 5. AI Tools yang Digunakan, Prompt & Perbaikan Manual

### A. AI Tools yang Digunakan
- **Tools**: Gemini Coding Assistant (Antigravity IDE)

### B. Prompt yang Diberikan (Sesuai Modul Week 6)
```text
Aplikasi Flutter Campus Notification App.
Stack: firebase_messaging, flutter_local_notifications,
flutter_secure_storage, go_router, Riverpod.
Buatkan PushService dengan:
- requestPermission + getToken + onTokenRefresh (kirim ke POST /devices)
- onMessage (tampilkan local notification manual)
- onMessageOpenedApp + getInitialMessage (navigasi ke data.route)
- subscribe/unsubscribe topic pengumuman-kampus
- background handler top-level dengan @pragma('vm:entry-point')
Tandai bagian yang BERBEDA untuk Android 13+ vs iOS,
dan bagian yang tidak boleh mengakses BuildContext.
```

### C. Masalah Ditemukan & Perbaikan Manual

| Masalah pada Draf Awal AI | Potensi Bug / Bahaya | Tindakan Perbaikan Manual |
|---------------------------|----------------------|---------------------------|
| Background handler dimasukkan sebagai method dalam class. | Fatal crash saat app di background karena method class tidak dapat dipanggil dari isolate background independen. | Diubah menjadi fungsi top-level di luar class dan ditambahkan anotasi `@pragma('vm:entry-point')`. |
| Penggunaan `BuildContext` pada callback asynchronous background. | `BuildContext across async gaps` dan crash karena context tidak tersedia pada background thread isolate. | Memisahkan penyimpanan/log dari navigasi. Navigasi hanya dipicu saat pengguna berinteraksi (klik) lewat `GoRouter`. |
| `onTokenRefresh` hanya dicetak menggunakan `print(token)`. | Token basi di database backend jika perangkat merotasi token atau instal ulang aplikasi. | Menghubungkan listener `onTokenRefresh` dengan fungsi `onToken` yang mengirim payload update ke API server `POST /devices`. |
| Pencetakan token secara mentah ke console. | Kebocoran kredensial rahasia (CWE-532 / OWASP M9). | Menerapkan fungsi sensor `maskToken()` di seluruh UI dan log developer. |
| Penggunaan API posisional lama `flutter_local_notifications` v17. | Error kompilasi pada versi plugin terbaru (`v22.3.1`). | Menyesuaikan parameter menjadi named parameters (`settings:`, `id:`, `notificationDetails:`). |
| Potensi infinite loop pada 401 refresh Dio interceptor. | Jika refresh token ditolak (401), request loop tiada henti membebani server dan memicu hang. | Menambahkan pengecekan flag `requestOptions.extra['isRetry']` sehingga pengulangan dibatasi tepat 1 kali saja. |

---

## 6. Hasil Pengujian (Testing Results)

Seluruh pengujian unit dan widget testing telah dijalankan dan lulus 100%:

```text
00:00 +0: Unit Tests: Routing & FCM Message Parsing routeFromMessage menangani route kosong dan tanpa slash
00:00 +1: Unit Tests: Routing & FCM Message Parsing data payload membawa id pengumuman dan fallback
00:00 +2: Unit Tests: Auth & Token Store Logic provider auth membaca status login dari token
00:00 +3: Unit Tests: Auth & Token Store Logic refresh gagal -> sesi dibersihkan (paksa login ulang)
00:00 +4: Unit Tests: Auth & Token Store Logic maskToken tidak membocorkan token penuh untuk keamanan
00:00 +5: Unit Tests: DioException Error Mapping pemetaan status code 401 ke pesan ramah pengguna
00:00 +6: Unit Tests: DioException Error Mapping pemetaan timeout ke pesan ramah koneksi
00:00 +7: Smoke test: LoginPage menampilkan elemen form dengan benar
00:02 +8: All tests passed!
```

Hasil `flutter analyze`:
```text
Analyzing campus_notify...
No issues found! (ran in 15.9s)
```

---

## 7. Jawaban Refleksi (Reflective Questions)

### 1. Mengapa refresh token tidak boleh disimpan di SharedPreferences? Apa risikonya bila bocor?
**Jawaban**: `SharedPreferences` pada Android menyimpan data dalam bentuk file XML teks polos (`plain-text`) di direktori internal aplikasi tanpa enkripsi perangkat keras. Jika perangkat di-root, dicadangkan (ADB backup), atau dieksploitasi oleh malware dengan hak akses root/file, refresh token dapat dibaca dengan mudah. Karena refresh token memiliki masa aktif panjang (mis. 7–30 hari), penyerang yang mencurinya dapat terus menerbitkan access token baru dan membajak sesi akun pengguna tanpa memerlukan kata sandi. Oleh karena itu, wajib menggunakan **Flutter Secure Storage** yang memanfaatkan **Keystore (Android)** dan **Keychain (iOS)** berbasis hardware-backed encryption.

### 2. Apa yang rusak bila `onTokenRefresh` diabaikan selama satu semester perkuliahan?
**Jawaban**: Token registrasi FCM dapat kedaluwarsa atau berubah sewaktu-waktu akibat pembaruan sistem operasi, pembersihan cache/data aplikasi, rotasi keamanan otomatis Firebase, atau instal ulang aplikasi. Jika listener `onTokenRefresh` diabaikan, server backend kampus akan terus menyimpan token lama (token basi / stale token). Dampaknya, mahasiswa tidak akan lagi menerima notifikasi pengumuman darurat, jadwal kuliah yang berubah, atau informasi nilai, dan server FCM akan mengembalikan error `registration-token-not-registered`.

### 3. Kapan memakai topik dan kapan memakai token perangkat? Beri contoh pesan kampus untuk masing-masing.
- **Topik (`Topic Messaging`)**: Digunakan saat mengirimkan satu pesan identik ke banyak penerima (broadcast multicast) tanpa perlu mengetahui atau mengelola daftar token ribuan mahasiswa di backend.
  - *Contoh Pesan*: Pengumuman libur nasional kampus, broadcast pembukaan KRS semester baru, atau pengumuman darurat cuaca buruk ke topik `pengumuman-kampus`.
- **Token Perangkat (`Device Token`)**: Digunakan untuk pesan yang bersifat pribadi, sensitif, atau tertuju spesifik ke satu akun mahasiswa (unicast).
  - *Contoh Pesan*: Notifikasi bahwa nilai ujian mata kuliah telah keluar, pengingat jatuh tempo pembayaran UKT individu, atau peringatan keamanan login baru pada akun mahasiswa.

### 4. Bagian mana dari draf AI yang Anda tolak atau perbaiki, dan mengapa?
**Jawaban**:
1. Menolak deklarasi background message handler sebagai method di dalam kelas dan mengubahnya menjadi **top-level function dengan `@pragma('vm:entry-point')`**, karena Firebase pada level native membutuhkan entry point C/Dart VM yang tidak terikat instance widget/state untuk dijalankan di background thread isolate.
2. Menolak pencetakan token mentah ke log dan menambahkan fungsi **`maskToken`** guna memenuhi kepatuhan keamanan data.
3. Memperbaiki signature pemanggilan fungsi `flutter_local_notifications` versi 22.x dari parameter posisional menjadi parameter bernama (`named parameters`).

---

## 8. Checklist Sebelum Submit

- **Auth**
  - [x] Guard route login berfungsi (belum login dialihkan ke `/login`, sudah login dialihkan ke `/`)
  - [x] Token hanya disimpan di Flutter Secure Storage, tidak pernah di SharedPreferences
  - [x] Interceptor Dio 401 menangani auto refresh 1x -> retry request / logout otomatis bila refresh gagal

- **FCM**
  - [x] Permission notifikasi runtime diminta secara eksplisit (Android 13+ & iOS)
  - [x] Listener `onTokenRefresh` terhubung untuk memperbarui token ke backend
  - [x] 3 app state (Foreground, Background, Terminated) teruji dengan tabel bukti dan handler lengkap
  - [x] Konfigurasi Topic (`pengumuman-kampus`) untuk broadcast dan Registration Token untuk notifikasi personal

- **AI & Quality**
  - [x] Prompt awal, analisis kelemahan, dan perbaikan manual dicatat lengkap
  - [x] Penjelasan lifecycle dan arsitektur dijabarkan secara mandiri
  - [x] `flutter analyze` bersih (0 issues) dan seluruh `flutter test` lulus (8 tests passed)
