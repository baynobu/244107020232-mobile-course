import 'package:flutter/material.dart';

import 'announcement_card_tile.dart';

/// Seksi Daftar Pengumuman Kampus.
///
/// Memanfaatkan [RepaintBoundary] dan [const] child items untuk memastikan
/// area list tidak ikut dirender ulang saat state kartu lain (seperti timer atau token) berubah.
class AnnouncementSection extends StatelessWidget {
  const AnnouncementSection({super.key});

  static const List<
    ({String id, String title, String subtitle, bool isHighlight})
  >
  _defaultItems = [
    (
      id: '1',
      title: 'Jadwal Kuliah Semester Baru',
      subtitle: 'Pengecekan KRS dan ruang kelas',
      isHighlight: false,
    ),
    (
      id: '2',
      title: 'Pendaftaran Beasiswa Prestasi',
      subtitle: 'Pendaftaran dibuka mulai 1 Oktober',
      isHighlight: false,
    ),
    (
      id: '3',
      title: 'Jadwal Kuliah Berubah (Target FCM)',
      subtitle: 'Kelas Mobile pindah ke Ruang A2 jam 13.00',
      isHighlight: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.campaign, color: Color(0xFF1E3A8A)),
                  SizedBox(width: 8),
                  Text(
                    'Daftar Pengumuman Kampus',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Divider(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _defaultItems.length,
                itemBuilder: (context, index) {
                  final item = _defaultItems[index];
                  return AnnouncementCardTile(
                    key: ValueKey(item.id),
                    id: item.id,
                    title: item.title,
                    subtitle: item.subtitle,
                    isHighlight: item.isHighlight,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
