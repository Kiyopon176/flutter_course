import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/event.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/confirm_dialog.dart';

typedef _Snapshot = (
  String,
  EventCategory?,
  DateTime?,
  TimeOfDay?,
  String,
  bool,
  String,
  String,
);

class FormScreen extends StatefulWidget {
  const FormScreen({super.key, required this.args});

  final FormArgs args;

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final Event? _editing = widget.args.event;
  late final TextEditingController _title;
  late final TextEditingController _capacity;
  late final TextEditingController _location;
  late final TextEditingController _description;
  late final TextEditingController _dateText;
  late final TextEditingController _timeText;
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _capacityFocus = FocusNode();
  final FocusNode _locationFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();

  EventCategory? _category;
  DateTime? _date;
  TimeOfDay? _time;
  late bool _online;
  late final _Snapshot _initial;

  bool _dirty = false;
  bool _saving = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    final base = _editing ?? Event.empty();
    _title = TextEditingController(text: base.title);
    _capacity = TextEditingController(text: base.capacity.toString());
    _location = TextEditingController(text: base.location);
    _description = TextEditingController(text: base.description ?? '');
    _dateText = TextEditingController();
    _timeText = TextEditingController();
    _online = base.online;
    if (_editing != null) {
      _category = base.category;
      _date = DateTime(base.starts.year, base.starts.month, base.starts.day);
      _time = TimeOfDay.fromDateTime(base.starts);
      _dateText.text = formatDate(base.starts);
      _timeText.text = formatTime(base.starts.hour, base.starts.minute);
    }
    _initial = _snapshot();
  }

  @override
  void dispose() {
    _title.dispose();
    _capacity.dispose();
    _location.dispose();
    _description.dispose();
    _dateText.dispose();
    _timeText.dispose();
    _titleFocus.dispose();
    _capacityFocus.dispose();
    _locationFocus.dispose();
    _descriptionFocus.dispose();
    super.dispose();
  }

  _Snapshot _snapshot() => (
    _title.text,
    _category,
    _date,
    _time,
    _capacity.text,
    _online,
    _location.text,
    _description.text,
  );

  void _onChanged() {
    final dirty = _snapshot() != _initial;
    if (dirty != _dirty) setState(() => _dirty = dirty);
  }

  DateTime? get _starts {
    final date = _date;
    final time = _time;
    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _unfocus() => FocusManager.instance.primaryFocus?.unfocus();

  // ---- validators ----

  String? _validateTitle(String? value) {
    final length = value?.trim().length ?? 0;
    return length < 3 || length > 60 ? 'Title must be 3–60 characters' : null;
  }

  String? _validateCategory(EventCategory? value) =>
      value == null ? 'Choose a category' : null;

  String? _validateDate(String? _) {
    final date = _date;
    if (date == null) return 'Pick a date';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (_editing == null && date.isBefore(today)) {
      return 'Date must not be in the past';
    }
    return null;
  }

  String? _validateTime(String? _) {
    final starts = _starts;
    if (_time == null) return 'Pick a time';
    if (starts != null && _editing == null && !starts.isAfter(DateTime.now())) {
      return 'Start must be in the future';
    }
    return null;
  }

  String? _validateCapacity(String? value) {
    final n = int.tryParse(value?.trim() ?? '');
    if (n == null || n < 1 || n > 500) return 'Enter a number from 1 to 500';
    final editing = _editing;
    if (editing != null && n < editing.count) {
      return 'Not below current registrations (${editing.count})';
    }
    return null;
  }

  String? _validateLocation(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return _online ? 'Link is required' : 'Place is required';
    if (_online && !text.contains('://')) return 'Link must contain ://';
    return null;
  }

  // ---- pickers ----

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: _editing == null ? now : DateTime(now.year - 5),
      lastDate: DateTime(now.year + 3),
    );
    if (picked == null || !mounted) return;
    _dateText.text = formatDate(picked);
    setState(() => _date = picked);
    _onChanged();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (picked == null || !mounted) return;
    _timeText.text = formatTime(picked.hour, picked.minute);
    setState(() => _time = picked);
    _onChanged();
  }

  // ---- save ----

  Event _build(DateTime starts) {
    final description = _description.text.trim();
    final base = _editing ?? Event.empty();
    final category = _category ?? base.category;
    return base.copyWith(
      id: _editing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: _title.text.trim(),
      category: category,
      starts: starts,
      capacity: int.parse(_capacity.text.trim()),
      online: _online,
      location: _location.text.trim(),
      description: description,
      clearDescription: description.isEmpty,
    );
  }

  Future<void> _save() async {
    final form = _formKey.currentState;
    final starts = _starts;
    if (_saving || form == null || !form.validate() || starts == null) return;
    final item = _build(starts);
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      _saving = false;
      _saved = true;
    });
    Navigator.pop(context, item);
  }

  Future<void> _confirmDiscard(bool didPop, Object? result) async {
    if (didPop) return;
    final discard = await confirmDialog(
      context,
      title: 'Discard changes?',
      message: 'Your changes will be lost.',
      confirmLabel: 'Discard',
    );
    if (discard != true || !mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isNew = _editing == null;
    return PopScope(
      canPop: !_dirty || _saved,
      onPopInvokedWithResult: _confirmDiscard,
      child: Scaffold(
        appBar: AppBar(title: Text(isNew ? 'New event' : 'Edit event')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
            key: _formKey,
            onChanged: _onChanged,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _title,
                  focusNode: _titleFocus,
                  maxLength: 60,
                  validator: _validateTitle,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.sentences,
                  onFieldSubmitted: (_) => _capacityFocus.requestFocus(),
                  onTapOutside: (_) => _unfocus(),
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _capacity,
                  focusNode: _capacityFocus,
                  validator: _validateCapacity,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _locationFocus.requestFocus(),
                  onTapOutside: (_) => _unfocus(),
                  decoration: const InputDecoration(
                    labelText: 'Capacity',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<EventCategory>(
                  initialValue: _category,
                  validator: _validateCategory,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final c in EventCategory.values)
                      DropdownMenuItem(
                        value: c,
                        child: Row(
                          children: [
                            Icon(c.icon),
                            const SizedBox(width: 12),
                            Text(c.label),
                          ],
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    setState(() => _category = value);
                    _onChanged();
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _dateText,
                        readOnly: true,
                        validator: _validateDate,
                        onTap: _pickDate,
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          suffixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _timeText,
                        readOnly: true,
                        validator: _validateTime,
                        onTap: _pickTime,
                        decoration: const InputDecoration(
                          labelText: 'Time',
                          suffixIcon: Icon(Icons.access_time),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Online event'),
                  value: _online,
                  onChanged: (value) {
                    setState(() => _online = value ?? false);
                    _onChanged();
                  },
                ),
                TextFormField(
                  controller: _location,
                  focusNode: _locationFocus,
                  validator: _validateLocation,
                  keyboardType: _online
                      ? TextInputType.url
                      : TextInputType.text,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _descriptionFocus.requestFocus(),
                  onTapOutside: (_) => _unfocus(),
                  decoration: InputDecoration(
                    labelText: _online ? 'Link' : 'Place',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _description,
                  focusNode: _descriptionFocus,
                  minLines: 2,
                  maxLines: 4,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _unfocus(),
                  onTapOutside: (_) => _unfocus(),
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
