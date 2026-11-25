import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'items_model.dart';
import 'items_repository.dart';

/// Warm-up 2 (20 min): a list from a fake repository that fails on demand.
/// loading · error with Retry · empty · data — four branches in one switch.
void main() {
  final repo = FakeItemsRepository();
  runApp(ItemsApp(repo: repo));
}

class ItemsApp extends StatelessWidget {
  const ItemsApp({super.key, required this.repo});

  final FakeItemsRepository repo;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ItemsModel(repo)..load(),
      child: MaterialApp(
        title: 'Warm-up 2',
        theme: ThemeData(colorSchemeSeed: Colors.teal),
        home: ItemsScreen(repo: repo),
      ),
    );
  }
}

class ItemsScreen extends StatelessWidget {
  const ItemsScreen({super.key, required this.repo});

  /// Only for the demo menu ("fail next" / "empty next").
  final FakeItemsRepository repo;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ItemsModel>().state;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cities'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'fail') repo.failNext = true;
              if (v == 'empty') repo.emptyNext = true;
              context.read<ItemsModel>().load();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'fail', child: Text('Reload → fail')),
              PopupMenuItem(value: 'empty', child: Text('Reload → empty')),
            ],
          ),
        ],
      ),
      body: switch (state) {
        Loading() => const Center(child: CircularProgressIndicator()),
        Failed(:final message) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 48),
              const SizedBox(height: 8),
              Text(message),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => context.read<ItemsModel>().load(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        Empty() => const Center(child: Text('Nothing here yet')),
        Loaded(:final items) => ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, i) => ListTile(
            leading: CircleAvatar(child: Text(items[i][0])),
            title: Text(items[i]),
          ),
        ),
      },
    );
  }
}
