import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'planner.dart';
import 'storage/browser_store.dart';
import 'screens/home.dart';
import 'screens/event_form.dart';
import 'screens/event_details.dart';
import 'screens/calendar.dart';

void main() => runApp(EventHub(planner: Planner(BrowserStore())));

class EventHub extends StatefulWidget {
  final Planner planner;
  final String? initialLocation;
  const EventHub({super.key, required this.planner, this.initialLocation});
  @override
  State<EventHub> createState() => _EventHubState();
}

class _EventHubState extends State<EventHub> {
  @override
  void initState() {
    super.initState();
    GoRouter.optionURLReflectsImperativeAPIs = true;
  }

  late final router = GoRouter(
    initialLocation: widget.initialLocation,
    routes: [
      GoRoute(
        path: '/',
        builder: (c, s) => WelcomeScreen(planner: widget.planner),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (c, s) => HomeScreen(planner: widget.planner),
      ),
      GoRoute(
        path: '/events',
        builder: (c, s) => HomeScreen(planner: widget.planner, list: true),
      ),
      GoRoute(
        path: '/calendar',
        builder: (c, s) => CalendarScreen(
          planner: widget.planner,
          expanded: s.uri.queryParameters['expanded'] == '1',
        ),
      ),
      GoRoute(
        path: '/events/new',
        builder: (c, s) => EventForm(
          planner: widget.planner,
          initialDate: DateTime.tryParse(s.uri.queryParameters['at'] ?? ''),
        ),
      ),
      GoRoute(
        path: '/events/:id/edit',
        builder: (c, s) =>
            EventForm(planner: widget.planner, id: s.pathParameters['id']),
      ),
      GoRoute(
        path: '/events/:id/delete',
        pageBuilder: (c, s) => CustomTransitionPage<void>(
          key: s.pageKey,
          opaque: false,
          barrierDismissible: false,
          transitionsBuilder: (c, a, b, child) =>
              FadeTransition(opacity: a, child: child),
          child: DeleteEvent(
            planner: widget.planner,
            id: s.pathParameters['id']!,
          ),
        ),
      ),
      GoRoute(
        path: '/events/:id',
        builder: (c, s) =>
            EventDetails(planner: widget.planner, id: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/saved/:id',
        builder: (c, s) => SaveConfirmation(
          planner: widget.planner,
          id: s.pathParameters['id']!,
        ),
      ),
    ],
    errorBuilder: (c, s) => Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: () => c.go('/dashboard'),
          child: const Text('Return to planner'),
        ),
      ),
    ),
  );
  @override
  void dispose() {
    router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'GSU EventHub',
    debugShowCheckedModeBanner: false,
    routerConfig: router,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: Color(0xff181818),
        onPrimary: Colors.white,
        primaryContainer: Color(0xffe5e5e5),
        onPrimaryContainer: Colors.black,
        secondary: Color(0xff555555),
        onSecondary: Colors.white,
        secondaryContainer: Color(0xffe5e5e5),
        onSecondaryContainer: Colors.black,
        tertiary: Color(0xff777777),
        onTertiary: Colors.white,
        error: Color(0xff333333),
        onError: Colors.white,
        errorContainer: Color(0xffeeeeee),
        onErrorContainer: Colors.black,
        surface: Colors.white,
        onSurface: Color(0xff181818),
        onSurfaceVariant: Color(0xff555555),
        surfaceContainer: Color(0xfff2f2f2),
        surfaceContainerHighest: Color(0xffeeeeee),
        outline: Color(0xff888888),
        outlineVariant: Color(0xffdddddd),
      ),
      scaffoldBackgroundColor: const Color(0xfff7f7f7),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xffdddddd)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        ),
      ),
    ),
  );
}
