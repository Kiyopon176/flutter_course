import 'package:flutter/foundation.dart';

class Student {
  const Student({required this.name, required this.group, this.gpa});

  final String name;
  final String group;
  final double? gpa;
}

class NoConnectionException implements Exception {}

const _seed = [
  Student(name: 'Aida Nurlanova', group: 'IT-2301', gpa: 3.7),
  Student(name: 'Dias Seitkali', group: 'IT-2301', gpa: 3.1),
  Student(name: 'Aruzhan Bek', group: 'IT-2302'),
  Student(name: 'Timur Alibekov', group: 'IT-2302', gpa: 2.9),
  Student(name: 'Dana Omarova', group: 'IT-2303', gpa: 3.9),
  Student(name: 'Alikhan Kairatuly', group: 'IT-2303', gpa: 3.4),
];

// Level 1: the API that does not exist yet. It must feel like a
// network: slow, and sometimes down.
class FakeApi {
  FakeApi({this.empty = false});

  final bool empty; // true -> the server has no students
  int calls = 0; // how many times fetchStudents() ran
  // How many times save() ran. Static = "server-side": every screen creates
  // its own FakeApi, and a successful save pops the screen, so a per-instance
  // counter would never reach its second (failing) call.
  static int saveCalls = 0;

  Future<List<Student>> fetchStudents() async {
    // Remember THIS call's number before the await: the line after await
    // runs later, and by then other calls may have bumped `calls` too.
    final n = ++calls;
    debugPrint('fetchStudents #$n');
    await Future.delayed(const Duration(seconds: 2));
    if (n % 3 == 0) throw NoConnectionException();
    return empty ? const [] : _seed;
  }

  Future<void> save(int value) async {
    final n = ++saveCalls;
    await Future.delayed(const Duration(seconds: 1));
    if (n % 2 == 0) throw StateError('server rejected $value');
  }
}
