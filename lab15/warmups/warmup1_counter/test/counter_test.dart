import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:warmup1_counter/main.dart';

void main() {
  test('Counter notifies on every change', () {
    final c = Counter();
    var calls = 0;
    c.addListener(() => calls++);
    c
      ..increment()
      ..increment()
      ..decrement();
    expect(c.value, 1);
    expect(calls, 3);
  });

  testWidgets('both screens show and change the same count', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => Counter(),
        child: const CounterApp(),
      ),
    );
    expect(find.text('Count: 0'), findsOneWidget);

    await tester.tap(find.byKey(const Key('increment')));
    await tester.tap(find.byKey(const Key('increment')));
    await tester.pump();
    expect(find.text('Count: 2'), findsOneWidget);

    await tester.tap(find.text('Open second screen'));
    await tester.pumpAndSettle();
    expect(find.text('Count: 2'), findsOneWidget);

    await tester.tap(find.byKey(const Key('decrement')));
    await tester.pump();
    expect(find.text('Count: 1'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Count: 1'), findsOneWidget);
  });
}
