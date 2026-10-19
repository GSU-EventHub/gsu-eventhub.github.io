import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/event.dart';
import '../planner.dart';

IconData statusIcon(String status) => switch (status) {
  'Going' => Icons.check_circle_outline,
  'Attended' => Icons.task_alt,
  _ => Icons.bookmark_border,
};

class AppFrame extends StatelessWidget {
  final String title;
  final Widget child;
  final Planner planner;
  final int? selected;
  final bool add;
  final String? addLocation;
  final List<Widget>? actions;
  const AppFrame({
    super.key,
    required this.title,
    required this.child,
    required this.planner,
    this.selected,
    this.add = false,
    this.addLocation,
    this.actions,
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
      ),
      leading: selected == null
          ? IconButton(
              tooltip: 'Back',
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/dashboard');
                }
              },
            )
          : null,
      actions: actions,
    ),
    body: SafeArea(
      child: Column(
        children: [
          ListenableBuilder(
            listenable: planner,
            builder: (c, _) => planner.warning == null
                ? const SizedBox.shrink()
                : Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: const Color(0xffe8e8e8),
                    child: Text(
                      planner.warning!,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
          ),
          Expanded(child: child),
        ],
      ),
    ),
    floatingActionButton: add
        ? FloatingActionButton.extended(
            onPressed: () => context.push(addLocation ?? '/events/new'),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Add Event'),
          )
        : null,
    bottomNavigationBar: selected == null
        ? null
        : NavigationBar(
            selectedIndex: selected!,
            onDestinationSelected: (i) =>
                context.go(['/dashboard', '/events', '/calendar'][i]),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.space_dashboard_outlined),
                selectedIcon: Icon(Icons.space_dashboard),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.event_note_outlined),
                selectedIcon: Icon(Icons.event_note),
                label: 'Events',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month),
                label: 'Calendar',
              ),
            ],
          ),
  );
}

class Content extends StatelessWidget {
  final Widget child;
  const Content({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1000),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
        child: child,
      ),
    ),
  );
}

class EmptyState extends StatelessWidget {
  final String title, message;
  final IconData icon;
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.event_available,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 32),
    child: Column(
      children: [
        Icon(icon, size: 44, color: Colors.grey.shade600),
        const SizedBox(height: 16),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xff555555)),
        ),
      ],
    ),
  );
}

class EventCard extends StatelessWidget {
  final Event event;
  const EventCard({super.key, required this.event});
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.push('/events/${event.id}'),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xfff2f2f2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    monthNames[event.start.month - 1]
                        .substring(0, 3)
                        .toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${event.start.day}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('${timeLabel(event.start)} – ${timeLabel(event.end)}'),
                  Text(
                    event.venue,
                    style: const TextStyle(color: Color(0xff555555)),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      Text(
                        event.category,
                        style: const TextStyle(fontSize: 12),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon(event.status), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            event.status,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    ),
  );
}

Widget sectionTitle(BuildContext context, String title) => Padding(
  padding: const EdgeInsets.only(top: 24, bottom: 12),
  child: Text(
    title,
    style: Theme.of(
      context,
    ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
  ),
);
