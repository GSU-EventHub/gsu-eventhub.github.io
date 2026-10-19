# GSU EventHub

A personal campus event scheduler built with **Flutter 3.47.7 stable and Dart**, targeting the web. A second-year student's solo project, separate from iSkedyul.

Plan seminars, workshops, sports, and club activities. **Interested, Going, and Attended are personal labels, not organizer registrations.** The planner starts empty. There are no accounts, backend services, external APIs, notifications, or paid services.

## Use the planner

1. Open the app and select **Open my planner**.
2. Tap **Add Event**. Enter a title, date (`YYYY-MM-DD`), start/end times (for example `9:00 AM` and `10:30 AM`), venue, category, and personal status. Organizer and plain-text description are optional. Events start and finish on the same day; end time must follow start time.
3. Save, then open the event details to edit or delete it. Deletion requires confirmation.
4. Search event titles or venues in **Events** and combine category/status filters. Upcoming events are chronological; past and attended events have their own sections.
5. Use **Calendar** for Month, Week, or Day views. Select a day, tap an hour to prefill a new event, use the arrows or Today, and expand the timetable when needed. Weeks scroll horizontally on narrow screens. Calendar selection and scroll positions survive navigation within the running app.

Browser Back/Forward follows screens, forms, expanded calendar, and the deletion confirmation. Forms use inline choices rather than popup menus. Leaving an unsaved form discards its changes. At the app root, Back remains normal browser navigation. Routes use `/#/...`, which also works on refresh and GitHub Pages without server rewrite rules. This is a web application, including when used in an Android browser.

## Cloud development

The cloud SDK is retained at `/workspace/tools/flutter-3.47.7`. No Android SDK or emulator is needed. The Windows laptop needs only a modern browser for the hosted app, or the compiled download below.

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
dart format --output=none --set-exit-if-changed lib test
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

Every successful delivery run uploads a **compiled-web** artifact and a **Windows-x64-tested-package** artifact. Actions artifacts download inside GitHub's outer ZIP; extract that first. The Windows job compiles a standalone x64 EXE, packages all web/runtime/font assets, extracts the ZIP, executes that extracted EXE on `windows-latest`, fetches runtime assets, and runs browser checks against its local server.

To create a public release, a maintainer pushes a `v*` tag (for example `v1.0.0`) after reviewing the changes. The release job waits for both the web verification and Windows tests. Only then does it publish **GSU-EventHub-Web.zip** and **GSU-EventHub-Windows-x64.zip** as release assets. This repository change does not itself push, deploy, or publish a release.

### Windows x64 launch

Download **GSU-EventHub-Windows-x64.zip** from a successful Actions run or GitHub Release. Extract the **entire** ZIP and open **GSU-EventHub.exe**. Its adjacent `web` folder must remain intact. Keep the console window open while using the app; closing it stops the server. The launcher opens your default browser and serves only local static files at a fixed loopback address. It requires no Flutter, Dart, Go, Python, Node, or installed application runtime. It is an unsigned executable; follow your institution's device policy. See [Windows instructions](docs/WINDOWS.txt).

If the browser does not open, enter `http://127.0.0.1:47831/`. If startup reports a port conflict, close another launcher before retrying. The fixed address preserves the browser origin across launches. The downloadable app needs no internet connection after extraction.

GitHub's green **Code → Download ZIP** and automatic **Source code (zip)** release links contain **source**, not a compiled app. They cannot be launched by double-clicking. The compiled Web ZIP is for static hosting; do not open `index.html` using `file://`. The Windows ZIP includes the server and is the download intended for a Windows laptop without development tools.

## Storage and privacy

All event data is stored under `gsu-eventhub.events.v1` in that browser's local storage. Nothing is sent to organizers. Data is specific to the origin, browser, and profile: the hosted site and Windows launcher keep separate planners. Clearing site data, private browsing expiration, or changing browser/profile/address can remove or hide events. There is no cloud backup, export, sync, shared publishing, or multi-tab conflict resolution; concurrent tabs use the last saved list. Event times use local wall-clock time and do not carry a time zone.

Invalid saved records are skipped with a visible warning; valid records remain usable. Completely unreadable data opens an empty planner with a warning. Loading never overwrites the original saved data. The next successful save replaces unreadable/skipped data with the current valid list. A storage write failure leaves the current in-memory events unchanged and shows a recovery message. Deleting the final event persists an empty list; refresh never restores sample data.

## Structure

- `lib/models/event.dart`: event data, date/time helpers, persisted-record validation.
- `lib/storage/`: a tiny storage interface and browser adapter; an in-memory adapter supports tests.
- `lib/planner.dart`: built-in `ChangeNotifier` state, persistence, ordering, filters, calendar state.
- `lib/screens/`: welcome/dashboard/list, calendar, form, details, and confirmation screens.
- `lib/main.dart`: grayscale Material theme and `go_router` browser routes.
- `test/`, `tool/browser/`: model/storage/widget and compiled-browser checks.
- `windows_launcher/`: small Go static-file launcher; Go's standard library only.

Runtime Dart dependencies are `go_router` for browser history and `web` for local storage. Roboto and Material icons are bundled, with font licensing included. No external font service is used. Characters outside the bundled font's glyph set may display as missing glyphs; remote font fallback is disabled.

## Verification and course submission

See [verification results](docs/VERIFICATION.md), the [concept document](docs/CONCEPT.md), and the [requirement/evidence checklist](docs/REQUIREMENTS.md). The course guide was not available in the attached files or workspace during implementation, so guide-specific rubric coverage needs confirmation. The app's detailed requested requirements are mapped separately from unverified delivery and submission evidence.
