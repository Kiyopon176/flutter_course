import 'package:flutter/material.dart';

class OfflineView extends StatelessWidget {
  const OfflineView({
    super.key,
    required this.host,
    required this.reason,
    required this.onRetry,
  });

  final String host;
  final String reason;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 72, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text("You're offline", style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Cannot reach $host and there is no saved list yet.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              reason,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
