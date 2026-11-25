import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:users_api/features/users/users_model.dart';
import 'package:users_api/features/users/users_screen.dart';

import '../../fakes/fake_user_repository.dart';

void main() {
  testWidgets('shows the offline view and Retry', (tester) async {
    // The fake answers after 100 ms of *fake* time, so right after the tap
    // the model is still loading and the spinner is on screen.
    const latency = Duration(milliseconds: 100);
    final model = UsersModel(FakeUserRepository(fail: true, delay: latency));
    await tester.runAsync(model.load); // first load: real time, before pump
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider.value(
          value: model,
          child: const UsersScreen(),
        ),
      ),
    );

    expect(find.text('No connection'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(latency); // let the fake fail again — no pending timers
    expect(find.text('No connection'), findsOneWidget);
  });
}
