import 'package:flutter/material.dart';

/// Search field + reload button. Knows nothing about UsersModel:
/// it gets two callbacks and reports what the user typed.
class UsersFilterRow extends StatelessWidget {
  const UsersFilterRow({
    super.key,
    required this.onQueryChanged,
    required this.onReload,
  });

  final ValueChanged<String> onQueryChanged;

  /// Null while loading — the button is disabled.
  final VoidCallback? onReload;

  @override
  Widget build(BuildContext context) {
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
              onChanged: onQueryChanged,
            ),
          ),
          IconButton(
            tooltip: 'Reload',
            icon: const Icon(Icons.refresh),
            onPressed: onReload,
          ),
        ],
      ),
    );
  }
}
