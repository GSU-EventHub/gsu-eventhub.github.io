# GSU EventHub

**Live app:** https://gsu-eventhub.github.io/ · [Successful deployment and Windows verification](https://github.com/GSU-EventHub/gsu-eventhub.github.io/actions/runs/39273646977)

A personal campus event scheduler built with **Flutter 3.47.7 stable and Dart**, targeting web browsers and Android. A second-year student's solo project, separate from iSkedyul.

Plan seminars, workshops, sports, and club activities. **Interested, Going, and Attended are personal labels, not organizer registrations.** The planner starts empty. There are no accounts, backend services, external APIs, notifications, or paid services.

## Use the planner

1. Open the app to go straight to **Home**. There is no welcome screen or extra start button.
2. Tap **Add event**. Enter a title, date and start/end times using the picker buttons (keyboard entry is also supported: `YYYY-MM-DD`, `9:00 AM`), venue, category, and personal status. Organizer and plain-text description are optional. Events start and finish on the same day; end time must follow start time.
3. Save, then open the event details to edit or delete it. Deletion requires confirmation.
4. Search event titles or venues in **Events**, open **Filters**, and combine category/status choices. Upcoming events are chronological; use the Past and Attended section chips for those events.
5. Use **Calendar** for Month, Week, or Day views. Select a day, tap an hour to prefill a new event, use the arrows or Today, and expand the timetable when needed. Weeks scroll horizontally on narrow screens. Calendar selection and scroll positions survive navigation within the running app.

Browser Back/Forward follows screens, forms, date/time pickers, filters, expanded calendar, and the deletion confirmation. Forms use inline choices rather than popup menus. Leaving an unsaved form discards its changes. At the app root, Back remains normal browser navigation. Routes use `/#/...`, which also works on refresh and GitHub Pages without server rewrite rules. These browser behaviors apply to the web version. The APK uses Android system navigation.

## Mobile interface

The project uses Flutter and Dart for **web browsers and an Android application**. The website runs in a browser. The Android APK runs the same Flutter screens directly on the device, with app-private file storage; it is not a WebView or browser launcher. Neither version needs Flutter installed on the user’s device.

The interface uses the approved restrained green design, custom GSU EventHub calendar/G logo, bundled Inter typography, and a floating four-action bottom navigation. Navigation and picker buttons have 48-pixel minimum targets. Safe-area padding keeps controls clear of phone home indicators. Forms scroll with the keyboard, and calendar weeks scroll horizontally on narrow devices. Larger text and portrait/landscape layouts are covered by widget tests.

New planners start empty. This styling update preserves the local-storage key and previously saved events; it does not insert example records or clear user data.

## Cloud development

The cloud SDK is retained at `/workspace/tools/flutter-3.47.7`. The cloud also has Android SDK 35/36, NDK, CMake, and a full Java 17 compiler for APK builds. Android hardware acceleration is unavailable here; the normal emulator checks run in GitHub Actions. The Windows laptop needs only a modern browser for the hosted app, or the compiled download below.

```bash
cd /workspace/gsu-eventhub.github.io
bash tool/setup-cloud.sh
source tool/cloud-env.sh
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
```

The setup script pins the official Flutter commit, enables web, uses writable workspace caches, restores the checked-in dependency lockfile, and prepares Go for the launcher and Node browser-test dependencies. It preserves TLS and checksum verification. Use the existing isolated checkout; no extra Git worktree is required. Source `tool/cloud-env.sh` in each new cloud shell. Runtime processes must be restarted in a new task.

Required development destinations include `github.com`, `storage.googleapis.com`, `pub.dev`, and `pub.dartlang.org` (including package redirects). Launcher/test setup also uses `go.dev`, `dl.google.com`, `registry.npmjs.org`, and Playwright's browser-download domains. This cloud instance currently allows these through its unrestricted network policy. No application credentials are required. The built app loads its fonts, icons, and CanvasKit renderer from bundled files, with no external resource requests.

```bash
source tool/cloud-env.sh
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze --no-pub
flutter test --no-pub
flutter build web --release --no-pub --base-href / --no-web-resources-cdn
# Serve the build in one shell, then check it in another:
python3 -m http.server 8080 --bind 127.0.0.1 --directory build/web
CHROMIUM_PATH=/usr/bin/chromium node tool/browser/check.cjs
# Launcher checks:
(cd windows_launcher && go test ./...)
```

Outside this cloud, install Flutter 3.47.7 and use the same Flutter commands; the workspace-specific environment script is only for the cloud. Browser checks use `tool/browser/package-lock.json`; run `npm ci` there and `npx playwright install chromium` if a browser is not already available. `CHROMIUM_PATH` is optional when using Playwright's downloaded Chromium.

## GitHub Pages and downloads

In this repository's **Settings → Pages**, select **GitHub Actions** as the build/deployment source. Push the implementation to `main`. The delivery workflow formats-checks, analyzes, runs tests, builds web, and runs Chromium checks before deployment. It pins **Flutter 3.47.7 stable**, builds with the root base path **`/`**, and deploys to **https://gsu-eventhub.github.io/**. No repository-name path suffix is used. Deployment must succeed in Actions before the live URL is considered verified.

Every successful delivery run uploads **compiled-web**, **Windows-x64-tested-package**, and **Android-APK** artifacts. Android upload is gated by its emulator checks. Actions artifacts download inside GitHub's outer ZIP; extract that first. The Windows job compiles a standalone x64 EXE, packages all web/runtime/font assets, extracts the ZIP, executes that extracted EXE on `windows-latest`, fetches runtime assets, and runs browser checks against its local server.

