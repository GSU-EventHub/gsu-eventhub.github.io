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

## Production deployment and Windows verification

[GitHub Actions run 39261626467](https://github.com/GSU-EventHub/gsu-eventhub.github.io/actions/runs/39261626467), for application commit `fca60f884c47e62d799ebf1b764488771637b4ce`, completed successfully on 19 October 2026:

- **verify:** pinned Flutter installation, formatting, analysis, all 11 tests, release build, Chromium browser suite, and artifact uploads passed on Ubuntu.
- **pages:** deployed successfully to **https://gsu-eventhub.github.io/**. Pages is configured with GitHub Actions as its source.
- **windows:** Go tests, x64 EXE compilation, ZIP extraction, actual EXE execution, runtime asset requests, and the Chromium suite passed on `windows-latest`.
- **release:** correctly skipped for the main-branch push; no version tag or GitHub Release was published.

The public HTTPS HTML, bootstrap JavaScript, compiled main JavaScript, asset manifest, bundled Roboto font, and CanvasKit WASM were fetched with TLS verification enabled. Their SHA-256 hashes match the files in the exact Windows-tested CI package. The local Windows download was replaced with that CI-tested ZIP.

The integration could push the implementation but received HTTP 403 when changing Pages settings. The user changed the Pages source to GitHub Actions. A separate direct Chromium HTTPS check in the cloud could not proceed because its proxy CA was missing from Chromium's trust store. Automatic approval review rejected adding that CA because it would broaden persistent browser trust; no trust change or TLS-verification bypass was made. Public deployment was instead verified through HTTPS file/hash checks and the successful CI browser tests.

## What the tests exercise

The seven storage/model tests cover an empty first load, save/reload, edits, deletion including the last event, combined search/category/status filters, chronological ordering, partially invalid records, duplicate IDs, invalid JSON/schema recovery, write failure without losing current state, date/time parsing, and invalid persisted durations.

The four widget tests cover the full welcome/dashboard/create/validate/save/details/edit/delete-confirm/cancel/delete flow; required-field and end-time errors; portrait, landscape, and desktop layouts; calendar selection across navigation; precise timetable start positions, duration heights, overlap lanes, and selecting an hour to prefill date/start/end.

The compiled-app Chromium checks use an isolated browser context. They exercise root Back to a preceding page; Back/Forward from a form; URL changes; save across a full refresh; edit and status persistence; Back/Forward and cancellation of deletion confirmation; actual deletion followed by refresh; combined search/category/status filters; calendar date/view and horizontal/vertical scroll restoration; expanded timetable Back; invalid local-storage recovery; and page loading at 320×640, 844×390, and 1440×900. No JavaScript runtime errors or external resource requests occurred during that suite. Responsive widget checks also detect Flutter render overflow, which a DOM-only width check would miss.

Screenshots in [screenshots](screenshots/) show the seven requested screens plus a desktop week timetable. They use isolated screenshot fixtures; the production app never seeds these records.

## Not verified here

- **Windows default-browser opening on the user's laptop:** actual Windows executable serving and browser tests passed in CI. Automated tests deliberately suppress automatic browser opening; the operating-system URL-handler interaction still needs a laptop check.
- **GitHub Release:** delivery artifacts exist in the successful Actions run, but no version tag or Release was published.
- **Direct interactive testing of the public HTTPS URL from this cloud browser:** blocked by the certificate-trust limitation described above. The live files match the Windows-tested build; no claim is made about an interactive public-URL browser run here.
- **Physical devices and other browsers:** Chromium and simulated viewports were checked. Physical Android Back behavior, the user's Windows laptop, Safari, and Firefox have not been tested. Viewport tests do not establish native Android support; this is a web app.
- **Unseen course guide:** no course-guide attachment or matching workspace file was available. Guide-specific assessment and student/instructor submission details remain pending.
- **Published cloud snapshot restoration:** the setup scripts were exercised in this instance and saved. Restoration in a fresh task after publication has not been independently verified.
