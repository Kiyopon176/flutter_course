import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:students_async/api/fake_api.dart';
import 'package:students_async/main.dart';

/// A widget test that captures debugPrint output; restored before the
/// framework checks its invariants.
void logged(
  String description,
  Future<void> Function(WidgetTester tester, List<String> logs) body,
) {
  testWidgets(description, (tester) async {
    final logs = <String>[];
    final original = debugPrint;
    debugPrint = (String? m, {int? wrapWidth}) => logs.add(m ?? '');
    try {
      await body(tester, logs);
    } finally {
      debugPrint = original;
    }
  });
}

Future<void> open(WidgetTester tester, String button) async {
  await tester.tap(find.text(button));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500)); // route transition
}

Future<void> back(WidgetTester tester) async {
  await tester.pageBack();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

int fetches(List<String> logs) =>
    logs.where((l) => l.startsWith('fetchStudents')).length;

void main() {
  logged('FakeApi: three calls in a row, only the third fails', (
    tester,
    logs,
  ) async {
    final api = FakeApi();
    final results = <Object>[];
    for (var i = 0; i < 3; i++) {
      unawaited(
        api.fetchStudents().then(
          (l) => results.add(l.length),
          onError: (Object e) => results.add(e),
        ),
      );
    }
    await tester.pump(const Duration(seconds: 2));
    expect(results.take(2), [6, 6]);
    expect(results[2], isA<NoConnectionException>());
  });

  logged('By hand: spinner -> list; Back during load is silent', (
    tester,
    logs,
  ) async {
    await tester.pumpWidget(const StudentsApp());
    await open(tester, 'By hand');
    expect(find.text('Loading students…'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Aida Nurlanova'), findsOneWidget);
    expect(find.text('—'), findsOneWidget); // Aruzhan has no gpa
    await back(tester);

    await open(tester, 'By hand');
    await back(tester); // leave during the 2 seconds
    await tester.pump(const Duration(seconds: 3));
    expect(tester.takeException(), isNull); // the mounted guard held
    expect(fetches(logs), 2);
  });

  logged('FutureBuilder: Switch x10 does not refetch', (tester, logs) async {
    await tester.pumpWidget(const StudentsApp());
    await open(tester, 'FutureBuilder');
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Dana Omarova'), findsOneWidget);

    for (var i = 0; i < 10; i++) {
      await tester.tap(find.byType(Switch));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    }
    expect(fetches(logs), 1);
  });

  logged('Countdown B: leaving at 8 stops the ticks', (tester, logs) async {
    await tester.pumpWidget(const StudentsApp());
    await open(tester, 'Countdown');
    await tester.tap(find.text('B · listen'));
    await tester.pump();
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    expect(find.text('8'), findsOneWidget);
    await back(tester);
    await tester.pump(const Duration(seconds: 12));
    expect(tester.takeException(), isNull);
    expect(logs.where((l) => l.startsWith('tick')).last, 'tick 8');
  });

  logged('Save: success pops; rejection shows a SnackBar and stays', (
    tester,
    logs,
  ) async {
    FakeApi.saveCalls = 0;
    await tester.pumpWidget(const StudentsApp());

    // 1st save: accepted -> back on the home screen. A fast 2nd tap is ignored.
    await open(tester, 'By hand');
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 500)); // FAB scales in
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 500));
    expect(FakeApi.saveCalls, 1);
    expect(find.text('Countdown'), findsOneWidget);

    // 2nd save: rejected -> SnackBar, the screen stays.
    await open(tester, 'By hand');
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 500)); // FAB scales in
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(find.text('server rejected 6'), findsOneWidget);
    expect(find.text('Students — by hand'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5)); // let the SnackBar go
  });
}
