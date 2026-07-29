import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpsyllabary/src/app.dart';
import 'package:jpsyllabary/src/kana_data.dart';

void main() {
  test('kana data sets stay aligned', () {
    expect(hiragana.length, 45);
    expect(katakana.length, hiragana.length);
    expect(romaji.length, hiragana.length);
    expect(sonant.length, 50);
    expect(sonantRomaji.length, sonant.length);
    expect(allKana.length, 140);
  });

  testWidgets('single practice screen opens the navigation drawer', (
    tester,
  ) async {
    await tester.pumpWidget(const JpSyllabaryApp());

    expect(find.byType(SingleScreen), findsOneWidget);
    expect(find.text('あ'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationDrawer), findsOneWidget);
    expect(find.text('Table'), findsOneWidget);
  });

  testWidgets('each twister row can be dragged independently', (tester) async {
    await tester.pumpWidget(const JpSyllabaryApp());
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tongue Twister'));
    await tester.pumpAndSettle();

    final firstRow = find.byType(PageView).first;
    expect(find.textContaining('あえい'), findsOneWidget);

    await tester.drag(firstRow, const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(find.textContaining('アエイ'), findsOneWidget);
    expect(find.textContaining('かけき'), findsOneWidget);
  });
}
