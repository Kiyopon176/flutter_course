import 'package:flutter/material.dart';

/// "Directory · 10 users" or "Directory · 2 of 10" while a filter is on.
class UsersHeader extends StatelessWidget {
  const UsersHeader({
    super.key,
    required this.total,
    required this.shown,
    required this.filtered,
  });

  final int total;
  final int shown;
  final bool filtered;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text('Directory', style: Theme.of(context).textTheme.titleLarge),
          const Spacer(),
          Text(filtered ? '$shown of $total' : '$total users'),
        ],
      ),
    );
  }
}
