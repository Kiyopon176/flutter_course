import 'package:flutter_test/flutter_test.dart';

import 'package:lab4/data.dart';
import 'package:lab4/info_row.dart';
import 'package:lab4/main.dart';

void main() {
  testWidgets('profile shows name and one row per fact', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('My profile'), findsOne);
    expect(find.text(myName), findsOne);
    expect(find.text(myUniversity), findsOne);
    expect(find.byType(InfoRow), findsNWidgets(facts.length));
  });
}
