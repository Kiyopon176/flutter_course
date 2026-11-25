import 'package:flutter_test/flutter_test.dart';
import 'package:users_api/core/api/api_exception.dart';
import 'package:users_api/features/users/users_model.dart';

import '../../fakes/fake_user_repository.dart';

void main() {
  group('UsersModel.load', () {
    test('load → items from the repository', () async {
      final model = UsersModel(FakeUserRepository());

      await model.load();

      expect(model.items, hasLength(2));
      expect(model.loading, isFalse);
      expect(model.error, isNull);
    });

    test('load → NoConnection sets error', () async {
      final model = UsersModel(FakeUserRepository(fail: true));

      await model.load();

      expect(model.error, isA<NoConnectionException>());
      expect(model.loading, isFalse);
    });
  });

  group('UsersModel.setQuery', () {
    test('filters by name or by city, case-insensitive', () async {
      final model = UsersModel(FakeUserRepository());
      await model.load();

      model.setQuery('wisoky');

      expect(model.items.single.name, 'Ervin Howell');
      expect(model.total, 2);
    });
  });
}
