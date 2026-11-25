import '../domain/user.dart';

User userFromJson(Map<String, dynamic> j) => User(
  id: j['id'] as int,
  name: j['name'] as String? ?? '',
  username: j['username'] as String? ?? '',
  email: j['email'] as String? ?? '',
  city: (j['address'] as Map<String, dynamic>?)?['city'] as String? ?? '',
  company: (j['company'] as Map<String, dynamic>?)?['name'] as String? ?? '',
);

Map<String, dynamic> userToJson(User u) => {
  'id': u.id,
  'name': u.name,
  'username': u.username,
  'email': u.email,
  'address': {'city': u.city},
  'company': {'name': u.company},
};
