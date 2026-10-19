import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'planner.dart';
import 'branding.dart';
import 'storage/browser_store.dart';
import 'screens/home.dart';
import 'screens/event_form.dart';
import 'screens/event_details.dart';
import 'screens/calendar.dart';
import 'screens/pickers.dart';

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
        builder: (c, s) => HomeScreen(planner: widget.planner),
      ),
      GoRoute(path: '/dashboard', redirect: (c, s) => '/'),
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
        routes: eventPickerRoutes(),
        builder: (c, s) => EventForm(
          planner: widget.planner,
          initialDate: DateTime.tryParse(s.uri.queryParameters['at'] ?? ''),
        ),
      ),
      GoRoute(
        path: '/events/:id/edit',
        routes: eventPickerRoutes(),
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
          onPressed: () => c.go('/'),
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
    theme: eventHubTheme(),
  );
}
