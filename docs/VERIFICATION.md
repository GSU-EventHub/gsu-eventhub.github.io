# Verification record

Verified in the Linux cloud workspace on **19 October 2026** using **Flutter 3.47.7 stable**, framework commit `abaf9c523780a608bd46686fd5e53740a07077f8`, **Dart 3.13.5**, **Go 1.27.2**, and Chromium via Playwright 1.58.2. Production events begin empty; event examples in tests and screenshots are fixtures only.

| Check | Outcome |
| --- | --- |
| `bash tool/setup-cloud.sh` | Passed, including a repeat run with the pinned SDK and locked dependencies |
| `dart format --output=none --set-exit-if-changed lib test` | Passed; 14 files, no changes |
| `flutter analyze --no-pub` | Passed; no issues |
| `flutter test --no-pub` | **11 tests passed**, no skipped tests |
| `flutter build web --release --no-pub --base-href / --no-web-resources-cdn` | Passed; compiled files in `build/web` |
| `CHROMIUM_PATH=/usr/bin/chromium node tool/browser/check.cjs` | Passed against the final compiled web build |
| Flutter development-server startup | Passed; actual debug app loaded in Chromium and navigated Welcome → empty dashboard |
| `go test ./...` in `windows_launcher` | Passed; static app serving, health marker, unsupported-method rejection |
| Windows x64 cross-compilation | Passed; PE32+ x86-64 console executable produced |
| Equivalent Linux launcher with full web bundle | Passed; served HTML, bootstrap, main JS, font, manifest, and CanvasKit WASM through HTTP |
| Compiled Web and Windows ZIP integrity | Passed; extracted entries' CRCs valid, full asset tree included |
| `git diff --check` | Passed |
| Reusable cloud configuration | `install_script` and `start_skill` saved successfully as a draft; publication is a separate user action |

The web build emitted a nonfatal framework icon-tree-shaking warning naming an unused Cupertino icon family. This app uses bundled Material icons; those icons and the app rendered during browser checks. The build completed successfully. Flutter's optional Wasm dry run also succeeded; the delivered app uses the standard JavaScript web release build.

## What the tests exercise

The seven storage/model tests cover an empty first load, save/reload, edits, deletion including the last event, combined search/category/status filters, chronological ordering, partially invalid records, duplicate IDs, invalid JSON/schema recovery, write failure without losing current state, date/time parsing, and invalid persisted durations.

The four widget tests cover the full welcome/dashboard/create/validate/save/details/edit/delete-confirm/cancel/delete flow; required-field and end-time errors; portrait, landscape, and desktop layouts; calendar selection across navigation; precise timetable start positions, duration heights, overlap lanes, and selecting an hour to prefill date/start/end.

The compiled-app Chromium checks use an isolated browser context. They exercise root Back to a preceding page; Back/Forward from a form; URL changes; save across a full refresh; edit and status persistence; Back/Forward and cancellation of deletion confirmation; actual deletion followed by refresh; combined search/category/status filters; calendar date/view and horizontal/vertical scroll restoration; expanded timetable Back; invalid local-storage recovery; and page loading at 320×640, 844×390, and 1440×900. No JavaScript runtime errors or external resource requests occurred during that suite. Responsive widget checks also detect Flutter render overflow, which a DOM-only width check would miss.

Screenshots in [screenshots](screenshots/) show the seven requested screens plus a desktop week timetable. They use isolated screenshot fixtures; the production app never seeds these records.

## Not verified here

- **Windows execution:** this machine is Linux. The Windows EXE was cross-compiled but not executed here. The configured `windows-latest` job will extract the distributable ZIP, run that exact EXE, check bundled assets, and run the browser suite against its server. Release publication depends on that job succeeding. Windows default-browser opening is implemented using the operating system URL handler; automated tests suppress automatic opening and have not verified that interaction on the user's laptop.
- **GitHub Actions, Pages, and Release:** workflows are implemented but have not run remotely in this task. No push, Pages deployment, or Release publication was performed. Pages must be configured to use GitHub Actions, then the branch pushed. Review successful runs before submitting downloads as tested Windows deliverables.
- **Physical devices and other browsers:** Chromium and simulated viewports were checked. Physical Android Back behavior, the user's Windows laptop, Safari, and Firefox have not been tested. Viewport tests do not establish native Android support; this is a web app.
- **Unseen course guide:** no course-guide attachment or matching workspace file was available. Guide-specific assessment and student/instructor submission details remain pending.
- **Published cloud snapshot restoration:** the setup scripts were exercised in this instance and saved. Restoration in a fresh task after publication has not been independently verified.
