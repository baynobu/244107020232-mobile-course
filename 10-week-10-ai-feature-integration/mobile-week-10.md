# #10 | Integrasi Fitur AI

_access\_time_95 mins remaining

1.  [Selamat datang](#0)
2.  [Konsep integrasi fitur AI](#1)
3.  [Praktikum: Chat Interface dengan AI](#2)
4.  [OCR, Speech-to-Text, dan Image Understanding](#3)
5.  [Privasi, Biaya, Error Handling, dan Fallback](#4)
6.  [Tugas dan Refleksi](#5)

[_bug\_report_ Report a mistake](https://github.com/jti-polinema/flutter-codelab/issues)

[_close_](/)[_menu_](#)

# #10 | Integrasi Fitur AI

_access\_time_95 mins remaining

## 1\. Selamat datang

**Terakhir diperbarui:** 26 Oktober 2026  

[Bahasa Indonesia](index.html) | [English](index-en.html)

## Tujuan pembelajaran

Setelah menyelesaikan codelab ini, mahasiswa mampu:

-   memahami konsep integrasi LLM API ke aplikasi mobile;
-   merancang chat interface dengan streaming response;
-   mengintegrasikan OCR, Speech-to-Text, dan Image Understanding;
-   menerapkan prompt design yang aman dan efektif;
-   menangani privasi, biaya, error handling, dan fallback design;
-   mengevaluasi pengalaman pengguna pada fitur AI.

## Persiapan

-   Laptop/PC dan project Minggu 5-9 yang sudah selesai (mis. `campus_notify` atau project hasil refactor Minggu 7). Codelab ini menambah satu fitur AI ke project yang sudah ada.
-   Flutter SDK, VS Code (ekstensi Flutter/Dart), Git, dan satu AI coding assistant (GitHub Copilot / Cursor / Claude Code / setara).
-   Pemahaman Riverpod, repository pattern, dan dependency rule Minggu 7.
-   Akun AI API provider (mis. Google Gemini, OpenAI, atau Hugging Face) untuk mendapatkan API key.

## 2\. Konsep integrasi fitur AI

## 1\. Apa itu Integrasi Fitur AI?

AI fitur memungkinkan aplikasi mobile berkomunikasi dengan model AI di cloud untuk menyediakan layanan cerdas kepada pengguna:

-   **Chat asisten** — pertanyaan jawab dalam waktu nyata dengan LLM API
-   **OCR** — ekstraksi teks dari gambar atau dokumen
-   **Speech-to-Text** — mengonversi input suara menjadi teks
-   **Image Understanding** — caption dan analisis gambar melalui AI
-   **Recommendation** — saran personalisasi berdasarkan data pengguna

## 2\. Arsitektur Integrasi AI

```
+----------------+      HTTPS/wss      +----------------+
|   Flutter UI   | <-----------------> |  AI API Layer  |
|  (Chat, OCR,   |      (Dio/http)     |  (LLM, OCR,    |
|   STT, Image)  |                     |   STT, Vision) |
+----------------+                     +----------------+
        |                                      |
        | API Key (secure storage)             | Response
        v                                      v
+----------------+      Optional      +----------------+
|  Local Cache   | <-----------------> |   Backend    |
|  (Hive/SQLite) |     (batching)     |  (auth, log) |
+----------------+                     +----------------+
```

-   Kunci API tidak pernah disimpan langsung di kode sumber
-   Gunakan `flutter_secure_storage` untuk menyimpan token/kunci
-   Pertimbangkan biaya per request dan rate limit
-   Terapkan cache lokal untuk mengurangi panggilan berulang ke AI API

## 3\. Prompt Design untuk Mobile

Komponen

Contoh

Tujuan

System prompt

"Kamu asisten kampus ramah, jawab dalam Bahasa Indonesia, maksimal 2 kalimat"

Menetapkan persona dan batas

User prompt

"Jadwal kampus hari Senin?"

Input pengguna

Konteks

Data jadwal, profil user, lokasi

Membuat respons relevan

Batas

Jangan memberikan data pribadi lain

Privasi dan keamanan

**Tips:** Pertahankan prompt singkat dan spesifik, terjemahkan hasil jika diperlukan, dan validasi output sebelum ditampilkan ke user.

## 3\. Praktikum: Chat Interface dengan AI

## Langkah 1: Tambahkan dependensi

Tambahkan ke `pubspec.yaml`:

```
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0
  flutter_secure_storage: ^9.0.0
  riverpod: ^2.5.0
```

## Langkah 2: Buat AI Service

Buat `lib/ai/ai_service.dart`:

```
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AiService {
  final _storage = const FlutterSecureStorage();
  final _apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  Future<String> ask(String question) async {
    final apiKey = await _storage.read(key: 'ai_api_key');
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API key tidak tersedia. Silakan atur di pengaturan.');
    }

    final response = await http.post(
      Uri.parse('$_apiUrl?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [{
          'parts': [{'text': question}]
        }]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw Exception('Gagal memanggil AI API: ${response.statusCode}');
    }
  }

  Future<void> saveApiKey(String key) async {
    await _storage.write(key: 'ai_api_key', value: key);
  }
}
```

## Langkah 3: Buat Chat Screen

Buat `lib/features/chat_screen.dart` dengan streaming response dan indikator loading.

## 4\. OCR, Speech-to-Text, dan Image Understanding

## OCR (Optical Character Recognition)

-   Ambil gambar dari kamera/galeri menggunakan `image_picker`
-   Kirim ke AI API untuk ekstraksi teks
-   Gunakan untuk: KTM, receipt, dokumen, papan pengumuman

## Speech-to-Text

-   Rekam suara pengguna menggunakan `record` atau `just_audio`
-   Konversi ke teks melalui AI API
-   Gunakan untuk: input cepat, aksesibilitas

## Image Understanding

-   Unggah gambar dan minta deskripsi ke AI
-   Gunakan untuk: deskripsi produk, identifikasi objek, aksesibilitas

```
final result = await aiService.recognizeText(imageFile);
final text = await aiService.speechToText(audioFile);
```

## 5\. Privasi, Biaya, Error Handling, dan Fallback

## Tabel Risiko dan Mitigasi

Risiko

Mitigasi

Bocor data pengguna

Jangan kirim data sensitif ke AI API

Biaya melonjak

Batasi request per user/hari, gunakan cache lokal

API error / down

Tampilkan pesan ramah, opsi coba lagi, mode offline

Respons tidak relevan

Terapkan validasi dan fallback ke data lokal

## Contoh Fallback

```
try {
  final response = await aiService.ask(question);
} catch (e) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Layanan AI Sibuk'),
      content: const Text('Coba lagi nanti atau gunakan mode offline.'),
    ),
  );
}
```

## 6\. Tugas dan Refleksi

## Mini project / Industry Challenge

1.  Integrasikan satu fitur AI (chat atau OCR atau Speech-to-Text) ke project yang sudah ada.
2.  Sertakan prompt sistem, user prompt, dan output awal AI di `docs/ai-log.md`.
3.  Bukti mesin hijau: `flutter analyze` + `flutter test` di README.
4.  Tabel risiko + mitigasi privasi dan biaya di README.
5.  Push ke `10-week-10-ai-feature-integration/` berisi `lib/`, `docs/`, `README.md`, `screenshots/`.

## Refleksi

-   Fitur AI mana yang Anda integrasikan dan mengapa?
-   Bagaimana Anda melindungi privasi pengguna saat menggunakan AI API?
-   Fallback apa yang Anda sediakan jika layanan AI error?
-   Satu hal yang Anda pelajari tentang UX fitur AI di mobile?

## Referensi pendukung

-   [Slide Week 10: Integrasi Fitur AI](../00-slides/Week_10_AI_Feature_Integration.html)
-   [Google Gemini AI API](https://ai.google.dev/)
-   [flutter\_secure\_storage](https://pub.dev/packages/flutter_secure_storage)
-   [http package](https://pub.dev/packages/http)
-   [Riverpod: Getting started](https://riverpod.dev/docs/introduction/getting_started)
-   [Learn Dart in Y Minutes](https://learnxinyminutes.com/dart/)
-   [Dart Language Tour](https://dart.dev/guides/language/language-tour)

[Back](# "Previous step")

[Next](# "Next step")[Done](/ "Codelab complete")