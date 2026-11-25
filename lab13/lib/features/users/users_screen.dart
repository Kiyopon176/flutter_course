import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users_api/add_user_dialog.dart';
import 'package:users_api/core/api/api_exception.dart';
import 'package:users_api/offline_banner.dart';
import 'package:users_api/profile_screen.dart';
import 'package:users_api/settings_screen.dart';
import 'package:users_api/features/users/user.dart';
import 'package:users_api/features/users/user_detail_screen.dart';
import 'package:users_api/features/users/widgets/user_tile.dart';
import 'package:users_api/features/users/users_model.dart';
import 'package:users_api/utils.dart';

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
      body = _buildError(error, model.load);
    } else if (items.isEmpty) {
      body = _buildEmpty(model.query);
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
          _buildHeader(context, model),
          _buildFilterRow(model),
          const SizedBox(height: 8),
          Expanded(child: body),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UsersModel model) {
    final shown = model.items.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text('Directory', style: Theme.of(context).textTheme.titleLarge),
          const Spacer(),
          Text(
            model.query.isEmpty
                ? '${model.total} users'
                : '$shown of ${model.total}',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(UsersModel model) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search by name or city',
                isDense: true,
              ),
              onChanged: model.setQuery,
            ),
          ),
          IconButton(
            tooltip: 'Reload',
            icon: const Icon(Icons.refresh),
            onPressed: model.loading ? null : model.load,
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(String query) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off, size: 48),
          const SizedBox(height: 12),
          Text(query.isEmpty ? 'No users yet' : 'Nobody matches "$query"'),
        ],
      ),
    );
  }

  Widget _buildError(ApiException error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48),
            const SizedBox(height: 12),
            Text(describeError(error), style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
