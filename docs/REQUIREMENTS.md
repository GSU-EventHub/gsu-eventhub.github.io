# Requirement coverage and submission evidence

This maps the user's project brief. The course guide could not be found in this chat's attachments or workspace, so course-specific rubric alignment is **pending the guide**.

| Requirement | Implementation / evidence |
| --- | --- |
| Flutter/Dart web, stable 3.47.7 | `.flutter-version`, pinned cloud setup, pinned Actions; local version confirmed |
| Personal planner, starts empty | Empty initial state; storage and browser tests; no production fixtures |
| All event fields, optional organizer/description | Model, add/edit form, details |
| Required fields, valid date/time, end after start | Form validation and model/storage tests; same-day events |
| Create/view/edit/delete, confirmation | Seven screens plus routed deletion confirmation; widget/browser tests |
| Search title/venue; category/status filters | Events list with combined filters; model/browser tests |
| Chronological upcoming, separate past/attended | Dashboard and Events sections |
| Browser persistence and invalid-data recovery | Versioned local storage adapter, visible warnings; tests include reload/edit/delete and malformed saved data |
| Intentional deletion survives refresh | Empty list explicitly persisted; tested in Chromium |
| Black/white/grayscale, cards, icons, bundled fonts | Material theme, bundled Roboto and Material icons; no external requests in browser checks |
| Portrait, landscape, desktop | Widget and browser checks at 320×640, 844×390, 1440×900 |
| Floating Add Event on main screens | Dashboard, Events, Calendar, expanded timetable |
| Calendar Day/Week/Month, Mon/Tue labels, AM/PM | Calendar controls, labeled timetable, chronological time placement |
| Date/range centered between arrows, compact Today | Calendar header and responsive toolbar |
| Duration/overlap placement, horizontal week scrolling | Wall-clock timetable positions and greedy overlap lanes; horizontally scrollable week |
| Expanded timetable and date/time prefill | Expanded calendar route and tappable hour slots |
| Calendar navigation state | Planner retains selected date, mode, month/timetable vertical and week horizontal offsets |
| Browser Back/Forward including deletion dialog | URL-reflected `go_router` routes; browser tests; form choices are inline chips, so there are no popup menus |
| Normal browser navigation at app root | Tested with a preceding browser page; no global Back interception |
| Pages on main, `/` base path | `.github/workflows/delivery.yml`; live deployment still awaits a successful Actions run and Pages settings |
| Compiled web artifact, Windows x64 ZIP | Delivery workflow and local compiled outputs |
| EXE serves bundled app with no laptop tools | Go standard-library launcher with fixed loopback origin; no external runtime dependencies |
| Windows runner test before Release | Windows job extracts ZIP, runs EXE, checks assets and browser behavior; release depends on its success. Runner execution remains pending |
| Format, analyze, tests, web build | Commands and outcomes recorded in `VERIFICATION.md` |
| 150–200-word concept | `CONCEPT.md` |
| Usage, cloud, deployment, downloads, storage docs | Root README and `WINDOWS.txt` |

## Submission evidence still needed

- Supply the actual course guide and compare its rubric, prescribed templates, and required platform with this implementation.
- Fill in student name, course/section, instructor, and submission date wherever the course requires them. These details were not supplied.
- Record a short demonstration: empty planner → invalid form → save → details → edit → search/filter → calendar views and prefill → Back/Forward → delete confirmation → refresh.
- Capture a successful GitHub Actions run, the deployed Pages URL, and a Windows job proving the **extracted** EXE passed its checks. Those remote runs have not occurred in this cloud task.
- Try the compiled ZIP on the actual Windows laptop and the site in a physical Android browser; record browser/OS versions and results. Emulated viewport checks are not device certification.
- Assemble any required presentation, source submission, screenshots, diagrams, test report, and demonstration video according to the guide. A concept document, screen captures, and technical test report are included, but no claim is made about an unseen course rubric.

Do not submit GitHub's source ZIP as if it were the compiled Windows application. Use the separately named compiled release assets or successful Actions artifacts.
