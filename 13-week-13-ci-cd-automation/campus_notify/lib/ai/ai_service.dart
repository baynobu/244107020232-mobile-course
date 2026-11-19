import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// Layanan AI untuk interaksi dengan Google Gemini API dan manajemen secure storage API key.
class AiService {
  final FlutterSecureStorage _storage;
  final http.Client _client;
  final String model;

  static const String defaultModel = 'gemini-flash-latest';
  static const String fallbackModel = 'gemini-pro-latest';
  static const String secureStorageKey = 'ai_api_key';

  static const String defaultSystemPrompt =
      'Kamu adalah asisten AI resmi kampus Campus Notify. '
      'Berikan informasi yang akurat, ramah, dan ringkas dalam Bahasa Indonesia mengenai jadwal kuliah, administrasi akademik, pengumuman kampus, dan fasilitas mahasiswa. '
      'Maksimal 3-4 kalimat per respons. Jangan pernah meminta atau membagikan kredensial atau password pengguna.';

  AiService({
    FlutterSecureStorage? storage,
    http.Client? client,
    this.model = defaultModel,
  }) : _storage = storage ?? const FlutterSecureStorage(),
       _client = client ?? http.Client();

  String _buildApiUrl(String targetModel, String apiKey) {
    return 'https://generativelanguage.googleapis.com/v1beta/models/$targetModel:generateContent?key=$apiKey';
  }

  Future<String?> getApiKey() async {
    return await _storage.read(key: secureStorageKey);
  }

  Future<void> saveApiKey(String key) async {
    await _storage.write(key: secureStorageKey, value: key.trim());
  }

  Future<void> clearApiKey() async {
    await _storage.delete(key: secureStorageKey);
  }

  Future<bool> hasApiKey() async {
    final key = await getApiKey();
    return key != null && key.trim().isNotEmpty;
  }

  /// Memanggil LLM Gemini API dengan prompt pengguna dan instruksi sistem kampus.
  Future<String> ask(String question, {bool fallbackToLocal = true}) async {
    final trimmedQuestion = question.trim();
    if (trimmedQuestion.isEmpty) {
      throw Exception('Pertanyaan tidak boleh kosong.');
    }

    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      if (fallbackToLocal) {
        return getOfflineFallbackResponse(trimmedQuestion);
      }
      throw Exception('API key tidak tersedia. Silakan atur di pengaturan.');
    }

    try {
      final uri = Uri.parse(_buildApiUrl(model, apiKey));
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': trimmedQuestion},
              ],
            },
          ],
          'systemInstruction': {
            'parts': [
              {'text': defaultSystemPrompt},
            ],
          },
          'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 500},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'] as Map<String, dynamic>?;
          final parts = content?['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            final text = parts[0]['text']?.toString().trim();
            if (text != null && text.isNotEmpty) {
              return text;
            }
          }
        }
        return 'Maaf, asisten AI tidak dapat menghasilkan jawaban untuk pertanyaan ini.';
      } else if (response.statusCode == 400 ||
          response.statusCode == 403 ||
          response.statusCode == 404) {
        // Coba model fallback jika model default bermasalah
        if (model != fallbackModel) {
          return await _askLegacy(trimmedQuestion, apiKey, fallbackToLocal);
        }
        throw Exception(
          'API Key tidak valid atau akses ditolak (${response.statusCode}). Periksa API Key Anda.',
        );
      } else {
        throw Exception('Gagal memanggil AI API: ${response.statusCode}');
      }
    } catch (e) {
      if (fallbackToLocal) {
        return '${getOfflineFallbackResponse(trimmedQuestion)}\n\n*(Mode Offline Aktif: Terjadi kendala koneksi AI)*';
      }
      rethrow;
    }
  }

  /// Panggilan cadangan (gemini-pro format legacy)
  Future<String> _askLegacy(
    String question,
    String apiKey,
    bool fallbackToLocal,
  ) async {
    try {
      final uri = Uri.parse(_buildApiUrl(fallbackModel, apiKey));
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text':
                      '$defaultSystemPrompt\n\nPertanyaan Mahasiswa: $question',
                },
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['candidates'][0]['content']['parts'][0]['text']
            .toString()
            .trim();
      } else {
        throw Exception('Gagal memanggil AI API (${response.statusCode})');
      }
    } catch (e) {
      if (fallbackToLocal) {
        return '${getOfflineFallbackResponse(question)}\n\n*(Mode Offline Aktif)*';
      }
      rethrow;
    }
  }

  /// Offline Fallback & Local Knowledge Base (Mitigasi Error Handling & Privasi/Downtime)
  String getOfflineFallbackResponse(String question) {
    final q = question.toLowerCase();

    if (q.contains('krs') || q.contains('registrasi')) {
      return 'Pengisian Kartu Rencana Studi (KRS) dilakukan daring melalui sistem akademik sesuai kalender akademik kampus. Silakan konsultasi dengan Dosen Pembimbing Akademik (DPA).';
    } else if (q.contains('jadwal') ||
        q.contains('kuliah') ||
        q.contains('kelas')) {
      return 'Untuk jadwal perkuliahan semester ini, Anda dapat mengecek portal SIAKAD kampus atau melihat pengumuman terbaru di dashboard Campus Notify.';
    } else if (q.contains('izin') ||
        q.contains('sakit') ||
        q.contains('absen')) {
      return 'Prosedur izin sakit: Unggah surat keterangan dokter yang sah ke portal akademik dan konfirmasikan ke dosen pengampu maksimal 2x24 jam.';
    } else if (q.contains('beasiswa') ||
        q.contains('ukt') ||
        q.contains('biaya')) {
      return 'Informasi beasiswa dan pengajuan penyesuaian UKT dapat dilihat pada Bagian Kemahasiswaan atau di papan pengumuman resmi kampus.';
    } else if (q.contains('kontak') ||
        q.contains('help') ||
        q.contains('bantuan')) {
      return 'Pusat Layanan Mahasiswa dapat dihubungi melalui email admin@polinema.ac.id atau nomor layanan akademik kampus.';
    } else {
      return 'Halo! Saya asisten kampus Campus Notify. Saat ini layanan AI cloud belum terhubung atau API Key belum diatur. Anda tetap bisa menanyakan informasi dasar seputar jadwal, KRS, izin sakit, atau kontak kampus.';
    }
  }
}
