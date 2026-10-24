import 'package:flutter/material.dart';

import 'models/event.dart';
import 'screens/detail_screen.dart';
import 'screens/form_screen.dart';

class Routes {
  static const String home = '/';
  static const String detail = '/detail';
  static const String form = '/form';
}

class DetailArgs {
  const DetailArgs({
    required this.event,
    required this.userName,
    required this.onChanged,
    required this.onDelete,
    required this.onSwitchTab,
  });

  final Event event;
  final String userName;
  final ValueChanged<Event> onChanged;
  final ValueChanged<Event> onDelete;
  final ValueChanged<int> onSwitchTab;
}

class FormArgs {
  const FormArgs({this.event});

  final Event? event;
}

Future<void> openDetail(
  BuildContext context, {
  required Event event,
  required String userName,
  required ValueChanged<Event> onChanged,
  required ValueChanged<Event> onDelete,
  required ValueChanged<int> onSwitchTab,
}) => Navigator.pushNamed(
  context,
  Routes.detail,
  arguments: DetailArgs(
    event: event,
    userName: userName,
    onChanged: onChanged,
    onDelete: onDelete,
    onSwitchTab: onSwitchTab,
  ),
);

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  final args = settings.arguments;
  switch (settings.name) {
    case Routes.detail when args is DetailArgs:
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => DetailScreen(args: args),
      );
    case Routes.form when args is FormArgs:
      return MaterialPageRoute<Event>(
        settings: settings,
        builder: (_) => FormScreen(args: args),
      );
  }
  return null;
}

Route<dynamic> onUnknownRoute(RouteSettings settings) =>
    MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Not found')),
        body: const Center(child: Text('Not found')),
      ),
    );
