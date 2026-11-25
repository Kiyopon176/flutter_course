// Grab-bag of things that did not have a home yet.

const apiHost = 'jsonplaceholder.typicode.com';

String initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  return parts.take(2).map((p) => p[0].toUpperCase()).join();
}
