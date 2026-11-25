import 'package:users_api/core/api/api_exception.dart';
import 'package:users_api/features/users/user.dart';
import 'package:users_api/features/users/user_repository.dart';
import 'package:users_api/features/users/users_result.dart';

/// A [UserRepository] with no network: two users written in Dart.
///
/// Lives in lib/ so main.dart can switch to it for a demo mode;
/// test/fakes/fake_user_repository.dart re-exports it for the tests.
class FakeUserRepository implements UserRepository {
  FakeUserRepository({this.fail = false, this.delay = Duration.zero});

  /// When true every call throws [NoConnectionException].
  final bool fail;

  /// Simulated latency. Zero means "no timer at all" — safe in widget tests.
  final Duration delay;

  int _nextId = 11;

  // The first two users of jsonplaceholder.typicode.com/users, as Dart maps.
  static const List<Map<String, dynamic>> _json = [
    {
      'id': 1,
      'name': 'Leanne Graham',
      'username': 'Bret',
      'email': 'Sincere@april.biz',
      'address': {
        'street': 'Kulas Light',
        'suite': 'Apt. 556',
        'city': 'Gwenborough',
        'zipcode': '92998-3874',
        'geo': {'lat': -37.3159, 'lng': '81.1496'}, // planted: a number
      },
      'phone': '1-770-736-8031 x56442',
      'website': 'hildegard.org',
    },
    {
      'id': 2,
      'name': 'Ervin Howell',
      'username': 'Antonette',
      'email': 'Shanna@melissa.tv',
      'address': {
        'street': 'Victor Plains',
        'suite': 'Suite 879',
        'city': 'Wisokyburgh',
        'zipcode': '90566-7771',
        'geo': {'lat': '-43.9509', 'lng': '-34.4618'},
      },
      'phone': '010-692-6593 x09125',
      'website': 'anastasia.net',
    },
  ];

  Future<void> _call() async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    if (fail) throw const NoConnectionException();
  }

  @override
  Future<UsersResult> getAll() async {
    await _call();
    return UsersResult(_json.map(User.fromJson).toList());
  }

  @override
  Future<User> getById(int id) async {
    await _call();
    final json = _json.where((u) => u['id'] == id).firstOrNull;
    if (json == null) throw NotFoundException('/users/$id');
    return User.fromJson(json);
  }

  @override
  Future<User> create(User draft) async {
    await _call();
    return User.fromJson({...draft.toJson(), 'id': _nextId++});
  }
}
