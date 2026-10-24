import 'package:flutter/material.dart';

import '../data/seed.dart';
import '../models/event.dart';
import '../routes.dart';
import '../widgets/confirm_dialog.dart';
import 'favourites_tab.dart';
import 'list_tab.dart';
import 'profile_tab.dart';

class Shell extends StatefulWidget {
  const Shell({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  static const List<String> _titles = ['Events', 'Favourites', 'Profile'];

  List<Event> _events = seedEvents();
  Profile _profile = const Profile.empty();
  int _index = 0;

  void _save(Event event) {
    final exists = _events.any((e) => e.id == event.id);
    final next = exists
        ? _events.map((e) => e.id == event.id ? event : e).toList()
        : [..._events, event];
    setState(() => _events = next);
  }

  void _delete(Event event) {
    final next = _events.where((e) => e.id != event.id).toList();
    setState(() => _events = next);
  }

  void _setProfile(Profile profile) => setState(() => _profile = profile);

  void _selectTab(int index) => setState(() => _index = index);

  /// Used by tabs and pushed screens: close everything above the shell first.
  void _showTab(int index) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    _selectTab(index);
  }

  Future<void> _addEvent() async {
    final created = await Navigator.pushNamed<Event>(
      context,
      Routes.form,
      arguments: const FormArgs(),
    );
    if (created == null || !mounted) return;
    _save(created);
  }

  Future<void> _showAbout() {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('About'),
        content: const Text(
          'Campus Events — browse events, register and keep track of '
          'your favourites. All data lives in memory.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset() async {
    final ok = await confirmDialog(
      context,
      title: 'Reset data?',
      message: 'This restores the sample events and clears your profile.',
      confirmLabel: 'Reset',
    );
    if (ok != true || !mounted) return;
    final seed = seedEvents();
    setState(() {
      _events = seed;
      _profile = const Profile.empty();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index])),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                onTap: () {
                  Navigator.pop(context);
                  _showAbout();
                },
              ),
              ListTile(
                leading: const Icon(Icons.restart_alt),
                title: const Text('Reset data'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmReset();
                },
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _index,
        children: [
          ListTab(
            events: _events,
            userName: _profile.name,
            onChanged: _save,
            onDelete: _delete,
            onSwitchTab: _showTab,
            onAdd: _addEvent,
          ),
          FavouritesTab(
            events: _events,
            userName: _profile.name,
            onChanged: _save,
            onDelete: _delete,
            onSwitchTab: _showTab,
          ),
          ProfileTab(
            profile: _profile,
            events: _events,
            themeMode: widget.themeMode,
            onProfileChanged: _setProfile,
            onThemeChanged: widget.onThemeChanged,
          ),
        ],
      ),
      floatingActionButton: _index == 0
          ? FloatingActionButton(
              onPressed: _addEvent,
              tooltip: 'New event',
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.event), label: 'Events'),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
