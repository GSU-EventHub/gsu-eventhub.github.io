# GSU EventHub concept

GSU EventHub is a personal campus event scheduler that helps students organize seminars, workshops, sports events, and club activities. It is designed for students who want a simple overview of their commitments without creating an account or learning a complicated planning system. The application is a manageable solo project for a second-year student, with a small codebase and clear separation between event models, browser storage, and screens.

Students can create, view, edit, and delete events containing a title, date, start and end time, venue, and category. Optional organizer and description fields provide context. Interested, Going, and Attended are personal planning labels; they do not register students with event organizers. Search, category filters, status filters, and separate upcoming, past, and attended sections make events easy to find. Day, Week, and Month calendar views help students understand their schedules.

The chosen platform is Flutter and Dart targeting the web, with responsive layouts for mobile and desktop browsers. Events remain in browser-local storage. GitHub Pages hosts the compiled application, while an optional Windows x64 launcher serves the same bundled web application locally. No backend, external APIs, notifications, or paid services are required.
