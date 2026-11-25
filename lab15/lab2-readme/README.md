# Users Directory — a Flutter REST client

Browse people from a REST API on your phone — and still see them in airplane mode.

| ![list](docs/list.png) | ![offline](docs/offline.png) |
|---|---|

## Run it
```
flutter pub get
flutter run --dart-define=USE_FAKES=true            # no network needed
flutter run --dart-define-from-file=env/prod.json
```
`env/prod.json`:
```json
{ "ENV": "prod", "API_HOST": "jsonplaceholder.typicode.com" }
```
Release APK (arm64): see **Releases** → v1.0.1 — install on any Android phone.

## Architecture (five lines)
- `lib/ui/<feature>/` — screen + `ChangeNotifier` view model with a sealed `UsersState` (loading · loaded · offline · failed)
- `lib/core/` — `ApiClient`: HTTPS by default, 10 s timeout, network vs HTTP errors; `Env` from `--dart-define`
- `lib/domain/` interfaces, `lib/data/` implementations: `HttpUserRepository` and `FakeUserRepository` for tests and demo mode
- storage: `shared_preferences` (offline cache + debug-only host override), secure storage (token — `SecureStore` from lab13, port it before you claim it)
- `flutter test`: 8 tests — repository + cache + error mapping, screen states

## Decisions
1. **Fakes behind an interface.** `UserRepository` is an `abstract interface class`; `USE_FAKES` is a `const`, so the fake is tree-shaken out of the release build.
2. **Offline = last good copy.** On a network error the repository returns the cached list with `cachedAt`; the UI shows a banner instead of an error.
3. **Composition root.** Only `main.dart` creates `http.Client()` — everything below takes it through the constructor, so tests use `MockClient`.
4. **Debug-only host switch.** Testers can point a debug build at another server; in release the override is ignored.

## Team
| Area | Owner | Reviewer |
|---|---|---|
| [users list + offline cache] | [name] | [name] |
| [api client + env] | [name] | [name] |
| [release + CI] | [name] | [name] |
