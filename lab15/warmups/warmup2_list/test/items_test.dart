import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warmup2_list/items_model.dart';
import 'package:warmup2_list/items_repository.dart';
import 'package:warmup2_list/main.dart';

void main() {
  group('ItemsModel', () {
    test('loading → loaded', () async {
      final m = ItemsModel(FakeItemsRepository(delay: Duration.zero));
      final f = m.load();
      expect(m.state, isA<Loading>());
      await f;
      expect(m.state, isA<Loaded>());
    });

    test('failure → Failed, Retry → Loaded', () async {
      final repo = FakeItemsRepository(delay: Duration.zero, failNext: true);
      final m = ItemsModel(repo);
      await m.load();
      expect(m.state, isA<Failed>());
      await m.load();
      expect(m.state, isA<Loaded>());
      expect(repo.calls, 2);
    });

    test('empty list → Empty, not Loaded([])', () async {
      final m = ItemsModel(
        FakeItemsRepository(delay: Duration.zero, emptyNext: true),
      );
      await m.load();
      expect(m.state, isA<Empty>());
    });

    test('disposed mid-request → no notify after dispose', () async {
      final m = ItemsModel(FakeItemsRepository(delay: Duration.zero));
      final f = m.load();
      m.dispose();
      await f; // would throw "used after being disposed" without the guard
    });
  });

  testWidgets('error with Retry on screen', (tester) async {
    final repo = FakeItemsRepository(failNext: true);
    await tester.pumpWidget(ItemsApp(repo: repo));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Almaty'), findsOneWidget);
  });
}
