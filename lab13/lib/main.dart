import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users_api/auth_model.dart';
import 'package:users_api/login_screen.dart';
import 'package:users_api/settings_model.dart';
import 'package:users_api/features/users/users_model.dart';
import 'package:users_api/features/users/users_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthModel()..restore()),
        ChangeNotifierProvider(create: (_) => SettingsModel()..load()),
        ChangeNotifierProvider(create: (_) => UsersModel()..load()),
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
