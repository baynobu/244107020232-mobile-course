# Dokumentasi AI Challenge: Campus Notification App

## 1. AI Tools yang Digunakan
- **Model / Tools**: Gemini Coding Assistant (Antigravity IDE)
- **Tujuan**: Membantu perancangan arsitektur boilerplate PushService FCM, autentikasi berbasis Secure Storage + Dio Interceptor, serta GoRouter guard.

---

## 2. Prompt yang Digunakan
Sesuai dengan spesifikasi modul Week 6 (Bagian 6: AI Challenge):

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

---

## 3. Output Awal AI & Evaluasi Kritis

### A. Output Awal Kode
AI coding assistant memberikan draf awal kelas `PushService` dengan implementasi method background handler di dalam kelas, pemanggilan langsung `print(token)` tanpa masking, serta implementasi `flutter_local_notifications` dengan tanda tangan API lama (posisional argument).

### B. Evaluasi & Temuan Masalah (Verifikasi Checklist)

| No | Kriteria Verifikasi | Evaluasi Output AI | Status | Tindakan Perbaikan |
|----|---------------------|--------------------|--------|---------------------|
| 1 | Background Handler Isolate | AI awalnya mencoba memasukkan handler sebagai method kelas atau tanpa `@pragma('vm:entry-point')`. | ❌ Ditolak | Diekstrak menjadi fungsi top-level di luar kelas dengan `@pragma('vm:entry-point')`. |
| 2 | Larangan BuildContext di Isolate | AI berpotensi memanggil navigator context di background handler. | ❌ Bahaya | Dilarang keras. Handler background hanya menjalankan logging/penyimpanan lokal. Navigasi dipindahkan ke saat klik notifikasi. |
| 3 | Pengiriman `onTokenRefresh` | AI hanya mencetak `print(token)` ke console log. | ❌ Ditolak | Diubah agar callback `onToken` dieksekusi dan dikirim ke endpoint backend `POST /devices` via Dio. |
| 4 | Keamanan Token (Masking) | AI mencetak token mentah secara penuh ke log. | ❌ Pelanggaran Keamanan | Dibuat fungsi helper `maskToken(token)` sehingga log hanya menampilkan string terpotong (mis. `mock-ac...c.id`). |
| 5 | Banner Notifikasi Foreground | AI lupa bahwa sistem Android/iOS tidak menampilkan banner otomatis di foreground. | ⚠️ Perlu dipertegas | Dipastikan menggunakan `flutter_local_notifications` dengan channel `campus_announcements_channel` saat `FirebaseMessaging.onMessage`. |
| 6 | Penanganan Rute Deep Link | AI mengasumsikan format `data['route']` selalu diawali `/`. | ⚠️ Fragile | Dibuat fungsi murni `routeFromMessage(data)` untuk memastikan leading slash dan fallback parsing `id`. |
| 7 | Kompatibilitas Library 22.x | AI menggunakan argumen posisional pada `initialize` dan `show`. | ❌ Build Error | Diperbarui menggunakan named parameters `settings:` dan `id:`, `notificationDetails:` sesuai API terbaru `flutter_local_notifications: ^22.3.1`. |

---

## 4. Perbaikan Manual & Keputusan Teknis Final

1. **Top-Level Background Handler**:
   ```dart
   @pragma('vm:entry-point')
   Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
     developer.log('FCM Background message diterima: id=${message.messageId}', name: 'PushService');
   }
   ```
   *Alasan*: Flutter engine mengeksekusi handler background pada isolate VM terpisah tanpa akses UI/BuildContext. Anotasi `@pragma('vm:entry-point')` memastikan tree shaking Dart tidak menghapus fungsi ini saat rilis produksi.

2. **Pencegahan Infinite Loop pada Dio 401 Interceptor**:
   Pada interceptor refresh token, ditambahkan flag `isRetry`:
   ```dart
   final isRetry = e.requestOptions.extra['isRetry'] == true;
   if (e.response?.statusCode == 401 && !isRetry) {
     // coba refresh 1x lalu tandai requestOptions.extra['isRetry'] = true;
   }
   ```
   *Alasan*: Mencegah loop tanpa henti jika token baru hasil refresh juga ditolak (401) oleh server.

3. **Masking Token untuk Keamanan**:
   Semua token (Access token, Refresh token, FCM Registration Token) yang ditampilkan di UI maupun di debug console disaring menggunakan `maskToken(...)`.
