import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/api_client.dart';
import 'core/dev_host.dart';
import 'core/env.dart';
import 'data/fake_user_repository.dart';
import 'data/http_user_repository.dart';
import 'data/users_cache.dart';
import 'domain/user_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // The commented line from Practice 13 is now a const switch: Env.useFakes
  // is known at compile time, so only one branch ends up in the binary.
  UserRepository buildRepository(String host) => Env.useFakes
      ? FakeUserRepository()
      : HttpUserRepository(
          ApiClient(http.Client(), host: host),
          cache: UsersCache(prefs),
        );

  runApp(
    ChangeNotifierProvider(
      create: (_) => DevHostSetting(prefs),
      child: UsersApp(buildRepository: buildRepository),
    ),
  );
}
