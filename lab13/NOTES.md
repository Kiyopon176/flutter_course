# Practice 13 — Where Things Go · notes

The rule of the whole lab: **dependencies point down** —
screens watch models, models use repositories, repositories touch the world — never up.

## Level 1 — Feature-first, one move per commit

Before: `flutter analyze` → 3 infos (the `print`s); `flutter test` →
`Test directory "test" does not appear to contain any test files.`

Then one move per commit (`git log --oneline`): `move api_exception to core/api`,
`move users_model to features/users`, … 18 moves + 3 commits that dissolved
`utils.dart` (→ `core/api/describe_error.dart`) and `helpers.dart`
(`apiHost` → `ApiClient.defaultHost`, `initialsOf` → `core/format/initials.dart`).

**Break it on purpose.** Added `import 'package:http/http.dart' as http;` to
`users_screen.dart`:

```
$ flutter analyze        -> 0 errors (it compiles, the app runs)
$ tool/check_layers.sh
lib/features/users/users_screen.dart
(exit 1)
```

The compiler has no opinion about layers — the script does. Import removed.

Note on the grep from Level 2: `grep -rn "HttpUserRepository(" lib/` prints two lines —
the call in `main.dart` **and** the constructor declaration
`HttpUserRepository(this._api, this._cache);` in `user_repository.dart`.
So rule 3 in `tool/check_layers.sh` drops the declaration and fails on any other call site.

## Level 2 — Interfaces and fakes

Checked out the old `UsersModel` (commit `facc73d`, the one that did
`final UserRepository _repo = HttpUserRepository(ApiClient(), UsersCache());`)
and ran the new test against it:

```
error - Too many positional arguments: 0 expected, but 1 found
        - test\features\users\users_model_test.dart:27:32 - extra_positional_arguments
```

**The first line I cannot write is the arrange step:
`final model = UsersModel(FakeUserRepository(fail: true));` — the old model builds its
own repository, so there is no way to hand it one that fails; the only way to get a
NoConnection was to really switch the Wi-Fi off.**

Demo mode: in `main.dart` swap the two `repo` lines → the app runs with no network,
two users, instantly. (When swapped, the analyzer warns that `api` / `UsersCache`
are unused — expected; swap back.)

## Level 3 — Five (now 15) green tests

**Break it on purpose.** In `UsersModel.load` replaced
`on ApiException catch (e) { error = e; }` with `catch (e) {}`:

```
00:00 +1 -1: UsersModel.load load → NoConnection sets error [E]
  Expected: <Instance of 'NoConnectionException'>
    Actual: <null>
     Which: is not an instance of 'NoConnectionException'

  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test\features\users\users_model_test.dart 24:7      main.<fn>.<fn>
```

Top-down: which test → what was expected → what came → the line of the `expect`.
Restored the model, green again.

## Level 4 — Extract widgets

`UsersHeader`, `UsersFilterRow`, `EmptyView`, `ErrorView`, `UsersList` — each a
`const`-constructible `StatelessWidget` in `features/users/widgets/`.
`UsersScreen.build()` is 55 lines (`tool/build_lengths.sh --all`).

**Why a widget and not a `_buildHeader()` method:**
a widget can be `const` (skipped on rebuild) and has its own `Element` — its own rebuild scope;
it shows up by name in DevTools / "Track widget rebuilds", and it can be pumped and tested alone — a method can do none of these.

**Widget test detail.** With `FakeUserRepository(fail: true)` and *zero* delay the
spinner never appears after tapping Retry — the failing `Future` completes in
microtasks before `pump()` draws a frame:

```
Expected: exactly one matching candidate
  Actual: _TypeWidgetFinder:<Found 0 widgets with type "CircularProgressIndicator": []>
```

So the test uses `delay: 100 ms` (fake time inside `testWidgets`): the first load runs
in `tester.runAsync`, the tap starts a load that is still pending at `pump()`, and
`pump(latency)` at the end drains the timer.

