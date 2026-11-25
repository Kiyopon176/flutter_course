import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users_api/core/api/describe_error.dart';
import 'package:users_api/features/profile/profile_screen.dart';
import 'package:users_api/features/settings/settings_screen.dart';
import 'package:users_api/features/users/user.dart';
import 'package:users_api/features/users/users_model.dart';
import 'package:users_api/features/users/widgets/add_user_dialog.dart';
import 'package:users_api/features/users/widgets/empty_view.dart';
import 'package:users_api/features/users/widgets/error_view.dart';
import 'package:users_api/features/users/widgets/offline_banner.dart';
import 'package:users_api/features/users/widgets/users_filter_row.dart';
import 'package:users_api/features/users/widgets/users_header.dart';
import 'package:users_api/features/users/widgets/users_list.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<UsersModel>();
    final error = model.error;
    final items = model.items;

    final Widget body;
    if (model.loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (error != null) {
      body = ErrorView(message: describeError(error), onRetry: model.load);
    } else if (items.isEmpty) {
      body = EmptyView(query: model.query);
    } else {
      body = UsersList(users: items);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.person),
            onPressed: () => _open(context, const ProfileScreen()),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: () => _open(context, const SettingsScreen()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add user',
        onPressed: () => _addUser(context, model),
        child: const Icon(Icons.person_add),
      ),
      body: Column(
        children: [
          if (model.fromCache) const OfflineBanner(),
          UsersHeader(
            total: model.total,
            shown: items.length,
            filtered: model.query.isNotEmpty,
          ),
          UsersFilterRow(
            onQueryChanged: model.setQuery,
            onReload: model.loading ? null : model.load,
          ),
          const SizedBox(height: 8),
          Expanded(child: body),
        ],
      ),
    );
  }

  void _open(BuildContext context, Widget screen) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => screen));

  Future<void> _addUser(BuildContext context, UsersModel model) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const AddUserDialog(),
    );
    if (name != null) await model.add(User.draft(name));
  }
}
