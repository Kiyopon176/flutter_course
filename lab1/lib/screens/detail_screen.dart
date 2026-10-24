import 'dart:async';

import 'package:flutter/material.dart';

import '../models/event.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state.dart';

enum _MenuAction { edit, delete }

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.args});

  final DetailArgs args;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Event _event = widget.args.event;
  DateTime _now = DateTime.now();
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      final now = DateTime.now();
      setState(() => _now = now);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _userName => widget.args.userName.trim();

  void _apply(Event event) {
    setState(() => _event = event);
    widget.args.onChanged(event);
  }

  Future<void> _register() async {
    final name = _userName;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Add your name in the profile first'),
          action: SnackBarAction(
            label: 'Profile',
            onPressed: () => widget.args.onSwitchTab(2),
          ),
        ),
      );
      return;
    }
    final ok = await confirmDialog(
      context,
      title: 'Register?',
      message: 'Register as "$name" for ${_event.title}?',
      confirmLabel: 'Register',
    );
    if (ok != true || !mounted) return;
    _apply(_event.copyWith(attendees: [..._event.attendees, name]));
  }

  void _unregister() {
    final name = _userName.toLowerCase();
    final rest = _event.attendees
        .where((a) => a.trim().toLowerCase() != name)
        .toList();
    _apply(_event.copyWith(attendees: rest));
  }

  Future<void> _edit() async {
    final updated = await Navigator.pushNamed<Event>(
      context,
      Routes.form,
      arguments: FormArgs(event: _event),
    );
    if (updated == null || !mounted) return;
    _apply(updated);
  }

  Future<void> _delete() async {
    final ok = await confirmDialog(
      context,
      title: 'Delete event?',
      message: '"${_event.title}" will be removed.',
      confirmLabel: 'Delete',
    );
    if (ok != true || !mounted) return;
    widget.args.onDelete(_event);
    Navigator.pop(context);
  }

  void _onMenu(_MenuAction action) => switch (action) {
    _MenuAction.edit => _edit(),
    _MenuAction.delete => _delete(),
  };

  @override
  Widget build(BuildContext context) {
    final joined = _event.contains(_userName);
    final VoidCallback? onPressed = joined
        ? _unregister
        : ((_event.isFull || _event.isPast) ? null : _register);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _event.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            PopupMenuButton<_MenuAction>(
              onSelected: _onMenu,
              itemBuilder: (_) => const [
                PopupMenuItem(value: _MenuAction.edit, child: Text('Edit')),
                PopupMenuItem(value: _MenuAction.delete, child: Text('Delete')),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            _Header(event: _event, now: _now),
            TabBar(
              tabs: [
                const Tab(text: 'About'),
                Tab(text: 'Names (${_event.count})'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _AboutTab(event: _event),
                  _NamesTab(event: _event, userName: _userName),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: onPressed,
              child: Text(joined ? 'Cancel registration' : 'Register'),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.event, required this.now});

  final Event event;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = event.category.color(scheme);
    return AspectRatio(
      aspectRatio: 16 / 7,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/header.png', fit: BoxFit.cover),
          Center(
            child: CircleAvatar(
              radius: 36,
              backgroundColor: scheme.surface,
              foregroundColor: color,
              child: Icon(event.category.icon, size: 40),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: _Pill(
              icon: event.category.icon,
              text: event.category.label,
              color: color,
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: _Pill(
              icon: Icons.timer_outlined,
              text: countdownLabel(event.countdownAt(now)),
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              text,
              style: theme.textTheme.labelMedium?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final (:taken, :free) = event.places;
    final description = event.description;
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.schedule),
          title: Text(formatDateTime(event.starts)),
          subtitle: const Text('Date'),
        ),
        ListTile(
          leading: Icon(event.online ? Icons.link : Icons.place),
          title: Text(event.location),
          subtitle: Text(event.online ? 'Online link' : 'Place'),
        ),
        ListTile(
          leading: const Icon(Icons.event_seat),
          title: Text('$taken of ${event.capacity} taken · $free free'),
          subtitle: const Text('Places'),
        ),
        if (description != null && description.isNotEmpty)
          ListTile(
            leading: const Icon(Icons.notes),
            title: Text(description),
            subtitle: const Text('Description'),
          ),
      ],
    );
  }
}

class _NamesTab extends StatelessWidget {
  const _NamesTab({required this.event, required this.userName});

  final Event event;
  final String userName;

  @override
  Widget build(BuildContext context) {
    final names = event.attendees;
    if (names.isEmpty) {
      return const EmptyState(
        icon: Icons.people_outline,
        message: 'Nobody has registered yet',
      );
    }
    final scheme = Theme.of(context).colorScheme;
    final me = userName.toLowerCase();
    return ListView(
      children: [
        for (final name in names)
          if (me.isNotEmpty && name.trim().toLowerCase() == me)
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('You'),
              subtitle: Text(name),
              tileColor: scheme.primaryContainer,
              textColor: scheme.onPrimaryContainer,
              iconColor: scheme.onPrimaryContainer,
            )
          else
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(name),
            ),
      ],
    );
  }
}
