# Verification record

Verified in the Linux cloud workspace on **19 October 2026** using **Flutter 3.47.7 stable**, framework commit `abaf9c523780a608bd46686fd5e53740a07077f8`, **Dart 3.13.5**, **Go 1.27.2**, and Chromium via Playwright 1.58.2. Production events begin empty; event examples in tests and screenshots are fixtures only.

| Check | Outcome |
| --- | --- |
| `bash tool/setup-cloud.sh` | Passed, including a repeat run with the pinned SDK and locked dependencies |
| `dart format --output=none --set-exit-if-changed lib test` | Passed; no changes |
| `flutter analyze --no-pub` | Passed; no issues |
| `flutter test --no-pub` | **18 tests passed**, no skipped tests |
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

## Android addition

The source now targets Android as well as web. All **18 local unit/widget tests** passed, including four real-file tests for reopening/editing/deleting, interrupted temporary writes, malformed saved data, and failed writes. Local analysis passed. A local release APK built successfully using the newly installed Android SDK and Temurin Java 17. Its APK signature, native Flutter/Dart libraries, bundled fonts, Android 7+ minimum, and absence of internet/external-storage permissions passed inspection. KVM is unavailable here. Android emulator results are still pending and must not be inferred from the local widget tests. GitHub Actions is currently queued during reported degraded service performance. The package is development-signed, and stable production upgrade signing is not configured.

## Direct Home entry

The welcome screen and Open planner button have been removed at the user’s request. The root URL now renders Home directly. Home navigation targets the root, and older `/#/dashboard` links redirect there. Existing saved events are unaffected. The startup widget and browser checks now assert direct Home entry and browser Back from a form to the root. The earlier development-server result records the previous welcome flow.

## Mobile interface revision

The current revision adds the approved green branding, locally drawn calendar/G logo, bundled Inter font, empty dashboard, and floating four-action navigation. The account-related phrase has been removed. Existing event storage and its key are preserved; the interface update does not clear saved events.

The 14-test suite and release-build browser suite passed locally for this revision. After correcting the browser helper to wait for Flutter semantics text-editing activation, two consecutive full browser-suite runs passed. A separate emulated mobile-touch check passed navigation, text entry, picker Back/draft preservation, and week view. Date/time pickers and filters now have browser routes. Back dismisses them before leaving the form or list, and the form draft and selected filters remain. Widget checks include 320-pixel portrait, phone landscape, desktop, text scaling to 1.3, and a simulated software-keyboard inset. No Flutter render overflow was detected.

## Mobile revision deployment and Windows verification

[GitHub Actions run 39273646977](https://github.com/GSU-EventHub/gsu-eventhub.github.io/actions/runs/39273646977), for application commit `b889cb8ee6e11e82e2279e346564b8d6a1f6b4f1`, completed successfully:

- **verify:** formatting, analysis, all 14 tests, release build, browser behavior checks, and artifact uploads passed.
- **pages:** the mobile redesign deployed to **https://gsu-eventhub.github.io/**.
- **windows:** the extracted Windows x64 package's actual EXE, runtime assets, and browser suite passed on `windows-latest`.
- **release:** skipped because this was a main-branch push, not a version tag.

Verified HTTPS downloads of HTML, bootstrap, compiled main JavaScript, asset manifest, bundled Inter font, and CanvasKit WASM match the exact CI web artifact by SHA-256. TLS verification remained enabled. The UI source is unchanged by the follow-up browser-helper synchronization fix.

## Earlier production deployment and Windows verification

[GitHub Actions run 39261626467](https://github.com/GSU-EventHub/gsu-eventhub.github.io/actions/runs/39261626467), for application commit `fca60f884c47e62d799ebf1b764488771637b4ce`, completed successfully on 19 October 2026:

- **verify:** pinned Flutter installation, formatting, analysis, all 11 tests, release build, Chromium browser suite, and artifact uploads passed on Ubuntu.
- **pages:** deployed successfully to **https://gsu-eventhub.github.io/**. Pages is configured with GitHub Actions as its source.
- **windows:** Go tests, x64 EXE compilation, ZIP extraction, actual EXE execution, runtime asset requests, and the Chromium suite passed on `windows-latest`.
- **release:** correctly skipped for the main-branch push; no version tag or GitHub Release was published.

The public HTTPS HTML, bootstrap JavaScript, compiled main JavaScript, asset manifest, bundled Roboto font, and CanvasKit WASM were fetched with TLS verification enabled. Their SHA-256 hashes match the files in the exact Windows-tested CI package. The local Windows download was replaced with that CI-tested ZIP.

The integration could push the implementation but received HTTP 403 when changing Pages settings. The user changed the Pages source to GitHub Actions. A separate direct Chromium HTTPS check in the cloud could not proceed because its proxy CA was missing from Chromium's trust store. Automatic approval review rejected adding that CA because it would broaden persistent browser trust; no trust change or TLS-verification bypass was made. Public deployment was instead verified through HTTPS file/hash checks and the successful CI browser tests.

## What the tests exercise

The seven storage/model tests cover an empty first load, save/reload, edits, deletion including the last event, combined search/category/status filters, chronological ordering, partially invalid records, duplicate IDs, invalid JSON/schema recovery, write failure without losing current state, date/time parsing, and invalid persisted durations.

The seven widget tests cover the direct Home entry and full create/validate/save/details/edit/delete-confirm/cancel/delete flow; required-field and end-time errors; portrait, landscape, and desktop layouts; calendar selection across navigation; precise timetable start positions, duration heights, overlap lanes, and selecting an hour to prefill date/start/end; empty initial screens; minimum 48-pixel navigation targets; date-picker selection and draft preservation; filter Back behavior; larger text; and a software-keyboard inset.

The compiled-app Chromium checks use an isolated browser context. They exercise root Back to a preceding page; Back/Forward from a form and its date/time pickers; draft preservation; filter-panel Back; URL changes; save across a full refresh; edit and status persistence; Back/Forward and cancellation of deletion confirmation; actual deletion followed by refresh; combined search/category/status filters; calendar date/view and horizontal/vertical scroll restoration; expanded timetable Back; invalid local-storage recovery; and page loading at 320×640, 844×390, and 1440×900. No JavaScript runtime errors or external resource requests occurred during that suite. Responsive widget checks also detect Flutter render overflow, which a DOM-only width check would miss.

Screenshots in [screenshots](screenshots/) show the six current screens, an empty desktop dashboard, and a desktop week timetable. Main screens are empty. Only event-details and save-confirmation images use isolated fixtures; the production app never seeds these records.

## Not verified here

- **Windows default-browser opening on the user's laptop:** actual Windows executable serving and browser tests passed in CI. Automated tests deliberately suppress automatic browser opening; the operating-system URL-handler interaction still needs a laptop check.
- **GitHub Release:** delivery artifacts exist in the successful Actions run, but no version tag or Release was published.
- **Direct interactive testing of the public HTTPS URL from this cloud browser:** blocked by the certificate-trust limitation described above. The live files match the Windows-tested build; no claim is made about an interactive public-URL browser run here.
- **Physical devices and other browsers:** Chromium and simulated viewports were checked. Physical Android Back behavior, the user's Windows laptop, Safari, and Firefox have not been tested. The Android APK has separate emulator checks; viewport tests alone do not establish native device behavior.
- **Unseen course guide:** no course-guide attachment or matching workspace file was available. Guide-specific assessment and student/instructor submission details remain pending.
- **Published cloud snapshot restoration:** the setup scripts were exercised in this instance and saved. Restoration in a fresh task after publication has not been independently verified.
