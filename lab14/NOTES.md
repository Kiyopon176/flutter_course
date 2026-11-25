# Practice 14 — Ship It: notes

## Level 1 — Identity and version

`applicationId = "kz.kiyopon.users"`, `namespace` is the same. `minSdk`, `targetSdk`,
`versionCode` and `versionName` all come from `flutter.*`, so they are read from
`pubspec.yaml` and never typed into Gradle.

**`version: 1.0.1+2`, one half at a time:**

| Part | Name | Who reads it | Rule |
|---|---|---|---|
| `1.0.1` | versionName / `CFBundleShortVersionString` | **People**: store listing, About screen, bug reports | Semantic version. Change it when the meaning of a release changes |
| `2` | versionCode / `CFBundleVersion` | **The store and the OS** | Plain integer. It **must go up on every upload**: Play refuses a code it has already seen, and Android refuses to install a lower code over a higher one |

**The "third-upload rejection", reproduced** (tried for real, then reverted):

```
# build.gradle.kts: versionCode = 1   pubspec: version: 1.0.1+3
aapt dump badging app-debug.apk → versionCode='1' versionName='1.0.1'   ← pubspec said 3
# put back versionCode = flutter.versionCode, pubspec 1.0.1+2
aapt dump badging app-debug.apk → versionCode='2' versionName='1.0.1'
```

The name updated but the code stayed at 1. Play would reject this upload as a duplicate version code.

**Something the lab text doesn't mention:** `--split-per-abi` rewrites the versionCode
as `abiCode * 1000 + buildNumber` (armeabi-v7a = 1, arm64-v8a = 2, x86_64 = 4).
The arm64 APK installed on the phone reports `versionCode=2002`, so About shows
**`1.0.1 (2002)`**, not `(2)`. This is by design: each ABI APK needs its own code
when they are uploaded side by side. The `.aab` and the universal APK keep `2`.

## Level 2 — A key you never commit

* The `.gitignore` lines (`*.jks`, `*.keystore`, `android/key.properties`,
  `env/*.local.json`) were written and checked with `git check-ignore`
  **before** the key existed. `android/.gitignore` from `flutter create` also covers them.
* Keystore: `C:/Users/NEXTGENPC/upload-keystore.jks`, alias `upload`, RSA 2048,
  10000 days, made with `keytool -genkey …` **outside the project folder**.
* **Backup:** TODO. Copy `upload-keystore.jks` and the password (into a password
  manager, never into git) to a place that isn't this laptop, then write *where* here.
* `build.gradle.kts` loads `key.properties` into `keystoreProperties`, creates
  `signingConfigs.release`, and the release build type uses
  `signingConfigs.getByName("release")` with `isMinifyEnabled = true`.

**Proof the release is signed with my key, not "Android Debug":**

```
$ keytool -printcert -jarfile build/app/outputs/flutter-apk/app-release.apk
Not a signed jar file
```

This doesn't mean the APK is unsigned. With minSdk 24, AGP signs only with
**APK Signature Scheme v2/v3** and skips the old v1 (JAR) scheme. `keytool -printcert -jarfile`
can only read v1. The tool that can read v2/v3 is `apksigner`:

```
$ apksigner verify --verbose --print-certs app-release.apk
Verified using v1 scheme (JAR signing): false
Verified using v2 scheme (APK Signature Scheme v2): true
Number of signers: 1
Signer #1 certificate DN: CN=Kiyopon, OU=Mobile, O=Kiyopon, L=Almaty, C=KZ
Signer #1 certificate SHA-256 digest: b60ca920d02ed730b8e665f62834be027e883b025c1efda6babbfc174b99b613

$ keytool -list -v -keystore ~/upload-keystore.jks -alias upload
Alias name: upload
Owner: CN=Kiyopon, OU=Mobile, O=Kiyopon, L=Almaty, C=KZ
SHA256: B6:0C:A9:20:D0:2E:D7:30:B8:E6:65:F6:28:34:BE:02:7E:88:3B:02:5C:1E:FD:A6:BA:BB:FC:17:4B:99:B6:13
```

The two digests match.

**What a classmate could do if I committed the key and `key.properties`:** they could
sign *any* APK as `kz.kiyopon.users`. Android would install it as an **update** over my
real app, keeping its data and permissions. Without Play App Signing they could also
upload it to my Play listing if they got into the account. That makes it a ready-made
way to push a trojan update.

