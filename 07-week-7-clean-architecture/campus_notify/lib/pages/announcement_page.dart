import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routes.dart';

class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({super.key, required this.id});

  final String id;

  // Mock database pengumuman kampus
  static final Map<String, Map<String, String>> _announcements = {
    '1': {
      'title': 'Jadwal Kuliah Semester Baru',
      'category': 'Akademik',
      'date': '28 September 2026',
      'body': 'Jadwal perkuliahan Semester Ganjil 2026/2027 telah dirilis. Mahasiswa diharapkan memeriksa KRS dan ruang kelas masing-masing melalui portal akademik.',
      'author': 'Bagian Administrasi Akademik',
    },
    '2': {
      'title': 'Pendaftaran Beasiswa Prestasi',
      'category': 'Kemahasiswaan',
      'date': '27 September 2026',
      'body': 'Pendaftaran beasiswa peningkatan prestasi akademik dibuka mulai tanggal 1 Oktober 2026. Siapkan transkrip nilai dan sertifikat kejuaraan pendukung.',
      'author': 'Kemahasiswaan & Alumni',
    },
    '3': {
      'title': 'Jadwal Kuliah Berubah',
      'category': 'Perkuliahan',
      'date': '28 September 2026',
      'body': 'Kelas Pemrograman Mobile pindah ke Ruang A2 jam 13.00 WIB. Diharapkan mahasiswa hadir tepat waktu dengan membawa laptop.',
      'author': 'Dosen Pengampu Pemrograman Mobile',
    },
  };

  @override
  Widget build(BuildContext context) {
    final item = _announcements[id] ?? {
      'title': 'Pengumuman Kampus #$id',
      'category': 'Umum',
      'date': 'Hari Ini',
      'body': 'Detail informasi terkait pengumuman nomor $id dari sistem push notification kampus.',
      'author': 'Sistem Notifikasi Kampus',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pengumuman'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Deep Link Metadata Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                  const SizedBox(width: 6),
                  Text(
                    'Deep Link Aktif: /pengumuman/$id',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              item['title']!,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),

            // Category & Date Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item['category']!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  item['date']!,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
            const Divider(height: 32),

            // Content
            Text(
              item['body']!,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 24),

            // Author Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFF1E3A8A),
                    child: Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Diterbitkan oleh:',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      Text(
                        item['author']!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Back to Home Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.go(AppRoutes.home),
                icon: const Icon(Icons.home_outlined),
                label: const Text('Kembali ke Beranda'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
