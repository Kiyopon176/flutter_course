# Interview prep — twenty questions, three stories

Format of every answer: **definition · where it lives in my code · one level deeper**, then stop.
Target: under 40 seconds out loud.

> ⭐ = took longer than 40 s or started with "it depends" in pair practice → rehearse again tomorrow.
> ✎ = after checking against the slides: wrong or vague (write the correction under it).
> The question numbering follows the lecture bank as I remember it — re-check the order against the slides.

---

## Part 1 — Twenty questions

### 1. StatelessWidget vs StatefulWidget
A StatelessWidget is an immutable description of UI built only from its constructor arguments; a StatefulWidget pairs that immutable widget with a long-lived `State` object that keeps mutable data between builds.
In `lab12/lib/features/users/users_screen.dart` the screen is stateless because the data lives in `UsersModel`, while `lab12/lib/features/users/new_user_screen.dart` is stateful because it owns three `TextEditingController`s and a `GlobalKey<FormState>`.
The widget object is recreated on every parent rebuild, but the `State` survives as long as the element stays in the tree at the same position with the same type and key — that is why state "sticks" to a position, not to an instance.

### 2. What does `setState` actually do?
`setState` runs the callback synchronously and marks the element dirty, so `build` runs again on the next frame — it does not rebuild immediately.
In `lab10/lib/students_future_screen.dart`, `_retry()` does `setState(() => _future = _api.fetchStudents())` so the `FutureBuilder` gets a new future.
Calling it after `dispose` throws "setState() called after dispose()", which is why every `setState` after an `await` in `lab10/lib/students_screen.dart` is guarded with `if (!mounted) return;`.

### 3. Widget, Element, RenderObject
Widgets are cheap immutable configurations, Elements are the live instances that hold position in the tree and the `State`, and RenderObjects do layout and painting.
When `UsersScreen` in `lab12` rebuilds after `notifyListeners()`, new `ListTile` widgets are created but Flutter reuses the existing elements and render objects whose type and key match.
That diff (`Widget.canUpdate` compares `runtimeType` and `key`) is why rebuilding is cheap and why creating new widgets in `build` is fine, while creating controllers or futures there is not.

### 4. BuildContext
A `BuildContext` is the element of the widget that is building — a handle to its position in the tree, used to look things up above it.
Every `context.watch<UsersModel>()` in `lab12/lib/features/users/users_screen.dart` and `Navigator.of(context)` walks *up* from that position.
Using a context after `await` is risky because the element may be unmounted; `lab10/lib/students_screen.dart` checks `context.mounted` before showing a SnackBar.

### 5. Keys — when do you need one?
A key tells Flutter which old element a new widget corresponds to when widgets of the same type move, are inserted or are removed among siblings.
In `lab14/lib/app.dart` the `ChangeNotifierProvider` has `key: ValueKey(host)`, so switching the API host throws away the whole subtree and creates a fresh `UsersViewModel`; tests find widgets by `Key('increment')` in `lab15/warmups/warmup1_counter`.
Without keys, reordering stateful list items makes the state stay at the old *positions* — the classic "checkbox jumps to the wrong row" bug; `ValueKey(id)` fixes it, `UniqueKey()` in `build` destroys state every frame.

### 6. State lifecycle
`createState` → `initState` (once) → `didChangeDependencies` → `build` (many times) → `didUpdateWidget` when the parent passes new config → `dispose` (once).
`lab10/lib/countdown_screen.dart` subscribes to the stream in `initState` and cancels the `StreamSubscription` in `dispose`; `new_user_screen.dart` disposes its controllers there.
`initState` cannot be `async` and cannot use `InheritedWidget` lookups that subscribe (`dependOnInheritedWidgetOfExactType`) — that belongs in `didChangeDependencies`; `context.read` is fine because it does not subscribe.

### 7. Why `const` constructors?
A `const` widget is canonicalized at compile time, so the same instance is reused and Flutter can skip rebuilding that subtree entirely.
`const LoadingView()`, `const MessageView(...)` and `body: const _UsersBody()` in `lab12/lib/features/users/users_screen.dart` are all const.
Identical widget instance → `Element.updateChild` short-circuits, so `const` is a real performance tool, not style; `flutter_lints` (`prefer_const_constructors`) enforces it in every lab.

### 8. Future, async/await and the event loop ⭐
A `Future` is a value that will arrive later; `await` suspends the function and returns control to the event loop, which keeps drawing frames until the result comes.
`lab10/NOTES.md` Level 1: `print('A'); Future.delayed(...print('B')); print('C')` prints A, C, first frame, then B.
An `async` function runs *synchronously* until its first `await` — that is why `fetchStudents #1` printed before the first frame, and why `sleep()` freezes the UI while `await Future.delayed` does not.