**What Play App Signing changes:** Google holds the real *app signing key*. The key in
this repo is only an *upload key*, which proves that an upload came from me. If the upload
key leaks or gets lost, I ask Play support to reset it, and users never notice because the
key their devices trust didn't change. Without enrolment, a lost key means you can never
update the app again, and a leaked key can't be revoked.

**Removing a committed file from all of git history** (then rotate the key anyway,
because the leak has already happened):

```
git filter-repo --invert-paths --path android/key.properties --path upload-keystore.jks
git push origin --force --all        # and --tags
```

(The older equivalent: `git filter-branch --index-filter "git rm --cached --ignore-unmatch <file>" -- --all`.)

## Level 3 — Environments

`lib/core/env.dart` is the only file that calls `fromEnvironment`. `main.dart` picks
`FakeUserRepository` or `HttpUserRepository` with the const `Env.useFakes`.

**Why the developer host switch can't use `fromEnvironment`:** `String.fromEnvironment`
is a **compile-time constant**. The value is baked into the binary when it is built,
and the running app has no way to change it. Picking a host at runtime needs storage that
can change while the app runs, so the choice is saved in `shared_preferences`
(`DevHostSetting`).

**Why it must never be visible in release:** anyone who installs the APK could point the
app at their own server. They could then capture traffic and tokens, feed users fake data,
or reach staging and admin hosts. `if (kDebugMode)` is a const, so the compiler removes the
tile and the code behind it from a release build entirely. `DevHostSetting.override` also
returns `null` outside debug, so a value left over in prefs is ignored.

**Release built without the env file:** `Env.name` falls back to `local` and the host to
the default. With a local default like `10.0.2.2:8080` (which is the emulator's alias for
the laptop and doesn't exist on a phone), the list is empty or offline. About then says
`… · release · local · 10.0.2.2:8080`, and that one line explains the problem: it's the
wrong build, not a bug in the code. Our default is the public host, so this build would
work but would label itself `local` instead of `prod`.

## Level 4 — Icon, splash, name

* Icon and splash are my own drawings (`tool/make_icons.py`, run with Pillow). The
  1024² icon is RGB with no alpha for iOS. The adaptive foreground stays inside the safe
  zone. The Android 12 image is 1152² with the glyph inside the central 768 circle.
* `android:label="Users"` and `CFBundleDisplayName = Users`.
* `INTERNET` is declared in `src/main/AndroidManifest.xml`. `aapt dump badging` on the
  release APK lists `uses-permission: android.permission.INTERNET`.
  If you remove it, the debug build still works because the debug manifest adds it, but the
  release build shows the Offline view on every launch. (I didn't rebuild to check this.)

## Level 5 — The release

| Build | File | Size |
|---|---|---|
| `flutter build apk --debug` | app-debug.apk | **152.5 MB** (JIT, all ABIs, no tree-shaking) |
| `flutter build apk --release` | app-release.apk (universal) | 47.8 MB |
| `--release --split-per-abi --obfuscate` | **app-arm64-v8a-release.apk** | **16.4 MB** |
| `flutter build appbundle --release` | app-release.aab | 41.7 MB, **not installable**. Play cuts per-device APKs from it |

The `releases/1.0.1+2/` folder holds the arm64 APK, `SHA256SUMS` and `symbols/`.
`symbols/` is gitignored because the symbol files belong to that one build.

**A crash log without symbols.** With `--obfuscate`, class and method names are
replaced by short meaningless identifiers. The stack trace shows only addresses inside
`libapp.so`, with no file names or line numbers:

```
*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
pid: 12345, tid: 12360, name 1.ui  >>> kz.kiyopon.users <<<
#00 abs 0000007a1b2c3d4e virt 00000000003c3d4e _kDartIsolateSnapshotInstructions+0x2a1f4e
#01 abs 0000007a1b2c1a10 virt 00000000003c1a10 _kDartIsolateSnapshotInstructions+0x29fc10
```

The symbols from **this exact build** turn it back into file names and line numbers:

```
flutter symbolize -i crash.txt -d releases/1.0.1+2/symbols/app.android-arm64.symbols
```

## Real phone: done vs. still to do

* Done: the arm64 APK installed on a real phone (Xiaomi 24117RN76G, Android 16) and the
  OS reports `versionName=1.0.1 versionCode=2002`. It was installed with `adb install`,
  **not** from the file.
* **Still to do:** send the APK to the phone, install it from the file manager on
  **mobile data**, then check first launch, an airplane-mode launch (the saved list with
  the "Offline" banner), *Take photo* after denying the permission, rotation, and About.
  Save the About screenshot as `screenshot_about_release.png`.
