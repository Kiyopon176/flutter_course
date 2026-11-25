# users_api — Practice 13: Where Things Go

The users app from Practices 11–12 (jsonplaceholder users, login, settings, profile),
refactored so that every file has a place, every model has a seam, and every rule has a test.
Nothing new appears on the screen.

**Dependencies point down:** screens watch models → models use repositories →
repositories touch the world. Never up.

## Tree

```
lib/
  main.dart                          composition root: the only HttpUserRepository(...)
  core/
    api/api_client.dart              http.Client, host, _send, _check, _decode
    api/api_exception.dart           the sealed hierarchy
    api/describe_error.dart          ApiException -> text for the user
    format/initials.dart
    storage/secure_store.dart
  features/
    users/
      user.dart                      User, Address, Geo + fromJson / toJson
      user_parsing.dart              JSON -> User; TypeError -> BadResponseException
      user_repository.dart           interface + HttpUserRepository
      fake_user_repository.dart      FakeUserRepository (demo mode + tests)
      users_cache.dart  users_result.dart
      users_model.dart               ChangeNotifier: loading / error / items
      users_screen.dart  user_detail_screen.dart
      widgets/  users_header  users_filter_row  empty_view  error_view
                users_list  user_tile  offline_banner  add_user_dialog
    auth/      auth_model.dart  login_screen.dart
    settings/  settings_model.dart  settings_screen.dart
    profile/   profile_screen.dart
test/
  features/users/user_test.dart  users_model_test.dart
  features/users/user_repository_test.dart  users_screen_test.dart
  fakes/fake_user_repository.dart    re-exports the fake from lib/
  fixtures/users_json.dart           real JSON of users 1 and 2, as strings
tool/
  check_layers.sh                    the layer rule (prints nothing when it holds)
  build_lengths.sh                   any build() over 60 lines
```

## Run

```bash
flutter pub get
flutter run                 # real API
flutter test                # 15 tests, offline, ~3 s
bash tool/check_layers.sh   # run before every commit
```

Demo mode (no network, two users): in `lib/main.dart` swap the `HttpUserRepository`
line with the commented `FakeUserRepository()` line.

The story of the refactor is in `git log --oneline -- lab13`; the trace, the
break-it-on-purpose outputs and the answers are in [NOTES.md](NOTES.md).

## Quality checklist

```
$ flutter analyze
Analyzing lab13...
No issues found! (ran in 5.6s)

$ dart format .
Formatted 34 files (0 changed) in 0.18 seconds.

$ flutter test
00:03 +15: All tests passed!

$ tool/check_layers.sh
(nothing — exit 0)
```
