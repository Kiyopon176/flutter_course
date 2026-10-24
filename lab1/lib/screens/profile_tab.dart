import 'package:flutter/material.dart';

import '../models/event.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.events,
    required this.themeMode,
    required this.onProfileChanged,
    required this.onThemeChanged,
  });

  final Profile profile;
  final List<Event> events;
  final ThemeMode themeMode;
  final ValueChanged<Profile> onProfileChanged;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  static final RegExp _groupPattern = RegExp(r'^[A-Za-z]{2,5}-\d{2,4}$');

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _group;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profile.name);
    _group = TextEditingController(text: widget.profile.group);
  }

  @override
  void didUpdateWidget(ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The model changed from outside (Reset data): follow it.
    if (widget.profile.name != oldWidget.profile.name &&
        widget.profile.name != _name.text.trim()) {
      _name.text = widget.profile.name;
    }
    if (widget.profile.group != oldWidget.profile.group &&
        widget.profile.group != _group.text.trim()) {
      _group.text = widget.profile.group;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _group.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final text = value?.trim() ?? '';
    return text.length > 30 ? 'At most 30 characters' : null;
  }

  String? _validateGroup(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty || _groupPattern.hasMatch(text)) return null;
    return 'Use a format like CS-101';
  }

  void _submit([String? _]) {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    widget.onProfileChanged(
      Profile(name: _name.text.trim(), group: _group.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lists = widget.events
        .where((e) => e.contains(widget.profile.name))
        .length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              TextFormField(
                controller: _name,
                validator: _validateName,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: _submit,
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                decoration: const InputDecoration(
                  labelText: 'Your name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _group,
                validator: _validateGroup,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: _submit,
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                decoration: const InputDecoration(
                  labelText: 'Group',
                  hintText: 'CS-101',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          lists == 1 ? 'You are on 1 list' : 'You are on $lists lists',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 24),
        Text('Theme', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final mode in ThemeMode.values)
              ChoiceChip(
                label: Text(switch (mode) {
                  ThemeMode.system => 'System',
                  ThemeMode.light => 'Light',
                  ThemeMode.dark => 'Dark',
                }),
                selected: widget.themeMode == mode,
                onSelected: (_) => widget.onThemeChanged(mode),
              ),
          ],
        ),
      ],
    );
  }
}
