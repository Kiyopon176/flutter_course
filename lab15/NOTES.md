# Practice 15 — Interview Day: notes

Fields marked `__` can only be filled by me, live: with a timer, a browser, a classmate or a phone.
Everything else is already checked against the repository.

---

## Level 1 — Ninety seconds on GitHub

### Contribution history — what a reviewer concludes

`git log --format='%ad %s' --date=short` on `main` (checked 2026-11-25):

| Date | Commit |
|---|---|
| 2026-10-24 | Initial commit: Flutter course labs — **517 files, labs 1–8 at once** |
| 2026-11-05 | lifted · lab9 · lab10 (three commits the same day) |
| 2026-11-25 | lab13 starting point · `tool/check_layers.sh` · move api_exception |

Three green days in a month, and the first one is half the course in a single commit.
**What the reviewer concludes:** "works in bursts and pushes at the end; can't see how the code grew; can't tell which lab was hard."
**What I do about it:** you cannot rewrite history now — so from this practice on, one commit per level, and the plan goes into the Lab 2 README as a "Decisions" section (see `lab2-readme/README.md`).

### Tree and history check (the Practice 14 command)

```
git log --all --diff-filter=A --name-only --format= | grep -E 'build/|\.jks$|key\.properties'
```
Result on 2026-11-25: **empty** — no `build/`, no keystore, no `key.properties` ever committed. ✅
(Note: `lab1/build`, `lab3/build`, `lab10/build` exist on disk but are ignored — keep it that way.)

### Profile checklist

- [ ] Real name, photo, bio: `Flutter developer · KBTU · 2026`
- [ ] Pinned: Lab 2 repository + one cleaned practice (candidate: `lab12` users_api — sealed errors, 25 tests)
- [ ] Lab 2 repo: descriptive name (e.g. `users-directory`, not `lab2_final_v3`), one-sentence description, topics `flutter` `dart` `provider`, public
- [ ] README from `lab2-readme/README.md`, two screenshots in `docs/`
- [ ] Release `v1.0.1` with the arm64 APK, pubspec version in the title

### Ninety seconds on my own profile (private window, timer)

- Saw: __
- Did not see: __

### Ninety seconds on a classmate's profile

- Classmate: __
- What I saw: __
- What I would ask them first (three sentences): __

---

## Level 2 — CV

- Draft: `docs/cv.md` → export to `docs/cv.pdf` (one page) or put a private link here: __
- Person who hires developers — "what would you ask me first?": __
- Person who does not — "what would you ask me first?": __
- Random-word test (picked: __) — could I talk 5 minutes with a file open? __

---

## Level 3 — Recording

Five questions recorded: __, __, __, __, __
Two things I would change:
1. __
2. __

---

## Level 4 — Warm-ups

The folders in `warmups/` are **reference solutions** — what "finished" looks like.
The real exercise is mine: empty `flutter create`, timer on, out loud, commit at minute 20 whatever the state.

| Warm-up | Reference | My attempt: minutes | How far I got | Where I stalled |
|---|---|---|---|---|
| 1 · counter + ChangeNotifier + 2 screens | `warmups/warmup1_counter` | __ | __ | __ |
| 2 · list: loading / error+Retry / empty / data | `warmups/warmup2_list` | __ | __ | __ |
| 3 · form, validators, controllers, unit test | `warmups/warmup3_form` | __ | __ | __ |
| 2 again, two days later, no peeking | — | __ | __ | __ |

**Warm-up 2 difference:** __ min → __ min = **__ minutes faster** (that number is the practice working).

What I would say at minute eighteen: "The four states work against the fake; I'd now move the switch into its own widget and add a test that Retry calls the repository twice — want me to start with the test?"

---

## Practice session

- Story told to the group: __ (bug / design decision / differently)
- Time: __ s (target < 90 s)
