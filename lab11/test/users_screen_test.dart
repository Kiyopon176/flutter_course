import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:users_api/app.dart';
import 'package:users_api/core/api/api_client.dart';
import 'package:users_api/features/users/user_repository.dart';
import 'package:users_api/features/users/users_model.dart';

import 'fixtures.dart';

Widget _app(MockClientHandler handler) => ChangeNotifierProvider(
  create: (_) =>
      UsersModel(UserRepository(ApiClient(MockClient(handler))))..load(),
  child: const App(),
);

http.Response _ok(String body, [int status = 200]) => http.Response(
  body,
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

void main() {
  testWidgets('loading → list of users, detail on tap', (tester) async {
    await tester.pumpWidget(_app((_) async => _ok(usersJson)));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('Leanne Graham'), findsOneWidget);
    expect(find.text('Ervin Howell'), findsOneWidget);
    expect(find.textContaining('Gwenborough'), findsOneWidget);

    await tester.tap(find.text('Leanne Graham'));
    await tester.pumpAndSettle();
    expect(find.text('1-770-736-8031 x56442'), findsOneWidget);
    expect(find.text('Romaguera-Crona'), findsOneWidget);
  });

  testWidgets('offline → Offline view; Retry loads without restart', (
    tester,
  ) async {
    var online = false;
    await tester.pumpWidget(
      _app((_) async {
        if (!online) throw const SocketException('Failed host lookup');
        return _ok(usersJson);
      }),
    );
    await tester.pumpAndSettle();
    expect(find.text('No connection'), findsOneWidget);

    online = true;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Leanne Graham'), findsOneWidget);
  });

  testWidgets('5xx → ServerError with status', (tester) async {
    await tester.pumpWidget(_app((_) async => _ok('down', 502)));
    await tester.pumpAndSettle();
    expect(find.text('Server error 502'), findsOneWidget);
  });

  testWidgets('New user: double tap sends one POST, user lands on top', (
    tester,
  ) async {
    var posts = 0;
    await tester.pumpWidget(
      _app((r) async {
        if (r.method == 'POST') {
          posts++;
          await Future<void>.delayed(const Duration(milliseconds: 100));
          final body = jsonDecode(r.body) as Map<String, dynamic>;
          return _ok(jsonEncode({...body, 'id': 11}), 201);
        }
        return _ok(usersJson);
      }),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('New user'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Name'),
      'Ada Lovelace',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Username'),
      'ada',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'ada@x.io',
    );

    final save = find.widgetWithText(FilledButton, 'Save');
    await tester.tap(save);
    await tester.tap(save, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(posts, 1);
    expect(find.text('New user'), findsOneWidget); // back on the list (FAB)
    expect(
      tester.getTopLeft(find.text('Ada Lovelace')).dy,
      lessThan(tester.getTopLeft(find.text('Leanne Graham')).dy),
    );
  });

  testWidgets('New user: 5xx → SnackBar, form stays open', (tester) async {
    await tester.pumpWidget(
      _app((r) async => r.method == 'POST' ? _ok('', 500) : _ok(usersJson)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('New user'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'Ada');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Username'),
      'ada',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'ada@x.io',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.text('Could not save: server error 500'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Save'), findsOneWidget);
  });
}
