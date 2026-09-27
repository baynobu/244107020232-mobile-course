import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/data/local/note.dart';
import 'package:week5_offline_notes/widgets/note_tile.dart';

void main() {
  testWidgets('NoteTile displays title and dirty badge when dirty is true', (WidgetTester tester) async {
    final note = Note(
      id: 1,
      title: 'Tugas Mobile',
      body: 'Mengerjakan codelab week 5',
      updatedAt: DateTime(2026, 9, 21, 10, 0),
      dirty: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NoteTile(
            note: note,
            onTap: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    expect(find.text('Tugas Mobile'), findsOneWidget);
    expect(find.text('Mengerjakan codelab week 5'), findsOneWidget);
    expect(find.text('Belum Tersinkron'), findsOneWidget);
  });

  testWidgets('NoteTile displays Tersinkron badge when dirty is false', (WidgetTester tester) async {
    final note = Note(
      id: 2,
      title: 'Catatan Bersih',
      body: 'Sudah tersinkron ke cloud',
      updatedAt: DateTime(2026, 9, 21, 10, 0),
      dirty: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NoteTile(
            note: note,
            onTap: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    expect(find.text('Catatan Bersih'), findsOneWidget);
    expect(find.text('Tersinkron'), findsOneWidget);
  });
}
