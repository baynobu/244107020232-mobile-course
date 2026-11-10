import 'package:campus_notify/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  // Inisialisasi integration test widgets flutter binding
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group(
    'End-to-End Integration Tests: Campus Notify (Week 12 Bagian 6 & 7)',
    () {
      testWidgets(
        'Alur lengkap pengguna: Login -> Dashboard -> Buka Chat AI -> Kembali',
        (tester) async {
          // 1. Arrange & Launch Application
          await app.main();
          await tester.pumpAndSettle();

          // 2. Periksa apakah berada di LoginPage atau langsung di HomePage
          final loginTitleFinder = find.text('Campus Notify');
          final emailFieldFinder = find.byKey(const Key('login-email-field'));
          final passwordFieldFinder = find.byKey(
            const Key('login-password-field'),
          );
          final loginButtonFinder = find.byKey(
            const Key('login-submit-button'),
          );

          if (emailFieldFinder.evaluate().isNotEmpty) {
            // Berada di LoginPage
            expect(loginTitleFinder, findsOneWidget);

            // Act: Masukkan kredensial pengguna
            await tester.enterText(emailFieldFinder, 'mahasiswa@kampus.ac.id');
            await tester.enterText(passwordFieldFinder, 'rahasia123');
            await tester.pumpAndSettle();

            // Tekan tombol Masuk Akun
            await tester.tap(loginButtonFinder);
            await tester.pumpAndSettle();
          }

          // 3. Verifikasi Transisi ke Dashboard (HomePage)
          expect(find.text('Campus Notify Dashboard'), findsOneWidget);
          expect(find.text('Daftar Pengumuman Kampus'), findsOneWidget);
          expect(find.text('Jadwal Kuliah Semester Baru'), findsOneWidget);

          // 4. Verifikasi Navigasi ke Fitur Asisten AI Kampus
          final aiFabFinder = find.byKey(const ValueKey('ai_assistant_fab'));
          final aiActionFinder = find.byIcon(Icons.smart_toy_outlined);

          if (aiActionFinder.evaluate().isNotEmpty) {
            await tester.tap(aiActionFinder);
          } else if (aiFabFinder.evaluate().isNotEmpty) {
            await tester.tap(aiFabFinder);
          }
          await tester.pumpAndSettle();

          // 5. Verifikasi Berada di Layaran Asisten AI
          expect(find.text('Asisten AI Kampus'), findsOneWidget);

          // 6. Kembali ke Dashboard
          final backButtonFinder = find.byTooltip('Back');
          if (backButtonFinder.evaluate().isNotEmpty) {
            await tester.tap(backButtonFinder);
          } else {
            final popIconFinder = find.byIcon(Icons.arrow_back);
            if (popIconFinder.evaluate().isNotEmpty) {
              await tester.tap(popIconFinder);
            }
          }
          await tester.pumpAndSettle();

          // 7. Verifikasi Kembali di Dashboard
          expect(find.text('Campus Notify Dashboard'), findsOneWidget);
        },
      );
    },
  );
}
