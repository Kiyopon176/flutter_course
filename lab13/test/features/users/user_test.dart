import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:users_api/features/users/user.dart';

import '../../fixtures/users_json.dart';

Map<String, dynamic> decode(String s) => jsonDecode(s) as Map<String, dynamic>;

void main() {
  group('User.fromJson', () {
    test('parses the real JSON of user 1', () {
      final json = decode(user1Json);

      final user = User.fromJson(json);

      expect(user.name, 'Leanne Graham');
      expect(user.address.city, 'Gwenborough');
      expect(user.address.geo.lat, isA<double>());
      expect(user.address.geo.lat, -37.3159);
    });

    test('"id": "1" (a string) throws TypeError — the cast is a claim', () {
      final json = decode(user1Json.replaceFirst('"id": 1', '"id": "1"'));

      expect(() => User.fromJson(json), throwsA(isA<TypeError>()));
    });
  });

  group('Geo.fromJson', () {
    // The planted bug from the trace: "lat": -37.3159 (a number, not a string).
    // #0 Geo.fromJson (user.dart:102:35) is where the claim `as String` fails.
    test('"lat" as a number throws TypeError', () {
      final json = <String, dynamic>{'lat': -37.3159, 'lng': '81.1496'};

      expect(() => Geo.fromJson(json), throwsA(isA<TypeError>()));
    });
  });
}
