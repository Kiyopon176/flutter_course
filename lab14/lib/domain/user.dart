class User {
  const User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.city = '',
    this.company = '',
  });

  final int id;
  final String name;
  final String username;
  final String email;
  final String city;
  final String company;

  String get initials {
    final parts = name.split(' ').where((p) => p.isNotEmpty).take(2);
    return parts.map((p) => p[0].toUpperCase()).join();
  }
}
