# Practice 9 — Put It High, Subscribe Low

> Values marked **(verify)** are the expected results from the assignment.
> Check them against your own console / rebuild counter when you run the app.

## Level 1 — Lift it up (commit `lifted`)

### Adding `total` to the badge "the honest way"
To show the total price in the badge, the value had to travel from the owner
(`_ShellState`) all the way down to `CartBadge`:

- **Constructors touched: 2** — `BooksScreen` (new `total` field + parameter) and
  `CartBadge` (new `total` field + parameter).
- **Call sites touched: 2** — `Shell.build` (`BooksScreen(..., total: _total)`) and
  `BooksScreen.build` (`CartBadge(count: ..., total: total)`).
- **Files touched: 3** — `lib/main.dart`, `lib/books_screen.dart`, `lib/cart_badge.dart`.

`BooksScreen` never uses `total` itself — it only carries it down for the badge.

### One tap on "Add" — console lines
`BooksScreen build` ×1 + `row …` ×6 = **7 lines** for one tap **(verify)**.
`setState` in `Shell` marks everything under it dirty: the whole screen and every row.

## Level 2 — A model with no widgets

- Experiment in `main()` (before `runApp`): add two books, add the first again,
  remove one → `1 items, 3100 ₸` (kept *Null Safety for Humans*) — printed before
  the first frame.
- `cart.items.add(books[0])` →
  `Unsupported operation: Cannot add to an unmodifiable list`.
- A `BuildContext` field in `Cart`: the `main()` lines no longer compile — there is
  no context before `runApp`. If the model needs a context, it is doing a widget's job.

## Level 3 — provider: the loud error and the silent one

- **Loud** — `context.watch<Cart>().add(b)` in `onPressed`:
  `Tried to listen to a value exposed with provider, from outside of the widget tree.`
  — provider explains that `watch` was called outside `build` and suggests
  `listen: false` / `context.read` instead **(verify exact wording)**.
- **Silent** — `context.read<Cart>().count` in the badge's `build`: no error, it
  compiles and runs, and the badge stays at **0 forever**. Nobody said "I depend on
  the cart".
- `grep -r "cart:" lib/` → nothing.

## Level 4 — Scope: `badge build` count for three presses on `+`

| Badge subscribes with | Three presses on `+` | Remove a book |
|---|---|---|
| `context.watch<Cart>().count` | **3** × `badge build` — the count did not change, the badge rebuilt anyway **(verify)** | 1 |
| `context.select<Cart, int>((c) => c.count)` | **0** — nothing printed **(verify)** | 1 |

Moving `context.watch<Cart>()` up into `BooksScreen.build` → every row on the Books
screen rebuilds on every `+` in the cart, on another screen. Subscribe where the value
is shown, not where it is convenient. (In the final code each `BookRow` uses `select`
on "is my book in the cart", so a `+` rebuilds no rows at all.)

The `Total:` label is the `const child` of a `Consumer` — `total label build` prints
once, not on every notify.

## Where does it live?

| Value | Home | Why |
|---|---|---|
| The cart | **provided** | Two routes (Books, Cart) and the badge all need it; it lives above `MaterialApp` in a `ChangeNotifierProvider`. |
| Search text in the Books AppBar | **ephemeral** | Only `BooksScreen` uses it to filter its own list; a `String` in its `State`. |
| Cart total expanded / collapsed | **ephemeral** | Pure UI detail of the Cart screen; nobody else cares, losing it on leave is fine. |
| Theme mode (dark-mode switch) | **provided** (or lifted into the widget above `MaterialApp`) | `MaterialApp.themeMode` is above every route, and the switch is somewhere deep in a settings screen. |
