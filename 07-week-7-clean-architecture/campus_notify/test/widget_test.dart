import 'package:campus_notify/pages/login_page.dart';
import 'package:campus_notify/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAuthNotifier extends AuthNotifier {
  @override
  Future<bool> build() async => false;
}

void main() {
  testWidgets('Smoke test: LoginPage menampilkan elemen form dengan benar', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(FakeAuthNotifier.new),
        ],
        child: const MaterialApp(
          home: LoginPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verifikasi teks header dan form
    expect(find.text('Campus Notify'), findsOneWidget);
    expect(find.text('Portal Notifikasi Akademik Kampus'), findsOneWidget);
    expect(find.text('Email Kampus'), findsOneWidget);
    expect(find.text('Kata Sandi'), findsOneWidget);
    expect(find.text('Masuk Akun'), findsOneWidget);
  });
}
