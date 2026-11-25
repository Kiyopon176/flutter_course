import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:users_api/features/users/user.dart';

import 'fixtures.dart';

Map<String, dynamic> _json(String s) => jsonDecode(s) as Map<String, dynamic>;

void main() {
  test('fromJson reads the real JSON of user 1', () {
    final u = User.fromJson(_json(user1Json));
    expect(u.id, 1);
    expect(u.name, 'Leanne Graham');
    expect(u.address.city, 'Gwenborough');
    expect(u.address.geo.lat, -37.3159);
    expect(u.address.geo.lng, 81.1496);
    expect(u.company.name, 'Romaguera-Crona');
    expect(u.website, 'hildegard.org');
  });

  test('round trip: fromJson(toJson()) is equal and has the same shape', () {
    final u = User.fromJson(_json(user1Json));
    final back = User.fromJson(u.toJson());
    expect(back, u);
    // Same shape as the server sent, minus company.bs which we do not model.
    final expected = _json(user1Json);
    (expected['company'] as Map).remove('bs');
    expect(u.toJson(), expected);
  });

  test('website is the only optional field', () {
    final m = _json(user1Json)..remove('website');
    expect(User.fromJson(m).website, isNull);
  });

  test('phoneDigits keeps only digits and +', () {
    final u = User.fromJson(_json(user1Json));
    expect(u.phoneDigits, '1770736803156442');
  });

  test('a lying cast names the field: id as a string', () {
    final m = _json(user1Json)..['id'] = '1';
    expect(() => User.fromJson(m), throwsA(isA<TypeError>()));
  });

  test('lat that is not a number fails in double.parse', () {
    final m = _json(user1Json);
    ((m['address'] as Map)['geo'] as Map)['lat'] = 'north';
    expect(() => User.fromJson(m), throwsFormatException);
  });
}
