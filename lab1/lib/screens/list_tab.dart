import 'package:flutter/material.dart';

import '../models/event.dart';
import '../routes.dart';
import '../widgets/empty_state.dart';
import '../widgets/event_collection.dart';

class ListTab extends StatefulWidget {
  const ListTab({
    super.key,
    required this.events,
    required this.userName,
    required this.onChanged,
    required this.onDelete,
    required this.onSwitchTab,
    required this.onAdd,
  });

  final List<Event> events;
  final String userName;
  final ValueChanged<Event> onChanged;
  final ValueChanged<Event> onDelete;
  final ValueChanged<int> onSwitchTab;
  final VoidCallback onAdd;

  @override
  State<ListTab> createState() => _ListTabState();
}

class _ListTabState extends State<ListTab> {
  final TextEditingController _search = TextEditingController();
  String _query = '';
  EventCategory? _category;
  bool _showPast = true;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _clearFilters() {
    _search.clear();
    setState(() {
      _query = '';
      _category = null;
      _showPast = true;
    });
  }

  void _open(Event event) {
    openDetail(
      context,
      event: event,
      userName: widget.userName,
      onChanged: widget.onChanged,
      onDelete: widget.onDelete,
      onSwitchTab: widget.onSwitchTab,
    );
  }

  void _toggleFavourite(Event event) =>
      widget.onChanged(event.copyWith(favourite: !event.favourite));

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final visible = sortedByDate(
      widget.events.where(
        (e) =>
            (_category == null || e.category == _category) &&
            (_showPast || !e.isPast) &&
            (query.isEmpty || e.title.toLowerCase().contains(query)),
      ),
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            controller: _search,
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Search events',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear',
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _search.clear();
                        setState(() => _query = '');
                      },
                    ),
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              FilterChip(
                label: const Text('Past'),
                selected: _showPast,
                onSelected: (value) => setState(() => _showPast = value),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('All'),
                selected: _category == null,
                onSelected: (_) => setState(() => _category = null),
              ),
              for (final category in EventCategory.values) ...[
                const SizedBox(width: 8),
                ChoiceChip(
                  avatar: Icon(category.icon),
                  label: Text(category.label),
                  selected: _category == category,
                  onSelected: (_) => setState(() => _category = category),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? (widget.events.isEmpty
                    ? EmptyState(
                        icon: Icons.event_busy,
                        message: 'No events yet',
                        actionLabel: 'Add event',
                        onAction: widget.onAdd,
                      )
                    : EmptyState(
                        icon: Icons.search_off,
                        message: 'No events match your search',
                        actionLabel: 'Clear filters',
                        onAction: _clearFilters,
                      ))
              : EventCollection(
                  events: visible,
                  onOpen: _open,
                  onToggleFavourite: _toggleFavourite,
                ),
        ),
      ],
    );
  }
}
