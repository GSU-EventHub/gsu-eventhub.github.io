import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../branding.dart';
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
        maxWidth: 540,
        child: Column(
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height < 500 ? 12 : 70),
            const HubLogo(size: 64),
            const SizedBox(height: 25),
            Text(
              'GSU EventHub',
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'A personal planner for your campus events.',
              textAlign: TextAlign.center,
              style: TextStyle(color: HubColors.muted),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: () => context.push('/dashboard'),
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: const Text('Open planner'),
            ),
            const SizedBox(height: 30),
            const Text(
              'Interested, Going, and Attended are personal labels. They don’t register you with an organizer.',
              style: TextStyle(fontSize: 12, color: HubColors.muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Your events stay in this browser on this device.',
              style: TextStyle(fontSize: 12, color: HubColors.muted),
              textAlign: TextAlign.center,
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
      return AppFrame(
        title: 'GSU EventHub',
        planner: p,
        selected: widget.list ? 1 : 0,
        add: true,
        child: Content(
          child: widget.list ? _events(context, p) : _dashboard(context, p),
        ),
      );
    },
  );
  Widget _dashboard(BuildContext context, Planner p) {
    final now = DateTime.now();
    final upcoming =
        p.events.where((e) => !e.isPast && e.status != 'Attended').toList()
          ..sort((a, b) => a.start.compareTo(b.start));
    final panel = Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 18),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Upcoming events',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${upcoming.length} ${upcoming.length == 1 ? 'event' : 'events'}',
                  style: const TextStyle(fontSize: 12, color: HubColors.muted),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: HubColors.line),
          if (upcoming.isEmpty)
            EmptyState(
              title: 'No events yet',
              message: 'Add an event to start your planner.',
              onAdd: () => context.push('/events/new'),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 3),
              child: Column(
                children: [
                  ...upcoming.take(5).map((e) => EventCard(event: e)),
                  TextButton.icon(
                    onPressed: () => context.go('/events'),
                    icon: const Icon(Icons.arrow_forward, size: 17),
                    label: const Text('View all events'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
    final calendar = MiniCalendar(planner: p);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${weekdays[now.weekday - 1]}, ${dateLabel(now)}',
          style: const TextStyle(fontSize: 12, color: HubColors.muted),
        ),
        const SizedBox(height: 8),
        Text('Your planner', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 26),
        LayoutBuilder(
          builder: (c, box) => box.maxWidth >= 800
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: panel),
                    const SizedBox(width: 24),
                    SizedBox(width: 300, child: calendar),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [panel, const SizedBox(height: 22), calendar],
                ),
        ),
        const SizedBox(height: 19),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lock_outline, size: 15, color: HubColors.muted),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Interested, Going, and Attended are your personal labels.',
                style: TextStyle(fontSize: 12, color: HubColors.muted),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _events(BuildContext context, Planner p) {
    final filtered = p.filtered();
    final groups = <String, List<Event>>{
      'Upcoming': filtered
          .where((e) => !e.isPast && e.status != 'Attended')
          .toList(),
      'Past': filtered
          .where((e) => e.isPast && e.status != 'Attended')
          .toList()
          .reversed
          .toList(),
      'Attended': filtered
          .where((e) => e.status == 'Attended')
          .toList()
          .reversed
          .toList(),
    };
    final showFilters =
        GoRouterState.of(context).uri.queryParameters['filters'] == '1';
    final list = groups[p.eventSection]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Events', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 22),
        TextField(
          controller: search,
          decoration: InputDecoration(
            labelText: 'Search title or venue',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: p.query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      search.clear();
                      p.updateFilters(search: '');
                    },
                  ),
          ),
          onChanged: (v) => p.updateFilters(search: v),
        ),
        const SizedBox(height: 9),
        Row(
          children: [
            TextButton.icon(
              onPressed: () {
                if (showFilters) {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/events');
                  }
                } else {
                  context.push('/events?filters=1');
                }
              },
              icon: const Icon(Icons.tune, size: 18),
              label: Text(showFilters ? 'Close filters' : 'Filters'),
            ),
            if (p.category != 'All' || p.status != 'All')
              Expanded(
                child: Text(
                  '${p.category == 'All' ? '' : p.category}${p.category != 'All' && p.status != 'All' ? ' · ' : ''}${p.status == 'All' ? '' : p.status}',
                  style: const TextStyle(fontSize: 12, color: HubColors.muted),
                  maxLines: 2,
                ),
              ),
          ],
        ),
        if (showFilters)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Category',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: ['All', ...categories]
                        .map(
                          (v) => ChoiceChip(
                            label: Text(v),
                            selected: p.category == v,
                            onSelected: (_) => p.updateFilters(category: v),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 19),
                  const Text(
                    'Personal status',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: ['All', ...statuses]
                        .map(
                          (v) => ChoiceChip(
                            label: Text(v),
                            selected: p.status == v,
                            onSelected: (_) => p.updateFilters(status: v),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () =>
                        p.updateFilters(category: 'All', status: 'All'),
                    child: const Text('Clear filters'),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 13),
        Wrap(
          spacing: 9,
          runSpacing: 6,
          children: groups.entries
              .map(
                (entry) => ChoiceChip(
                  label: Text('${entry.key} · ${entry.value.length}'),
                  selected: p.eventSection == entry.key,
                  onSelected: (_) => p.selectSection(entry.key),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 20),
        if (list.isEmpty)
          Card(
            child: EmptyState(
              title: p.events.isEmpty
                  ? 'No events yet'
                  : filtered.isEmpty
                  ? 'No matching events'
                  : 'No ${p.eventSection.toLowerCase()} events',
              message: p.events.isEmpty
                  ? 'Add an event to start your planner.'
                  : filtered.isEmpty
                  ? 'Try a different search or filter.'
                  : 'Events in this section will appear here.',
              onAdd: p.events.isEmpty
                  ? () => context.push('/events/new')
                  : null,
            ),
          )
        else
          ...list.map((e) => EventCard(event: e)),
      ],
    );
  }
}

class MiniCalendar extends StatefulWidget {
  final Planner planner;
  const MiniCalendar({super.key, required this.planner});
  @override
  State<MiniCalendar> createState() => _MiniCalendarState();
}

class _MiniCalendarState extends State<MiniCalendar> {
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final begin = DateTime(month.year, month.month, 2 - month.weekday);
    final rows =
        ((month.weekday - 1 + DateTime(month.year, month.month + 1, 0).day) / 7)
            .ceil();
    final count = widget.planner.events
        .where((e) => sameDay(e.start, now))
        .length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${monthNames[month.month - 1]} ${month.year}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Previous month',
                  onPressed: () => setState(
                    () => month = DateTime(month.year, month.month - 1),
                  ),
                  icon: const Icon(Icons.chevron_left, size: 20),
                ),
                IconButton(
                  tooltip: 'Next month',
                  onPressed: () => setState(
                    () => month = DateTime(month.year, month.month + 1),
                  ),
                  icon: const Icon(Icons.chevron_right, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: weekdays
                  .map(
                    (d) => Expanded(
                      child: Text(
                        d,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 10,
                          color: HubColors.muted,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 7),
            ...List.generate(
              rows,
              (r) => Row(
                children: List.generate(7, (c) {
                  final day = DateTime(
                    begin.year,
                    begin.month,
                    begin.day + r * 7 + c,
                  );
                  final today = sameDay(day, now);
                  final hasEvent = widget.planner.events.any(
                    (e) => sameDay(e.start, day),
                  );
                  return Expanded(
                    child: Semantics(
                      button: true,
                      label: 'View ${dateLabel(day)}',
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          widget.planner.selectedDate = day;
                          widget.planner.calendarView = 'Day';
                          context.go('/calendar');
                        },
                        child: Container(
                          height: 42,
                          margin: const EdgeInsets.all(2),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: today ? HubColors.green : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '${day.day}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: today
                                        ? Colors.white
                                        : day.month == month.month
                                        ? HubColors.muted
                                        : const Color(0xffc1c8bc),
                                  ),
                                ),
                              ),
                              if (hasEvent)
                                Container(
                                  width: 3,
                                  height: 3,
                                  margin: const EdgeInsets.only(top: 2),
                                  decoration: BoxDecoration(
                                    color: today
                                        ? Colors.white
                                        : HubColors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(color: HubColors.line),
            const SizedBox(height: 9),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: HubColors.muted,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    count == 0
                        ? 'Nothing scheduled for today.'
                        : '$count ${count == 1 ? 'event' : 'events'} today',
                    style: const TextStyle(
                      fontSize: 12,
                      color: HubColors.muted,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
