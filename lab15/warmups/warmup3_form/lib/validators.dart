// Validation rules as plain functions: no widgets, so a unit test can call
// them directly. A FormField validator returns null for "valid".

String? validateName(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Enter a name';
  if (v.length < 2) return 'At least 2 characters';
  return null;
}

final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? validateEmail(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Enter an email';
  if (!_email.hasMatch(v)) return 'Not a valid email';
  return null;
}
