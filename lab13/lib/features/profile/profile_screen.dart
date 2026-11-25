import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users_api/features/auth/auth_model.dart';
import 'package:users_api/core/format/initials.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final email = context.select<AuthModel, String?>((a) => a.email) ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              child: Text(initialsOf(email.split('@').first)),
            ),
            const SizedBox(height: 12),
            Text(email, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Sign out'),
              onPressed: () async {
                final navigator = Navigator.of(context);
                await context.read<AuthModel>().logout();
                navigator.popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }
}
