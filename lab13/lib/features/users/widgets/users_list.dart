import 'package:flutter/material.dart';
import 'package:users_api/features/users/user.dart';
import 'package:users_api/features/users/user_detail_screen.dart';
import 'package:users_api/features/users/widgets/user_tile.dart';

/// The list itself; a tap opens the detail screen.
class UsersList extends StatelessWidget {
  const UsersList({super.key, required this.users});

  final List<User> users;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: users.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) => UserTile(
        user: users[i],
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => UserDetailScreen(user: users[i]),
          ),
        ),
      ),
    );
  }
}
