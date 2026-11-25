import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/widgets/state_views.dart';
import 'new_user_screen.dart';
import 'user.dart';
import 'user_detail_screen.dart';
import 'users_model.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: const _UsersBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const NewUserScreen())),
        icon: const Icon(Icons.person_add),
        label: const Text('New user'),
      ),
    );
  }
}

class _UsersBody extends StatelessWidget {
  const _UsersBody();

  @override
  Widget build(BuildContext context) {
    final m = context.watch<UsersModel>();
    // While pull-to-refresh is running the list stays on screen and the
    // RefreshIndicator shows its own spinner.
    if (m.loading && m.items.isEmpty) return const LoadingView();

    // Exhaustive: ApiException is sealed, so there is no default.
    return switch (m.error) {
      null => UserList(m.items, onRefresh: m.load),
      NoConnectionException() => Offline(onRetry: m.load),
      NotFoundException() => const MessageView(
        icon: Icons.search_off,
        title: 'Not found',
      ),
      UnauthorizedException() => const MessageView(
        icon: Icons.lock_outline,
        title: 'Sign in required',
      ),
      ServerException(:final status) => ServerError(status, onRetry: m.load),
      BadResponseException() => const GenericError(),
    };
  }
}

class UserList extends StatelessWidget {
  const UserList(this.users, {super.key, required this.onRefresh});

  final List<User> users;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: users.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final u = users[i];
          return ListTile(
            leading: CircleAvatar(child: Text(u.name.characters.first)),
            title: Text(u.name),
            subtitle: Text('${u.email} · ${u.address.city}'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => UserDetailScreen(u)),
            ),
          );
        },
      ),
    );
  }
}
