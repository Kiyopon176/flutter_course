import 'package:flutter/material.dart';
import 'package:users_api/helpers.dart';
import 'package:users_api/features/users/user.dart';

class UserTile extends StatelessWidget {
  const UserTile({super.key, required this.user, this.onTap});

  final User user;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text(initialsOf(user.name))),
      title: Text(user.name),
      subtitle: Text('${user.email} · ${user.address.city}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
