import 'package:flutter/material.dart';

/// Shown above the list when the users came from the cache.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      color: scheme.tertiaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.wifi_off, size: 18, color: scheme.onTertiaryContainer),
          const SizedBox(width: 8),
          Text(
            'Offline — showing saved users',
            style: TextStyle(color: scheme.onTertiaryContainer),
          ),
        ],
      ),
    );
  }
}
