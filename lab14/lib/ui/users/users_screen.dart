import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/user.dart';
import '../settings/settings_screen.dart';
import 'offline_view.dart';
import 'users_view_model.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UsersViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: switch (vm.state) {
        UsersLoading() => const Center(child: CircularProgressIndicator()),
        UsersOffline(:final host, :final reason) => OfflineView(
          host: host,
          reason: reason,
          onRetry: vm.load,
        ),
        UsersFailed(:final message) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(onPressed: vm.load, child: const Text('Retry')),
              ],
            ),
          ),
        ),
        UsersLoaded(:final page) => RefreshIndicator(
          onRefresh: vm.load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              if (page.fromCache) _CachedBanner(at: page.cachedAt!),
              for (final u in page.users) _UserTile(user: u),
            ],
          ),
        ),
      },
    );
  }
}

class _CachedBanner extends StatelessWidget {
  const _CachedBanner({required this.at});
  final DateTime at;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final time = TimeOfDay.fromDateTime(at.toLocal()).format(context);
    return Container(
      color: scheme.tertiaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(Icons.cloud_off, size: 18, color: scheme.onTertiaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Offline — showing the list saved at $time',
              style: TextStyle(color: scheme.onTertiaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user});
  final User user;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      user.email,
      if (user.city.isNotEmpty) user.city,
    ].join(' · ');
    return ListTile(
      leading: CircleAvatar(child: Text(user.initials)),
      title: Text(user.name),
      subtitle: Text(subtitle),
    );
  }
}
