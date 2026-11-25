import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users_api/features/users/widgets/add_user_dialog.dart';
import 'package:users_api/features/users/widgets/empty_view.dart';
import 'package:users_api/features/users/widgets/error_view.dart';
import 'package:users_api/features/users/widgets/offline_banner.dart';
import 'package:users_api/features/profile/profile_screen.dart';
import 'package:users_api/features/settings/settings_screen.dart';
import 'package:users_api/features/users/user.dart';
import 'package:users_api/features/users/user_detail_screen.dart';
import 'package:users_api/features/users/widgets/user_tile.dart';
import 'package:users_api/features/users/widgets/users_filter_row.dart';
import 'package:users_api/features/users/widgets/users_header.dart';
import 'package:users_api/features/users/users_model.dart';
import 'package:users_api/core/api/describe_error.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<UsersModel>();
    final error = model.error;
    final items = model.items;

    Widget body;
    if (model.loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (error != null) {
      body = ErrorView(message: describeError(error), onRetry: model.load);
    } else if (items.isEmpty) {
      body = EmptyView(query: model.query);
    } else {
      body = ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, i) => UserTile(
          user: items[i],
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => UserDetailScreen(user: items[i]),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add user',
        onPressed: () async {
          final name = await showDialog<String>(
            context: context,
            builder: (_) => const AddUserDialog(),
          );
          if (name != null) await model.add(User.draft(name));
        },
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
}
