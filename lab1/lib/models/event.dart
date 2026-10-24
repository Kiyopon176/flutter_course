import 'package:flutter/material.dart';

/// How long an event counts as "started" before it is "ended".
const Duration eventLength = Duration(hours: 3);

enum EventCategory {
  tech('Tech', Icons.computer),
  music('Music', Icons.music_note),
  sport('Sport', Icons.sports_soccer),
  art('Art', Icons.palette),
  career('Career', Icons.work),
  social('Social', Icons.groups);

  const EventCategory(this.label, this.icon);

  final String label;
  final IconData icon;

  Color color(ColorScheme scheme) => switch (this) {
    EventCategory.tech => scheme.primary,
    EventCategory.music => scheme.secondary,
    EventCategory.sport => scheme.tertiary,
    EventCategory.art => scheme.error,
    EventCategory.career => scheme.onPrimaryContainer,
    EventCategory.social => scheme.onSecondaryContainer,
  };
}

sealed class Countdown {
  const Countdown();
}

class Upcoming extends Countdown {
  const Upcoming(this.remaining);
  final Duration remaining;
}

class Started extends Countdown {
  const Started(this.elapsed);
  final Duration elapsed;
}

class Ended extends Countdown {
  const Ended();
}

DateTime _tomorrowNoon() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day + 1, 12);
}

@immutable
class Event {
  const Event({
    required this.id,
    required this.title,
    required this.category,
    required this.starts,
    required this.capacity,
    required List<String> attendees,
    required this.online,
    required this.location,
    this.description,
    this.favourite = false,
  }) : _attendees = attendees;

  Event.empty()
    : this(
        id: '',
        title: '',
        category: EventCategory.tech,
        starts: _tomorrowNoon(),
        capacity: 20,
        attendees: const [],
        online: false,
        location: '',
      );

  final String id;
  final String title;
  final EventCategory category;
  final DateTime starts;
  final int capacity;
  final bool online;
  final String location;
  final String? description;
  final bool favourite;
  final List<String> _attendees;

  /// Read-only view: callers cannot mutate the list inside the model.
  List<String> get attendees => List.unmodifiable(_attendees);

  int get count => _attendees.length;
  int get free => (capacity - count).clamp(0, capacity);
  bool get isFull => count >= capacity;
  bool get isPast => starts.isBefore(DateTime.now());

  ({int taken, int free}) get places => (taken: count, free: free);

  bool contains(String name) {
    final wanted = name.trim().toLowerCase();
    return wanted.isNotEmpty &&
        _attendees.any((a) => a.trim().toLowerCase() == wanted);
  }

  Countdown countdownAt(DateTime now) {
    final diff = starts.difference(now);
    if (!diff.isNegative) return Upcoming(diff);
    final elapsed = -diff;
    return elapsed < eventLength ? Started(elapsed) : const Ended();
  }

  Event copyWith({
    String? id,
    String? title,
    EventCategory? category,
    DateTime? starts,
    int? capacity,
    List<String>? attendees,
    bool? online,
    String? location,
    String? description,
    bool clearDescription = false,
    bool? favourite,
  }) => Event(
    id: id ?? this.id,
    title: title ?? this.title,
    category: category ?? this.category,
    starts: starts ?? this.starts,
    capacity: capacity ?? this.capacity,
    attendees: attendees ?? _attendees,
    online: online ?? this.online,
    location: location ?? this.location,
    description: clearDescription ? null : (description ?? this.description),
    favourite: favourite ?? this.favourite,
  );
}

/// Past items go last; each group is ordered by date. Returns a new list.
List<Event> sortedByDate(Iterable<Event> events) {
  final copy = [...events];
  copy.sort((a, b) {
    if (a.isPast != b.isPast) return a.isPast ? 1 : -1;
    return a.starts.compareTo(b.starts);
  });
  return copy;
}

@immutable
class Profile {
  const Profile({required this.name, required this.group});

  const Profile.empty() : name = '', group = '';

  final String name;
  final String group;

  Profile copyWith({String? name, String? group}) =>
      Profile(name: name ?? this.name, group: group ?? this.group);
}
