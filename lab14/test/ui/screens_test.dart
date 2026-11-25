import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:users/app.dart';
import 'package:users/core/dev_host.dart';
import 'package:users/data/fake_user_repository.dart';
import 'package:users/domain/user_repository.dart';
import 'package:users/ui/about/about_screen.dart';

class _OfflineRepo implements UserRepository {
  @override
  Future<UsersPage> fetchUsers() async =>
      throw OfflineException('example.invalid', 'Failed host lookup');
}

Future<Widget> _app(UserRepository repo) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return ChangeNotifierProvider(
    create: (_) => DevHostSetting(prefs),
    child: UsersApp(buildRepository: (_) => repo),
  );
}

void main() {
  testWidgets('fakes: two users, no network', (tester) async {
    await tester.pumpWidget(await _app(FakeUserRepository()));
    await tester.pumpAndSettle();
    expect(find.text('Leanne Graham'), findsOneWidget);
    expect(find.text('Ervin Howell'), findsOneWidget);
  });

  testWidgets('unreachable host: Offline view names it', (tester) async {
    await tester.pumpWidget(await _app(_OfflineRepo()));
    await tester.pumpAndSettle();
    expect(find.text("You're offline"), findsOneWidget);
    expect(find.textContaining('example.invalid'), findsOneWidget);
  });

  testWidgets('Settings → About shows version, mode, env, host', (
    tester,
  ) async {
    PackageInfo.setMockInitialValues(
      appName: 'Users',
      packageName: 'kz.kiyopon.users',
      version: '1.0.1',
      buildNumber: '2',
      buildSignature: '',
    );
    await tester.pumpWidget(await _app(FakeUserRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Developer: API host'), findsOneWidget); // debug only
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Text>(find.byKey(const Key('about-summary'))).data,
      '1.0.1 (2) · debug · local · jsonplaceholder.typicode.com',
    );
    expect(buildMode, 'debug');
    expect(find.text('Open-source licences'), findsOneWidget);
  });
}
