# Practice 9 — Put It High, Subscribe Low

## Level 1 — Lift it up

### Adding `total` to the badge "the honest way"
To show the total price in the badge, the value had to travel from the owner
(`_ShellState`) all the way down to `CartBadge`:

- **Constructors touched: 2** — `BooksScreen` (new `total` field + parameter) and
  `CartBadge` (new `total` field + parameter).
- **Call sites touched: 2** — `Shell.build` (`BooksScreen(..., total: _total)`) and
  `BooksScreen.build` (`CartBadge(count: ..., total: total)`).
- **Files touched: 3** — `lib/main.dart`, `lib/books_screen.dart`, `lib/cart_badge.dart`.

`BooksScreen` does not use `total` at all — it only carries it for the badge.

### One tap on "Add" — console lines
`BooksScreen build` ×1 + `row …` ×6 = **7 lines** for one tap.
`setState` in `Shell` marks everything under it dirty: the whole screen and every row rebuild.