### 9. Future vs Stream
A Future delivers one value or one error; a Stream delivers many values over time and must be listened to and cancelled.
`lab10/lib/api/countdown.dart` is an `async*` generator; `countdown_screen.dart` shows it two ways — `StreamBuilder` with the stream in a field, and `listen` with `_sub.cancel()` in `dispose`.
A single-subscription stream throws "Stream has already been listened to" on a second listen — so a stream created in `build` both breaks and leaks.

### 10. `watch` / `read` / `select`
`watch` subscribes the widget and rebuilds it on every `notifyListeners()`; `read` gets the object once without subscribing; `select` subscribes to one derived value and rebuilds only when that value changes.
`lab12/lib/features/users/users_screen.dart` watches `UsersModel` in `build`, `new_user_screen.dart` reads it in `_save()` and selects `m.saving`, and `lab9/lib/cart_badge.dart` selects `c.count` so a quantity change does not rebuild the badge.
`select` compares with `==`, so selecting a freshly built `List` rebuilds every time — select a primitive or an immutable value; and `read` inside `build` is an assertion error in debug.

### 11. ChangeNotifier and where the provider goes
A `ChangeNotifier` is a plain Dart class that holds state and calls `notifyListeners()` after each mutation; `ChangeNotifierProvider` creates it, exposes it to the subtree and disposes it.
`lab9/lib/models/cart.dart` (`Cart`) and `lab12/lib/features/users/users_model.dart` (`UsersModel`) — neither imports `material.dart`, both are tested without widgets in `lab9/test/cart_test.dart`.
The provider must sit *above* `MaterialApp` if more than one route needs it, because pushed routes are siblings under the Navigator, not children of the first screen — `ProviderNotFoundException` otherwise.

### 12. FutureBuilder — why the future is a field
`FutureBuilder` subscribes to a future and rebuilds with an `AsyncSnapshot` (waiting, data or error).
`lab10/lib/students_future_screen.dart` creates `_future` once in `initState` and passes the field: `future: _future, // the field, never a call`.
If you write `future: api.fetch()` inside `build`, every rebuild (a Switch flip, a keyboard opening) starts a new request and shows the spinner again — `lab10/NOTES.md` counted `#2 #3 #4` in the console.

### 13. `mounted` and setState after dispose
`mounted` is true while the `State` is in the tree; after `dispose` it is false and `setState` throws.
`lab10/lib/students_screen.dart` checks `if (!mounted) return;` after every `await`, `new_user_screen.dart` does it before `Navigator.pop`.
Better still is a model with no `mounted` at all: `lab14/lib/ui/users/users_view_model.dart` sets `_disposed = true` in `dispose()` and `_set()` drops late results — the UI stays a dumb listener.

### 14. JSON: `int` vs `double` ⭐
`jsonDecode` turns `3` into an `int` and `3.5` into a `double`, so `json['price'] as double` throws a `TypeError` the day the server sends a whole number.
In `lab12/lib/features/users/user.dart`, `Geo.fromJson` gets coordinates as *strings* and uses `double.parse`; `UserRepository._parse` turns any `TypeError`/`FormatException` from `fromJson` into `BadResponseException`.
The safe form is `(json['x'] as num).toDouble()`; and on Flutter **web** every number is a JS double, so `3.0 is int` is `true` there — a test that passes on web can fail on Android.

### 15. fromJson / toJson and null safety in models
A model is an immutable class with a `factory fromJson(Map<String, dynamic>)` that casts every field explicitly and a `toJson()` for the way back.
`lab12/lib/features/users/user.dart` makes only `website` nullable (`String?`) because it is the only optional field; `lab14/lib/data/user_json.dart` keeps the mapping outside the domain class.
Every `as String` is a claim about the server; a wrong claim is a bug report, not a retry — which is why parsing errors map to a different screen (`GenericError`) than network errors (`Offline` with Retry).

### 16. HTTP errors: status, timeout, no connection ⭐
`package:http` does not throw on 404 or 500 — you check `statusCode` yourself; it *does* throw (`SocketException`/`ClientException`) when there is no connection, and only `.timeout()` stops a hanging request.
`lab12/lib/core/api/api_client.dart` checks status first and body second, and maps everything to the sealed `ApiException` in `api_exception.dart`; the screen's `switch` in `users_screen.dart` has no `default`.
Because the hierarchy is `sealed`, adding a new exception type makes the compiler point at every switch that does not handle it — the error mapping cannot silently fall through.

