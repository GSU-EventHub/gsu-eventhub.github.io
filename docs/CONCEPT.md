# GSU EventHub concept

GSU EventHub is a personal campus event scheduler that helps students organize seminars, workshops, sports events, and club activities. It is designed for students who want a simple overview of their commitments without creating an account or learning a complicated planning system. The application is a manageable solo project for a second-year student, with a small codebase and clear separation between event models, platform storage, and screens.

Students can create, view, edit, and delete events containing a title, date, start and end time, venue, and category. Optional organizer and description fields provide context. Interested, Going, and Attended are personal planning labels; they do not register students with event organizers. Search, category filters, status filters, and separate upcoming, past, and attended sections make events easy to find. Day, Week, and Month calendar views help students understand their schedules.

The chosen platforms are Android and web, built with Flutter and Dart. The Android application saves events in app-private files; the responsive website uses browser-local storage. GitHub Pages hosts the website. An optional Windows launcher serves the bundled web application locally. No backend, external APIs, notifications, or paid services are required.
