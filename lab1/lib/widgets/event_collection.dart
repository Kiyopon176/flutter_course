import 'package:flutter/material.dart';

import '../models/event.dart';
import 'event_card.dart';

/// A list on phones, a grid on wide layouts — decided by the space we get.
class EventCollection extends StatelessWidget {
  const EventCollection({
    super.key,
    required this.events,
    required this.onOpen,
    required this.onToggleFavourite,
  });

  final List<Event> events;
  final ValueChanged<Event> onOpen;
  final ValueChanged<Event> onToggleFavourite;

  Widget _card(Event e) => EventCard(
    event: e,
    onTap: () => onOpen(e),
    onToggleFavourite: () => onToggleFavourite(e),
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 360,
              mainAxisExtent: 144,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: events.length,
            itemBuilder: (_, i) => _card(events[i]),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: events.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (_, i) => _card(events[i]),
        );
      },
    );
  }
}
