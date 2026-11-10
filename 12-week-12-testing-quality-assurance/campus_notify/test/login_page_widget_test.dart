import 'package:campus_notify/pages/login_page.dart';
import 'package:campus_notify/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fake AuthNotifier untuk mengontrol alur pengujian widget LoginPage.
class MockSuccessAuthNotifier extends AuthNotifier {
  bool loginCalled = false;
  String? lastEmail;
  String? lastPassword;

  @override
  Future<bool> build() async => false;

  @override
  Future<void> login(String email, String password) async {
    loginCalled = true;
    lastEmail = email;
    lastPassword = password;
    state = const AsyncValue.data(true);
  }
}

class MockFailureAuthNotifier extends AuthNotifier {
  @override
  Future<bool> build() async => false;

  @override
  Future<void> login(String email, String password) async {
    state = AsyncValue.error(
      Exception('Kredensial salah atau pengguna tidak terdaftar (401)'),
      StackTrace.empty,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildLoginPage({AuthNotifier Function()? notifierOverride}) {
    return ProviderScope(
      overrides: [
        if (notifierOverride != null)
          authStateProvider.overrideWith(notifierOverride)
        else
          authStateProvider.overrideWith(() => MockSuccessAuthNotifier()),
      ],
      child: const MaterialApp(home: LoginPage()),
    );
  }

  group('Widget Tests: LoginPage (Week 12 Bagian 5 & 7)', () {
    // ─── 1. Uji Tampilan Awal ────────────────────────────────────────────────
    testWidgets('memeriksa tampilan awal form login dan seluruh kontrol UI', (
      tester,
    ) async {
      await tester.pumpWidget(buildLoginPage());
      await tester.pumpAndSettle();

      // Assert elemen header
      expect(find.text('Campus Notify'), findsOneWidget);
      expect(find.text('Portal Notifikasi Akademik Kampus'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_active_rounded), findsOneWidget);

      // Assert elemen form
      expect(find.byKey(const Key('login-email-field')), findsOneWidget);
      expect(find.byKey(const Key('login-password-field')), findsOneWidget);
      expect(find.byKey(const Key('login-submit-button')), findsOneWidget);
      expect(find.text('Masuk Akun'), findsOneWidget);

      // Assert badge keamanan
      expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
      expect(find.textContaining('Flutter Secure Storage'), findsOneWidget);
      expect(find.textContaining('GoRouter Guard'), findsOneWidget);
    });

    // ─── 2. Uji Masukan Tidak Valid (Validasi Form Error) ────────────────────
    testWidgets(
      'menampilkan pesan validasi ketika input email & kata sandi kosong',
      (tester) async {
        await tester.pumpWidget(buildLoginPage());
        await tester.pumpAndSettle();

        // Kosongkan input default dengan enterText ''
        await tester.enterText(find.byKey(const Key('login-email-field')), '');
        await tester.enterText(
          find.byKey(const Key('login-password-field')),
          '',
        );

        // Act: Tekan tombol submit
        await tester.tap(find.byKey(const Key('login-submit-button')));
        await tester.pumpAndSettle();

        // Assert: Validasi pesan error muncul di UI
        expect(find.text('Email tidak boleh kosong'), findsOneWidget);
        expect(find.text('Kata sandi tidak boleh kosong'), findsOneWidget);
      },
    );

    testWidgets(
      'menampilkan pesan error jika format email tidak memiliki simbol @',
      (tester) async {
        await tester.pumpWidget(buildLoginPage());
        await tester.pumpAndSettle();

        // Masukkan email invalid
        await tester.enterText(
          find.byKey(const Key('login-email-field')),
          'format-email-tanpa-at',
        );
        await tester.enterText(
          find.byKey(const Key('login-password-field')),
          'rahasia123',
        );

        // Act
        await tester.tap(find.byKey(const Key('login-submit-button')));
        await tester.pumpAndSettle();

        // Assert
        expect(
          find.text('Format email tidak valid (harus mengandung @)'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'menampilkan pesan error jika kata sandi kurang dari 6 karakter',
      (tester) async {
        await tester.pumpWidget(buildLoginPage());
        await tester.pumpAndSettle();

        // Masukkan password terlalu pendek (< 6 chars)
        await tester.enterText(
          find.byKey(const Key('login-email-field')),
          'mahasiswa@kampus.ac.id',
        );
        await tester.enterText(
          find.byKey(const Key('login-password-field')),
          '123',
        );

        // Act
        await tester.tap(find.byKey(const Key('login-submit-button')));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Kata sandi minimal 6 karakter'), findsOneWidget);
      },
    );

    // ─── 3. Uji Tindakan Pengguna yang Berhasil ──────────────────────────────
    testWidgets(
      'mengirim formulir dan memanggil auth notifier saat input valid',
      (tester) async {
        final mockNotifier = MockSuccessAuthNotifier();
        await tester.pumpWidget(
          buildLoginPage(notifierOverride: () => mockNotifier),
        );
        await tester.pumpAndSettle();

        // Arrange: Isi kredensial valid
        await tester.enterText(
          find.byKey(const Key('login-email-field')),
          'hanif@polinema.ac.id',
        );
        await tester.enterText(
          find.byKey(const Key('login-password-field')),
          'passwordAman2026',
        );

        // Act: Tap tombol submit
        await tester.tap(find.byKey(const Key('login-submit-button')));
        await tester.pumpAndSettle();

        // Assert: Form berhasil tervalidasi dan notifier menerima parameter yang benar
        expect(mockNotifier.loginCalled, isTrue);
        expect(mockNotifier.lastEmail, 'hanif@polinema.ac.id');
        expect(mockNotifier.lastPassword, 'passwordAman2026');
        expect(find.text('Email tidak boleh kosong'), findsNothing);
        expect(find.text('Kata sandi minimal 6 karakter'), findsNothing);
      },
    );

    // ─── 4. Uji Tampilan Pesan Kesalahan Autentikasi (Error Banner) ───────────
    testWidgets('menampilkan banner pesan kesalahan saat autentikasi gagal', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildLoginPage(notifierOverride: MockFailureAuthNotifier.new),
      );
      await tester.pumpAndSettle();

      // Act: Submit login
      await tester.tap(find.byKey(const Key('login-submit-button')));
      await tester.pumpAndSettle();

      // Assert: Banner error tampil
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(
        find.textContaining('Kredensial salah atau pengguna tidak terdaftar'),
        findsOneWidget,
      );
    });

    // ─── 5. Uji Toggle Visibilitas Kata Sandi ─────────────────────────────────
    testWidgets(
      'dapat mengubah visibilitas teks kata sandi via tombol suffix icon',
      (tester) async {
        await tester.pumpWidget(buildLoginPage());
        await tester.pumpAndSettle();

        // Awalnya teks tersembunyi (obscureText = true), ikon = visibility_off
        expect(find.byIcon(Icons.visibility_off), findsOneWidget);

        // Tap toggle visibility
        await tester.tap(find.byIcon(Icons.visibility_off));
        await tester.pumpAndSettle();

        // Sekarang ikon berganti ke visibility
        expect(find.byIcon(Icons.visibility), findsOneWidget);
      },
    );
  });
}
