import 'package:flutter/material.dart';

import '../models/event.dart';
import '../routes.dart';
import '../widgets/empty_state.dart';
import '../widgets/event_collection.dart';

class FavouritesTab extends StatelessWidget {
  const FavouritesTab({
    super.key,
    required this.events,
    required this.userName,
    required this.onChanged,
    required this.onDelete,
    required this.onSwitchTab,
  });

  final List<Event> events;
  final String userName;
  final ValueChanged<Event> onChanged;
  final ValueChanged<Event> onDelete;
  final ValueChanged<int> onSwitchTab;

  @override
  Widget build(BuildContext context) {
    final favourites = sortedByDate(events.where((e) => e.favourite));
    if (favourites.isEmpty) {
      return EmptyState(
        icon: Icons.favorite_border,
        message: 'No favourites yet',
        actionLabel: 'Browse events',
        onAction: () => onSwitchTab(0),
      );
    }
    return EventCollection(
      events: favourites,
      onOpen: (event) => openDetail(
        context,
        event: event,
        userName: userName,
        onChanged: onChanged,
        onDelete: onDelete,
        onSwitchTab: onSwitchTab,
      ),
      onToggleFavourite: (event) =>
          onChanged(event.copyWith(favourite: !event.favourite)),
    );
  }
}
