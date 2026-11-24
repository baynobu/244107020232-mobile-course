import 'package:campus_notify/pages/widgets/announcement_card_tile.dart';
import 'package:campus_notify/pages/widgets/announcement_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Widget Tests: Announcement Components (Week 12 Bagian 5 & 7)', () {
    testWidgets(
      'AnnouncementCardTile menampilkan detail judul, id, dan subtitle',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AnnouncementCardTile(
                id: '1',
                title: 'Jadwal Kuliah Semester Baru',
                subtitle: 'Pengecekan KRS dan ruang kelas',
                isHighlight: false,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert elemen teks
        expect(find.text('Jadwal Kuliah Semester Baru'), findsOneWidget);
        expect(find.text('Pengecekan KRS dan ruang kelas'), findsOneWidget);
        expect(find.text('1'), findsOneWidget);
        expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      },
    );

    testWidgets(
      'AnnouncementCardTile dengan isHighlight=true merender styling khusus',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AnnouncementCardTile(
                id: '3',
                title: 'Jadwal Kuliah Berubah (Target FCM)',
                subtitle: 'Kelas Mobile pindah ke Ruang A2',
                isHighlight: true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Jadwal Kuliah Berubah (Target FCM)'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
      },
    );

    testWidgets(
      'AnnouncementSection merender header dan seluruh item daftar pengumuman',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: AnnouncementSection()),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert header
        expect(find.text('Daftar Pengumuman Kampus'), findsOneWidget);
        expect(find.byIcon(Icons.campaign), findsOneWidget);

        // Assert default item pengumuman
        expect(find.text('Jadwal Kuliah Semester Baru'), findsOneWidget);
        expect(find.text('Pendaftaran Beasiswa Prestasi'), findsOneWidget);
        expect(find.text('Jadwal Kuliah Berubah (Target FCM)'), findsOneWidget);
      },
    );
  });
}
