import '../domain/user.dart';
import '../domain/user_repository.dart';

/// USE_FAKES=true: two users, no network, instant.
class FakeUserRepository implements UserRepository {
  static const users = [
    User(
      id: 1,
      name: 'Leanne Graham',
      username: 'Bret',
      email: 'leanne@fake.local',
      city: 'Gwenborough',
      company: 'Romaguera-Crona',
    ),
    User(
      id: 2,
      name: 'Ervin Howell',
      username: 'Antonette',
      email: 'ervin@fake.local',
      city: 'Wisokyburgh',
      company: 'Deckow-Crist',
    ),
  ];

  @override
  Future<UsersPage> fetchUsers() async => const UsersPage(users);
}
