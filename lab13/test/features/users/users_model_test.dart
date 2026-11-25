import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:users_api/core/api/api_client.dart';
import 'package:users_api/core/api/api_exception.dart';
import 'package:users_api/core/api/describe_error.dart';
import 'package:users_api/features/users/user_repository.dart';
import 'package:users_api/features/users/users_cache.dart';
import 'package:users_api/features/users/users_model.dart';

import '../../fakes/fake_user_repository.dart';
import '../../fixtures/users_json.dart';

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

  group('UsersModel with a server that broke the contract', () {
    test(
      '"lat" as a number → error is BadResponseException, no crash',
      () async {
        final broken = usersJson.replaceFirst('"-37.3159"', '-37.3159');
        final api = ApiClient(
          client: MockClient((_) async => http.Response(broken, 200)),
        );
        final model = UsersModel(HttpUserRepository(api, UsersCache()));

        await model.load();

        expect(model.error, isA<BadResponseException>());
        expect(describeError(model.error!), 'Something went wrong');
        expect(model.loading, isFalse);
      },
    );
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
