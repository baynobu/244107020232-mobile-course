import 'package:campus_notify/data/token_store.dart';
import 'package:campus_notify/features/announcements/domain/entities/announcement.dart';
import 'package:campus_notify/features/announcements/presentation/providers/announcements_providers.dart';
import 'package:campus_notify/pages/home_page.dart';
import 'package:campus_notify/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeTokenStore extends TokenStore {
  @override
  Future<String?> readAccess() async => 'fake-access-token-12345';

  @override
  Future<String?> readRefresh() async => 'fake-refresh-token-67890';
}

void main() {
  final testAnnouncements = [
    Announcement(
      id: '1',
      title: 'Jadwal Kuliah Semester Baru',
      category: 'Akademik',
      body: 'Jadwal perkuliahan Semester Ganjil 2026/2027 telah dirilis.',
      author: 'Bagian Administrasi Akademik',
      publishedAt: DateTime(2026, 9, 28),
    ),
    Announcement(
      id: '2',
      title: 'Pendaftaran Beasiswa Prestasi',
      category: 'Kemahasiswaan',
      body: 'Pendaftaran beasiswa peningkatan prestasi akademik dibuka.',
      author: 'Kemahasiswaan & Alumni',
      publishedAt: DateTime(2026, 9, 27),
    ),
    Announcement(
      id: '3',
      title: 'Jadwal Kuliah Berubah',
      category: 'Perkuliahan',
      body: 'Kelas Pemrograman Mobile pindah ke Ruang A2 jam 13.00 WIB.',
      author: 'Dosen Mobile',
      publishedAt: DateTime(2026, 9, 28),
    ),
  ];

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        tokenStoreProvider.overrideWithValue(FakeTokenStore()),
        announcementsProvider.overrideWith((ref) async => testAnnouncements),
      ],
      child: const MaterialApp(home: HomePage()),
    );
  }

  testWidgets(
    'Search bar memfilter daftar pengumuman dan menampilkan empty state saat tidak cocok',
    (tester) async {
      // Set screen size agar scrolling dan UI leluasa
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // 1. Kondisi awal: ketiga pengumuman muncul di UI
      expect(find.text('Jadwal Kuliah Semester Baru'), findsOneWidget);
      expect(find.text('Pendaftaran Beasiswa Prestasi'), findsOneWidget);
      expect(find.text('Jadwal Kuliah Berubah'), findsOneWidget);
      expect(find.byKey(const Key('announcement_empty_state')), findsNothing);

      // 2. Ketik query pencarian yang cocok: "beasiswa"
      final searchField = find.byKey(const Key('search_announcement_field'));
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'beasiswa');
      await tester.pumpAndSettle();

      // Hanya pengumuman beasiswa yang tampil
      expect(find.text('Pendaftaran Beasiswa Prestasi'), findsOneWidget);
      expect(find.text('Jadwal Kuliah Semester Baru'), findsNothing);
      expect(find.text('Jadwal Kuliah Berubah'), findsNothing);
      expect(find.byKey(const Key('announcement_empty_state')), findsNothing);

      // 3. Ketik query yang tidak cocok: "zzz-tak-ada"
      await tester.enterText(searchField, 'zzz-tak-ada');
      await tester.pumpAndSettle();

      // Empty state harus muncul
      expect(find.byKey(const Key('announcement_empty_state')), findsOneWidget);
      expect(find.text('Pengumuman Tidak Ditemukan'), findsOneWidget);
      expect(
        find.text(
          'Tidak ada pengumuman yang sesuai dengan kata kunci "zzz-tak-ada".',
        ),
        findsOneWidget,
      );
      expect(find.text('Pendaftaran Beasiswa Prestasi'), findsNothing);

      // 4. Tekan tombol "Reset Pencarian"
      final resetButton = find.byKey(const Key('reset_search_button'));
      expect(resetButton, findsOneWidget);
      await tester.tap(resetButton);
      await tester.pumpAndSettle();

      // Empty state hilang, semua pengumuman kembali tampil
      expect(find.byKey(const Key('announcement_empty_state')), findsNothing);
      expect(find.text('Jadwal Kuliah Semester Baru'), findsOneWidget);
      expect(find.text('Pendaftaran Beasiswa Prestasi'), findsOneWidget);
      expect(find.text('Jadwal Kuliah Berubah'), findsOneWidget);
    },
  );
}
