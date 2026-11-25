import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:users_api/core/api/api_client.dart';
import 'package:users_api/core/storage/secure_store.dart';
import 'package:users_api/features/auth/auth_model.dart';
import 'package:users_api/features/auth/login_screen.dart';
import 'package:users_api/features/settings/settings_model.dart';
// ignore: unused_import — used by the demo-mode line in main()
import 'package:users_api/features/users/fake_user_repository.dart';
import 'package:users_api/features/users/user_repository.dart';
import 'package:users_api/features/users/users_cache.dart';
import 'package:users_api/features/users/users_model.dart';
import 'package:users_api/features/users/users_screen.dart';

/// The composition root: the only place that decides which implementation
/// each model gets. Everything below receives its dependencies.
void main() {
  final api = ApiClient();
  final UserRepository repo = HttpUserRepository(api, UsersCache());
  // final UserRepository repo = FakeUserRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthModel(SecureStore())..restore(),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsModel(SharedPreferencesAsync())..load(),
        ),
        ChangeNotifierProvider(create: (_) => UsersModel(repo)..load()),
      ],
      child: const UsersApp(),
    ),
  );
}

class UsersApp extends StatelessWidget {
  const UsersApp({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = context.select<SettingsModel, bool>((s) => s.darkMode);
    final auth = context.watch<AuthModel>();
    final Widget home;
    if (auth.restoring) {
      home = const Scaffold(body: Center(child: CircularProgressIndicator()));
    } else if (auth.isLoggedIn) {
      home = const UsersScreen();
    } else {
      home = const LoginScreen();
    }
    return MaterialApp(
      title: 'Users',
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: home,
    );
  }
}
