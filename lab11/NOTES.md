# Practice 11 — A Real Server

## Level 1 — Postman first (curl, 2026-11-25)

`GET https://jsonplaceholder.typicode.com/users` → **200**,
`Content-Type: application/json; charset=utf-8`, body is a **list of 10 users**.
`GET …/users/1` → 200, one object.

- Nested objects: `address`, `company`. Nested twice: `address.geo`.
- `geo.lat` / `geo.lng` are **strings** (`"-37.3159"`), not numbers.
- Nothing is null or absent in the real data. We still treat `website` as
  optional (`String?`) — a user without a site is plausible; everything else is
  a claim and fails loudly if broken.
- `company.bs` exists on the wire but is not modelled (dropped by `toJson`).

### User

| field    | JSON type | Dart type                               | nullable? |
|----------|-----------|-----------------------------------------|-----------|
| id       | number    | `int`                                   | no        |
| name     | string    | `String`                                | no        |
| username | string    | `String`                                | no        |
| email    | string    | `String`                                | no        |
| address  | object    | `Address`                               | no        |
| phone    | string    | `String` (+ `phoneDigits` getter)       | no        |
| website  | string    | `String?`                               | yes (our choice) |
| company  | object    | `({String name, String catchPhrase})`   | no        |

### Address

| field   | JSON type | Dart type | nullable? |
|---------|-----------|-----------|-----------|
| street  | string    | `String`  | no |
| suite   | string    | `String`  | no |
| city    | string    | `String`  | no |
| zipcode | string    | `String`  | no |
| geo     | object    | `Geo`     | no |

### Geo

| field | JSON type | Dart type                          | nullable? |
|-------|-----------|------------------------------------|-----------|
| lat   | string    | `double` via `double.parse`        | no |
| lng   | string    | `double` via `double.parse`        | no |

### Company

| field       | JSON type | Dart type | nullable? |
|-------------|-----------|-----------|-----------|
| name        | string    | `String`  | no |
| catchPhrase | string    | `String`  | no |
| bs          | string    | — (ignored) | — |

### Statuses

| request | status | body |
|---|---|---|
| `GET /users/999` | **404 Not Found** | `{}` — an empty object, *not* an error message |
| `POST /users` with JSON + `Content-Type: application/json` | **201 Created** | what we sent + `"id": 11`; header `Location: …/users/11` |
| `POST /users` with `"id": 0` in the body | 201 | server overrides it: `"id": 11` |
| `POST /users` with a broken JSON body | **500** | |
| `GET /users?id=3` | 200 | a **list of one** `[{...}]`, not an object |

Nothing is really saved: every POST gets id 11, and `GET /users/11` is 404.

## Level 2 — breaking the model on purpose

- `json['lat'] as double` → `type 'String' is not a subtype of type 'double' in type cast`. Put `double.parse` back.
- `"id": "1"` in the pasted JSON → `type 'String' is not a subtype of type 'int' in type cast`. Names the field — a good failure.
- Both covered by `test/user_test.dart`.

## Level 3 — repository

`flutter run --dart-define=SMOKE=true` runs `lib/dev/smoke.dart` before `runApp`:
10 names, `getById(999): not found`, `create: server assigned id 11`.
Same checks against the live server: `LIVE=1 flutter test test/live_api_test.dart` (4/4 passed).

`grep -rn "package:http" lib/`:

```
lib/core/api/api_client.dart:7:import 'package:http/http.dart' as http;
lib/main.dart:2:import 'package:http/http.dart' as http;
```

`main.dart` is the composition root — the task requires `http.Client()` to be
created there, so it has to import the package. `user_repository.dart` does
**not** need it: `ApiClient` exposes `get`/`post` that already return decoded
JSON or throw an `ApiException`, so the repository only sees `Uri` + JSON.
No screen, model or widget imports http.

Break-it: with the 404 line removed from `_check`, `getById(999)` decodes `{}`
and fails in `fromJson` on `id` → `BadResponseException('users/999: …')` —
our exception, wrong cause. Status is checked before the body.

## Level 4

Removing the `BadResponseException()` arm → compile error
`The type 'ApiException?' isn't exhaustively matched by the switch cases since it doesn't match the pattern 'BadResponseException()'` (`non_exhaustive_switch_expression`).

Host typo → `SocketException` (failed host lookup) → Offline view; Retry works
after the fix without restarting.

## Level 5 — two kinds of "no network" (fill in on a real device)

| scenario | time until Offline view |
|---|---|
| Airplane mode | _TODO_ s |
| Wi-Fi without internet (hotspot, uplink off) | _TODO_ s (expected ≈ 10 s — the timeout) |

Screenshots to commit: `screenshot_timeout.png`, `screenshot_200.png`.
