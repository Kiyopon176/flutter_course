import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_course/main.dart';
import 'package:flutter_course/tap_card.dart';

void main() {
  testWidgets('tap card counts and resets through the dialog', (tester) async {
    await tester.pumpWidget(const MyApp());
    final card = find.byType(TapCard);
    for (var i = 0; i < 10; i++) {
      await tester.tap(card);
    }
    await tester.pump();
    expect(find.descendant(of: card, matching: find.text('10')), findsOne);

    await tester.longPress(card);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.descendant(of: card, matching: find.text('10')), findsOne);

    await tester.longPress(card);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset').last);
    await tester.pumpAndSettle();
    expect(find.descendant(of: card, matching: find.text('0')), findsOne);
  });

  testWidgets('removing a running stopwatch leaves no timer', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Start'));
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('00:03'), findsOne);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
  });
}
