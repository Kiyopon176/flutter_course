# Practice 10 — The Data Arrives Later

> Lines marked **(verify)** are the expected output from the assignment / Flutter's
> standard messages. Hash codes like `#a1b2c` differ on every run — paste your own.

## Level 1 — the order of events

Experiment in `main()` before `runApp` (deleted afterwards):

```dart
print('A');
Future.delayed(const Duration(seconds: 2), () => print('B'));
print('C');
final api = FakeApi();
api.fetchStudents().then((l) => print('${l.length} students'));
```

| | Order |
|---|---|
| **Predicted** | `A`, `C`, first frame, … 2 s … `B`, `6 students` |
| **Actual** | `A`, `C`, `fetchStudents #1`, first frame, … 2 s … `B`, `6 students` **(verify)** |

`fetchStudents #1` appears immediately: an `async` function runs synchronously up
to its first `await`. Nothing waited for the timer — `main()` ran to the end, the
loop drew the screen, and the two callbacks came later as events (`B` first: its
timer was registered first).

Three `fetchStudents()` in a row from `main()` → the third one prints
`Unhandled Exception: Instance of 'NoConnectionException'` and the app keeps
running as if nothing happened **(verify)**.

`sleep(const Duration(seconds: 2))` instead of `await Future.delayed(...)` → no
first frame for two seconds: the loop is **blocked**, not waiting.

### A bug found on the way
The first version checked `calls % 3 == 0` *after* the `await`. Three calls in a
row each do `calls++` before any of them wakes up, so by the time they check,
`calls == 3` for **all three** and all three fail. The fix: remember this call's
number before the `await` (`final n = ++calls;`) and check `n`. Same lesson as the
whole lab — the line after `await` runs later, in a world that has changed.

## Level 2 — `setState()` called after `dispose()`

Without the two `if (!mounted) return;` lines, open *By hand* and press Back within
two seconds:

```
setState() called after dispose(): _StudentsScreenState#xxxxx(lifecycle state: defunct, not mounted)
```
**(verify — copy the exact first line from your console)**

With the guards: nothing in the console. The response arrived at a State that was
gone, and `mounted` said so.

## Level 3 — FutureBuilder

- Future in a field, Switch flipped ten times → one `fetchStudents #1`, no flicker.
- `future: _api.fetchStudents()` inline in `build` → a spinner on every flip and
  `#2 #3 #4 …` in the console; the third one fails.
- `hasData` checked before `hasError` while the server is down → spinner forever.

## Level 4 — countdown with and without `cancel()`

| Version | Back at 7 | Console |
|---|---|---|
| B, `_sub.cancel()` in `dispose` | stops | last line `tick 7` |
| B, `cancel()` commented out | keeps going | `setState() called after dispose(): _ListenCountdownState#xxxxx(lifecycle state: defunct, not mounted)`, then `tick 6`, `tick 5` … `tick 0` with nobody on screen — **the leak** **(verify)** |
| A, `StreamBuilder`, no cancel anywhere in my code | stops | last line `tick 7` — `StreamBuilder` cancelled for me |

## Level 5 — the error that vanished

The "AI version": `onPressed: () { _api.save(n); Navigator.pop(context); }`

- `flutter analyze` → `unawaited_futures` flags the `_api.save(n)` line.
- Second Save → the screen pops as if it worked, and the console says:
  `Unhandled Exception: Bad state: server rejected 6` **(verify)**

**The user saw a success.**

The honest version: `await` + `try / on StateError`, `context.mounted` after the
`await`, `pop` only on success, a SnackBar only on failure, and the button disabled
with a small spinner while the request is in flight (a fast double tap = one
request).

Note: `FakeApi.saveCalls` is `static` — "server-side" state. Every screen creates its
own `FakeApi`, and a successful save pops the screen, so a per-instance counter would
never reach its second (failing) call.
