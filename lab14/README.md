# Users — Practice 14: Ship It

A users directory backed by a REST API (jsonplaceholder by default). It keeps the last
list and shows it offline, and its About screen tells you which build you're holding.
App id `kz.kiyopon.users`, version `1.0.1+2`.

## Layout

```
lib/
  main.dart                  wiring: Env.useFakes ? Fake : Http(ApiClient(host: Env.host))
  app.dart                   MaterialApp + providers
  core/env.dart              the ONLY fromEnvironment calls
  core/api_client.dart       http + host, Network/Api exceptions
  core/dev_host.dart         debug-only runtime host override (shared_preferences)
  domain/                    User, UserRepository, UsersPage, OfflineException
  data/                      HttpUserRepository (+ UsersCache), FakeUserRepository
  ui/users|settings|about/   screens; they import domain/ only
env/local.json · env/staging.json · env/prod.json
tool/make_icons.py           draws assets/icon + assets/splash
releases/1.0.1+2/            arm64 APK + SHA256SUMS (+ symbols/, gitignored)
```

## Four ways to run

```bash
flutter run                                                    # defaults: local · jsonplaceholder
flutter run --dart-define=USE_FAKES=true                       # two fake users, no network
flutter run --dart-define-from-file=env/local.json             # local env from file
flutter build apk --release --dart-define-from-file=env/prod.json
```

Also: `flutter run --dart-define=ENV=staging --dart-define=API_HOST=example.invalid`
shows the Offline view with the host named.

The full release (Level 5):

```bash
flutter build apk --release --split-per-abi --obfuscate \
  --split-debug-info=build/symbols --dart-define-from-file=env/prod.json
```

Signing needs `android/key.properties` (gitignored), which points at a keystore
outside the repo:

```properties
storePassword=…
keyPassword=…
keyAlias=upload
storeFile=C:/Users/<you>/upload-keystore.jks
```

## Checks

```bash
flutter analyze                                   # No issues found
dart format --set-exit-if-changed .               # 0 changed
flutter test                                      # 8 passed
grep -rn fromEnvironment lib/                     # only lib/core/env.dart
grep -rnE "package:http|/data/" lib/ui lib/domain # empty (layer rule)
git log --all --diff-filter=A --name-only | grep -e jks -e key.properties   # empty
```

## Pre-release checklist (14 boxes)

> I rebuilt this list from the lab text. Compare it with the lecture slide and fix the
> wording if it differs.

- [x] **1. applicationId** is reverse-domain and final: `kz.kiyopon.users` in `build.gradle.kts`
- [x] **2. Version from pubspec**: `1.0.1+2`, Gradle uses `flutter.versionCode` (proof: `aapt` versionCode='2', NOTES.md)
- [x] **3. Signed with my upload key**, not debug: `apksigner --print-certs` → `CN=Kiyopon` (NOTES.md)
- [x] **4. No secret in git**: `.gitignore` covers `*.jks`, `*.keystore`, `android/key.properties`; `git check-ignore`
- [ ] **5. Keystore backed up** off this laptop and location recorded in NOTES.md: **TODO**
- [x] **6. Environment baked in**: `--dart-define-from-file=env/prod.json`; About shows `prod`
- [x] **7. INTERNET in the main manifest**: `aapt` → `uses-permission: android.permission.INTERNET`
- [x] **8. Name and icon**: "Users", adaptive icon (`mipmap-anydpi-v26/ic_launcher.xml`)
- [x] **9. Splash incl. Android 12**: `values-v31/styles.xml` from `flutter_native_splash`
- [x] **10. No debug-only UI in release**: dev host tile behind `kDebugMode`, `debugShowCheckedModeBanner: false`
- [x] **11. About + licences**: version, build, mode, env, host; `showLicensePage`
- [x] **12. Obfuscated with symbols archived**: `releases/1.0.1+2/symbols/`, `flutter symbolize` in NOTES.md
- [ ] **13. Tested on a real phone from the file over mobile data** (first launch, airplane mode, denied camera, rotate, About): `screenshot_about_release.png` **TODO**
- [ ] **14. Published**: GitHub Release `v1.0.1` with the arm64 APK: `screenshot_release_page.png` **TODO**