### 17. Repository and dependency injection — why pass `http.Client` in?
A repository is the one class screens ask for domain objects; it hides URLs, JSON and errors behind methods like `getAll()`.
`lab12/lib/main.dart` is the composition root — "the only file that says `http.Client()`"; `lab12/test/users_screen_test.dart` passes `MockClient` instead and tests offline → Retry without a network.
In `lab14/lib/domain/user_repository.dart` the repository is an `abstract interface class`, so `FakeUserRepository` and `HttpUserRepository` are swapped at compile time by `Env.useFakes`.

### 18. Unit vs widget vs integration tests
A unit test runs plain Dart (a model, a parser); a widget test pumps widgets in a fake environment with a fake clock; an integration test drives the real app on a device.
`lab12/test/user_test.dart` (JSON parsing), `user_repository_test.dart` (error mapping with `MockClient`), `users_screen_test.dart` (loading → list → detail).
In widget tests time does not pass by itself: `pump()` draws one frame, `pumpAndSettle()` pumps until no animations are scheduled — and hangs forever on an infinite spinner, so for loading states use `pump()`.

### 19. Local storage: shared_preferences vs secure storage vs files
`shared_preferences` is a key-value store for small non-secret data, `flutter_secure_storage` uses Keychain/Keystore for secrets, files (`path_provider`) are for larger blobs.
`lab14/lib/data/users_cache.dart` keeps the last good user list in `shared_preferences`; `lab13/lib/secure_store.dart` keeps the auth token in secure storage.
`shared_preferences` is a plain XML/plist file readable on a rooted device or from a backup — a token there is a security bug; and cache keys are versioned (`users_cache_v1`) so a model change does not crash on old data.

### 20. Build modes, `--dart-define` and release signing
Debug (JIT, hot reload, asserts), profile (AOT with tooling) and release (AOT, tree-shaken, no asserts); configuration goes in at build time with `--dart-define` / `--dart-define-from-file`.
`lab14/lib/core/env.dart` reads `API_HOST`, `USE_FAKES` and `ENV` as `const`; `lab14/lib/core/dev_host.dart` allows a host override only when `kDebugMode`.
Because the values are `const`, the branch not taken is tree-shaken out of the release binary; and the upload keystore and `key.properties` must never be committed — lose the keystore and you can never update the app on Play.

---

## Part 2 — Three stories (one minute each)

### Story 1 — A bug in five beats

> Beats 1, 3, 4 are from `lab10/NOTES.md` ("A bug found on the way"). Beat 2 is reconstructed — replace it with what you really tried first; an interviewer can tell.

1. **Symptom.** In Practice 10 the fake API was supposed to fail every third call. I called `fetchStudents()` three times in a row from `main()` — and *all three* failed, not just the third.
2. **Wrong first guess.** I thought my modulo was off by one and spent a while changing `calls % 3 == 0` to `== 2`, which just made a different set of calls fail.
3. **What actually found it.** I printed `calls` on the line right *after* the `await` — it printed `3`, `3`, `3`. All three calls did `calls++` before any of them woke up.
4. **The fix.** Take this call's number *before* the `await`: `final n = ++calls;` and check `n`, not the shared field (`lab10/lib/api/fake_api.dart`).
5. **The habit.** Anything I need from shared state I copy into a local before `await` — the line after `await` runs later, in a world that has changed. Same reason I check `mounted` after every `await` in a State.

### Story 2 — A design decision: the repository takes an `http.Client`

- **Decision.** `ApiClient(http.Client client)` in `lab12/lib/core/api/api_client.dart`; only `main.dart` creates the real `http.Client()`.
- **Alternative.** Call the top-level `http.get(...)` inside the repository — fewer lines, no constructor parameter.
- **What it would have cost.** Every test would hit `jsonplaceholder.typicode.com`: slow, flaky, impossible to test "no connection", "500" or "broken JSON". With injection, `users_screen_test.dart` uses `MockClient` and tests offline → Retry in milliseconds; the same seam later became the `UserRepository` interface and `FakeUserRepository` for `USE_FAKES` in lab14.

### Story 3 — One thing I would do differently

**I would build the fake repository first, and keep one `core/api` for the whole project.** In lab12 the error model was a proper sealed `ApiException`; in lab14 I rewrote the client and ended up with two loose classes (`ApiException`, `NetworkException`) and a view model that catches `OfflineException` plus a bare `catch (e)` — so the exhaustive `switch` I was proud of in lab12 was gone. `FakeUserRepository` also came last, so screens were shaped by JSONPlaceholder's quirks (coordinates as strings). Next project: interface + fake on day one, every screen built against the fake, real API plugged in behind the same sealed errors. And commit per feature — not 500 files in one "Initial commit".
