import 'package:campus_notify/features/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ChatScreen Widget Tests', () {
    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
    });

    Widget createChatScreen() {
      return const ProviderScope(child: MaterialApp(home: ChatScreen()));
    }

    testWidgets(
      'Menampilkan AppBar, pesan sambutan awal, dan quick prompt chips',
      (tester) async {
        await tester.pumpWidget(createChatScreen());
        await tester.pumpAndSettle();

        // Cek AppBar
        expect(find.text('Asisten AI Kampus'), findsOneWidget);
        expect(find.byIcon(Icons.vpn_key_outlined), findsOneWidget);
        expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);

        // Cek Pesan Sambutan Awal
        expect(
          find.textContaining('Halo! Saya Asisten AI Resmi Campus Notify'),
          findsOneWidget,
        );

        // Cek Banner Privasi / Mode Offline
        expect(find.textContaining('API key belum diatur'), findsOneWidget);

        // Cek Quick Prompt Chips
        expect(
          find.text('Kapan jadwal pengisian KRS semester baru?'),
          findsOneWidget,
        );
        expect(
          find.text('Bagaimana prosedur pengajuan izin sakit?'),
          findsOneWidget,
        );
      },
    );

    testWidgets('Tapping tombol pengaturan API Key membuka AlertDialog', (
      tester,
    ) async {
      await tester.pumpWidget(createChatScreen());
      await tester.pumpAndSettle();

      // Tap ikon kunci
      await tester.tap(find.byIcon(Icons.vpn_key_outlined));
      await tester.pumpAndSettle();

      // Dialog terbuka
      expect(find.text('Pengaturan API Key'), findsOneWidget);
      expect(find.text('Simpan'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);

      // Tap Batal
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      // Dialog tertutup
      expect(find.text('Pengaturan API Key'), findsNothing);
    });

    testWidgets(
      'Mengirim pertanyaan melalui quick prompt chip memperbarui riwayat chat',
      (tester) async {
        await tester.pumpWidget(createChatScreen());
        await tester.pumpAndSettle();

        // Tap salah satu chip prompt cepat
        final chipFinder = find.text(
          'Kapan jadwal pengisian KRS semester baru?',
        );
        expect(chipFinder, findsOneWidget);

        await tester.tap(chipFinder);
        await tester.pump(); // memicu loading state

        // Tunggu hingga respon selesai di-render
        await tester.pumpAndSettle();

        // Pesan user muncul di bubble chat
        expect(
          find.text('Kapan jadwal pengisian KRS semester baru?'),
          findsWidgets,
        );

        // Jawaban fallback offline muncul karena belum ada API key
        expect(
          find.textContaining('Pengisian Kartu Rencana Studi (KRS)'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Mereset obrolan mengembalikan pesan ke kondisi sambutan awal',
      (tester) async {
        await tester.pumpWidget(createChatScreen());
        await tester.pumpAndSettle();

        // Kirim pesan custom via textfield
        final inputField = find.byType(TextField);
        await tester.enterText(inputField, 'kontak bantuan kampus');
        await tester.tap(find.byIcon(Icons.send_rounded));
        await tester.pumpAndSettle();

        expect(find.text('kontak bantuan kampus'), findsOneWidget);

        // Tap tombol reset obrolan
        await tester.tap(find.byIcon(Icons.refresh_rounded));
        await tester.pumpAndSettle();

        // Pesan reset ditampilkan
        expect(find.textContaining('Percakapan telah direset'), findsOneWidget);
        expect(find.text('kontak bantuan kampus'), findsNothing);
      },
    );
  });
}
