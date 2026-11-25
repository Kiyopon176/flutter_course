import 'package:flutter/material.dart';

/// Nothing to show: either no users at all or the filter matched nobody.
class EmptyView extends StatelessWidget {
  const EmptyView({super.key, this.query = ''});

  final String query;

  @override
  Widget build(BuildContext context) {
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
}
