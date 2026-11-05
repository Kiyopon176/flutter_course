import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shop/main.dart';
import 'package:shop/models/book.dart';
import 'package:shop/models/cart.dart';

void main() {
  group('Cart (no widgets)', () {
    test('no duplicates, remove, total', () {
      final cart = Cart();
      expect(cart.add(books[0]), isTrue);
      expect(cart.add(books[1]), isTrue);
      expect(cart.add(books[0]), isFalse);
      cart.remove(books[0]);
      expect(cart.count, 1);
      expect(cart.total, 3100);
    });

    test('items is unmodifiable', () {
      final cart = Cart();
      expect(() => cart.items.add(books[0]), throwsUnsupportedError);
    });

    test('increment changes total but not count', () {
      final cart = Cart()..add(books[1]);
      cart.increment(books[1]);
      expect(cart.qtyOf(books[1]), 2);
      expect(cart.count, 1);
      expect(cart.total, 6200);
    });
  });

  testWidgets('Add -> badge, Added, SnackBar; + does not rebuild the badge', (
    tester,
  ) async {
    final logs = <String>[];
    final original = debugPrint;
    debugPrint = (String? m, {int? wrapWidth}) => logs.add(m ?? '');
    try {
      await tester.pumpWidget(
        ChangeNotifierProvider(create: (_) => Cart(), child: const Shell()),
      );
      await tester.tap(find.widgetWithText(OutlinedButton, 'Add').first);
      await tester.pump();
      expect(find.text('Added'), findsOneWidget);
      expect(find.textContaining('Added "'), findsOneWidget); // SnackBar
      expect(
        find.descendant(of: find.byType(Badge), matching: find.text('1')),
        findsOneWidget,
      );

      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();
      logs.clear();
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();
      }
      expect(find.text('16800 ₸'), findsOneWidget); // 4200 × 4
      expect(logs.where((l) => l == 'badge build'), isEmpty);
      expect(logs.where((l) => l == 'total label build'), isEmpty);

      await tester.tap(find.byIcon(Icons.delete_sweep));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.close), findsNothing);
    } finally {
      debugPrint = original;
    }
  });
}