To create a public release, a maintainer pushes a `v*` tag (for example `v1.0.0`) after reviewing the changes. The release job waits for web verification, Windows tests, and Android emulator checks. Only then does it publish the compiled web ZIP, Windows x64 ZIP, and Android APK as release assets. Pushes to main deploy the site and provide tested Actions downloads. A GitHub Release requires a separate version tag.

### Android download and install

Open a successful [Actions run](https://github.com/GSU-EventHub/gsu-eventhub.github.io/actions), sign in, scroll to **Artifacts**, and download **Android-APK**. Extract the GitHub ZIP and open **GSU-EventHub-Android.apk** on an Android 7.0+ phone. Android may ask you to allow installation from that file source. The APK works offline and has no account, browser, or development-tool requirement. This is not an iPhone/iOS package. See [Android instructions](docs/ANDROID.txt).

The current classroom APK is a release-optimized build signed with a development certificate. Stable production upgrade signing and Play Store publishing are not configured. A different CI development certificate can prevent installing a later APK over the previous one. Uninstalling permits reinstalling but **deletes that app’s events**; retain the current APK while its data matters. No private signing material is committed. GitHub secret administration was unavailable to this integration, so no claim is made that a persistent private signing key was configured.

The Android job uses Flutter 3.47.7, Java 17, Android APIs 35/36, NDK 28.2, CMake 3.22.1, and an API 35 emulator. It verifies actual native Flutter libraries, assets, APK signature, minimum Android version, and absence of internet/storage permissions. It exercises CRUD, on-device persistence across reopening, picker/dialog Back, then installs the actual release APK and checks Home, Android Back, and force-stop/relaunch. Device evidence is uploaded separately.

For Android development on another machine with Android SDK/Java installed:

```bash
flutter pub get --enforce-lockfile
flutter test integration_test/android_app_test.dart -d <android-device-id>
flutter build apk --release
```

In this cloud, prepare or restore the Android tools with `bash tool/setup-android-cloud.sh`, then source `tool/android-cloud-env.sh` before APK commands. It selects workspace caches, Java 17, the managed proxy, and the existing system CA trust store without changing global trust or disabling TLS checks. The setup pins verified Google command-line tools and a checksum-verified Temurin JDK. Source downloads include the Android project but are not installable APKs.

### Windows x64 launch

Download **GSU-EventHub-Windows-x64.zip** from a successful Actions run or GitHub Release. Extract the **entire** ZIP and open **GSU-EventHub.exe**. Its adjacent `web` folder must remain intact. Keep the console window open while using the app; closing it stops the server. The launcher opens your default browser and serves only local static files at a fixed loopback address. It requires no Flutter, Dart, Go, Python, Node, or installed application runtime. It is an unsigned executable; follow your institution's device policy. See [Windows instructions](docs/WINDOWS.txt).

If the browser does not open, enter `http://127.0.0.1:47831/`. If startup reports a port conflict, close another launcher before retrying. The fixed address preserves the browser origin across launches. The downloadable app needs no internet connection after extraction.

GitHub's green **Code → Download ZIP** and automatic **Source code (zip)** release links contain **source**, not a compiled app. They cannot be launched by double-clicking. The compiled Web ZIP is for static hosting; do not open `index.html` using `file://`. The Windows ZIP includes the server and is the download intended for a Windows laptop without development tools.

## Storage and privacy

On the web, event data is stored under `gsu-eventhub.events.v1` in that browser’s local storage. On Android, the same schema is saved in an app-private file; no storage permission is required. Android and web planners have separate data. Uninstalling Android or clearing its app data deletes its events. Automatic Android backup is disabled. Nothing is sent to organizers. Data is specific to the origin, browser, and profile: the hosted site and Windows launcher keep separate planners. Clearing site data, private browsing expiration, or changing browser/profile/address can remove or hide events. There is no cloud backup, export, sync, shared publishing, or multi-tab conflict resolution; concurrent tabs use the last saved list. Event times use local wall-clock time and do not carry a time zone.

Invalid saved records are skipped with a visible warning; valid records remain usable. Completely unreadable data opens an empty planner with a warning. Loading never overwrites the original saved data. The next successful save replaces unreadable/skipped data with the current valid list. A storage write failure leaves the current in-memory events unchanged and shows a recovery message. Deleting the final event persists an empty list; refresh never restores sample data.

## Structure

- `lib/models/event.dart`: event data, date/time helpers, persisted-record validation.
- `lib/storage/`: a small storage interface, conditional platform selection, browser adapter, and native file adapter; an in-memory adapter supports tests.
- `lib/planner.dart`: built-in `ChangeNotifier` state, persistence, ordering, filters, calendar state.
- `lib/screens/`: home/events list, calendar, form, details, and confirmation screens.
- `lib/main.dart`: `go_router` browser routes. The green Material theme, bundled font, and custom logo live in `lib/branding.dart`.
- `test/`, `tool/browser/`, `integration_test/`: model/storage/widget, compiled-browser, and Android emulator checks.
- `android/`: Android manifest, Kotlin Flutter activity, app icon, and Gradle configuration.
- `windows_launcher/`: small Go static-file launcher; Go's standard library only.

Runtime Dart dependencies are `go_router` for navigation, `web` for browser local storage, and `path_provider` for the Android app’s private storage directory. Inter and Material icons are bundled, with font licensing included. No external font service is used. Characters outside the bundled font's glyph set may display as missing glyphs; remote font fallback is disabled.

## Verification and course submission

See [verification results](docs/VERIFICATION.md), the [concept document](docs/CONCEPT.md), and the [requirement/evidence checklist](docs/REQUIREMENTS.md). The course guide was not available in the attached files or workspace during implementation, so guide-specific rubric coverage needs confirmation. The app's detailed requested requirements are mapped separately from unverified delivery and submission evidence.
