import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'widgets/empty_view.dart';
import 'widgets/error_view.dart';
import 'widgets/loading_view.dart';
import 'widgets/student_list.dart';

/// Level 2: the four states by hand. Level 5: a Save button that does not
/// lose its error.
class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  List<Student>? _students; // null = not loaded yet
  Object? _error; // non-null = failed
  final _api = FakeApi();

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // initState is synchronous: start the request, do not await it.
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _students = null;
      _error = null;
    });
    try {
      final list = await _api.fetchStudents();
      if (!mounted) return; // the user may have left during the 2 seconds
      setState(() => _students = list);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  // A callback with its own BuildContext: after every await ask
  // context.mounted — the screen may already be gone.
  Future<void> _save(BuildContext context) async {
    final n = _students!.length;
    setState(() => _saving = true);
    try {
      await _api.save(n);
      if (!context.mounted) return;
      Navigator.pop(context); // pop only on success
    } on StateError catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _body() {
    if (_error != null) return ErrorView(onRetry: _load);
    final students = _students;
    if (students == null) return const LoadingView();
    if (students.isEmpty) return const EmptyView();
    return StudentList(students);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Students — by hand')),
      body: _body(),
      floatingActionButton: _students == null
          ? null
          : FloatingActionButton(
              tooltip: 'Save',
              // null while in flight: a second fast tap does nothing.
              onPressed: _saving ? null : () => _save(context),
              child: _saving
                  ? const SizedBox.square(
                      dimension: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : const Icon(Icons.save),
            ),
    );
  }
}
