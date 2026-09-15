// Ini adalah pengujian widget dasar pada Flutter.
//
// Untuk melakukan interaksi dengan widget dalam pengujian Anda, gunakan utilitas
// WidgetTester yang ada dalam paket flutter_test. Misalnya, Anda dapat mengirim
// gestur ketukan (tap) dan gulir (scroll). Anda juga dapat menggunakan WidgetTester
// untuk menemukan widget anak di dalam pohon widget, membaca teks, dan 
// memverifikasi bahwa nilai dari properti widget sudah benar.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:week3_navigation/main.dart';

void main() {
  testWidgets('menambah tugas baru', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    expect(find.text('Belum ada tugas'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Kerjakan PR minggu 3');
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();

    expect(find.text('Kerjakan PR minggu 3'), findsOneWidget);
  });
}