**Break it on purpose.** Retry → "Try again":

```
Expected: exactly one matching candidate
  Actual: _TextWidgetFinder:<Found 0 widgets with text "Retry": []>
   Which: means none were found but one was expected
#4      main.<anonymous closure> (file:///…/test/features/users/users_screen_test.dart:26:5)
```

The screen changed and something noticed. Changed back.

## Level 5 — Read a trace in thirty seconds

Planted in `FakeUserRepository`: user 1 `"geo": {"lat": -37.3159, …}` (a number).
Ran the app on the Android emulator against the fake, signed in → crash.
Full trace, copied from `flutter run`:

```
E/flutter: [ERROR:flutter/runtime/dart_vm_initializer.cc(40)] Unhandled Exception: type 'double' is not a subtype of type 'String' in type cast
#0      new Geo.fromJson (package:users_api/features/users/user.dart:102:35)
#1      new Address.fromJson (package:users_api/features/users/user.dart:82:14)
#2      new User.fromJson (package:users_api/features/users/user.dart:48:22)
#3      MappedListIterable.elementAt (dart:_internal/iterable.dart:442:31)
#4      ListIterator.moveNext (dart:_internal/iterable.dart:371:26)
#5      new _GrowableList._ofEfficientLengthIterable (dart:core-patch/growable_array.dart:194:27)
#6      new _GrowableList.of (dart:core-patch/growable_array.dart:154:28)
#7      new List.of (dart:core-patch/array_patch.dart:39:18)
#8      ListIterable.toList (dart:_internal/iterable.dart:224:7)
#9      FakeUserRepository.getAll (package:users_api/features/users/fake_user_repository.dart:63:49)
<asynchronous suspension>
#10     UsersModel.load (package:users_api/features/users/users_model.dart:42:22)
<asynchronous suspension>
```

1. **The message** — `type 'double' is not a subtype of type 'String' in type cast`:
   somebody claimed `as String` and got a `double`.
2. **My first frame** — `#0 new Geo.fromJson (…/features/users/user.dart:102:35)`:
   line 102 is `lat: double.parse(json['lat'] as String),`, column 35 is exactly the `as`.
   (Frames #3–#8 are `dart:` internals of `.map(...).toList()` — skip them.)
3. **The path** — `Geo.fromJson ← Address.fromJson ← User.fromJson ← FakeUserRepository.getAll`
   `<asynchronous suspension>` `← UsersModel.load` (`await _repo.getAll()`, line 42).
   `UsersModel.load` only catches `ApiException`, a `TypeError` is not one → unhandled.

**The data that went in:** field `address.geo.lat` of **user 1 (Leanne Graham)** —
`-37.3159` as a JSON number instead of the string `"-37.3159"`.

**#0 was the right place to throw and the wrong place to fix:** `as String` is the
contract stated at the exact spot the data violates it, so the error points straight at
the bad field — but `Geo` cannot know what the app should *do* about a broken server; that is the
boundary's job, so the repository (`parseUser`/`parseUsers` in `user_parsing.dart`)
turns the `TypeError` into `BadResponseException` and the screen shows
"Something went wrong" instead of crashing.

Tests:
- `user_test.dart` — `Geo.fromJson({'lat': -37.3159, …})` throws `TypeError` (the reproduction).
- `user_repository_test.dart` — MockClient returns the broken JSON → `getAll()` / `getById(1)`
  throw `BadResponseException`. Red before the fix:
  ```
  Expected: throws <Instance of 'BadResponseException'>
    Actual: <Instance of 'Future<UsersResult>'>
     Which: threw _TypeError:<type 'double' is not a subtype of type 'String' in type cast>
  ```
  green after.
- `users_model_test.dart` — the model with that repository ends with
  `error is BadResponseException`, `describeError(...) == 'Something went wrong'`, `loading == false`.

`print` → `log(..., name: 'users' | 'auth')` from `dart:developer`;
`avoid_print: error` in `analysis_options.yaml`.
