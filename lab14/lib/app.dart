import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/dev_host.dart';
import 'domain/user_repository.dart';
import 'ui/users/users_screen.dart';
import 'ui/users/users_view_model.dart';

const brandColor = Color(0xFF00897B);

class UsersApp extends StatelessWidget {
  const UsersApp({super.key, required this.buildRepository});

  /// Wiring lives in main.dart; the app only knows the interface.
  final UserRepository Function(String host) buildRepository;

  @override
  Widget build(BuildContext context) {
    final host = context.select<DevHostSetting, String>((d) => d.host);
    // Keyed by host: when a tester switches host (debug only), the whole
    // tree is rebuilt against a fresh repository.
    return ChangeNotifierProvider(
      key: ValueKey(host),
      create: (_) => UsersViewModel(buildRepository(host))..load(),
      child: MaterialApp(
        title: 'Users',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: brandColor),
        darkTheme: ThemeData(
          colorSchemeSeed: brandColor,
          brightness: Brightness.dark,
        ),
        home: const UsersScreen(),
      ),
    );
  }
}
