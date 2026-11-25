import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/api/api_client.dart';
import 'dev/smoke.dart';
import 'features/users/user_repository.dart';
import 'features/users/users_model.dart';

/// The composition root: the only file that says `http.Client()`.
Future<void> main() async {
  final repo = UserRepository(ApiClient(http.Client()));

  if (const bool.fromEnvironment('SMOKE')) await smoke(repo);

  runApp(
    ChangeNotifierProvider(
      create: (_) => UsersModel(repo)..load(),
      child: const App(),
    ),
  );
}
