import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../planner.dart';
import '../models/event.dart';
import 'common.dart';

class WelcomeScreen extends StatelessWidget {
  final Planner planner;
  const WelcomeScreen({super.key, required this.planner});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Content(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.event_note, size: 56),
            const SizedBox(height: 24),
            const Text(
              'GSU EventHub',
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your campus.\nYour plans.',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Keep seminars, workshops, club activities, and sports in one personal planner.',
              style: TextStyle(fontSize: 17, height: 1.6),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.push('/dashboard'),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Open my planner'),
            ),
            const SizedBox(height: 32),
            const Text(
              'Private to this browser',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'No account needed. Interested, Going, and Attended are your personal labels. They do not register you for an event. Your events stay on this device and browser.',
            ),
          ],
        ),
      ),
    ),
  );
}

class HomeScreen extends StatefulWidget {
  final Planner planner;
  final bool list;
  const HomeScreen({super.key, required this.planner, this.list = false});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final search = TextEditingController(text: widget.planner.query);
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.planner,
    builder: (c, _) {
      final p = widget.planner;
      final all = widget.list
          ? p.filtered()
          : (p.events.toList()..sort((a, b) => a.start.compareTo(b.start)));
      final upcoming = all
          .where((e) => !e.isPast && e.status != 'Attended')
          .toList();
      final past = all
          .where((e) => e.isPast && e.status != 'Attended')
          .toList();
      final attended = all.where((e) => e.status == 'Attended').toList();
      return AppFrame(
        title: 'GSU EventHub',
        planner: p,
        selected: widget.list ? 1 : 0,
        add: true,
        child: Content(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.list ? 'Your events' : 'Make room for campus life.',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.list
                    ? 'Find a plan, revisit a memory.'
                    : 'A little planning. More showing up.',
                style: const TextStyle(color: Color(0xff555555)),
              ),
              if (!widget.list) ...[
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _stat('Upcoming', upcoming.length),
                    _stat(
                      'Going',
                      all.where((e) => !e.isPast && e.status == 'Going').length,
                    ),
                    _stat('Attended', attended.length),
                  ],
                ),
                sectionTitle(context, 'Up next'),
                if (upcoming.isEmpty)
                  const EmptyState(
                    title: 'Your next event starts here',
                    message: 'Tap Add Event to make your first campus plan.',
                  ),
                ...upcoming.take(5).map((e) => EventCard(event: e)),
                TextButton.icon(
                  onPressed: () => context.go('/events'),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('View all events'),
                ),
              ] else ...[
                const SizedBox(height: 24),
                TextField(
                  controller: search,
                  decoration: const InputDecoration(
                    labelText: 'Search title or venue',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (v) => setState(() => p.query = v),
                ),
                sectionTitle(context, 'Category'),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: ['All', ...categories]
                      .map(
                        (v) => ChoiceChip(
                          label: Text(v),
                          selected: p.category == v,
                          onSelected: (_) => setState(() => p.category = v),
                        ),
                      )
                      .toList(),
                ),
                sectionTitle(context, 'Personal status'),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: ['All', ...statuses]
                      .map(
                        (v) => ChoiceChip(
                          label: Text(v),
                          selected: p.status == v,
                          onSelected: (_) => setState(() => p.status = v),
                        ),
                      )
                      .toList(),
                ),
                if (all.isEmpty)
                  EmptyState(
                    title: p.events.isEmpty
                        ? 'No events yet'
                        : 'No matching events',
                    message: p.events.isEmpty
                        ? 'Add your first event to start planning.'
                        : 'Try a different search or filter.',
                  ),
                sectionTitle(context, 'Upcoming · ${upcoming.length}'),
                ...upcoming.map((e) => EventCard(event: e)),
                if (upcoming.isEmpty && all.isNotEmpty)
                  const Text('No upcoming events in this view.'),
                sectionTitle(context, 'Past · ${past.length}'),
                ...past.reversed.map((e) => EventCard(event: e)),
                if (past.isEmpty) const Text('Past events will appear here.'),
                sectionTitle(context, 'Attended · ${attended.length}'),
                ...attended.reversed.map((e) => EventCard(event: e)),
                if (attended.isEmpty)
                  const Text('Mark an event Attended after you take part.'),
              ],
            ],
          ),
        ),
      );
    },
  );
  Widget _stat(String label, int count) => Container(
    width: 145,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xffdddddd)),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$count',
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        Text(label),
      ],
    ),
  );
}
