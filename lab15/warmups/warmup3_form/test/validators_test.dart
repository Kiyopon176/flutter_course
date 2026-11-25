import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warmup3_form/main.dart';
import 'package:warmup3_form/validators.dart';

void main() {
  group('validateEmail (plain function)', () {
    test('empty / null → asks for an email', () {
      expect(validateEmail(null), 'Enter an email');
      expect(validateEmail('   '), 'Enter an email');
    });
    test('no @ or no domain → invalid', () {
      expect(validateEmail('student'), 'Not a valid email');
      expect(validateEmail('a@b'), 'Not a valid email');
    });
    test('valid, surrounding spaces trimmed → null', () {
      expect(validateEmail('  dev@kbtu.kz '), isNull);
    });
  });

  test('validateName: min 2 characters', () {
    expect(validateName(''), 'Enter a name');
    expect(validateName('A'), 'At least 2 characters');
    expect(validateName('Al'), isNull);
  });

  testWidgets('Submit shows errors, then succeeds', (tester) async {
    await tester.pumpWidget(const FormApp());
    await tester.tap(find.text('Submit'));
    await tester.pump();
    expect(find.text('Enter a name'), findsOneWidget);
    expect(find.text('Enter an email'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'Alex');
    await tester.enterText(find.byType(TextFormField).at(1), 'dev@kbtu.kz');
    await tester.tap(find.text('Submit'));
    await tester.pump();
    expect(find.text('Submitted: Alex <dev@kbtu.kz>'), findsOneWidget);
  });
}
